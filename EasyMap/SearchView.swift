//
//  SearchView.swift
//  EasyMap
//
//  Created by Francesco Apicella on 07/07/25.
//

import SwiftUI

struct SearchView: View {
    @State private var giornata: Giornata? = nil
    @State private var searchText: String = ""
    @State private var selectedAula: Aula? = nil
    @State private var showingFloorPlan = false
    @State private var recentSearches: [String] = []

    let edificiValidi: Set<String> = [
        "E", "E1", "E2", "D", "D1", "D2", "D3", "C", "C1", "C2", "B", "B1", "B2", "F", "F1", "F2", "F3"
    ]

    var filteredAule: [Aula] {
        guard let aule = giornata?.aule else { return [] }
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if query.isEmpty {
            return []
        } else {
            return aule.filter { aula in
                edificiValidi.contains(aula.edificio) &&
                aula.nome.lowercased().contains(query)
            }
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
                        // 🔷 Ricerche recenti
                        if searchText.isEmpty && !recentSearches.isEmpty {
                            Section(header: Text("Ricerche recenti").font(.headline)) {
                                ForEach(recentSearches, id: \.self) { query in
                                    HStack {
                                        Text(query)
                                            .onTapGesture {
                                                searchText = query
                                            }
                                        Spacer()
                                        Button(action: {
                                            SearchHistoryManager.shared.cancella(query: query)
                                            recentSearches = SearchHistoryManager.shared.leggi() ?? []
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }

                        // 🔷 Risultati ricerca
                        if !filteredAule.isEmpty {
                            Section(header: Text("Risultati").font(.headline)) {
                                ForEach(filteredAule, id: \.nome) { aula in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(aula.nome)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Circle()
                                                .fill(aula.isOccupiedNow() ? .red : .green)
                                                .frame(width: 12, height: 12)
                                        }
                                        Text("Edificio: \(aula.edificio)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
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
                    .background(.ultraThinMaterial)
                }
            }
            .searchable(text: $searchText, prompt: "Cerca aula…")
            .padding(.bottom, 50)
            .task {
                self.giornata = await leggiJSONDaURL()
                self.recentSearches = SearchHistoryManager.shared.leggi() ?? []
            }
            .sheet(isPresented: $showingFloorPlan) {
                if let aula = selectedAula {
                    FloorPlanViewWithRoom(buildingName: aula.edificio, selectedRoomName: aula.nome)
                }
            }
        }
        .background(.ultraThinMaterial)
    }

    private func handleAulaSelection(_ aula: Aula) {
        SearchHistoryManager.shared.salva(query: aula.nome)
        recentSearches = SearchHistoryManager.shared.leggi() ?? []
        selectedAula = aula
        showingFloorPlan = true
    }
}

struct FloorPlanViewWithRoom: View {
    let buildingName: String
    let selectedRoomName: String
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var buildingManager = BuildingDataManager.shared
    @State private var selectedFloorIndex = 0
    @State private var selectedRoom: RoomImage?
    
    private var building: Building? {
        buildingManager.getBuilding(named: buildingName)
    }
    
    private var targetFloorAndRoom: (floorIndex: Int, room: RoomImage)? {
        guard let building = building else { return nil }
        
        for (floorIndex, floor) in building.floors.enumerated() {
            if let room = floor.rooms.first(where: { $0.name == selectedRoomName }) {
                return (floorIndex, room)
            }
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                
                if let building = building, !building.floors.isEmpty {
                    if building.floors.count > 1 {
                        floorSelector(building: building)
                    }
                    
                    if let floor = building.floors[safe: selectedFloorIndex] {
                        FloorPlanImageView(floor: floor, selectedRoom: $selectedRoom)
                    }
                } else {
                    BuildingRoomListView(buildingName: buildingName)
                }
            }
            .onAppear {
                if let target = targetFloorAndRoom {
                    selectedFloorIndex = target.floorIndex
                    selectedRoom = target.room
                }
            }
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailView(room: room)
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.backward")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 17)
                    .padding(.vertical, 12)
            }
            
            Text("Edificio \(buildingName)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
    
    private func floorSelector(building: Building) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(building.floors[selectedFloorIndex].name)")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }
            HStack(spacing: 20) {
                Text("Piano")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { Double(selectedFloorIndex) },
                        set: {
                            selectedFloorIndex = Int($0.rounded())
                            selectedRoom = nil
                        }
                    ),
                    in: 0...Double(building.floors.count - 1),
                    step: 1
                )
                .accentColor(.blue)
                
                Text("\(building.floors[selectedFloorIndex].number)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(minWidth: 20)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    SearchView()
}

