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
    @StateObject private var roomStatusManager = RoomStatusManager.shared

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isFirstLoad = true

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    private let labelThreshold: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            if let image = UIImage(named: floor.imageName) {
                let imageSize = image.size
                let aspectRatio = imageSize.width / imageSize.height
                
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                let imageHeight = viewHeight
                let imageWidth = imageHeight * aspectRatio
                
                let initialOffsetX = isFirstLoad ? (viewWidth - imageWidth) / 2 : 0
                let initialOffsetY: CGFloat = 0

                ZStack {
                    Color.black.opacity(0.05)
                    
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()

                        ForEach(floor.rooms) { room in
                            Button(action: {
                                selectedRoom = room
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(roomStatusManager.getRoomColor(for: room).opacity(0.7))
                                    if scale >= labelThreshold {
                                        Text(room.name)
                                            .font(.system(size: 8 / scale))
                                            .foregroundColor(.primary)
                                            .padding(2)
                                            .background(Color.white.opacity(0.4))
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(
                                width: room.size.width * imageWidth,
                                height: room.size.height * imageHeight
                            )
                            .position(
                                x: room.position.x * imageWidth,
                                y: room.position.y * imageHeight
                            )
                        }
                    }
                    .frame(width: imageWidth, height: imageHeight)
                    .scaleEffect(scale)
                    .offset(x: initialOffsetX + offset.width, y: initialOffsetY + offset.height)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = min(max(lastScale * value, minScale), maxScale)
                                    
                                    let centerX = geometry.size.width / 2
                                    let centerY = geometry.size.height / 2
                                    
                                    let imagePointX = (centerX - initialOffsetX - lastOffset.width) / lastScale
                                    let imagePointY = (centerY - initialOffsetY - lastOffset.height) / lastScale
                                    
                                    let newOffsetX = centerX - initialOffsetX - imagePointX * newScale
                                    let newOffsetY = centerY - initialOffsetY - imagePointY * newScale
                                    
                                    scale = newScale
                                    offset = CGSize(width: newOffsetX, height: newOffsetY)
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    offset = limitOffset(offset, scale: scale, geometry: geometry, imageWidth: imageWidth, imageHeight: imageHeight, initialOffsetX: initialOffsetX, initialOffsetY: initialOffsetY)
                                    lastOffset = offset
                                },
                            
                            DragGesture()
                                .onChanged { value in
                                    let newOffset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                    offset = limitOffset(newOffset, scale: scale, geometry: geometry, imageWidth: imageWidth, imageHeight: imageHeight, initialOffsetX: initialOffsetX, initialOffsetY: initialOffsetY)
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
            } else {
                Text("Immagine non trovata")
                    .foregroundColor(.red)
            }
        }
        .task {
            await roomStatusManager.loadData()
            isFirstLoad = false
        }
    }
    
    private func limitOffset(_ offset: CGSize, scale: CGFloat, geometry: GeometryProxy, imageWidth: CGFloat, imageHeight: CGFloat, initialOffsetX: CGFloat, initialOffsetY: CGFloat) -> CGSize {
        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        
        let maxOffsetX: CGFloat
        let minOffsetX: CGFloat
        
        if scaledImageWidth > geometry.size.width {
            let maxPanDistance = (scaledImageWidth - geometry.size.width) / 2
            maxOffsetX = maxPanDistance - initialOffsetX
            minOffsetX = -maxPanDistance - initialOffsetX
        } else {
            maxOffsetX = -initialOffsetX
            minOffsetX = -initialOffsetX
        }
        
        let maxOffsetY: CGFloat
        let minOffsetY: CGFloat
        
        if scaledImageHeight > geometry.size.height {
            let maxPanDistance = (scaledImageHeight - geometry.size.height) / 2
            maxOffsetY = maxPanDistance - initialOffsetY
            minOffsetY = -maxPanDistance - initialOffsetY
        } else {
            maxOffsetY = -initialOffsetY
            minOffsetY = -initialOffsetY
        }
        
        let limitedOffsetX = max(minOffsetX, min(maxOffsetX, offset.width))
        let limitedOffsetY = max(minOffsetY, min(maxOffsetY, offset.height))
        
        return CGSize(width: limitedOffsetX, height: limitedOffsetY)
    }
}

struct BuildingRoomListView: View {
    let buildingName: String
    @StateObject private var roomStatusManager = RoomStatusManager.shared
    @State private var selectedRoom: RoomImage?
    
    private var buildingRooms: [Aula] {
        guard let giornata = roomStatusManager.giornata else { return [] }
        return giornata.aule.filter { aula in
            aula.edificio == buildingName
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack{

                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
    
        List {
            if buildingRooms.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Nessuna aula trovata")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Nell'edificio \(buildingName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
            } else {
                ForEach(buildingRooms, id: \.nome) { aula in
                    Button(action: {
                        let roomImage = RoomImage(
                            name: aula.nome,
                            position: .zero,
                            size: .zero,
                            description: aula.isOccupiedNow() ? "Aula occupata" : "Aula libera",
                            buildingName: aula.edificio
                        )
                        selectedRoom = roomImage
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(aula.nome)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                                                    
                                Text("Posti: \(aula.posti)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(aula.isOccupiedNow() ? .red : .green)
                                .frame(width: 12, height: 12)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .task {
            await roomStatusManager.loadData()
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailView(room: room)
        }
    }
}

struct FloorPlanView: View {
    let buildingName: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var buildingManager = BuildingDataManager.shared
    @State private var selectedFloorIndex = 1
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

                    Text("Edificio \(buildingName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .background(Color(.systemBackground))
                
                if let building = building, !building.floors.isEmpty {
                    if building.floors.count > 1 {
                        VStack(spacing: 8) {
                            HStack{
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
                    
                    if let floor = currentFloor {
                        FloorPlanImageView(floor: floor, selectedRoom: $selectedRoom)
                    }
                } else {
                    BuildingRoomListView(buildingName: buildingName)
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
    @StateObject private var roomStatusManager = RoomStatusManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Circle()
                            .fill(roomStatusManager.getRoomColor(for: room))
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
                                    .fill(roomStatusManager.getRoomColor(for: room))
                                    .frame(width: 12, height: 12)
                                Text(roomStatusManager.getOccupancyStatus(for: room))
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
                                Text(room.buildingName)
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
                    
                    if let aula = roomStatusManager.getAula(for: room) {
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
            await roomStatusManager.loadData()
        }
    }
    
    private func getCapacityText() -> String {
        if let aula = roomStatusManager.getAula(for: room) {
            return "\(aula.posti) persone"
        }
        return "Non specificata"
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
    FloorPlanView(buildingName: "E")
}
