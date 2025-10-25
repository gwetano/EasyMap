import SwiftUI
import MapKit

struct FloorPlanImageView: View {
    let floor: Floor
    let buildingName: String
    @Binding var selectedRoom: RoomImage?
    let highlightedRoomName: String?
    @StateObject private var roomStatusManager = RoomStatusManager.shared
    
    @State private var isHighlighted = false
    @State private var highlightTimer: Timer?
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isFirstLoad = true
    @State private var hasAnimatedToHighlightedRoom = false
    
    @State private var sliderValue: Double = 0.5
    @State private var imageWidth: CGFloat = 0
    
    // Lista di edifici che necessitano dello slider
    private let buildingsWithHorizontalSlider = ["E", "D", "C", "B","F"]
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    private let labelThreshold: CGFloat = 1
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                if let image = UIImage(named: floor.imageName) {
                    let imageSize = image.size
                    let aspectRatio = imageSize.width / imageSize.height
                    
                    let viewWidth = geometry.size.width
                    let viewHeight = geometry.size.height
                    
                    let imageHeight = viewHeight
                    let calculatedImageWidth = imageHeight * aspectRatio
                    
                    // Calcola se serve lo slider direttamente qui
                    let needsSlider = buildingsWithHorizontalSlider.contains(buildingName) &&
                                    calculatedImageWidth > viewWidth * 1.2
                    
                    let initialOffsetX = isFirstLoad ? (viewWidth - calculatedImageWidth) / 2 : 0
                    let initialOffsetY: CGFloat = 0
                    
                    ZStack {
                        Color.black.opacity(0.05)
                        
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: calculatedImageWidth, height: imageHeight)
                                .clipped()
                            
                            ForEach(floor.rooms) { room in
                                Button(action: {
                                    selectedRoom = room
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(roomStatusManager.getRoomColor(for: room)
                                                .opacity(getOpacityForRoom(room)))
                                        
                                        if scale >= labelThreshold {
                                            Text(room.name)
                                                .font(.system(size: 8 / scale))
                                                .foregroundColor(.black)
                                                .padding(2)
                                                .background(Color.white.opacity(0.6))
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(
                                    width: room.size.width * calculatedImageWidth,
                                    height: room.size.height * imageHeight
                                )
                                .position(
                                    x: room.position.x * calculatedImageWidth,
                                    y: room.position.y * imageHeight
                                )
                            }
                        }
                        .frame(width: calculatedImageWidth, height: imageHeight)
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
                                        offset = limitOffset(offset, scale: scale, geometry: geometry, imageWidth: calculatedImageWidth, imageHeight: imageHeight, initialOffsetX: initialOffsetX, initialOffsetY: initialOffsetY)
                                        lastOffset = offset
                                        updateSliderValue(geometry: geometry, imageWidth: calculatedImageWidth, initialOffsetX: initialOffsetX, needsSlider: needsSlider)
                                    },
                                
                                DragGesture()
                                    .onChanged { value in
                                        let newOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                        offset = limitOffset(newOffset, scale: scale, geometry: geometry, imageWidth: calculatedImageWidth, imageHeight: imageHeight, initialOffsetX: initialOffsetX, initialOffsetY: initialOffsetY)
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                        updateSliderValue(geometry: geometry, imageWidth: calculatedImageWidth, initialOffsetX: initialOffsetX, needsSlider: needsSlider)
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                scale = 1.0
                                lastScale = 1.0
                                offset = .zero
                                lastOffset = .zero
                                sliderValue = 0.5
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .onAppear {
                        if !hasAnimatedToHighlightedRoom {
                            centerOnHighlightedRoom(
                                geometry: geometry,
                                imageWidth: calculatedImageWidth,
                                imageHeight: imageHeight,
                                initialOffsetX: initialOffsetX,
                                initialOffsetY: initialOffsetY
                            )
                            hasAnimatedToHighlightedRoom = true
                        }
                        startHighlightAnimation()
                    }
                    .onDisappear {
                        stopHighlightAnimation()
                    }
                    
                    // Slider per edifici che ne hanno bisogno
                    if needsSlider && scale == 1.0 {
                        VStack {
                            Spacer()
                            
                            Slider(value: $sliderValue, in: 0...1)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 20)
                                .accentColor(.blue)
                                .onChange(of: sliderValue) { newValue in
                                    scrollWithSlider(geometry: geometry, imageWidth: calculatedImageWidth, initialOffsetX: initialOffsetX, needsSlider: needsSlider)
                                }
                                .onAppear {
                                    updateSliderValue(geometry: geometry, imageWidth: calculatedImageWidth, initialOffsetX: initialOffsetX, needsSlider: needsSlider)
                                }
                        }
                    }
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
    }
    
   
    
    private func getOpacityForRoom(_ room: RoomImage) -> Double {
        guard shouldHighlightRoom(room) else { return 0.7 }
        return isHighlighted ? 1.0 : 0.4
    }
    
    private func shouldHighlightRoom(_ room: RoomImage) -> Bool {
        guard let highlightedRoomName = highlightedRoomName else { return false }
        return room.name.caseInsensitiveCompare(highlightedRoomName) == .orderedSame
    }
    
    private func startHighlightAnimation() {
        guard highlightedRoomName != nil else { return }
        highlightTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                isHighlighted.toggle()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.stopHighlightAnimation()
        }
    }
    
    private func stopHighlightAnimation() {
        highlightTimer?.invalidate()
        highlightTimer = nil
        withAnimation {
            isHighlighted = false
        }
    }
    
    private func limitOffset(_ offset: CGSize, scale: CGFloat, geometry: GeometryProxy, imageWidth: CGFloat, imageHeight: CGFloat, initialOffsetX: CGFloat, initialOffsetY: CGFloat) -> CGSize {
        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        
        let maxOffsetX: CGFloat
        let minOffsetX: CGFloat
        
        if scaledImageWidth > geometry.size.width {
            let maxPanDistance = (scaledImageWidth - geometry.size.width) / 2
            maxOffsetX = maxPanDistance
            minOffsetX = -maxPanDistance
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
    
    private func centerOnHighlightedRoom(
        geometry: GeometryProxy,
        imageWidth: CGFloat,
        imageHeight: CGFloat,
        initialOffsetX: CGFloat,
        initialOffsetY: CGFloat
    ) {
        guard let highlightedRoomName = highlightedRoomName,
              let highlightedRoom = floor.rooms.first(where: {
                  $0.name.caseInsensitiveCompare(highlightedRoomName) == .orderedSame
              }) else { return }

        let targetScale: CGFloat = 1.0

        let roomCenterX = highlightedRoom.position.x * imageWidth * targetScale
        let roomCenterY = highlightedRoom.position.y * imageHeight * targetScale
        
        let viewCenterX = geometry.size.width / 2
        let viewCenterY = geometry.size.height / 2
        
        let targetOffsetX = viewCenterX - roomCenterX - initialOffsetX
        let targetOffsetY = viewCenterY - roomCenterY - initialOffsetY

        let targetOffset = CGSize(width: targetOffsetX, height: targetOffsetY)
        
        let limitedOffset = limitOffset(
            targetOffset,
            scale: targetScale,
            geometry: geometry,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            initialOffsetX: initialOffsetX,
            initialOffsetY: initialOffsetY
        )

        withAnimation(.easeInOut(duration: 1.0)) {
            scale = targetScale
            offset = limitedOffset
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            lastScale = targetScale
            lastOffset = limitedOffset
        }
    }
    
    private func updateSliderValue(geometry: GeometryProxy, imageWidth: CGFloat, initialOffsetX: CGFloat, needsSlider: Bool) {
        guard needsSlider else { return }
        
        let scaledImageWidth = imageWidth * scale
        guard scaledImageWidth > geometry.size.width else {
            sliderValue = 0.5
            return
        }
        
        let maxPanDistance = (scaledImageWidth - geometry.size.width) / 2
        
        
        let normalizedOffset = 1 - ((offset.width + maxPanDistance) / (2 * maxPanDistance))
        sliderValue = Double(max(0, min(1, normalizedOffset)))
    }
    
    private func scrollWithSlider(geometry: GeometryProxy, imageWidth: CGFloat, initialOffsetX: CGFloat, needsSlider: Bool) {
        guard needsSlider else { return }
        
        let scaledImageWidth = imageWidth * scale
        guard scaledImageWidth > geometry.size.width else { return }
        
        let maxPanDistance = (scaledImageWidth - geometry.size.width) / 2
        
       
        let newOffsetX = maxPanDistance - (CGFloat(sliderValue) * 2 * maxPanDistance)
        
        withAnimation(.easeInOut(duration: 0.2)) {
            offset.width = newOffsetX
            lastOffset.width = newOffsetX
        }
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
            HStack {}
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let roomImage = RoomImage(
                                name: aula.nome,
                                position: .zero,
                                size: .zero,
                                description: aula.isOccupiedNow() ? "Aula occupata" : "Aula libera",
                                buildingName: aula.edificio
                            )
                            selectedRoom = roomImage
                        }
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
}

struct FloorPlanView: View {
    let buildingName: String
    let highlightedRoomName: String?
    @StateObject private var adManager = AdManager.shared
    @Environment(\.dismiss) private var dismiss
    @StateObject private var buildingManager = BuildingDataManager.shared
    @State private var selectedFloorIndex = 0
    @State private var selectedRoom: RoomImage?
    
    init(buildingName: String, highlightedRoomName: String? = nil) {
        self.buildingName = buildingName
        self.highlightedRoomName = highlightedRoomName
    }
    
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
                            HStack(spacing: 20) {
                                Button(action: {
                                    if selectedFloorIndex > 0 {
                                        selectedFloorIndex -= 1
                                        selectedRoom = nil
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }

                                Text("Piano \(building.floors[selectedFloorIndex].number)")
                                    .font(.caption)
                                    .fontWeight(.medium)

                                Button(action: {
                                    if selectedFloorIndex < building.floors.count - 1 {
                                        selectedFloorIndex += 1
                                        selectedRoom = nil
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    if let floor = currentFloor {
                        FloorPlanImageView(
                            floor: floor,
                            buildingName: buildingName,
                            selectedRoom: $selectedRoom,
                            highlightedRoomName: highlightedRoomName
                        )
                    }
                } else {
                    BuildingRoomListView(buildingName: buildingName)
                }
            }
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailView(room: room)
        }
        .onAppear {
            if let highlightedRoomName = highlightedRoomName,
               let building = building {
                for (index, floor) in building.floors.enumerated() {
                    if floor.rooms.contains(where: {
                        $0.name.caseInsensitiveCompare(highlightedRoomName) == .orderedSame
                    }) {
                        selectedFloorIndex = index
                        break
                    }
                }
            }
        }
    }
}

struct RoomDetailView: View {
    let room: RoomImage
    @StateObject private var adManager = AdManager.shared
    @StateObject private var daily = DailyUnlockManager.shared
    @Environment(\.dismiss) private var dismiss
    @StateObject private var roomStatusManager = RoomStatusManager.shared
    
    @State private var shouldShowRewardedAd = false
    
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
                        Divider()
                        ZStack {
                            Group {
                                if !aula.prenotazioni.isEmpty {
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
                            //.blur(radius: daily.isUnlockedToday ? 0 : 20)
                            //.allowsHitTesting(daily.isUnlockedToday)
/*
                            if !daily.isUnlockedToday {
                                VStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.primary)

                                    Text("Prenotazioni bloccate")
                                        .font(.headline)

                                    Text("Guarda un annuncio di 20 secondi per sbloccarle per tutta la giornata.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)

                                    Button {
                                        shouldShowRewardedAd = true
                                    } label: {
                                        Text("SBLOCCA ORA")
                                            .font(.headline)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 340, alignment: .center)
                                .animation(.easeInOut(duration: 0.2), value: daily.isUnlockedToday)
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .padding()
                            }*/
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
        }/*
        .fullScreenCover(isPresented: $shouldShowRewardedAd) {
            RewardedAdFullscreenView(manager: adManager) {
                shouldShowRewardedAd = false
            }
        }
        .onAppear {
            daily.refresh()
        }*/
    }
        
    
    private func getCapacityText() -> String {
        if let aula = roomStatusManager.getAula(for: room) {
            return "\(aula.posti) persone"
        }
        return "Non specificata"
    }
    
    private func calculateOffsetToCenter(room: RoomImage, imageWidth: CGFloat, imageHeight: CGFloat, geometry: GeometryProxy, scale: CGFloat) -> CGSize {
        let roomCenter = CGPoint(x: room.position.x * imageWidth, y: room.position.y * imageHeight)
        let viewCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        
        let dx = viewCenter.x - roomCenter.x * scale
        let dy = viewCenter.y - roomCenter.y * scale
        
        return CGSize(width: dx, height: dy)
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
    FloorPlanView(buildingName: "E", highlightedRoomName: "F3.01")
}
