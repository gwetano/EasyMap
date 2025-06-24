//
//  CampusMapView.swift
//  EasyMap
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
    @State private var selectedBuilding: String? = nil
    
    var body: some View {
        ZStack {
            MapReader { reader in
                Map(position: $locationManager.cameraPosition, bounds: locationManager.cameraBounds) {
                    
                    UserAnnotation()
                    
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
                    
                    // Annotazioni con i titoli degli edifici
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
                }
                .onTapGesture { screenCoordinate in
                    if let coordinate = reader.convert(screenCoordinate, from: .local) {
                        handleTap(at: coordinate)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onAppear {
                locationManager.startTracking()
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(item: Binding<IdentifiableString?>(
                get: { selectedBuilding.map(IdentifiableString.init) },
                set: { selectedBuilding = $0?.value }
            )) { building in
                BuildingDetailView(buildingName: building.value)
            }
            // ✅ Pulsanti in basso
            VStack {
                Spacer() // Spinge tutto in basso
                HStack {
                    // Pulsante in basso a sinistra
                    Button(action: {
                        print("bacheca")
                    }) {
                        Image("bacheca")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // ✅ mantiene proporzioni
                            .frame(width: 60)
                            .padding()
                    }

                    Spacer()
                    Button(action: {
                        print("profilo")
                    }) {
                        Image("login")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // ✅ mantiene proporzioni
                            .frame(width: 70)
                            .padding()
                    }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            }
        }
    }
    
    private func handleTap(at coordinate: CLLocationCoordinate2D) {
        if isPointInPolygon(point: coordinate, polygon: edificioECoordinates) {
            selectedBuilding = "E"
        } else if isPointInPolygon(point: coordinate, polygon: edificioE1Coordinates) {
            selectedBuilding = "E1"
        } else if isPointInPolygon(point: coordinate, polygon: edificioE2Coordinates) {
            selectedBuilding = "E2"
        }
    }
}

// MARK: - Coordinate degli overlay
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
    CLLocationCoordinate2D(latitude: 40.77200, longitude: 14.79127),
    CLLocationCoordinate2D(latitude: 40.77122, longitude: 14.79183),
    CLLocationCoordinate2D(latitude: 40.77111, longitude: 14.79155),
    CLLocationCoordinate2D(latitude: 40.77194, longitude: 14.79091),
    CLLocationCoordinate2D(latitude: 40.77203, longitude: 14.79111),
    CLLocationCoordinate2D(latitude: 40.77198, longitude: 14.79116),
    CLLocationCoordinate2D(latitude: 40.77200, longitude: 14.79127)
]

private let centroEdificioE = CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675)
private let centroEdificioE1 = CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132)
private let centroEdificioE2 = CLLocationCoordinate2D(latitude: 40.772135, longitude: 14.791490)

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

struct BuildingDetailView: View {
    let buildingName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edificio \(buildingName)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "building.2")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Pianta Edificio \(buildingName)")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Sostituisci con la tua immagine")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Informazioni:")
                        .font(.headline)
                    
                    Text("• Piano terra: Aule e laboratori")
                    Text("• Primo piano: Uffici docenti")
                    Text("• Secondo piano: Sale riunioni")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button("Chiudi") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    CampusMapView()
}
