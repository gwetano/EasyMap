//
//  MissionView.swift
//  EasyMap
//
//  Created by Francesco Apicella on 04/07/25.
//

import SwiftUI
import CoreLocation
import CoreMotion

struct Medaglia: Identifiable, Codable {
    let id = UUID()
    let nome: String
    let descrizione: String
    let immagineDaSbloccare: String
    let immagineSbloccata: String
    var sbloccata: Bool = false
    let missioneAssociata: String?
}

struct Missione: Identifiable, Codable {
    let id = UUID()
    let titolo: String
    let descrizione: String
    let edificioTarget: String?
    let coordinate: CLLocationCoordinate2D?
    let icona: String
    var completata: Bool = false
    let raggioVerifica: Double
    let medaliaAssociata: String?
    
    enum CodingKeys: String, CodingKey {
        case titolo, descrizione, edificioTarget, icona, completata, raggioVerifica, medaliaAssociata
        case latitudine, longitudine
    }
    
    init(titolo: String, descrizione: String, edificioTarget: String? = nil, coordinate: CLLocationCoordinate2D? = nil, icona: String, raggioVerifica: Double = 50.0, medaliaAssociata: String? = nil) {
        self.titolo = titolo
        self.descrizione = descrizione
        self.edificioTarget = edificioTarget
        self.coordinate = coordinate
        self.icona = icona
        self.raggioVerifica = raggioVerifica
        self.medaliaAssociata = medaliaAssociata
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titolo = try container.decode(String.self, forKey: .titolo)
        descrizione = try container.decode(String.self, forKey: .descrizione)
        edificioTarget = try container.decodeIfPresent(String.self, forKey: .edificioTarget)
        icona = try container.decode(String.self, forKey: .icona)
        completata = try container.decode(Bool.self, forKey: .completata)
        raggioVerifica = try container.decodeIfPresent(Double.self, forKey: .raggioVerifica) ?? 50.0
        medaliaAssociata = try container.decodeIfPresent(String.self, forKey: .medaliaAssociata)
        
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
        try container.encode(icona, forKey: .icona)
        try container.encode(completata, forKey: .completata)
        try container.encode(raggioVerifica, forKey: .raggioVerifica)
        try container.encodeIfPresent(medaliaAssociata, forKey: .medaliaAssociata)
        
        if let coordinate = coordinate {
            try container.encode(coordinate.latitude, forKey: .latitudine)
            try container.encode(coordinate.longitude, forKey: .longitudine)
        }
    }
}

class MissioniGPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var missioni: [Missione] = []
    @Published var medaglie: [Medaglia] = []
    @Published var posizioneCorrente: CLLocation?
    @Published var missioneCompletataRecente: Missione?
    @Published var medaliaRecente: Medaglia?
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
    private let medaglieKey = "medaglie_salvate"
    private let edificiKey = "edifici_visitati"
    
    override init() {
        super.init()
        setupLocationManager()
        setupMotionManager()
        caricaDati()
        inizializzaMissioni()
        inizializzaMedaglie()
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
        
        if let data = userDefaults.data(forKey: medaglieKey),
           let medaglieSalvate = try? JSONDecoder().decode([Medaglia].self, from: data) {
            self.medaglie = medaglieSalvate
        }
        
        if let edificiData = userDefaults.array(forKey: edificiKey) as? [String] {
            self.edificiVisitati = Set(edificiData)
        }
    }
    
    private func salvaDati() {
        if let data = try? JSONEncoder().encode(missioni) {
            userDefaults.set(data, forKey: missioniKey)
        }
        
        if let data = try? JSONEncoder().encode(medaglie) {
            userDefaults.set(data, forKey: medaglieKey)
        }
        
        userDefaults.set(Array(edificiVisitati), forKey: edificiKey)
    }
    
    private func inizializzaMissioni() {
        if missioni.isEmpty {
            missioni = [
                Missione(
                    titolo: "Visita l'Edificio E",
                    descrizione: "Visita l'Edificio E e scopri le sue aule",
                    edificioTarget: "E",
                    coordinate: centroEdificioE,
                    icona: "building.2",
                    raggioVerifica: 30.0,
                    medaliaAssociata: "Esploratore dell'Edificio E"
                ),
                Missione(
                    titolo: "Esplora l'Edificio C",
                    descrizione: "Visita l'Edificio C e scopri le sue aule",
                    edificioTarget: "C",
                    coordinate: centroEdificioC,
                    icona: "building.2",
                    raggioVerifica: 30.0,
                    medaliaAssociata: "Esploratore dell'Edificio C"
                ),
                Missione(
                    titolo: "Visita l'Edificio D",
                    descrizione: "Esplora l'Edificio D e le sue aule",
                    edificioTarget: "D",
                    coordinate: centroEdificioD,
                    icona: "building.2",
                    raggioVerifica: 30.0,
                    medaliaAssociata: "Esploratore dell'Edificio D"
                ),
                Missione(
                    titolo: "Visita il Matitone",
                    descrizione: "Localizza il matitone in Piazza del Sapere",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77066, longitude: 14.79237),
                    icona: "pencil",
                    raggioVerifica: 30.0,
                    medaliaAssociata: "Matitone"
                ),
                Missione(
                    titolo: "Visita la Mensa",
                    descrizione: "Trova la mensa studentesca",
                    edificioTarget: "Q2",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77275, longitude: 14.79337),
                    icona: "fork.knife",
                    raggioVerifica: 25.0,
                    medaliaAssociata: "Buongustaio"
                ),
                Missione(
                    titolo: "Scopri il boschetto",
                    descrizione: "Scopri l'area verde del campus",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77162, longitude: 14.78910),
                    icona: "tree.fill",
                    raggioVerifica: 20.0,
                    medaliaAssociata: "Pollice verde"
                ),
                Missione(
                    titolo: "Esplora tutti gli Edifici",
                    descrizione: "Visita almeno 5 edifici diversi del campus",
                    icona: "map.fill",
                    medaliaAssociata: "Maestro Esploratore"
                )
            ]
            salvaDati()
        }
    }
    
    private func inizializzaMedaglie() {
        if medaglie.isEmpty {
            medaglie = [
                Medaglia(
                    nome: "Esploratore dell'Edificio E",
                    descrizione: "Hai visitato l'Edificio E",
                    immagineDaSbloccare: "medaglia1_da_sbloccare",
                    immagineSbloccata: "medaglia1_sbloccata",
                    missioneAssociata: "Esplora l'Edificio E",
                ),
                Medaglia(
                    nome: "Esploratore dell'Edificio C",
                    descrizione: "Hai visitato l'Edificio C",
                    immagineDaSbloccare: "medaglia2_da_sbloccare",
                    immagineSbloccata: "medaglia2_sbloccata",
                    missioneAssociata: "Esplora l'Edificio C",
                ),
                Medaglia(
                    nome: "Esploratore dell'Edificio D",
                    descrizione: "Hai visitato l'Edificio D",
                    immagineDaSbloccare: "medaglia3_da_sbloccare",
                    immagineSbloccata: "medaglia3_sbloccata",
                    missioneAssociata: "Visita l'Edificio D",
                ),
                Medaglia(
                    nome: "Matitone",
                    descrizione: "Hai trovato il Matitone in Piazza del Sapere",
                    immagineDaSbloccare: "medaglia4_da_sbloccare",
                    immagineSbloccata: "medaglia4_sbloccata",
                    missioneAssociata: "Visita il matitone",
                ),
                Medaglia(
                    nome: "Buongustaio",
                    descrizione: "Hai visitato la mensa",
                    immagineDaSbloccare: "medaglia5_da_sbloccare",
                    immagineSbloccata: "medaglia5_sbloccata",
                    missioneAssociata: "Visita la Mensa",
                ),
                Medaglia(
                    nome: "Pollice verde",
                    descrizione: "Hai scoperto il boschetto",
                    immagineDaSbloccare: "medaglia6_da_sbloccare",
                    immagineSbloccata: "medaglia6_sbloccata",
                    missioneAssociata: "Scopri il boschetto",
                ),
                Medaglia(
                    nome: "Maestro Esploratore",
                    descrizione: "Hai visitato tutti gli edifici principali",
                    immagineDaSbloccare: "medaglia7_da_sbloccare",
                    immagineSbloccata: "medaglia7_sbloccata",
                    missioneAssociata: "Esplora tutti gli Edifici",
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
            
            if let nomeMedaglia = missione.medaliaAssociata {
                sbloccaMedaglia(nome: nomeMedaglia)
            }
            
            salvaDati()
            verificaMissioniSpeciali()
        }
    }
    
    private func sbloccaMedaglia(nome: String) {
        if let index = medaglie.firstIndex(where: { $0.nome == nome && !$0.sbloccata }) {
            medaglie[index].sbloccata = true
            medaliaRecente = medaglie[index]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.medaliaRecente = nil
            }
        }
    }
    
    private func verificaMissioniSpeciali() {
        if edificiVisitati.count >= 5 {
            if let index = missioni.firstIndex(where: { $0.titolo == "Esplora tutti gli Edifici" && !$0.completata }) {
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
    
    func medaglieSbloccate() -> [Medaglia] {
        return medaglie.filter { $0.sbloccata }
    }
    
    func medaglieDaSbloccare() -> [Medaglia] {
        return medaglie.filter { !$0.sbloccata }
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
    @State private var mostraMedaglie = false
    @State private var missioneSelezionata: Missione? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
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

                        Text(mostraMedaglie ? "Medaglie" : "Missioni")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .background(Color(.systemGray6))
                    
                    headerView
                    
                    filterView
                    
                    if mostraMedaglie {
                        medaglieView
                    } else {
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
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack{
                Text("Completate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack{
                Text("\(missioniManager.missioniCompletate().count)/\(missioniManager.missioni.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Spacer()
                
                HStack {
                    Image(systemName: missioniManager.posizioneCorrente != nil ? "location.fill" : "location.slash")
                        .foregroundColor(missioniManager.posizioneCorrente != nil ? .green : .red)
                    Text(missioniManager.posizioneCorrente != nil ? "GPS Attivo" : "GPS Non Disponibile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: Double(missioniManager.missioniCompletate().count), total: Double(missioniManager.missioni.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
    }
    
    private var filterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                    mostraMedaglie = false
                }) {
                    HStack {
                        Image(systemName: "target")
                        Text("Missioni Attive")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(!mostraMedaglie ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(!mostraMedaglie ? Color.blue : Color(.systemGray5))
                    .cornerRadius(15)
                }
                
                Button(action: { mostraMedaglie = true }) {
                    HStack {
                        Image(systemName: "medal.fill")
                        Text("Medaglie")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(mostraMedaglie ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(mostraMedaglie ? Color.yellow : Color(.systemGray5))
                    .cornerRadius(15)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var medaglieView: some View {
        MedaglieDettagliateView(missioniManager: missioniManager)
    }
    
    private func missioniFiltrate() -> [Missione] {
        let missioni = missioniManager.missioniAttive()
        
        return missioni
    }
}

struct BussolaView: View {
    let bearing: Double?
    let currentHeading: Double
    let distanza: Double?
    let raggioVerifica: Double
    
    @State private var displayedRotation: Double = 0
    
    var targetRotation: Double {
        guard let bearing = bearing else { return 0 }
        return bearing - currentHeading
    }
    
    var isNearTarget: Bool {
        guard let distanza = distanza else { return false }
        return distanza <= 50
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: isNearTarget ? 48 : 40, height: isNearTarget ? 48 : 40)
                    .animation(.easeInOut(duration: 0.3), value: isNearTarget)
                
                if bearing != nil {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(isNearTarget ? .title : .title2)
                        .foregroundColor(isNearTarget ? .green : .blue)
                        .rotationEffect(.degrees(displayedRotation))
                        .opacity(1.0)
                        .animation(.easeInOut(duration: 0.3), value: isNearTarget)
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
            
            Text(isNearTarget ? "Vicino!" : "Vai")
                .font(.caption2)
                .foregroundColor(isNearTarget ? .green : .blue)
                .animation(.easeInOut(duration: 0.3), value: isNearTarget)
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
                    }
                    
                    Text(missione.descrizione)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
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
                        distanza: distanza,
                        raggioVerifica: missione.raggioVerifica
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
                                .frame(
                                    width: distanza <= missione.raggioVerifica ? 240 : 200,
                                    height: distanza <= missione.raggioVerifica ? 240 : 200
                                )
                                .animation(.easeInOut(duration: 0.5), value: distanza <= missione.raggioVerifica)
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: distanza <= missione.raggioVerifica ? 120 : 100))
                                .foregroundColor(distanza <= missione.raggioVerifica ? .green : .blue)
                                .rotationEffect(.degrees(bearing - missioniManager.heading))
                                .animation(.easeInOut(duration: 0.3), value: bearing - missioniManager.heading)
                                .animation(.easeInOut(duration: 0.5), value: distanza <= missione.raggioVerifica)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Distanza")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f metri", distanza))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(distanza <= missione.raggioVerifica ? .green : .primary)
                        }
                    }
                    
                    if missione.completata{
                        Text("Medaglia sbloccata, vai nella sezione Medaglie")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                
                Spacer()
            }
            .padding()
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

struct MedagliaDettagliataCard: View {
    let medaglia: Medaglia
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(medaglia.sbloccata ? medaglia.immagineSbloccata : medaglia.immagineDaSbloccare)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: medaglia.sbloccata ? "lock.open.fill" : "lock.fill")
                            .font(.caption)
                            .foregroundColor(medaglia.sbloccata ? .green :  .red)
                    }
                    Spacer()
                }
                .frame(width: 120, height: 120)
            }
            
            VStack(spacing: 8) {
                Text(medaglia.nome)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(medaglia.sbloccata ? .primary : .secondary)
                
                Text(medaglia.descrizione)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(medaglia.sbloccata ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
        .opacity(medaglia.sbloccata ? 1.0 : 0.7)
        .scaleEffect(medaglia.sbloccata ? 1.0 : 0.95)
    }
}

struct MedaglieDettagliateView: View {
    @ObservedObject var missioniManager: MissioniGPSManager
    @State private var medagliaSelezionata: Medaglia? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(missioniManager.medaglie) { medaglia in
                        MedagliaCard(medaglia: medaglia)
                            .onTapGesture {
                                medagliaSelezionata = medaglia
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .sheet(item: $medagliaSelezionata) { medaglia in
            MedagliaDetailView(medaglia: medaglia, missioniManager: missioniManager)
        }
    }
}

struct MedagliaCard: View {
    let medaglia: Medaglia

    var body: some View {
        VStack(spacing: 12) {
            Image(medaglia.sbloccata ? medaglia.immagineSbloccata : medaglia.immagineDaSbloccare)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()

            VStack(spacing: 4) {
                Text(medaglia.nome)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)

                Text(medaglia.descrizione)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding()
        .frame(width: 170, height: 180)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(medaglia.sbloccata ? 1.0 : 0.6)
    }
}

struct MedagliaDetailView: View {
    let medaglia: Medaglia
    @ObservedObject var missioniManager: MissioniGPSManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRotating = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text(medaglia.nome)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(medaglia.sbloccata ? .primary : .secondary)
                        
                        Image(medaglia.sbloccata ? medaglia.immagineSbloccata : medaglia.immagineDaSbloccare)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170, height: 170)
                            .rotation3DEffect(
                                .degrees(rotationAngle),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .scaleEffect(scale)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 1)) {
                                    rotationAngle += 360
                                }
                                
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    scale = 1.2
                                }
                                
                                withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                                    scale = 1.0
                                }
                            }
                            .onAppear {
                                if medaglia.sbloccata {
                                    withAnimation(.easeInOut(duration: 1.5)) {
                                        rotationAngle = 360
                                    }
                                    
                                    glowOpacity = 1.0
                                }
                            }
                    
                    if medaglia.sbloccata {
                        Text(medaglia.descrizione)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: medaglia.sbloccata ? "checkmark.circle.fill" : "lock.fill")
                            .font(.title2)
                            .foregroundColor(medaglia.sbloccata ? .green : .gray)
                        
                        Text(medaglia.sbloccata ? "Medaglia Sbloccata" : "Medaglia Bloccata")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(medaglia.sbloccata ? .green : .gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    
                    if !medaglia.sbloccata {
                        VStack(spacing: 8) {
                            Text("Completa la missione associata per sbloccare questa medaglia")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    } else {
                        Text("Tocca la medaglia per farla ruotare!")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .opacity(0.7)
                            .padding(.top)
                    }
                }
                .padding()
            }
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

#Preview {
    MissioniView()
}
