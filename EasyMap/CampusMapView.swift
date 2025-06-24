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

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    private let unisaCoordinate = CLLocationCoordinate2D(latitude: 40.772705, longitude: 14.791365)

    @Published var cameraPosition: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 40.772705, longitude: 14.791365),
                  distance: 500, heading: 62, pitch: 0)
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
    }

    func startTracking() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        DispatchQueue.main.async {
            self.cameraPosition = .camera(
                MapCamera(centerCoordinate: location.coordinate,
                          distance: 200, heading: 0, pitch: 0)
            )
        }
    }
}

struct CampusMapView: View {
    @StateObject private var locationManager = LocationManager()
    
    @StateObject var store = AnnuncioStore()
    @State private var mostraCreazione = false
    @State private var mostraBacheca = false
    @State private var annunci: [Annuncio] = [
        Annuncio(titolo: "Torneo di Scacchi", descrizione: "Benvenuti al torneo!", data: Date(), luogo: "UNISA", immagini: [], autore: "Francesco"),
        Annuncio(titolo: "Hackathon", descrizione: "Coding no stop", data: Date(), luogo: "Biblioteca", immagini: [], autore: "Lucia")
    ]

    var body: some View {
        ZStack {
            Map(position: $locationManager.cameraPosition, bounds: locationManager.cameraBounds) {
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onAppear {
                locationManager.startTracking()
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                
                Spacer()

                HStack {
                    // Bottone BACHECA
                    Button(action: {
                        mostraBacheca = true
                    }) {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .resizable()
                            .frame(width: 40, height: 50)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                    Spacer()

                    // Bottone PROFILO
                    Button(action: {
                        print("Profilo non ancora implementato")
                    }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $mostraBacheca) {
            BachecaTikTokView(store: store)
        }
    }
}


#Preview {
    CampusMapView()
}
