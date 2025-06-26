//
//  FloorPlanView.swift
//  EasyMap
//
//  Created by Studente on 25/06/25.
//

import SwiftUI

struct FloorPlanView: View {
    let buildingName: String
    @Environment(\.dismiss) private var dismiss
    @State private var currentFloor: Int = 0
    @State private var giornata: Giornata?
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var baseScale: CGFloat = 1.0
    @State private var initialSetupDone = false
    
    private var floorsData: [FloorData] {
        switch buildingName {
        case "E1":
            return [
                FloorData(floor: -1, imageName: "edificio_e1_piano_1", rooms: [
                    RoomInfo(id: "E101", name: "Aula delle Lauree", position: CGPoint(x: 150, y: 300), size: CGSize(width: 90, height: 200)),
                    RoomInfo(id: "E102", name: "E002", position: CGPoint(x: 200, y: 150), size: CGSize(width: 60, height: 40)),
                    RoomInfo(id: "E103", name: "Aula N", position: CGPoint(x: 260, y: 400), size: CGSize(width: 90, height: 40))
                ]),
                FloorData(floor: 0, imageName: "edificio_e1_piano_1", rooms: [
                    RoomInfo(id: "E102", name: "E002", position: CGPoint(x: 200, y: 150), size: CGSize(width: 60, height: 40)),
                    RoomInfo(id: "E103", name: "Aula N", position: CGPoint(x: 260, y: 400), size: CGSize(width: 90, height: 40))
                ]),
                FloorData(floor: 1, imageName: "edificio_e1_piano_1", rooms: [
                    RoomInfo(id: "E101", name: "Aula infografica", position: CGPoint(x: 150, y: 300), size: CGSize(width: 90, height: 200)),
                    RoomInfo(id: "E102", name: "E002", position: CGPoint(x: 200, y: 150), size: CGSize(width: 60, height: 40)),
                    RoomInfo(id: "E103", name: "Aula N", position: CGPoint(x: 260, y: 400), size: CGSize(width: 90, height: 40))
                ]),
                FloorData(floor: 2, imageName: "edificio_e_piano_2", rooms: [
                    RoomInfo(id: "E101", name: "E101", position: CGPoint(x: 120, y: 180), size: CGSize(width: 60, height: 40)),
                    RoomInfo(id: "E102", name: "E102", position: CGPoint(x: 220, y: 180), size: CGSize(width: 60, height: 40))
                ])
            ]
        default:
            return []
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("← Indietro") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Edificio \(buildingName)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Reset") {
                    resetView()
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            floorSelector
                
            GeometryReader { geometry in
                ZStack {
                    floorPlanImage
                    
                    if let currentFloorData = floorsData.first(where: { $0.floor == currentFloor }) {
                        ForEach(currentFloorData.rooms, id: \.id) { room in
                            roomOverlay(for: room)
                        }
                    }
                }
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = baseScale * value
                                scale = max(0.5, min(newScale, 2.0))
                            }
                            .onEnded { value in
                                baseScale = scale
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
                .onChange(of: currentFloor) { _, _ in
                    resetView()
                }
                .clipped()
                .background(Color.gray.opacity(0.1))
            }
        }
        .task {
            giornata = await leggiJSONDaURL()
        }
    }
    
    private func resetView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = baseScale
            offset = .zero
            lastOffset = .zero
        }
    }
    
    private var floorSelector: some View {
        HStack {
            Text("Piano:")
                .font(.headline)
            
            Picker("Piano", selection: $currentFloor) {
                ForEach(floorsData.indices, id: \.self) { index in
                    Text("\(floorsData[index].floor)")
                        .tag(floorsData[index].floor)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
    }
    
    private var floorPlanImage: some View {
        Image("edificio_\(buildingName.lowercased())_piano_\(currentFloor)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 960, maxHeight: 960)
    }
    
    private func roomOverlay(for room: RoomInfo) -> some View {
        let isOccupied = isRoomOccupied(roomId: room.id)
        
        return ZStack {
            Rectangle()
                .fill(isOccupied ? Color.red.opacity(0.7) : Color.green.opacity(0.7))
                .frame(width: room.size.width, height: room.size.height)
            // Nome dell'aula
            Text(room.name)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
        }
        .position(room.position)
        .onTapGesture {
            showRoomDetails(for: room.id)
        }
    }
    
    private func isRoomOccupied(roomId: String) -> Bool {
        guard let giornata = giornata else { return false }
        
        let aula = giornata.aule.first { $0.nome == roomId }
        return aula?.isOccupiedNow() ?? false
    }
    
    private func showRoomDetails(for roomId: String) {
        print("Toccata aula: \(roomId)")
    }
}

struct FloorData {
    let floor: Int
    let imageName: String
    let rooms: [RoomInfo]
}

struct RoomInfo {
    let id: String
    let name: String
    let position: CGPoint
    let size: CGSize
}

#Preview {
    FloorPlanView(buildingName: "E")
}
