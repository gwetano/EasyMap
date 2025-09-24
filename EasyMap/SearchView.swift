import SwiftUI

struct SearchView: View {
    @State private var giornata: Giornata? = nil
    @State private var searchText: String = ""
    @State private var selectedBuildingName: String? = nil
    @State private var selectedRoomName: String? = nil
    @State private var recentSearches: [String] = []
    @State private var showingEmptyRooms: Bool = false
    @State private var selectedBuildingFilter: String? = nil // Nuovo stato per il filtro

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
    
    // Funzione per trovare il piano di un'aula
    private func getFloorForRoom(_ roomName: String, _ buildingName: String) -> String? {
        if let building = BuildingDataManager.shared.getBuilding(named: buildingName) {
            for floor in building.floors {
                if floor.rooms.contains(where: { $0.name.caseInsensitiveCompare(roomName) == .orderedSame }) {
                    return floor.name
                }
            }
        }
        return nil
    }

    var filteredAule: [Aula] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        var combined: [Aula] = []

        if let jsonAule = giornata?.aule {
            combined.append(contentsOf: jsonAule)
        }

        let buildings = ["E", "E1", "E2","B","C","C1","C2","D","D1","D2","D3","F1","F2","F3"]
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
    
    // Computed property per le aule vuote con filtro per edificio
    var emptyRooms: [Aula] {
        guard let giornata = giornata else { return [] }
        
        var combined: [Aula] = []
        
        // Aggiungi aule dal JSON
        combined.append(contentsOf: giornata.aule)
        
        // Aggiungi aule dai building data
        let buildings = ["E", "E1", "E2","B","C","C1","C2","D","D1","D2","D3","F1","F2","F3"]
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
        
        // Filtra aule vuote, valide e per edificio selezionato
        var filtered = combined.filter { aula in
            guard edificiValidi.contains(aula.edificio) else { return false }
            
            // Filtra per edificio se selezionato
            if let selectedBuilding = selectedBuildingFilter {
                guard aula.edificio == selectedBuilding else { return false }
            }
            
            // Includi solo aule con dati disponibili e non occupate
            return hasAvailableData(aula) && !isRoomOccupied(aula)
        }
        
        return filtered.sorted { $0.edificio < $1.edificio || ($0.edificio == $1.edificio && $0.nome < $1.nome) }
    }
    
    // Funzione helper per controllare se un'aula è occupata
    private func isRoomOccupied(_ aula: Aula) -> Bool {
        guard let giornata = giornata else { return false }
        
        if let jsonAula = giornata.aule.first(where: {
            $0.nome.caseInsensitiveCompare(aula.nome) == .orderedSame &&
            $0.edificio.caseInsensitiveCompare(aula.edificio) == .orderedSame
        }) {
            return jsonAula.isOccupiedNow()
        }
        return false // Se non è nel JSON, assumiamo sia libera
    }
    
    // Funzione helper per controllare se i dati di un'aula sono disponibili
    private func hasAvailableData(_ aula: Aula) -> Bool {
        guard let giornata = giornata else { return false }
        
        // Se l'aula è presente nel JSON, allora i dati sono disponibili
        return giornata.aule.contains { jsonAula in
            jsonAula.nome.caseInsensitiveCompare(aula.nome) == .orderedSame &&
            jsonAula.edificio.caseInsensitiveCompare(aula.edificio) == .orderedSame
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
                        // Pulsante per aule vuote - mostra sempre quando i dati sono caricati
                        if !showingEmptyRooms {
                            Section {
                                Button {
                                    showingEmptyRooms = true
                                    searchText = "" // Pulisci la ricerca quando mostri aule vuote
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Lista aule vuote")
                                            .font(.headline)
                                        Spacer()
                                        Text("(\(emptyRooms.count))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        
                        // Mostra aule vuote se attivato
                        if showingEmptyRooms {
                            // Filtri per edificio
                            Section {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        // Pulsante "Tutti"
                                        Button("Tutti") {
                                            selectedBuildingFilter = nil
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedBuildingFilter == nil ? Color.blue : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            selectedBuildingFilter == nil ? .white : .primary
                                        )
                                        .cornerRadius(16)
                                        
                                        // Pulsanti per ogni edificio
                                        ForEach(Array(edificiValidi).sorted(), id: \.self) { edificio in
                                            Button(edificio) {
                                                selectedBuildingFilter = edificio
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                selectedBuildingFilter == edificio ? Color.blue : Color.gray.opacity(0.2)
                                            )
                                            .foregroundColor(
                                                selectedBuildingFilter == edificio ? .white : .primary
                                            )
                                            .cornerRadius(16)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                }
                            }
                            
                            Section(header: HStack {
                                VStack(alignment: .leading) {
                                    Text("Aule vuote ora")
                                        .font(.headline)
                                    if let selectedBuilding = selectedBuildingFilter {
                                        Text("Edificio: \(selectedBuilding)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Button("Chiudi") {
                                    showingEmptyRooms = false
                                    selectedBuildingFilter = nil
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }) {
                                if emptyRooms.isEmpty {
                                    Text(selectedBuildingFilter == nil ?
                                         "Nessuna aula vuota disponibile al momento" :
                                         "Nessuna aula vuota disponibile nell'edificio \(selectedBuildingFilter!)")
                                        .foregroundColor(.gray)
                                        .italic()
                                        .padding()
                                } else {
                                    ForEach(emptyRooms, id: \.nome) { aula in
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text(aula.nome)
                                                    .font(.headline)
                                                Spacer()
                                                Circle()
                                                    .fill(.green)
                                                    .frame(width: 12, height: 12)
                                            }
                                            HStack {
                                                Text("Edificio: \(aula.edificio)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                
                                                // Mostra il piano se disponibile
                                                if let piano = getFloorForRoom(aula.nome, aula.edificio) {
                                                    Text("• Piano: \(piano)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
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
                            }
                        }
                        
                        // Ricerche recenti (solo se non stiamo mostrando aule vuote)
                        if !showingEmptyRooms && searchText.isEmpty && !recentSearches.isEmpty {
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

                        // Risultati della ricerca (solo se non stiamo mostrando aule vuote)
                        if !showingEmptyRooms && !filteredAule.isEmpty {
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
                                        HStack {
                                            Text("Edificio: \(aula.edificio)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            // Mostra il piano se disponibile
                                            if let piano = getFloorForRoom(aula.nome, aula.edificio) {
                                                Text("• Piano: \(piano)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
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

                        } else if !showingEmptyRooms && !searchText.isEmpty {
                            Text("Nessuna aula trovata.")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Cerca aula…")
            .onChange(of: searchText) { _, newValue in
                // Se l'utente inizia a digitare, nascondi la lista aule vuote
                if !newValue.isEmpty && showingEmptyRooms {
                    showingEmptyRooms = false
                }
            }
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
        // Nascondi la lista aule vuote quando selezioni un'aula
        showingEmptyRooms = false
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
