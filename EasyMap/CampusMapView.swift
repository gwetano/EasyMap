//
//  CampusMapView.swift
//  EasyMap
//
//  Created by Studente on 21/06/25.
//

import SwiftUI
import MapKit
import Foundation
import CoreLocation

// Struct per gestire i dati del parcheggio
struct ParkingSpot {
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let address: String?
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var missioniManager: MissioniGPSManager?
    @Published var parkingSpot: ParkingSpot?
    
    private let unisaCoordinate = CLLocationCoordinate2D(latitude: 40.772705, longitude: 14.791365)

    @Published var cameraPosition: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 40.7720, longitude: 14.79128),
                  distance: 780, heading: 132, pitch: 70)
    )

    let cameraBounds = MapCameraBounds(
        centerCoordinateBounds: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.772705, longitude: 14.791365),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ),
        minimumDistance: 100,
        maximumDistance: 1800
    )

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        loadParkingSpot()
    }

    func startTracking() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func centerOnUserLocation() {
        guard let location = manager.location else { return }
        
        DispatchQueue.main.async {
            self.cameraPosition = .camera(
                MapCamera(centerCoordinate: location.coordinate,
                          distance: 200, heading: 0, pitch: 0)
            )
        }
    }
    
    func centerOnCoordinate(_ coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            self.cameraPosition = .camera(
                MapCamera(centerCoordinate: coordinate,
                          distance: 200, heading: 0, pitch: 0)
            )
        }
    }
    
    func setMissioniManager(_ manager: MissioniGPSManager) {
        self.missioniManager = manager
    }
    
    // Funzioni per gestire il parcheggio
    func addParkingAtCurrentLocation() {
        guard let location = manager.location else { return }
        
        let parking = ParkingSpot(
            coordinate: location.coordinate,
            timestamp: Date(),
            address: nil
        )
        
        self.parkingSpot = parking
        saveParkingSpot()
        
        // Reverse geocoding per ottenere l'indirizzo (opzionale)
        // reverseGeocodeLocation(location.coordinate)
    }
    
    func addParkingAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let parking = ParkingSpot(
            coordinate: coordinate,
            timestamp: Date(),
            address: nil
        )
        
        self.parkingSpot = parking
        saveParkingSpot()
        
        // Reverse geocoding per ottenere l'indirizzo (opzionale)
        //reverseGeocodeLocation(coordinate)
    }
    
    func removeParkingSpot() {
        parkingSpot = nil
        UserDefaults.standard.removeObject(forKey: "ParkingSpot")
    }
    
    private func saveParkingSpot() {
        guard let parking = parkingSpot else { return }
        
        let data: [String: Any] = [
            "latitude": parking.coordinate.latitude,
            "longitude": parking.coordinate.longitude,
            "timestamp": parking.timestamp.timeIntervalSince1970,
            "address": parking.address ?? ""
        ]
        
        UserDefaults.standard.set(data, forKey: "ParkingSpot")
    }
    
    private func loadParkingSpot() {
        guard let data = UserDefaults.standard.dictionary(forKey: "ParkingSpot"),
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double,
              let timestamp = data["timestamp"] as? TimeInterval else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let date = Date(timeIntervalSince1970: timestamp)
        let address = data["address"] as? String
        
        parkingSpot = ParkingSpot(coordinate: coordinate, timestamp: date, address: address)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else { return }
        
        if let missioniManager = missioniManager {
            missioniManager.locationManager(manager, didUpdateLocations: locations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errore GPS: \(error.localizedDescription)")
        missioniManager?.locationManager(manager, didFailWithError: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Permesso GPS negato")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
        
        missioniManager?.locationManager(manager, didChangeAuthorization: status)
    }
    
    // Attiva/disattiva modalità satellite centrata sull'utente
    func setSatelliteMode(_ enabled: Bool) {
        if enabled {
            centerOnUserLocation()
            // Qui usi il nuovo MapKit: stile 2D satellitare
            cameraPosition = .automatic
        } else {
            // Ritorna alla vista standard UNISA
            cameraPosition = .camera(
                MapCamera(centerCoordinate: unisaCoordinate,
                          distance: 780, heading: 132, pitch: 70)
            )
        }
    }

    // Aggiungi un parcheggio generico a una coordinata
    func addParking(at coordinate: CLLocationCoordinate2D) {
        let parking = ParkingSpot(
            coordinate: coordinate,
            timestamp: Date(),
            address: nil
        )
        
        self.parkingSpot = parking
        saveParkingSpot()
        // reverseGeocodeLocation(coordinate)
    }
    
    func getCurrentCoordinate() -> CLLocationCoordinate2D? {
        manager.location?.coordinate
    }
    
}


struct CampusMapView: View {
    
    @State private var parcheggioMode = false
    @State private var isManualSelectionActive = false
    @State private var pendingParking: CLLocationCoordinate2D? = nil
    
    @State private var showSearchSheet = false
    @StateObject private var adManager = AdManager.shared
    
    @StateObject private var locationManager = LocationManager()
    @State private var selectedBuilding: String? = nil

    @StateObject var store = AnnuncioStore()
    @State private var mostraCreazione = false
    @State private var mostraBacheca = false
    @State private var mostraMissioni = false
    @EnvironmentObject var authManager: AuthManager
    @State private var isMap3D = false
    @State private var mostraPDFMensa = false
    @Namespace private var mapScope
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            MapReader { reader in
                Map(position: $locationManager.cameraPosition, bounds: locationManager.cameraBounds, scope: mapScope) {
                    
                    UserAnnotation()
                    
                    // Marker del parcheggio Confermato
                    if let parking = locationManager.parkingSpot {
                        Marker(
                            "Parcheggio",systemImage: "car.fill",coordinate: parking.coordinate
                        ).tint(.blue)
                    }
                    
                    MapPolygon(coordinates: edificioECoordinates)
                        .foregroundStyle(.blue.opacity(0.3))
                        .stroke(.blue, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioE1Coordinates)
                        .foregroundStyle(.blue.opacity(0.3))
                        .stroke(.blue, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioE2Coordinates)
                        .foregroundStyle(.blue.opacity(0.3))
                        .stroke(.blue, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioDCoordinates)
                        .foregroundStyle(.red.opacity(0.3))
                        .stroke(.red, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioD3Coordinates)
                        .foregroundStyle(.red.opacity(0.3))
                        .stroke(.red, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioD2Coordinates)
                        .foregroundStyle(.red.opacity(0.3))
                        .stroke(.red, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioD1Coordinates)
                        .foregroundStyle(.red.opacity(0.3))
                        .stroke(.red, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioCCoordinates)
                        .foregroundStyle(.green.opacity(0.3))
                        .stroke(.green, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioC1Coordinates)
                        .foregroundStyle(.green.opacity(0.3))
                        .stroke(.green, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioC2Coordinates)
                        .foregroundStyle(.green.opacity(0.3))
                        .stroke(.green, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioFCoordinates)
                        .foregroundStyle(.yellow.opacity(0.3))
                        .stroke(.yellow, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioF1Coordinates)
                        .foregroundStyle(.yellow.opacity(0.3))
                        .stroke(.yellow, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioF2Coordinates)
                        .foregroundStyle(.yellow.opacity(0.3))
                        .stroke(.yellow, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioF3Coordinates)
                        .foregroundStyle(.yellow.opacity(0.3))
                        .stroke(.yellow, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioBCoordinates)
                        .foregroundStyle(.orange.opacity(0.3))
                        .stroke(.orange, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioB1Coordinates)
                        .foregroundStyle(.orange.opacity(0.3))
                        .stroke(.orange, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioB2Coordinates)
                        .foregroundStyle(.orange.opacity(0.3))
                        .stroke(.orange, lineWidth: 2)
                    
                    MapPolygon(coordinates: edificioQ2Coordinates)
                        .foregroundStyle(.purple.opacity(0.3))
                        .stroke(.purple, lineWidth: 2)
                    
                    MapPolygon(coordinates: bibliotecaScientificaCoordinates)
                        .foregroundStyle(.brown.opacity(0.3))
                        .stroke(.brown, lineWidth: 2)
                    
                    MapPolygon(coordinates: bibliotecaUmanisticaCoordinates)
                        .foregroundStyle(.brown.opacity(0.3))
                        .stroke(.brown, lineWidth: 2)
                    
                    
                    Annotation("E", coordinate: centroEdificioE) {
                        Text("E")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.blue, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("E1", coordinate: centroEdificioE1) {
                        Text("E1")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.blue, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("E2", coordinate: centroEdificioE2) {
                        Text("E2")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.blue, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("D", coordinate: centroEdificioD) {
                        Text("D")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.red, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("D1", coordinate: centroEdificioD1) {
                        Text("D1")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.red, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("D2", coordinate: centroEdificioD2) {
                        Text("D2")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.red, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("D3", coordinate: centroEdificioD3) {
                        Text("D3")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.red, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("C", coordinate: centroEdificioC) {
                        Text("C")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.green, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("C1", coordinate: centroEdificioC1) {
                        Text("C1")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.green, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("C2", coordinate: centroEdificioC2) {
                        Text("C2")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.green, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("F", coordinate: centroEdificioF) {
                        Text("F")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.yellow, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("F1", coordinate: centroEdificioF1) {
                        Text("F1")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.yellow, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("F2", coordinate: centroEdificioF2) {
                        Text("F2")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.yellow, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("F3", coordinate: centroEdificioF3) {
                        Text("F3")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.yellow, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("B", coordinate: centroEdificioB) {
                        Text("B")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.orange, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("B1", coordinate: centroEdificioB1) {
                        Text("B1")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.orange, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    Annotation("B2", coordinate: centroEdificioB2) {
                        Text("B2")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.orange, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("Mensa", coordinate: centroEdificioQ2) {
                        Text("Mensa")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.purple, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("Biblioteca Scientifica", coordinate: centroBiblioSci) {
                        Text("Biblioteca Scientifica")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.brown)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.brown, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    Annotation("Biblioteca Umanistica", coordinate: centroBiblioUma) {
                        Text("Biblioteca Umanistica")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.brown)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.9))
                                    .stroke(.brown, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .scaleEffect(0.8)
                    }
                    .annotationTitles(.hidden)
                    
                    //Marker per parcheggio in Attesa
                    if let pending = pendingParking {
                        Marker(
                            "Parcheggio in Attesa",systemImage: "car.fill",coordinate: pending
                        ).tint(.orange)
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .onTapGesture { screenCoordinate in
                    if let coordinate = reader.convert(screenCoordinate, from: .local) {
                        if parcheggioMode, isManualSelectionActive {
                            // salvo temporaneamente il punto selezionato
                            pendingParking = coordinate
                        } else {
                            handleTap(at: coordinate)
                        }
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                VStack(spacing: 11) {
                    MapUserLocationButton(scope: mapScope)
                        .tint(.primary)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    MapPitchToggle(scope: mapScope)
                        .tint(.primary)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    MapCompass(scope: mapScope)
                        .tint(.primary)
                        .cornerRadius(15)
                }
                .padding(.trailing , 11)
            }
            .overlay(alignment: .bottom) {
                if parcheggioMode {
                    VStack {
                        Spacer()
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Button {
                                    if let current = locationManager.getCurrentCoordinate() {
                                        pendingParking = current
                                    }
                                } label: {
                                    Label("GPS", systemImage: "location.fill")
                                        .padding(10)
                                        .frame(minWidth: 80)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                }

                                Button {
                                    isManualSelectionActive = true
                                } label: {
                                    Label("Manuale", systemImage: "hand.point.up.left.fill")
                                        .padding(10)
                                        .frame(minWidth: 80)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                }

                                Button {
                                    locationManager.removeParkingSpot()
                                    pendingParking = nil
                                    isManualSelectionActive = false
                                    parcheggioMode = false
                                } label: {
                                    Label("Elimina", systemImage: "trash")
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(12)
                                        .foregroundStyle(.red)
                                } //Disalitano il tasto Elimina se non viene selezionato il parcheggio
                                .disabled(locationManager.parkingSpot == nil && pendingParking == nil)
                                .foregroundColor(locationManager.parkingSpot == nil && pendingParking == nil ? .gray : .red)
                                .opacity(locationManager.parkingSpot == nil && pendingParking == nil ? 0.5 : 1.0)
                            }
                            
                            //Bottone Conferma, visibile solo se c’è un parcheggio in attesa
                            if let pending = pendingParking {
                                Button {
                                    locationManager.addParkingAtCoordinate(pending)
                                    pendingParking = nil
                                    isManualSelectionActive = false
                                    parcheggioMode = false
                                } label: {
                                    Label("Conferma", systemImage: "checkmark")
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(12)
                                }
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            } else if locationManager.parkingSpot != nil {
                                // Conferma solo per "visionare" un parcheggio già salvato
                                Button {
                                    parcheggioMode = false
                                } label: {
                                    Label("Indietro", systemImage: "arrow.left")
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(12)
                                }
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // posizione sopra la barra di ricerca
                    }
                }
            }
            .mapControls {
                MapCompass(scope: mapScope)
                    .mapControlVisibility(.hidden)
            }
            .onAppear {
                locationManager.startTracking()
            }
            .edgesIgnoringSafeArea(.bottom)
            .fullScreenCover(item: Binding<IdentifiableString?>(
                   get: { selectedBuilding.map(IdentifiableString.init) },
                   set: { selectedBuilding = $0?.value }
               )) { building in
                   FloorPlanView(buildingName: building.value)
               }
           .fullScreenCover(isPresented: $mostraPDFMensa) {
               MensaPDFView()
           }
           .fullScreenCover(isPresented: $adManager.isPresentingAd) {
               AdFullscreenView(manager: adManager)
           }
            if !parcheggioMode {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        // Spacer 5% dal bordo sinistro
                        Spacer()
                            .frame(maxWidth: .infinity)
                            .layoutPriority(0.05)
                        
                        // Barra di ricerca 65%
                        Button {
                            showSearchSheet.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.primary)
                                Text("Cerca aula…")
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(11)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                        }
                        .frame(maxWidth: .infinity)
                        .layoutPriority(0.65)
                        
                        // Spacer 5% tra i due pulsanti
                        Spacer()
                            .frame(maxWidth: .infinity)
                            .layoutPriority(0.03)
                        
                        // Tasto parcheggio 12%
                       Button(action: {
                       parcheggioMode.toggle()
                           if parcheggioMode {
                               if let parking = locationManager.parkingSpot {
                                   //Zoom sul marker se il parcheggio è impostato
                                   locationManager.centerOnCoordinate(parking.coordinate)
                               } else {
                                   // Zoom sull'utente se il parcheggio non è impostato
                                   locationManager.centerOnUserLocation()
                               }
                           } else {
                               // torna a standard
                               locationManager.setSatelliteMode(false)
                           }
                       }) {
                           Image(systemName: locationManager.parkingSpot != nil ? "car.fill" : "car")
                               .foregroundColor(locationManager.parkingSpot != nil ? .blue : .primary)
                               .padding(11)
                               .background(.ultraThinMaterial)
                               .cornerRadius(15)
                       }
                       .frame(maxWidth: .infinity)
                       .layoutPriority(0.12)
                       
                       // Spacer 3% tra i pulsanti
                       Spacer()
                           .frame(maxWidth: .infinity)
                           .layoutPriority(0.03)
                        
                        // Tasto missioni 10%
                        Button(action: {
                            mostraMissioni = true
                        }) {
                            Image(systemName: "flag.checkered")
                                .foregroundColor(.primary)
                                .padding(11)
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                        }
                        .frame(maxWidth: .infinity)
                        .layoutPriority(0.1)
                        
                        // Spacer 2% dal bordo destro
                        Spacer()
                            .frame(maxWidth: .infinity)
                            .layoutPriority(0.02)
                    }
                    .padding(.horizontal, 15)
                }
                .fullScreenCover(isPresented: $mostraBacheca) {
                    BachecaTikTokView(store: store)
                }
                .fullScreenCover(isPresented: $mostraMissioni) {
                    MissioniView()
                }
                .sheet(isPresented: $showSearchSheet) {
                    SearchView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
        }
        .mapScope(mapScope)
    }
    
    private func handleTap(at coordinate: CLLocationCoordinate2D) {
        if isPointInPolygon(point: coordinate, polygon: edificioECoordinates) {
            selectedBuilding = "E"
        } else if isPointInPolygon(point: coordinate, polygon: edificioE1Coordinates) {
            selectedBuilding = "E1"
        } else if isPointInPolygon(point: coordinate, polygon: edificioE2Coordinates) {
            selectedBuilding = "E2"
        } else if isPointInPolygon(point: coordinate, polygon: edificioDCoordinates) {
            selectedBuilding = "D"
        } else if isPointInPolygon(point: coordinate, polygon: edificioD1Coordinates) {
            selectedBuilding = "D1"
        } else if isPointInPolygon(point: coordinate, polygon: edificioD2Coordinates) {
            selectedBuilding = "D2"
        } else if isPointInPolygon(point: coordinate, polygon: edificioD3Coordinates) {
            selectedBuilding = "D3"
        } else if isPointInPolygon(point: coordinate, polygon: edificioFCoordinates) {
            selectedBuilding = "F"
        } else if isPointInPolygon(point: coordinate, polygon: edificioF1Coordinates) {
            selectedBuilding = "F1"
        } else if isPointInPolygon(point: coordinate, polygon: edificioF2Coordinates) {
            selectedBuilding = "F2"
        } else if isPointInPolygon(point: coordinate, polygon: edificioF3Coordinates) {
            selectedBuilding = "F3"
        } else if isPointInPolygon(point: coordinate, polygon: edificioCCoordinates) {
            selectedBuilding = "C"
        } else if isPointInPolygon(point: coordinate, polygon: edificioC1Coordinates) {
            selectedBuilding = "C1"
        } else if isPointInPolygon(point: coordinate, polygon: edificioC2Coordinates) {
            selectedBuilding = "C2"
        } else if isPointInPolygon(point: coordinate, polygon: edificioBCoordinates) {
            selectedBuilding = "B"
        } else if isPointInPolygon(point: coordinate, polygon: edificioB1Coordinates) {
            selectedBuilding = "B1"
        } else if isPointInPolygon(point: coordinate, polygon: edificioB2Coordinates) {
            selectedBuilding = "B2"
        } else if isPointInPolygon(point: coordinate, polygon: edificioQ2Coordinates) {
            let showAd = Bool.random()
            if showAd {
                adManager.requestAd {
                    mostraPDFMensa = true
                }
            } else {
                mostraPDFMensa = true
            }
        }else if isPointInPolygon(point: coordinate, polygon: bibliotecaScientificaCoordinates){
            if let url = URL(string: "https://www.biblioteche.unisa.it/chiedi-al-bibliotecario?richiesta=3") {
                        adManager.requestAd {
                            openURL(url)
                        }
                    }
        }else if isPointInPolygon(point: coordinate, polygon: bibliotecaUmanisticaCoordinates){
            if let url = URL(string: "https://www.biblioteche.unisa.it/chiedi-al-bibliotecario?richiesta=3") {
                adManager.requestAd {
                    openURL(url)
                }
            }
        }
    }
}


private let edificioECoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77213, longitude: 14.79143),
    CLLocationCoordinate2D(latitude: 40.77377, longitude: 14.79024),
    CLLocationCoordinate2D(latitude: 40.77364, longitude: 14.78992),
    CLLocationCoordinate2D(latitude: 40.77200, longitude: 14.79117),
    CLLocationCoordinate2D(latitude: 40.77213, longitude: 14.79143)
]

private let edificioE1Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.773061, longitude: 14.790224),
    CLLocationCoordinate2D(latitude: 40.772896, longitude: 14.789840),
    CLLocationCoordinate2D(latitude: 40.772602, longitude: 14.790060),
    CLLocationCoordinate2D(latitude: 40.772760, longitude: 14.790438),
    CLLocationCoordinate2D(latitude: 40.773061, longitude: 14.790224)
]

private let edificioE2Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77206, longitude: 14.79136),
    CLLocationCoordinate2D(latitude: 40.77211, longitude: 14.79146),
    CLLocationCoordinate2D(latitude: 40.77227, longitude: 14.79136),
    CLLocationCoordinate2D(latitude: 40.77239, longitude: 14.79161),
    CLLocationCoordinate2D(latitude: 40.77210, longitude: 14.79182),
    CLLocationCoordinate2D(latitude: 40.77193, longitude: 14.79144),
    CLLocationCoordinate2D(latitude: 40.77206, longitude: 14.79136)
]

private let edificioDCoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77200, longitude: 14.79127),
    CLLocationCoordinate2D(latitude: 40.77122, longitude: 14.79183),
    CLLocationCoordinate2D(latitude: 40.77111, longitude: 14.79155),
    CLLocationCoordinate2D(latitude: 40.77194, longitude: 14.79091),
    CLLocationCoordinate2D(latitude: 40.77203, longitude: 14.79111),
    CLLocationCoordinate2D(latitude: 40.77198, longitude: 14.79116),
    CLLocationCoordinate2D(latitude: 40.77200, longitude: 14.79127)
]

private let edificioD3Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77171, longitude: 14.79048),
    CLLocationCoordinate2D(latitude: 40.77142, longitude: 14.79068),
    CLLocationCoordinate2D(latitude: 40.77158, longitude: 14.79109),
    CLLocationCoordinate2D(latitude: 40.77176, longitude: 14.79097),
    CLLocationCoordinate2D(latitude: 40.77180, longitude: 14.79069),
    CLLocationCoordinate2D(latitude: 40.77171, longitude: 14.79048)
]

private let edificioD2Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77126, longitude: 14.79138),
    CLLocationCoordinate2D(latitude: 40.77111, longitude: 14.79101),
    CLLocationCoordinate2D(latitude: 40.77075, longitude: 14.79126),
    CLLocationCoordinate2D(latitude: 40.77092, longitude: 14.79169),
    CLLocationCoordinate2D(latitude: 40.77126, longitude: 14.79138)
]

private let edificioD1Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77112, longitude: 14.79201),
    CLLocationCoordinate2D(latitude: 40.77131, longitude: 14.79242),
    CLLocationCoordinate2D(latitude: 40.77161, longitude: 14.79219),
    CLLocationCoordinate2D(latitude: 40.77151, longitude: 14.79200),
    CLLocationCoordinate2D(latitude: 40.77128, longitude: 14.79191),
    CLLocationCoordinate2D(latitude: 40.77112, longitude: 14.79201)
]

private let edificioCCoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77214, longitude: 14.79188),
    CLLocationCoordinate2D(latitude: 40.77228, longitude: 14.79219),
    CLLocationCoordinate2D(latitude: 40.77062, longitude: 14.79340),
    CLLocationCoordinate2D(latitude: 40.77051, longitude: 14.79311),
    CLLocationCoordinate2D(latitude: 40.77214, longitude: 14.79188)
]

private let edificioC1Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77063, longitude: 14.79384),
    CLLocationCoordinate2D(latitude: 40.77049, longitude: 14.79348),
    CLLocationCoordinate2D(latitude: 40.77067, longitude: 14.79337),
    CLLocationCoordinate2D(latitude: 40.77086, longitude: 14.79346),
    CLLocationCoordinate2D(latitude: 40.77093, longitude: 14.79365),
    CLLocationCoordinate2D(latitude: 40.77063, longitude: 14.79384)
]

private let edificioC2Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77194, longitude: 14.79298),
    CLLocationCoordinate2D(latitude: 40.77159, longitude: 14.79324),
    CLLocationCoordinate2D(latitude: 40.77142, longitude: 14.79288),
    CLLocationCoordinate2D(latitude: 40.77176, longitude: 14.79262),
    CLLocationCoordinate2D(latitude: 40.77194, longitude: 14.79298)
]

private let edificioFCoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77557, longitude: 14.78834),
    CLLocationCoordinate2D(latitude: 40.77361, longitude: 14.78977),
    CLLocationCoordinate2D(latitude: 40.77347, longitude: 14.78946),
    CLLocationCoordinate2D(latitude: 40.77542, longitude: 14.78800),
    CLLocationCoordinate2D(latitude: 40.77557, longitude: 14.78834)
]

private let edificioF1Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77386, longitude: 14.78900),
    CLLocationCoordinate2D(latitude: 40.77356, longitude: 14.78923),
    CLLocationCoordinate2D(latitude: 40.77339, longitude: 14.78882),
    CLLocationCoordinate2D(latitude: 40.77368, longitude: 14.78859),
    CLLocationCoordinate2D(latitude: 40.77386, longitude: 14.78900)
]

private let edificioF2Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77476, longitude: 14.78981),
    CLLocationCoordinate2D(latitude: 40.77439, longitude: 14.79008),
    CLLocationCoordinate2D(latitude: 40.77418, longitude: 14.78957),
    CLLocationCoordinate2D(latitude: 40.77456, longitude: 14.78931),
    CLLocationCoordinate2D(latitude: 40.77476, longitude: 14.78981)
]

private let edificioF3Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77533, longitude: 14.78925),
    CLLocationCoordinate2D(latitude: 40.77503, longitude: 14.78948),
    CLLocationCoordinate2D(latitude: 40.77486, longitude: 14.78908),
    CLLocationCoordinate2D(latitude: 40.77506, longitude: 14.78893),
    CLLocationCoordinate2D(latitude: 40.77523, longitude: 14.78901),
    CLLocationCoordinate2D(latitude: 40.77533, longitude: 14.78925)
]

private let edificioBCoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77051, longitude: 14.79319),
    CLLocationCoordinate2D(latitude: 40.76974, longitude: 14.79377),
    CLLocationCoordinate2D(latitude: 40.76960, longitude: 14.79352),
    CLLocationCoordinate2D(latitude: 40.77045, longitude: 14.79286),
    CLLocationCoordinate2D(latitude: 40.77055, longitude: 14.79306),
    CLLocationCoordinate2D(latitude: 40.77050, longitude: 14.79311),
    CLLocationCoordinate2D(latitude: 40.77051, longitude: 14.79319)
]

private let edificioB1Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.76978, longitude: 14.79333),
    CLLocationCoordinate2D(latitude: 40.76946, longitude: 14.79362),
    CLLocationCoordinate2D(latitude: 40.76926, longitude: 14.79318),
    CLLocationCoordinate2D(latitude: 40.76962, longitude: 14.79295),
    CLLocationCoordinate2D(latitude: 40.76978, longitude: 14.79333)
]

private let edificioB2Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77019, longitude: 14.79222),
    CLLocationCoordinate2D(latitude: 40.77040, longitude: 14.79271),
    CLLocationCoordinate2D(latitude: 40.77002, longitude: 14.79302),
    CLLocationCoordinate2D(latitude: 40.76980, longitude: 14.79251),
    CLLocationCoordinate2D(latitude: 40.77019, longitude: 14.79222)
]


private let edificioQ2Coordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77272, longitude: 14.79329),
    CLLocationCoordinate2D(latitude: 40.77268, longitude: 14.79347),
    CLLocationCoordinate2D(latitude: 40.77272, longitude: 14.79350),
    CLLocationCoordinate2D(latitude: 40.77270, longitude: 14.79355),
    CLLocationCoordinate2D(latitude: 40.77243, longitude: 14.79374),
    CLLocationCoordinate2D(latitude: 40.77265, longitude: 14.79425),
    CLLocationCoordinate2D(latitude: 40.77279, longitude: 14.79415),
    CLLocationCoordinate2D(latitude: 40.77292, longitude: 14.79446),
    CLLocationCoordinate2D(latitude: 40.77333, longitude: 14.79418),
    CLLocationCoordinate2D(latitude: 40.77321, longitude: 14.79386),
    CLLocationCoordinate2D(latitude: 40.77338, longitude: 14.79371),
    CLLocationCoordinate2D(latitude: 40.77316, longitude: 14.79319),
    CLLocationCoordinate2D(latitude: 40.77289, longitude: 14.79340),
    CLLocationCoordinate2D(latitude: 40.77286, longitude: 14.79338),
    CLLocationCoordinate2D(latitude: 40.77287, longitude: 14.79334),
    CLLocationCoordinate2D(latitude: 40.77272, longitude: 14.79329),
]

private let bibliotecaScientificaCoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.77278, longitude: 14.78894),
    CLLocationCoordinate2D(latitude: 40.77254, longitude: 14.78837),
    CLLocationCoordinate2D(latitude: 40.77211, longitude: 14.78867),
    CLLocationCoordinate2D(latitude: 40.77235, longitude: 14.78924),
    CLLocationCoordinate2D(latitude: 40.77278, longitude: 14.78894)
]

private let bibliotecaUmanisticaCoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 40.76944, longitude: 14.79116),
    CLLocationCoordinate2D(latitude: 40.76920, longitude: 14.79057),
    CLLocationCoordinate2D(latitude: 40.76926, longitude: 14.79056),
    CLLocationCoordinate2D(latitude: 40.76914, longitude: 14.79024),
    CLLocationCoordinate2D(latitude: 40.76870, longitude: 14.79054),
    CLLocationCoordinate2D(latitude: 40.76866, longitude: 14.79076),
    CLLocationCoordinate2D(latitude: 40.76872, longitude: 14.79092),
    CLLocationCoordinate2D(latitude: 40.76884, longitude: 14.79088),
    CLLocationCoordinate2D(latitude: 40.76906, longitude: 14.79138),
    CLLocationCoordinate2D(latitude: 40.76944, longitude: 14.79116)
]


public let centroEdificioE = CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675)
public let centroEdificioE1 = CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132)
public let centroEdificioE2 = CLLocationCoordinate2D(latitude: 40.772135, longitude: 14.791490)
public let centroEdificioD = CLLocationCoordinate2D(latitude: 40.77156, longitude: 14.79138)
public let centroEdificioD1 = CLLocationCoordinate2D(latitude: 40.77135, longitude: 14.79216)
public let centroEdificioD2 = CLLocationCoordinate2D(latitude: 40.77105, longitude: 14.79137)
public let centroEdificioD3 = CLLocationCoordinate2D(latitude: 40.77164, longitude: 14.79077)
public let centroEdificioC = CLLocationCoordinate2D(latitude: 40.77136, longitude: 14.79265)
public let centroEdificioC1 = CLLocationCoordinate2D(latitude: 40.77070, longitude: 14.79360)
public let centroEdificioC2 = CLLocationCoordinate2D(latitude: 40.77168, longitude: 14.79295)
public let centroEdificioF = CLLocationCoordinate2D(latitude: 40.77457, longitude: 14.78887)
public let centroEdificioF1 = CLLocationCoordinate2D(latitude: 40.77363, longitude: 14.78893)
public let centroEdificioF2 = CLLocationCoordinate2D(latitude: 40.77449, longitude: 14.78972)
public let centroEdificioF3 = CLLocationCoordinate2D(latitude: 40.77510, longitude: 14.78919)
public let centroEdificioB = CLLocationCoordinate2D(latitude: 40.77014, longitude: 14.79328)
public let centroEdificioB1 = CLLocationCoordinate2D(latitude: 40.76954, longitude: 14.79329)
public let centroEdificioB2 = CLLocationCoordinate2D(latitude: 40.77007, longitude: 14.79259)
public let centroEdificioQ2 = CLLocationCoordinate2D(latitude: 40.77289, longitude: 14.79374)
public let centroBiblioSci = CLLocationCoordinate2D(latitude: 40.77245, longitude: 14.78879)
public let centroBiblioUma = CLLocationCoordinate2D(latitude: 40.76901, longitude: 14.79086)


struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

func isPointInPolygon(point: CLLocationCoordinate2D, polygon: [CLLocationCoordinate2D]) -> Bool {
    let x = point.latitude
    let y = point.longitude
    var inside = false
    
    var j = polygon.count - 1
    for i in 0..<polygon.count {
        let xi = polygon[i].latitude
        let yi = polygon[i].longitude
        let xj = polygon[j].latitude
        let yj = polygon[j].longitude
        
        if ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
            inside.toggle()
        }
        
        j = i
    }
    return inside

}

#Preview {
    CampusMapView()
}
