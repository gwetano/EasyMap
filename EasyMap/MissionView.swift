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
                    raggioVerifica: 40.0,
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
                    coordinate: CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132),
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
        
        if missioni.allSatisfy({ $0.completata }) {
            sbloccaMedaglia(nome: "Completista")
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
                
                if let missioneCompletata = missioniManager.missioneCompletataRecente {
                    VStack {
                        NotificaCompletamento(missione: missioneCompletata)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Completate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(missioniManager.missioniCompletate().count)/\(missioniManager.missioni.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: missioniManager.posizioneCorrente != nil ? "location.fill" : "location.slash")
                        .foregroundColor(missioniManager.posizioneCorrente != nil ? .green : .red)
                    Text(missioniManager.posizioneCorrente != nil ? "GPS Attivo" : "GPS Non Disponibile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
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
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(missioniManager.medaglie) { medaglia in
                    MedagliaCard(medaglia: medaglia)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    private func missioniFiltrate() -> [Missione] {
        let missioni = missioniManager.missioniAttive()
        
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



struct MedagliaCard: View {
    let medaglia: Medaglia

    var body: some View {
        VStack(spacing: 12) {
            Image(medaglia.sbloccata ? medaglia.immagineSbloccata : medaglia.immagineDaSbloccare)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)

            VStack(spacing: 4) {
                Text(medaglia.nome)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(medaglia.descrizione)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(medaglia.sbloccata ? 1.0 : 0.6)
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
