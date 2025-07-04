//
//  MissionView.swift
//  EasyMap
//
//  Created by Francesco Apicella on 04/07/25.
//

import SwiftUI
import CoreLocation

// Modello per le missioni (aggiornato)
struct Missione: Identifiable, Codable {
    let id = UUID()
    let titolo: String
    let descrizione: String
    let edificioTarget: String?
    let coordinate: CLLocationCoordinate2D?
    let punti: Int
    let icona: String
    var completata: Bool = false
    let categoria: CategoriaMissione
    let raggioVerifica: Double // Raggio in metri per la verifica automatica
    
    enum CodingKeys: String, CodingKey {
        case titolo, descrizione, edificioTarget, punti, icona, completata, categoria, raggioVerifica
        case latitudine, longitudine
    }
    
    init(titolo: String, descrizione: String, edificioTarget: String? = nil, coordinate: CLLocationCoordinate2D? = nil, punti: Int, icona: String, categoria: CategoriaMissione, raggioVerifica: Double = 50.0) {
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
        categoria = try container.decode(CategoriaMissione.self, forKey: .categoria)
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

enum CategoriaMissione: String, CaseIterable, Codable {
    case esplorazione = "Esplorazione"
    case studio = "Studio"
    case sociale = "Sociale"
    case speciale = "Speciale"
    
    var colore: Color {
        switch self {
        case .esplorazione: return .blue
        case .studio: return .green
        case .sociale: return .orange
        case .speciale: return .purple
        }
    }
    
    var icona: String {
        switch self {
        case .esplorazione: return "map"
        case .studio: return "book"
        case .sociale: return "person.2"
        case .speciale: return "star"
        }
    }
}

// Manager per il tracking delle missioni con GPS
class MissioniGPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var missioni: [Missione] = []
    @Published var puntiTotali: Int = 0
    @Published var posizioneCorrente: CLLocation?
    @Published var missioneCompletataRecente: Missione?
    @Published var edificiVisitati: Set<String> = []
    
    private let locationManager = CLLocationManager()
    private let userDefaults = UserDefaults.standard
    private let missioniKey = "missioni_salvate"
    private let puntiKey = "punti_totali"
    private let edificiKey = "edifici_visitati"
    
    override init() {
        super.init()
        setupLocationManager()
        caricaDati()
        inizializzaMissioni()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Aggiorna ogni 10 metri
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func caricaDati() {
        // Carica missioni
        if let data = userDefaults.data(forKey: missioniKey),
           let missioniSalvate = try? JSONDecoder().decode([Missione].self, from: data) {
            self.missioni = missioniSalvate
        }
        
        // Carica punti
        self.puntiTotali = userDefaults.integer(forKey: puntiKey)
        
        // Carica edifici visitati
        if let edificiData = userDefaults.array(forKey: edificiKey) as? [String] {
            self.edificiVisitati = Set(edificiData)
        }
    }
    
    private func salvaDati() {
        // Salva missioni
        if let data = try? JSONEncoder().encode(missioni) {
            userDefaults.set(data, forKey: missioniKey)
        }
        
        // Salva punti
        userDefaults.set(puntiTotali, forKey: puntiKey)
        
        // Salva edifici visitati
        userDefaults.set(Array(edificiVisitati), forKey: edificiKey)
    }
    
    private func inizializzaMissioni() {
        if missioni.isEmpty {
            missioni = [
                Missione(
                    titolo: "Esplora l'Edificio E",
                    descrizione: "Visita il campus dell'Edificio E e scopri le sue aule",
                    edificioTarget: "E",
                    coordinate: CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675),
                    punti: 50,
                    icona: "building.2",
                    categoria: .esplorazione,
                    raggioVerifica: 30.0
                ),
                Missione(
                    titolo: "Scopri la Biblioteca",
                    descrizione: "Trova e visita la biblioteca del campus",
                    edificioTarget: "C",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77136, longitude: 14.79265),
                    punti: 75,
                    icona: "books.vertical",
                    categoria: .studio,
                    raggioVerifica: 25.0
                ),
                Missione(
                    titolo: "Visita l'Edificio D",
                    descrizione: "Esplora l'Edificio D e le sue strutture",
                    edificioTarget: "D",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77156, longitude: 14.79138),
                    punti: 50,
                    icona: "building",
                    categoria: .esplorazione,
                    raggioVerifica: 30.0
                ),
                Missione(
                    titolo: "Trova l'Aula Magna",
                    descrizione: "Localizza l'Aula Magna nell'Edificio F",
                    edificioTarget: "F",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77457, longitude: 14.78887),
                    punti: 60,
                    icona: "theatermask.and.paintbrush",
                    categoria: .studio,
                    raggioVerifica: 35.0
                ),
                Missione(
                    titolo: "Visita la Mensa",
                    descrizione: "Trova la mensa studentesca nell'Edificio B",
                    edificioTarget: "B",
                    coordinate: CLLocationCoordinate2D(latitude: 40.77014, longitude: 14.79328),
                    punti: 40,
                    icona: "fork.knife",
                    categoria: .sociale,
                    raggioVerifica: 25.0
                ),
                Missione(
                    titolo: "Scopri il Laboratorio Informatico",
                    descrizione: "Trova i laboratori informatici nell'Edificio E1",
                    edificioTarget: "E1",
                    coordinate: CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132),
                    punti: 65,
                    icona: "desktopcomputer",
                    categoria: .studio,
                    raggioVerifica: 20.0
                ),
                // Missioni speciali senza coordinate specifiche
                Missione(
                    titolo: "Esplora tutti gli Edifici",
                    descrizione: "Visita almeno 5 edifici diversi del campus",
                    punti: 200,
                    icona: "map.fill",
                    categoria: .speciale
                ),
                Missione(
                    titolo: "Esploratore del Campus",
                    descrizione: "Completa 3 missioni di esplorazione",
                    punti: 150,
                    icona: "trophy",
                    categoria: .speciale
                ),
                Missione(
                    titolo: "Socializza in Bacheca",
                    descrizione: "Pubblica un post nella bacheca del campus",
                    punti: 30,
                    icona: "bubble.left.and.bubble.right",
                    categoria: .sociale
                ),
                Missione(
                    titolo: "Maestro del Campus",
                    descrizione: "Raggiungi 500 punti totali",
                    punti: 100,
                    icona: "crown",
                    categoria: .speciale
                )
            ]
            salvaDati()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.posizioneCorrente = location
            self.verificaMissioniGPS(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errore GPS: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Permesso GPS negato")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    // MARK: - Verifica Missioni
    private func verificaMissioniGPS(location: CLLocation) {
        for i in 0..<missioni.count {
            let missione = missioni[i]
            
            // Verifica solo missioni non completate con coordinate
            guard !missione.completata,
                  let coordinate = missione.coordinate else { continue }
            
            let missioneLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distanza = location.distance(from: missioneLocation)
            
            // Se l'utente è abbastanza vicino, completa la missione
            if distanza <= missione.raggioVerifica {
                completaMissione(missione)
                
                // Aggiungi l'edificio ai visitati se presente
                if let edificio = missione.edificioTarget {
                    edificiVisitati.insert(edificio)
                }
                
                // Mostra notifica di completamento
                missioneCompletataRecente = missione
                
                // Rimuovi la notifica dopo 3 secondi
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.missioneCompletataRecente = nil
                }
                
                break // Completa solo una missione per volta
            }
        }
    }
    
    private func completaMissione(_ missione: Missione) {
        if let index = missioni.firstIndex(where: { $0.id == missione.id }) {
            missioni[index].completata = true
            puntiTotali += missione.punti
            salvaDati()
            
            // Verifica missioni speciali dopo ogni completamento
            verificaMissioniSpeciali()
        }
    }
    
    private func verificaMissioniSpeciali() {
        // Verifica "Esplora tutti gli Edifici"
        if edificiVisitati.count >= 5 {
            if let index = missioni.firstIndex(where: { $0.titolo == "Esplora tutti gli Edifici" && !$0.completata }) {
                completaMissione(missioni[index])
            }
        }
        
        // Verifica "Esploratore del Campus"
        let missioniEsplorazioneCompletate = missioni.filter { $0.categoria == .esplorazione && $0.completata }.count
        if missioniEsplorazioneCompletate >= 3 {
            if let index = missioni.firstIndex(where: { $0.titolo == "Esploratore del Campus" && !$0.completata }) {
                completaMissione(missioni[index])
            }
        }
        
        // Verifica "Maestro del Campus"
        if puntiTotali >= 500 {
            if let index = missioni.firstIndex(where: { $0.titolo == "Maestro del Campus" && !$0.completata }) {
                completaMissione(missioni[index])
            }
        }
    }
    
    // MARK: - Funzioni pubbliche
    func completaMissioneManuale(_ missione: Missione) {
        // Per missioni speciali che non hanno coordinate (come "Socializza in Bacheca")
        completaMissione(missione)
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
}

// MARK: - Vista Missioni Aggiornata
struct MissioniView: View {
    @StateObject private var missioniManager = MissioniGPSManager()
    @State private var categoriaSelezionata: CategoriaMissione? = nil
    @State private var mostraCompletate = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header con punti e stato GPS
                    headerView
                    
                    // Filtri
                    filterView
                    
                    // Lista missioni
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(missioniFiltrate()) { missione in
                                MissioneCard(
                                    missione: missione,
                                    distanza: missioniManager.distanzaDaMissione(missione),
                                    onComplete: {
                                        // Solo per missioni manuali (senza coordinate)
                                        if missione.coordinate == nil {
                                            missioniManager.completaMissioneManuale(missione)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
                
                // Notifica di completamento
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
            
            // Stato GPS
            HStack {
                Image(systemName: missioniManager.posizioneCorrente != nil ? "location.fill" : "location.slash")
                    .foregroundColor(missioniManager.posizioneCorrente != nil ? .green : .red)
                Text(missioniManager.posizioneCorrente != nil ? "GPS Attivo" : "GPS Non Disponibile")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            // Barra di progresso
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
                // Filtro Tutte/Completate
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
                
                // Filtri per categoria
                ForEach(CategoriaMissione.allCases, id: \.self) { categoria in
                    Button(action: {
                        categoriaSelezionata = categoriaSelezionata == categoria ? nil : categoria
                    }) {
                        HStack {
                            Image(systemName: categoria.icona)
                            Text(categoria.rawValue)
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(categoriaSelezionata == categoria ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(categoriaSelezionata == categoria ? categoria.colore : Color(.systemGray5))
                        .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)
        }
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

// MARK: - Card Missione Aggiornata
struct MissioneCard: View {
    let missione: Missione
    let distanza: Double?
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icona
            VStack {
                Image(systemName: missione.icona)
                    .font(.title2)
                    .foregroundColor(missione.categoria.colore)
                    .frame(width: 40, height: 40)
                    .background(missione.categoria.colore.opacity(0.1))
                    .cornerRadius(10)
                
                if missione.completata {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .offset(y: -5)
                }
            }
            
            // Contenuto
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(missione.titolo)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Badge categoria
                    Text(missione.categoria.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(missione.categoria.colore)
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
                    
                    // Mostra distanza se disponibile
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
            
            // Indicatore di stato
            if !missione.completata {
                if missione.coordinate != nil {
                    // Missione GPS - mostra solo indicatore
                    Image(systemName: "location.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                } else {
                    // Missione manuale - mostra bottone
                    Button(action: onComplete) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(missione.completata ? 0.7 : 1.0)
    }
}

// MARK: - Notifica Completamento
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
