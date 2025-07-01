//
//  FloorPlanView.swift
//  EasyMap
//
//  Created by Studente on 27/06/25.
//

import SwiftUI
import MapKit

struct Room: Identifiable {
    let id = UUID()
    let name: String
    let imagePosition: CGPoint
    let imageSize: CGSize
    let capacity: Int?
    let description: String?
    
    var isSmall: Bool {
        return (capacity ?? 0) < 20
    }
}

struct Floor: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let imageName: String
    let rooms: [Room]
}

struct Building {
    let name: String
    let floors: [Floor]
}

class BuildingDataManager: ObservableObject {
    static let shared = BuildingDataManager()
    
    private init() {}
    
    func getBuilding(named name: String) -> Building? {
        switch name {
        case "E":
            return createBuildingE()
        case "E1":
            return createBuildingE1()
        case "E2":
            return createBuildingE2()
        default:
            return nil
        }
    }
    
    private func createBuildingE() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_e_piano_0",
            rooms: [
                Room(
                    name: "Aula 21",
                    imagePosition: CGPoint(x: 0.15, y: 0.25),
                    imageSize: CGSize(width: 0.15, height: 0.12),
                    capacity: 120,
                    description: "Aula magna con proiettore e sistema audio"
                ),
                Room(
                    name: "Aula 22",
                    imagePosition: CGPoint(x: 0.65, y: 0.15),
                    imageSize: CGSize(width: 0.12, height: 0.10),
                    capacity: 30,
                    description: "Laboratorio informatico con 30 postazioni"
                ),
                Room(
                    name: "E03",
                    imagePosition: CGPoint(x: 0.45, y: 0.75),
                    imageSize: CGSize(width: 0.10, height: 0.08),
                    capacity: nil,
                    description: "Ufficio docenti - Piano terra"
                ),
                Room(
                    name: "WC",
                    imagePosition: CGPoint(x: 0.05, y: 0.65),
                    imageSize: CGSize(width: 0.06, height: 0.08),
                    capacity: nil,
                    description: "Servizi igienici"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e_piano_1",
            rooms: [
                Room(
                    name: "E11",
                    imagePosition: CGPoint(x: 0.25, y: 0.35),
                    imageSize: CGSize(width: 0.14, height: 0.12),
                    capacity: 80,
                    description: "Aula con lavagna interattiva e sistema di videoconferenza"
                ),
                Room(
                    name: "E12",
                    imagePosition: CGPoint(x: 0.55, y: 0.25),
                    imageSize: CGSize(width: 0.12, height: 0.10),
                    capacity: 50,
                    description: "Sala studio e consultazione con accesso Wi-Fi"
                )
            ]
        )
        
        return Building(
            name: "E",
            floors: [floor0, floor1]
        )
    }
    
    private func createBuildingE1() -> Building {
        let floorm1 = Floor(
            number: -1,
            name: "Sottoscala",
            imageName: "edificio_e1_piano_-1",
            rooms: [
                Room(
                    name: "Aula delle Lauree - V. Cardone",
                    imagePosition: CGPoint(x: 0.31, y: 0.45),
                    imageSize: CGSize(width: 0.27, height: 0.40),
                    capacity: 15,
                    description: "Sala deposito e archivio"
                ),
                Room(
                    name: "Laboratorio Icaro - ICT",
                    imagePosition: CGPoint(x: 0.653, y: 0.637),
                    imageSize: CGSize(width: 0.263, height: 0.25),
                    capacity: nil,
                    description: "Ufficio tecnico"
                ),
            ]
        )
        
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_e1_piano_0",
            rooms: [
                Room(
                    name: "Aula G",
                    imagePosition: CGPoint(x: 0.352, y: 0.665),
                    imageSize: CGSize(width: 0.176, height: 0.11),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                Room(
                    name: "Aula D",
                    imagePosition: CGPoint(x: 0.625, y: 0.557),
                    imageSize: CGSize(width: 0.22, height: 0.09),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                Room(
                    name: "Aula E",
                    imagePosition: CGPoint(x: 0.625, y: 0.665),
                    imageSize: CGSize(width: 0.22, height: 0.11),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                Room(
                    name: "Aula F",
                    imagePosition: CGPoint(x: 0.352, y: 0.552),
                    imageSize: CGSize(width: 0.176, height: 0.1),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                Room(
                    name: "Aula O",
                    imagePosition: CGPoint(x: 0.352, y: 0.436),
                    imageSize: CGSize(width: 0.176, height: 0.11),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e1_piano_1",
            rooms: [
                Room(
                    name: "Aula Infografica",
                    imagePosition: CGPoint(x: 0.352, y: 0.517),
                    imageSize: CGSize(width: 0.217, height: 0.44),
                    capacity: 45,
                    description: "Aula seminari con disposizione a ferro di cavallo"
                ),
                Room(
                    name: "Aula N",
                    imagePosition: CGPoint(x: 0.654, y: 0.759),
                    imageSize: CGSize(width: 0.212, height: 0.105),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                Room(
                    name: "Aula 102 CAD",
                    imagePosition: CGPoint(x: 0.654, y: 0.651),
                    imageSize: CGSize(width: 0.212, height: 0.095),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
            ]
        )
        
        let floor2 = Floor(
            number: 2,
            name: "Secondo Piano",
            imageName: "edificio_e1_piano_2",
            rooms: [
                Room(
                    name: "Spazio per attivita' complementari_107",
                    imagePosition: CGPoint(x: 0.404, y: 0.445),
                    imageSize: CGSize(width: 0.12, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
                Room(
                    name: "Sala 108/9C",
                    imagePosition: CGPoint(x: 0.404, y: 0.554),
                    imageSize: CGSize(width: 0.12, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
                Room(
                    name: "Sala 109/9C",
                    imagePosition: CGPoint(x: 0.404, y: 0.666),
                    imageSize: CGSize(width: 0.12, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
                Room(
                    name: "Laboratorio Modelli",
                    imagePosition: CGPoint(x: 0.653, y: 0.65),
                    imageSize: CGSize(width: 0.22, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
            ]
        )
        
        return Building(
            name: "E1",
            floors: [floorm1, floor0, floor1, floor2]
            )
    }
    
    private func createBuildingE2() -> Building {
        return Building(
            name: "E2",
            floors: [],
        )
    }
}

struct FloorPlanImageView: View {
    let floor: Floor
    @Binding var selectedRoom: Room?

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var giornata: Giornata?

    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 4.0
    private let labelThreshold: CGFloat = 0.7

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.05)

                ZStack {
                    if let image = UIImage(named: floor.imageName) {
                        let imageSize = image.size
                        let imageAspect = imageSize.width / imageSize.height

                        let displayWidth = geometry.size.width
                        let displayHeight = displayWidth / imageAspect

                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: displayWidth, height: displayHeight)
                                .clipped()

                            ForEach(floor.rooms) { room in
                                Button(action: {
                                    selectedRoom = room
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(getRoomColor(for: room).opacity(0.7))
                                        if scale >= labelThreshold {
                                            Text(room.name)
                                                .font(.caption2)
                                                .foregroundColor(.primary)
                                                .padding(2)
                                                .background(Color.white.opacity(0.4))
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(
                                    width: room.imageSize.width * displayWidth,
                                    height: room.imageSize.height * displayHeight
                                )
                                .position(
                                    x: room.imagePosition.x * displayWidth,
                                    y: room.imagePosition.y * displayHeight
                                )
                            }
                        }
                        .frame(width: displayWidth, height: displayHeight)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = min(max(lastScale * value, minScale), maxScale)
                                        scale = newScale
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                        )
                    } else {
                        Text("Immagine non trovata")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .task {
            giornata = await leggiJSONDaURL()
        }
    }
    
    private func getRoomColor(for room: Room) -> Color {
        guard let giornata = giornata else {
            return .gray
        }
        
        for aula in giornata.aule {
            if aula.nome == room.name {
                return aula.isOccupiedNow() ? .red : .green
            }
        }
        
        return .green
    }

}

struct FloorPlanView: View {
    let buildingName: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var buildingManager = BuildingDataManager.shared
    @State private var selectedFloorIndex = 0
    @State private var selectedRoom: Room?
    
    private var building: Building? {
        buildingManager.getBuilding(named: buildingName)
    }
    
    private var currentFloor: Floor? {
        guard let building = building,
              selectedFloorIndex < building.floors.count else { return nil }
        return building.floors[selectedFloorIndex]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 12)
                    }


                    Text("Edificio \(buildingName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .background(Color(.systemBackground))
                
                if let building = building, building.floors.count > 1 {
                    VStack(spacing: 8) {
                        Text(building.floors[selectedFloorIndex].name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
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
                
                if let floor = currentFloor {
                    FloorPlanImageView(floor: floor, selectedRoom: $selectedRoom)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "building.2")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Nessun dato disponibile")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Per l'edificio \(buildingName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailView(room: room)
        }
    }
}

struct RoomDetailView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    @State private var giornata: Giornata?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Circle()
                        .fill(getRoomColor())
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "square.split.bottomrightquarter")
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(room.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Circle()
                                .fill(getRoomColor())
                                .frame(width: 12, height: 12)
                            Text(getOccupancyStatus())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    if let capacity = room.capacity {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                                .padding()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Capienza")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(capacity) persone")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    
                    if let description = room.description {
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                                .padding()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Descrizione")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .task {
            giornata = await leggiJSONDaURL()
        }
    }
    
    private func getRoomColor() -> Color {
        guard let giornata = giornata else {
            return .gray
        }
        
        for aula in giornata.aule {
            if aula.nome == room.name {
                return aula.isOccupiedNow() ? .red : .green
            }
        }
        
        return .green
    }
    
    private func getOccupancyStatus() -> String {
        guard let giornata = giornata else {
            return "Stato sconosciuto"
        }
        
        for aula in giornata.aule {
            if aula.nome == room.name {
                return aula.isOccupiedNow() ? "Occupata" : "Libera"
            }
        }
        
        return "Libera"
    }
}

#Preview {
    FloorPlanView(buildingName: "E1")
}
