//
//  FloorPlanImageView.swift
//  EasyMap
//
//  Updated Floor Plan View with Image Overlay and Markers
//

import SwiftUI
import MapKit

struct Room: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let imagePosition: CGPoint
    let type: RoomType
    let capacity: Int?
    let description: String?
    
    enum RoomType: String, CaseIterable {
        case classroom = "Aula"
        case lab = "Laboratorio"
        case office = "Ufficio"
        case library = "Biblioteca"
        case bathroom = "Bagno"
        case other = "Altro"
        
        var icon: String {
            switch self {
            case .classroom: return "person.3.fill"
            case .lab: return "flask.fill"
            case .office: return "briefcase.fill"
            case .library: return "book.fill"
            case .bathroom: return "figure.walk"
            case .other: return "building.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .classroom: return .blue
            case .lab: return .green
            case .office: return .orange
            case .library: return .purple
            case .bathroom: return .gray
            case .other: return .brown
            }
        }
    }
    
    var isSmall: Bool {
        return type == .bathroom || (capacity ?? 0) < 20
    }
    
    var isImportant: Bool {
        return type == .library || type == .lab || (capacity ?? 0) > 50
    }
    
    var area: Double {
        return Double(capacity ?? 10)
    }
}

struct Floor: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let imageName: String
    let rooms: [Room]
    let imageOverlayBounds: MKCoordinateRegion
}

struct Building {
    let name: String
    let floors: [Floor]
    let baseCoordinate: CLLocationCoordinate2D
    let polygonCoordinates: [CLLocationCoordinate2D]
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
                    name: "E01",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77290, longitude: 14.79065),
                    imagePosition: CGPoint(x: 0.2, y: 0.3), // 20% da sinistra, 30% dall'alto
                    type: .classroom,
                    capacity: 120,
                    description: "Aula magna con proiettore"
                ),
                Room(
                    name: "E02",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77285, longitude: 14.79070),
                    imagePosition: CGPoint(x: 0.7, y: 0.2),
                    type: .lab,
                    capacity: 30,
                    description: "Laboratorio informatico"
                ),
                Room(
                    name: "E03",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77280, longitude: 14.79075),
                    imagePosition: CGPoint(x: 0.5, y: 0.8),
                    type: .office,
                    capacity: nil,
                    description: "Ufficio docenti"
                ),
                Room(
                    name: "WC",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77275, longitude: 14.79080),
                    imagePosition: CGPoint(x: 0.1, y: 0.7),
                    type: .bathroom,
                    capacity: nil,
                    description: "Servizi igienici"
                )
            ],
            imageOverlayBounds: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675),
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e_piano_1",
            rooms: [
                Room(
                    name: "E11",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77292, longitude: 14.79063),
                    imagePosition: CGPoint(x: 0.3, y: 0.4),
                    type: .classroom,
                    capacity: 80,
                    description: "Aula con lavagna interattiva"
                ),
                Room(
                    name: "E12",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77287, longitude: 14.79068),
                    imagePosition: CGPoint(x: 0.6, y: 0.3),
                    type: .library,
                    capacity: 50,
                    description: "Sala studio e consultazione"
                )
            ],
            imageOverlayBounds: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675),
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        )
        
        return Building(
            name: "E",
            floors: [floor0, floor1],
            baseCoordinate: CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675),
            polygonCoordinates: [
                CLLocationCoordinate2D(latitude: 40.77213, longitude: 14.79143),
                CLLocationCoordinate2D(latitude: 40.77377, longitude: 14.79024),
                CLLocationCoordinate2D(latitude: 40.77364, longitude: 14.78992),
                CLLocationCoordinate2D(latitude: 40.77200, longitude: 14.79117),
                CLLocationCoordinate2D(latitude: 40.77213, longitude: 14.79143)
            ]
        )
    }
    
    private func createBuildingE1() -> Building {
        
        let floorm1 = Floor(
            number: -1,
            name: "Sottoscala",
            imageName: "edificio_e1_piano_-1",
            rooms: [
                Room(
                    name: "E11",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77292, longitude: 14.79063),
                    imagePosition: CGPoint(x: 0.3, y: 0.4),
                    type: .classroom,
                    capacity: 80,
                    description: "Aula con lavagna interattiva"
                ),
                Room(
                    name: "E12",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77287, longitude: 14.79068),
                    imagePosition: CGPoint(x: 0.6, y: 0.3),
                    type: .library,
                    capacity: 50,
                    description: "Sala studio e consultazione"
                )
            ],
            imageOverlayBounds: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675),
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        )
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_e1_piano_0",
            rooms: [
                Room(
                    name: "E1-01",
                    coordinate: CLLocationCoordinate2D(latitude: 40.772850, longitude: 14.790120),
                    imagePosition: CGPoint(x: 0.4, y: 0.5),
                    type: .classroom,
                    capacity: 60,
                    description: "Aula per lezioni frontali"
                )
            ],
            imageOverlayBounds: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132),
                span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            )
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e1_piano_1",
            rooms: [
                Room(
                    name: "E11",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77292, longitude: 14.79063),
                    imagePosition: CGPoint(x: 0.3, y: 0.4),
                    type: .classroom,
                    capacity: 80,
                    description: "Aula con lavagna interattiva"
                ),
                Room(
                    name: "E12",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77287, longitude: 14.79068),
                    imagePosition: CGPoint(x: 0.6, y: 0.3),
                    type: .library,
                    capacity: 50,
                    description: "Sala studio e consultazione"
                )
            ],
            imageOverlayBounds: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675),
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        )
        
        let floor2 = Floor(
            number: 2,
            name: "Primo Piano",
            imageName: "edificio_e1_piano_2",
            rooms: [
                Room(
                    name: "E11",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77292, longitude: 14.79063),
                    imagePosition: CGPoint(x: 0.3, y: 0.4),
                    type: .classroom,
                    capacity: 80,
                    description: "Aula con lavagna interattiva"
                ),
                Room(
                    name: "E12",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77287, longitude: 14.79068),
                    imagePosition: CGPoint(x: 0.6, y: 0.3),
                    type: .library,
                    capacity: 50,
                    description: "Sala studio e consultazione"
                )
            ],
            imageOverlayBounds: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675),
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        )
        
        return Building(
            name: "E1",
            floors: [floorm1,floor0,floor1,floor2],
            baseCoordinate: CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132),
            polygonCoordinates: [
                CLLocationCoordinate2D(latitude: 40.773061, longitude: 14.790224),
                CLLocationCoordinate2D(latitude: 40.772896, longitude: 14.789840),
                CLLocationCoordinate2D(latitude: 40.772602, longitude: 14.790060),
                CLLocationCoordinate2D(latitude: 40.772760, longitude: 14.790438),
                CLLocationCoordinate2D(latitude: 40.773061, longitude: 14.790224)
            ]
        )
    }
    
    private func createBuildingE2() -> Building {
        return Building(name: "E2", floors: [], baseCoordinate: CLLocationCoordinate2D(latitude: 40.772135, longitude: 14.791490), polygonCoordinates: [])
    }
}

struct FloorPlanImageView: View {
    let floor: Floor
    @Binding var selectedRoom: Room?
    @State private var imageSize: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 4.0
    
    private let markerVisibilityThreshold: CGFloat = 0.7
    private let smallRoomVisibilityThreshold: CGFloat = 1.1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if UIImage(named: floor.imageName) != nil {
                        Image(floor.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onAppear {
                                if let image = UIImage(named: floor.imageName) {
                                    imageSize = image.size
                                }
                            }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                VStack(spacing: 10) {
                                    Image(systemName: "building.2.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("Pianta \(floor.name)")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    Text("Edificio \(floor.imageName)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                            )
                            .onAppear {
                                imageSize = geometry.size
                            }
                    }
                }
                .scaleEffect(scale)
                .offset(offset)
                
                ForEach(visibleRooms(at: scale)) { room in
                    RoomMarkerView(
                        room: room,
                        isSelected: selectedRoom?.id == room.id,
                        zoomScale: scale
                    )
                    .position(
                        x: room.imagePosition.x * geometry.size.width,
                        y: room.imagePosition.y * geometry.size.height
                    )
                    .scaleEffect(scale)
                    .offset(offset)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedRoom = room
                        }
                    }
                    .opacity(markerOpacity(for: room, at: scale))
                }
                
                VStack {
                    HStack {
                        Spacer()
                        LegendView(rooms: floor.rooms)
                            .padding()
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Button(action: zoomOut) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.title2)
                                .padding(12)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .disabled(scale <= minScale + 0.1)
                        
                        Spacer()
                        
                        Text("\(Int(scale * 100))%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button(action: zoomIn) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.title2)
                                .padding(12)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .disabled(scale >= maxScale - 0.1)
                        
                        Spacer()
                        
                        Button(action: resetZoom) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .padding(12)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                }
            }
            .clipped()
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let newScale = lastScale * value
                            scale = min(max(newScale, minScale), maxScale)
                        }
                        .onEnded { _ in
                            lastScale = scale
                        },
                    
                    DragGesture()
                        .onChanged { value in
                            let newOffset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                            offset = constrainOffset(newOffset, geometry: geometry)
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            )
        }
    }

    private func visibleRooms(at currentScale: CGFloat) -> [Room] {
        return floor.rooms.filter { room in
            if selectedRoom?.id == room.id {
                return true
            }
            
            if currentScale < markerVisibilityThreshold {
                return false
            }
            
            if room.isSmall && currentScale < smallRoomVisibilityThreshold {
                return false
            }
            
            return true
        }
    }
    
    private func markerOpacity(for room: Room, at currentScale: CGFloat) -> Double {
        if selectedRoom?.id == room.id {
            return 1.0
        }
        
        if room.isSmall {
            let fadeStart = smallRoomVisibilityThreshold - 0.2
            let fadeEnd = smallRoomVisibilityThreshold
            
            if currentScale < fadeStart {
                return 0.0
            } else if currentScale < fadeEnd {
                return Double((currentScale - fadeStart) / (fadeEnd - fadeStart))
            }
        }
        
        if currentScale < markerVisibilityThreshold {
            let fadeStart = markerVisibilityThreshold - 0.2
            if currentScale < fadeStart {
                return 0.0
            } else {
                return Double((currentScale - fadeStart) / 0.2)
            }
        }
        
        return 1.0
    }
    
    private func constrainOffset(_ newOffset: CGSize, geometry: GeometryProxy) -> CGSize {
        let scaledWidth = geometry.size.width * scale
        let scaledHeight = geometry.size.height * scale
        
        let maxOffsetX = max(0, (scaledWidth - geometry.size.width) / 2)
        let maxOffsetY = max(0, (scaledHeight - geometry.size.height) / 2)
        
        let constrainedX = min(max(newOffset.width, -maxOffsetX), maxOffsetX)
        let constrainedY = min(max(newOffset.height, -maxOffsetY), maxOffsetY)
        
        return CGSize(width: constrainedX, height: constrainedY)
    }
    
    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newScale = min(scale * 1.4, maxScale)
            scale = newScale
            lastScale = newScale
        }
    }
    
    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newScale = max(scale / 1.4, minScale)
            scale = newScale
            lastScale = newScale
            
            if scale <= 1.0 {
                offset = .zero
                lastOffset = .zero
            }
        }
    }
    
    private func resetZoom() {
        withAnimation(.easeInOut(duration: 0.5)) {
            scale = 1.0
            offset = .zero
            lastScale = 1.0
            lastOffset = .zero
        }
    }
}

// MARK: - RoomMarkerView aggiornata
struct RoomMarkerView: View {
    let room: Room
    let isSelected: Bool
    let zoomScale: CGFloat
    
    init(room: Room, isSelected: Bool, zoomScale: CGFloat = 1.0) {
        self.room = room
        self.isSelected = isSelected
        self.zoomScale = zoomScale
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: room.type.icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: markerSize, height: markerSize)
                .background(
                    Circle()
                        .fill(room.type.color)
                        .shadow(color: .black.opacity(0.3), radius: shadowRadius, x: 0, y: shadowOffset)
                )
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: strokeWidth)
                )
            
            if zoomScale > 1.0 {
                Text(room.name)
                    .font(.system(size: textSize, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.white.opacity(0.95))
                            .stroke(room.type.color, lineWidth: 1)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    )
            }
        }
        .scaleEffect(markerScale)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: zoomScale)
    }
    
    private var markerScale: CGFloat {
        let baseScale = isSelected ? 1.1 : 1.0
        let importanceMultiplier = room.isImportant ? 1.15 : 1.0
        let zoomAdjustment = max(0.8, min(1.2, 1.0 / sqrt(zoomScale)))
        
        return baseScale * importanceMultiplier * zoomAdjustment
    }
    
    private var markerSize: CGFloat {
        let baseSize: CGFloat = room.isImportant ? 32 : 28
        return isSelected ? baseSize + 4 : baseSize
    }
    
    private var iconSize: CGFloat {
        return isSelected ? 16 : 14
    }
    
    private var textSize: CGFloat {
        return isSelected ? 11 : 9
    }
    
    private var strokeWidth: CGFloat {
        return isSelected ? 3 : 2
    }
    
    private var shadowRadius: CGFloat {
        return isSelected ? 4 : 2
    }
    
    private var shadowOffset: CGFloat {
        return isSelected ? 2 : 1
    }
}

struct LegendView: View {
    let rooms: [Room]
    
    private var roomTypes: [Room.RoomType] {
        Array(Set(rooms.map { $0.type })).sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Legenda")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 4) {
                ForEach(roomTypes, id: \.self) { type in
                    HStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.system(size: 10))
                            .foregroundColor(type.color)
                        Text(type.rawValue)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

struct FloorPlanView: View {
    let buildingName: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var buildingManager = BuildingDataManager.shared
    @State private var selectedFloorIndex = 0
    @State private var selectedRoom: Room?
    @State private var showImageView = true
    @State private var cameraPosition: MapCameraPosition
    
    private var building: Building? {
        buildingManager.getBuilding(named: buildingName)
    }
    
    private var currentFloor: Floor? {
        guard let building = building,
              selectedFloorIndex < building.floors.count else { return nil }
        return building.floors[selectedFloorIndex]
    }
    
    init(buildingName: String) {
        self.buildingName = buildingName
        let baseCoordinate = BuildingDataManager.shared.getBuilding(named: buildingName)?.baseCoordinate ?? CLLocationCoordinate2D(latitude: 40.772705, longitude: 14.791365)
        self._cameraPosition = State(initialValue: .camera(
            MapCamera(
                centerCoordinate: baseCoordinate,
                distance: 300,
                heading: 0,
                pitch: 0
            )
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                
                if let building = building, building.floors.count > 1 {
                    floorSelectorView
                }
                
                if let floor = currentFloor {
                    FloorPlanImageView(floor: floor, selectedRoom: $selectedRoom)
                } else {
                    noFloorDataView
                }
            }
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailView(room: room)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Chiudi") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("Edificio \(buildingName)")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
    
    private var floorSelectorView: some View {
        VStack(spacing: 8) {
            if let building = building {
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
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var noFloorDataView: some View {
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

struct RoomDetailView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: room.type.icon)
                        .font(.title)
                        .foregroundColor(room.type.color)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(room.type.color.opacity(0.1))
                        )
                    
                    VStack(alignment: .leading) {
                        Text(room.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(room.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if let capacity = room.capacity {
                        InfoRow(icon: "person.3.fill", title: "Capienza", value: "\(capacity) persone")
                    }
                    
                    if let description = room.description {
                        InfoRow(icon: "info.circle.fill", title: "Descrizione", value: description)
                    }
                    
                    InfoRow(icon: "location.fill", title: "Coordinate", value: String(format: "%.6f, %.6f", room.coordinate.latitude, room.coordinate.longitude))
                }
                
                Spacer()
                
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
