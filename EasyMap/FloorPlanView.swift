//
//  FloorPlanView.swift
//  EasyMap
//
//  Created by Studente on 27/06/25.
//

import SwiftUI
import MapKit
import PDFKit

struct FloorPlanPDFView: View {
    let floor: Floor
    @Binding var selectedRoom: RoomImage?
    @StateObject private var roomStatusManager = RoomStatusManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            if let pdfDocument = PDFDocument(url: Bundle.main.url(forResource: floor.imageName, withExtension: "pdf")!) {
                PDFViewRepresentable(
                    pdfDocument: pdfDocument,
                    floor: floor,
                    selectedRoom: $selectedRoom,
                    roomStatusManager: roomStatusManager
                )
            } else {
                Text("PDF non trovato")
                    .foregroundColor(.red)
            }
        }
        .task {
            await roomStatusManager.loadData()
        }
    }
}

struct PDFViewRepresentable: UIViewRepresentable {
    let pdfDocument: PDFDocument
    let floor: Floor
    @Binding var selectedRoom: RoomImage?
    let roomStatusManager: RoomStatusManager
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = false
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        
        // Configura la vista PDF
        pdfView.minScaleFactor = 0.4
        pdfView.maxScaleFactor = 5.0
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        
        // Aggiungi gesture recognizer per tocchi
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        pdfView.addGestureRecognizer(tapGesture)
        
        // Aggiungi gesture recognizer per doppio tocco (reset zoom)
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        pdfView.addGestureRecognizer(doubleTapGesture)
        
        // Assicurati che il singolo tocco non interferisca con il doppio tocco
        tapGesture.require(toFail: doubleTapGesture)
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Aggiorna la vista se necessario
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: PDFViewRepresentable
        
        init(_ parent: PDFViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let pdfView = gesture.view as? PDFView,
                  let page = pdfView.currentPage else { return }
            
            let point = gesture.location(in: pdfView)
            let pagePoint = pdfView.convert(point, to: page)
            
            // Converti il punto in coordinate normalizzate (0-1)
            let pageBounds = page.bounds(for: .mediaBox)
            let normalizedX = pagePoint.x / pageBounds.width
            let normalizedY = 1.0 - (pagePoint.y / pageBounds.height) // Inverti Y
            
            // Trova la stanza più vicina al punto toccato
            let tappedRoom = findRoomAtPoint(CGPoint(x: normalizedX, y: normalizedY))
            
            if let room = tappedRoom {
                parent.selectedRoom = room
            }
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let pdfView = gesture.view as? PDFView else { return }
            
            // Reset zoom
            pdfView.scaleFactor = pdfView.minScaleFactor
        }
        
        private func findRoomAtPoint(_ point: CGPoint) -> RoomImage? {
            for room in parent.floor.rooms {
                let roomBounds = CGRect(
                    x: room.position.x - room.size.width / 2,
                    y: room.position.y - room.size.height / 2,
                    width: room.size.width,
                    height: room.size.height
                )
                
                if roomBounds.contains(point) {
                    return room
                }
            }
            return nil
        }
    }
}

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
            if Bundle.main.url(forResource: floor.imageName, withExtension: "pdf") != nil {
                FloorPlanPDFView(floor: floor, selectedRoom: $selectedRoom)
            }else {
                Text(" PDF NON TROVATO")
                    .foregroundColor(.red)
            }
        }
        .task {
            await roomStatusManager.loadData()
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

    func giornoCorrenteAbbreviato() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "E"
        let giorno = formatter.string(from: Date()).capitalized
        return giorno.prefix(1).uppercased() + giorno.dropFirst().lowercased()
    }
    
    func dopoLe15() -> Bool {
        let now = Date()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "it_IT")

        let todayAt3PM = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now)!
        return now > todayAt3PM
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
