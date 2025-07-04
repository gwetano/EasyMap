//
//  MissionView.swift
//  EasyMap
//
//  Created by Francesco Apicella on 04/07/25.
//

import SwiftUI
import CoreLocation
import CoreMotion

struct Missione: Identifiable, Codable {
    let id = UUID()
    let titolo: String
    let descrizione: String
    let edificioTarget: String?
    let coordinate: CLLocationCoordinate2D?
    let punti: Int
    let icona: String
    var completata: Bool = false
    let categoria: String
    let raggioVerifica: Double
    
    enum CodingKeys: String, CodingKey {
        case titolo, descrizione, edificioTarget, punti, icona, completata, categoria, raggioVerifica
        case latitudine, longitudine
    }
    
    init(titolo: String, descrizione: String, edificioTarget: String? = nil, coordinate: CLLocationCoordinate2D? = nil, punti: Int, icona: String, categoria: String, raggioVerifica: Double = 50.0) {
        self.titolo = titolo
        self.descrizione = descrizione
        self.edificioTarget = edificioTarget
        self.coordinate = coordinate
        self.punti = punti
        self.icona = icona
        self.categoria = categoria
        self.raggioVerifica = raggioVerifica
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titolo = try container.decode(String.self, forKey: .titolo)
        descrizione = try container.decode(String.self, forKey: .descrizione)
        edificioTarget = try container.decodeIfPresent(String.self, forKey: .edificioTarget)
        punti = try container.decode(Int.self, forKey: .punti)
        icona = try container.decode(String.self, forKey: .icona)
        completata = try container.decode(Bool.self, forKey: .completata)
        categoria = try container.decode(String.self, forKey: .categoria)
        raggioVerifica = try container.decodeIfPresent(Double.self, forKey: .raggioVerifica) ?? 50.0
        
        if let lat = try container.decodeIfPresent(Double.self, forKey: .latitudine),
           let lon = try container.decodeIfPresent(Double.self, forKey: .longitudine) {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            coordinate = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(titolo, forKey: .titolo)
        try container.encode(descrizione, forKey: .descrizione)
        try container.encodeIfPresent(edificioTarget, forKey: .edificioTarget)
        try container.encode(punti, forKey: .punti)
        try container.encode(icona, forKey: .icona)
        try container.encode(completata, forKey: .completata)
        try container.encode(categoria, forKey: .categoria)
        try container.encode(raggioVerifica, forKey: .raggioVerifica)
        
        if let coordinate = coordinate {
            try container.encode(coordinate.latitude, forKey: .latitudine)
            try container.encode(coordinate.longitude, forKey: .longitudine)
        }
    }
}

class MissioniGPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var missioni: [Missione] = []
    @Published var puntiTotali: Int = 0
    @Published var posizioneCorrente: CLLocation?
    @Published var missioneCompletataRecente: Missione?
    @Published var edificiVisitati: Set<String> = []
    @Published var heading: Double = 0.0
    @Published var headingAccuracy: Double = 0.0
    
    private var headingBuffer: [Double] = []
    private let bufferSize = 5
    private var lastValidHeading: Double = 0.0
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private let userDefaults = UserDefaults.standard
    private let missioniKey = "missioni_salvate"
    private let puntiKey = "punti_totali"
    private let edificiKey = "edifici_visitati"
    
    override init() {
        super.init()
        setupLocationManager()
        setupMotionManager()
        caricaDati()
        inizializzaMissioni()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2
        locationManager.headingFilter = 1
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    private func setupMotionManager() {
    }
    
    private func smoothHeading(_ newHeading: Double) -> Double {
        headingBuffer.append(newHeading)
        
        if headingBuffer.count > bufferSize {
            headingBuffer.removeFirst()
        }
        
        var weightedSum: Double = 0
        var totalWeight: Double = 0
        
        for (index, value) in headingBuffer.enumerated() {
            let weight = Double(index + 1)
            weightedSum += value * weight
            totalWeight += weight
        }
        
        let smoothedHeading = weightedSum / totalWeight
        
        let headingDifference = abs(smoothedHeading - lastValidHeading)
        
        if headingDifference < 180 || headingBuffer.count == 1 {
            lastValidHeading = smoothedHeading
            return smoothedHeading
        } else {
            let adjustedDifference = min(headingDifference, 360 - headingDifference)
            if adjustedDifference < 45 {
                lastValidHeading = smoothedHeading
                return smoothedHeading
            }
        }
        
        return lastValidHeading
    }
    
    private func caricaDati() {
        if let data = userDefaults.data(forKey: missioniKey),
           let missioniSalvate = try? JSONDecoder().decode([Missione].self, from: data) {
            self.missioni = missioniSalvate
        }
        
        self.puntiTotali = userDefaults.integer(forKey: puntiKey)
        
        if let edificiData = userDefaults.array(forKey: edificiKey) as? [String] {
            self.edificiVisitati = Set(edificiData)
        }
    }
    
    private func salvaDati() {
        if let data = try? JSONEncoder().encode(missioni) {
            userDefaults.set(data, forKey: missioniKey)
        }
        
        userDefaults.set(puntiTotali, forKey: puntiKey)
        
        userDefaults.set(Array(edificiVisitati), forKey: edificiKey)
    }
    
    private func inizializzaMissioni() {
        if missioni.isEmpty {
            missioni = [
                Missione(
                    titolo: "Esplora l'Edificio E",
                    descrizione: "Visita l'Edificio E e scopri le sue aule",
                    edificioTarget: "E",
                    coordinate: centroEdificioE,
                    punti: 50,
                    icona: "building.2",
                    categoria: "Esplorazione",
                    raggioVerifica: 30.0
                ),
                Missione(
                    titolo: "Esplora l'Edificio C",
                    descrizione: "Visita l'Edificio E e scopri le sue aule",
                    edificioTarget: "C",
                    coordinate:centroEdificioC,
                    punti: 75,
                    icona: "building.2",
                    categoria: "Esplorazione",
                    raggioVerifica: 30.0
                ),
                Missione(
                    titolo: "Visita l'Edificio D",
                    descrizione: "Esplora l'Edificio D e le sue aule",
                    edificioTarget: "D",
                    coordinate: centroEdificioD,
                    punti: 50,
                    icona: "building",
                    categoria: "Esplorazione",
                    raggioVerifica: 30.0
                ),
                Missione(
                    titolo: "Trova l'Aula Magna",
                    descrizione: "Localizza l'Aula Magna nell'Edificio F",
                    edificioTarget: "F",
                    coordinate: centroEdificioF,
                    punti: 60,
                    icona: "theatermask.and.paintbrush",
                    categoria: "Studio",
                    raggioVerifica: 35.0
                ),
                Missione(
                    titolo: "Visita la Mensa",
                    descrizione: "Trova la mensa studentesca",
                    edificioTarget: "Q2",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77275, longitude: 14.79337),
                    punti: 40,
                    icona: "fork.knife",
                    categoria: "Esplorazione",
                    raggioVerifica: 25.0
                ),
                Missione(
                    titolo: "Scopri il Laboratorio Informatico",
                    descrizione: "Trova i laboratori informatici nell'Edificio E1",
                    edificioTarget: "E1",
                    coordinate: CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132),
                    punti: 65,
                    icona: "desktopcomputer",
                    categoria: "Studio",
                    raggioVerifica: 20.0
                ),
                Missione(
                    titolo: "Esplora tutti gli Edifici",
                    descrizione: "Visita almeno 5 edifici diversi del campus",
                    punti: 200,
                    icona: "map.fill",
                    categoria: "Esplorazione"
                )
            ]
            salvaDati()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.posizioneCorrente = location
            self.verificaMissioniGPS(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let rawHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        DispatchQueue.main.async {
            self.heading = self.smoothHeading(rawHeading)
            self.headingAccuracy = newHeading.headingAccuracy
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errore GPS: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        case .denied, .restricted:
            print("Permesso GPS negato")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    private func verificaMissioniGPS(location: CLLocation) {
        for i in 0..<missioni.count {
            let missione = missioni[i]
            
            guard !missione.completata,
                  let coordinate = missione.coordinate else { continue }
            
            let missioneLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distanza = location.distance(from: missioneLocation)
            
            if distanza <= missione.raggioVerifica {
                completaMissione(missione)
                
                if let edificio = missione.edificioTarget {
                    edificiVisitati.insert(edificio)
                }
                
                missioneCompletataRecente = missione
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.missioneCompletataRecente = nil
                }
                
                break
            }
        }
    }
    
    private func completaMissione(_ missione: Missione) {
        if let index = missioni.firstIndex(where: { $0.id == missione.id }) {
            missioni[index].completata = true
            puntiTotali += missione.punti
            salvaDati()
            
            verificaMissioniSpeciali()
        }
    }
    
    private func verificaMissioniSpeciali() {
        if edificiVisitati.count >= 5 {
            if let index = missioni.firstIndex(where: { $0.titolo == "Esplora tutti gli Edifici" && !$0.completata }) {
                completaMissione(missioni[index])
            }
        }
        
        if puntiTotali >= 500 {
            if let index = missioni.firstIndex(where: { $0.titolo == "Maestro del Campus" && !$0.completata }) {
                completaMissione(missioni[index])
            }
        }
    }
    
    func missioniAttive() -> [Missione] {
        return missioni.filter { !$0.completata }
    }
    
    func missioniCompletate() -> [Missione] {
        return missioni.filter { $0.completata }
    }
    
    func distanzaDaMissione(_ missione: Missione) -> Double? {
        guard let coordinate = missione.coordinate,
              let posizioneCorrente = posizioneCorrente else { return nil }
        
        let missioneLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return posizioneCorrente.distance(from: missioneLocation)
    }
    
    func bearingToMission(_ missione: Missione) -> Double? {
        guard let coordinate = missione.coordinate,
              let posizioneCorrente = posizioneCorrente else { return nil }
        
        let lat1 = posizioneCorrente.coordinate.latitude * .pi / 180
        let lon1 = posizioneCorrente.coordinate.longitude * .pi / 180
        let lat2 = coordinate.latitude * .pi / 180
        let lon2 = coordinate.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        let bearing = atan2(y, x) * 180 / .pi
        return bearing.truncatingRemainder(dividingBy: 360) + (bearing < 0 ? 360 : 0)
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}

struct MissioniView: View {
    @StateObject private var missioniManager = MissioniGPSManager()
    @State private var categoriaSelezionata: String? = nil
    @State private var mostraCompletate = false
    @State private var missioneSelezionata: Missione? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    headerView
                    
                    filterView
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(missioniFiltrate()) { missione in
                                MissioneCard(
                                    missione: missione,
                                    distanza: missioniManager.distanzaDaMissione(missione),
                                    bearing: missioniManager.bearingToMission(missione),
                                    currentHeading: missioniManager.heading,
                                    onTap: {
                                        if !missione.completata && missione.coordinate != nil {
                                            missioneSelezionata = missione
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
                
                if let missioneCompletata = missioniManager.missioneCompletataRecente {
                    VStack {
                        NotificaCompletamento(missione: missioneCompletata)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Missioni")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $missioneSelezionata) { missione in
                NavigationMissioneView(
                    missione: missione,
                    missioniManager: missioniManager
                )
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Punti Totali")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(missioniManager.puntiTotali)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Completate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(missioniManager.missioniCompletate().count)/\(missioniManager.missioni.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Image(systemName: missioniManager.posizioneCorrente != nil ? "location.fill" : "location.slash")
                    .foregroundColor(missioniManager.posizioneCorrente != nil ? .green : .red)
                Text(missioniManager.posizioneCorrente != nil ? "GPS Attivo" : "GPS Non Disponibile")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "safari")
                        .foregroundColor(.blue)
                    Text("Bussola")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            ProgressView(value: Double(missioniManager.missioniCompletate().count), total: Double(missioniManager.missioni.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
    
    private var filterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: { mostraCompletate.toggle() }) {
                    HStack {
                        Image(systemName: mostraCompletate ? "checkmark.circle.fill" : "circle")
                        Text(mostraCompletate ? "Completate" : "Attive")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(mostraCompletate ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(mostraCompletate ? Color.green : Color(.systemGray5))
                    .cornerRadius(15)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func missioniFiltrate() -> [Missione] {
        let missioni = mostraCompletate ? missioniManager.missioniCompletate() : missioniManager.missioniAttive()
        
        if let categoria = categoriaSelezionata {
            return missioni.filter { $0.categoria == categoria }
        }
        
        return missioni
    }
}

struct MissioneCard: View {
    let missione: Missione
    let distanza: Double?
    let bearing: Double?
    let currentHeading: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack {
                    Image(systemName: missione.icona)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(.blue.opacity(0.1))
                        .cornerRadius(10)
                    
                    if missione.completata {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                            .offset(y: -5)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(missione.titolo)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(missione.categoria)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.blue)
                            .cornerRadius(8)
                    }
                    
                    Text(missione.descrizione)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("\(missione.punti) punti")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        if let distanza = distanza {
                            HStack(spacing: 4) {
                                Image(systemName: "location")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Text(String(format: "%.0f m", distanza))
                                    .font(.caption)
                                    .foregroundColor(distanza <= missione.raggioVerifica ? .green : .primary)
                            }
                        } else if missione.edificioTarget != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "building.2")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Text("Edificio \(missione.edificioTarget!)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                if !missione.completata && missione.coordinate != nil {
                    BussolaView(
                        bearing: bearing,
                        currentHeading: currentHeading,
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .opacity(missione.completata ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(missione.completata || missione.coordinate == nil)
    }
}

struct BussolaView: View {
    let bearing: Double?
    let currentHeading: Double
    
    @State private var displayedRotation: Double = 0
    
    var targetRotation: Double {
        guard let bearing = bearing else { return 0 }
        return bearing - currentHeading
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                if bearing != nil {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(displayedRotation))
                        .opacity(1.0)
                        .onChange(of: targetRotation) { newValue in
                            withAnimation(.easeInOut(duration: 0.8)) {
                                displayedRotation = normalizeAngle(newValue)
                            }
                        }
                        .onAppear {
                            displayedRotation = normalizeAngle(targetRotation)
                        }
                }
            }
            
            Text("Vai")
                .font(.caption2)
                .foregroundColor(.blue)
        }
    }
    
    private func normalizeAngle(_ angle: Double) -> Double {
        var normalized = angle.truncatingRemainder(dividingBy: 360)
        if normalized > 180 {
            normalized -= 360
        } else if normalized < -180 {
            normalized += 360
        }
        return normalized
    }
}

struct NavigationMissioneView: View {
    let missione: Missione
    @ObservedObject var missioniManager: MissioniGPSManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: missione.icona)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text(missione.titolo)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(missione.descrizione)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                if let bearing = missioniManager.bearingToMission(missione),
                   let distanza = missioniManager.distanzaDaMissione(missione) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                .frame(width: 200, height: 200)
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(bearing - missioniManager.heading))
                                .animation(.easeInOut(duration: 0.3), value: bearing - missioniManager.heading)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Distanza")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f metri", distanza))
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        if distanza <= missione.raggioVerifica {
                            Text("Sei arrivato! La missione verrà completata automaticamente.")
                                .font(.callout)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(missione.punti) punti")
                        .fontWeight(.medium)
                }
                .font(.callout)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("Navigazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificaCompletamento: View {
    let missione: Missione
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading) {
                Text("Missione Completata!")
                    .font(.headline)
                    .fontWeight(.bold)
                Text(missione.titolo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("+\(missione.punti)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    MissioniView()
}
