//
//  FloorPlanView.swift
//  EasyMap
//
//  Created by Studente on 27/06/25.
//

import SwiftUI
import MapKit

struct FloorPlanImageView: View {
    let floor: Floor
    @Binding var selectedRoom: RoomImage?

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
                        let size = image.size
                        let imageAspect = size.width / size.height

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
                                                .font(.system(size: 8))
                                                .foregroundColor(.primary)
                                                .padding(2)
                                                .background(Color.white.opacity(0.4))
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(
                                    width: room.size.width * displayWidth,
                                    height: room.size.height * displayHeight
                                )
                                .position(
                                    x: room.position.x * displayWidth,
                                    y: room.position.y * displayHeight
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
    
    private func getRoomColor(for room: RoomImage) -> Color {
        guard let giornata = giornata else {
            return .gray
        }
        
        for aula in giornata.aule {
            if aula.nome == room.name && (aula.edificio == "E" || aula.edificio == "E1" || aula.edificio == "E2") {
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
    @State private var selectedRoom: RoomImage?
    
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

                    Spacer()


                    
                }
                .background(Color(.systemBackground))
                
                if let building = building, building.floors.count > 1 {
                    VStack(spacing: 8) {
                        HStack{
                            Text("Edificio \(buildingName) - \(building.floors[selectedFloorIndex].name)")
                                .font(.headline)
                                .fontWeight(.semibold)
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
    let room: RoomImage
    @Environment(\.dismiss) private var dismiss
    @State private var giornata: Giornata?
    
    var body: some View {
        NavigationView {
            ScrollView {
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
                            .padding()
                        
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
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                                .padding(.horizontal)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Capienza")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(getCapacityText())")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                                .padding(.horizontal)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Edificio")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(getBuilding())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if let description = room.description {
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                    .padding(.horizontal)
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
                            .padding(.horizontal)
                        }
                    }
                    
                    if let aula = getAulaFromJSON() {
                        if !aula.prenotazioni.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(.orange)
                                        .frame(width: 24)
                                    Text("Prenotazioni di oggi")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal)
                                
                                ForEach(aula.prenotazioni.indices, id: \.self) { index in
                                    let prenotazione = aula.prenotazioni[index]
                                    PrenotazioneCard(prenotazione: prenotazione)
                                }
                            }
                        } else {
                            Divider()
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar.badge.checkmark")
                                        .foregroundColor(.green)
                                        .frame(width: 24)
                                    Text("Nessuna prenotazione oggi")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal)
                                
                                Text("L'aula è libera per la giornata")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
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
            if aula.nome == room.name && (aula.edificio == "E" || aula.edificio == "E1" || aula.edificio == "E2") {
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
            if aula.nome == room.name && (aula.edificio == "E" || aula.edificio == "E1" || aula.edificio == "E2") {
                return aula.isOccupiedNow() ? "Occupata" : "Libera"
            }
        }
        
        return "Libera"
    }
    
    private func getCapacityText() -> String {
        if let aulaJSON = getAulaFromJSON() {
            return "\(aulaJSON.posti) persone"
        }
        else if let capacity = room.capacity {
            return "\(capacity) persone"
        }
        return "Non specificata"
    }
    
    private func getBuilding() -> String {
        if let aulaJSON = getAulaFromJSON() {
            return aulaJSON.edificio
        }
        return "Non specificato"
    }
    
    private func getAulaFromJSON() -> Aula? {
        guard let giornata = giornata else { return nil }
        
        return giornata.aule.first { aula in
            aula.nome == room.name && (aula.edificio == "E" || aula.edificio == "E1" || aula.edificio == "E2");
        }
    }
}

struct PrenotazioneCard: View {
    let prenotazione: Prenotazione
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                Text(prenotazione.orario)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isCurrentlyActive() {
                    Text("IN CORSO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
            
            if !prenotazione.corso.isEmpty {
                Text(prenotazione.corso)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            if !prenotazione.docente.isEmpty {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(prenotazione.docente)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !prenotazione.tipo.isEmpty {
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(prenotazione.tipo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCurrentlyActive() ? Color.red : Color.clear, lineWidth: 2)
                )
        )
        .padding(.horizontal)
    }
    
    private func isCurrentlyActive() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let now = dateFormatter.string(from: Date())
        
        let parts = prenotazione.orario.components(separatedBy: " - ")
        if parts.count == 2,
           let start = dateFormatter.date(from: parts[0].trimmingCharacters(in: .whitespaces)),
           let end = dateFormatter.date(from: parts[1].trimmingCharacters(in: .whitespaces)),
           let current = dateFormatter.date(from: now) {
            return current >= start && current <= end
        }
        return false
    }
}

#Preview {
    FloorPlanView(buildingName: "E1")
}
