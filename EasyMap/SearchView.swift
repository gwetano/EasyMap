import SwiftUI

struct SearchView: View {
    @State private var giornata: Giornata? = nil
    @State private var searchText: String = ""
    @State private var selectedBuildingName: String? = nil
    @State private var selectedRoomName: String? = nil
    @State private var recentSearches: [String] = []

    let edificiValidi: Set<String> = [
        "E", "E1", "E2", "D", "D1", "D2", "D3", "C", "C1", "C2", "B", "B1", "B2", "F", "F1", "F2", "F3"
    ]

    private func normalizeText(_ text: String) -> String {
        let normalized = text.lowercased()
        return normalized.replacingOccurrences(of: "laboratorio", with: "lab")
    }
    
    private func textsMatch(_ text1: String, _ text2: String) -> Bool {
        let normalized1 = normalizeText(text1)
        let normalized2 = normalizeText(text2)
        return normalized1.contains(normalized2) || normalized2.contains(normalized1)
    }

    var filteredAule: [Aula] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        var combined: [Aula] = []

        if let jsonAule = giornata?.aule {
            combined.append(contentsOf: jsonAule)
        }

        let buildings = ["E", "E1", "E2"]
        for buildingName in buildings {
            if let building = BuildingDataManager.shared.getBuilding(named: buildingName) {
                for floor in building.floors {
                    for room in floor.rooms {
                        let alreadyExists = combined.contains {
                            $0.nome.caseInsensitiveCompare(room.name) == .orderedSame &&
                            $0.edificio.caseInsensitiveCompare(room.buildingName) == .orderedSame
                        }
                        if !alreadyExists {
                            combined.append(
                                Aula(
                                    nome: room.name,
                                    edificio: room.buildingName,
                                    posti: 0,
                                    prenotazioni: [],
                                    description: room.description
                                )
                            )
                        }
                    }
                }
            }
        }

        return combined.filter { aula in
            guard edificiValidi.contains(aula.edificio) else { return false }
            
            let nomeMatch = textsMatch(aula.nome, query)
            let descMatch = aula.description.map { textsMatch($0, query) } ?? false
            
            return nomeMatch || descMatch
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if giornata == nil {
                    ProgressView("Caricamento…")
                        .padding()
                } else {
                    List {
                        if searchText.isEmpty && !recentSearches.isEmpty {
                            Section(header: Text("Ricerche recenti").font(.headline)) {
                                ForEach(recentSearches, id: \.self) { query in
                                    HStack {
                                        Text(query)
                                        Spacer()
                                        Button {
                                            removeRecent(query)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        searchText = query
                                        selectFirstMatchingAula(for: query)
                                    }
                                }
                            }
                        }

                        if !filteredAule.isEmpty {
                            Section(header: Text("Risultati").font(.headline)) {
                                ForEach(filteredAule, id: \.nome) { aula in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(aula.nome)
                                                .font(.headline)
                                            Spacer()
                                            Circle()
                                                .fill(colorForRoom(aula))
                                                .frame(width: 12, height: 12)
                                        }
                                        Text("Edificio: \(aula.edificio)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        if let desc = aula.description, !desc.isEmpty {
                                            Text(desc)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        handleAulaSelection(aula)
                                    }
                                }
                            }

                        } else if !searchText.isEmpty {
                            Text("Nessuna aula trovata.")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Cerca aula…")
            .task {
                self.giornata = await leggiJSONDaURL()
                loadRecents()
            }
            .sheet(isPresented: Binding<Bool>(
                get: { selectedBuildingName != nil },
                set: { if !$0 { selectedBuildingName = nil; selectedRoomName = nil } }
            )) {
                if let buildingName = selectedBuildingName {
                    FloorPlanView(
                        buildingName: buildingName,
                        highlightedRoomName: selectedRoomName
                    )
                }
            }
        }
    }

    private func handleAulaSelection(_ aula: Aula) {
        SearchHistoryManager.shared.salva(query: aula.nome)
        loadRecents()
        selectedRoomName = aula.nome
        selectedBuildingName = aula.edificio
    }

    private func removeRecent(_ query: String) {
        SearchHistoryManager.shared.cancella(query: query)
        loadRecents()
    }

    private func loadRecents() {
        recentSearches = SearchHistoryManager.shared.leggi() ?? []
    }

    private func selectFirstMatchingAula(for query: String) {
        if let aula = filteredAule.first(where: {
            textsMatch($0.nome, query) || textsMatch($0.description ?? "", query)
        }) {
            handleAulaSelection(aula)
        }
    }
    private func colorForRoom(_ aula: Aula) -> Color {
        guard let giornata = giornata else {
            return .gray
        }
        if let jsonAula = giornata.aule.first(where: {
            $0.nome.caseInsensitiveCompare(aula.nome) == .orderedSame &&
            $0.edificio.caseInsensitiveCompare(aula.edificio) == .orderedSame
        }) {
            return jsonAula.isOccupiedNow() ? .red : .green
        } else {
            return .yellow
        }
    }
}

#Preview {
    SearchView()
}
