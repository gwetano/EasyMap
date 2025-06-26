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
                  distance: 1500, heading: 62, pitch: 0)
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
    
    func centerOnUserLocation() {
        guard let location = manager.location else { return }
        
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

    @StateObject var store = AnnuncioStore()
    @State private var mostraCreazione = false
    @State private var mostraBacheca = false
    @State private var annunci: [Annuncio] = [
        Annuncio(titolo: "Torneo di Scacchi", descrizione: "Benvenuti al torneo!", data: Date(), luogo: "UNISA", immagini: [], autore: "Francesco"),
        Annuncio(titolo: "Hackathon", descrizione: "Coding no stop", data: Date(), luogo: "Biblioteca", immagini: [], autore: "Lucia")
    ]

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
                }
                .mapStyle(.imagery(elevation: .realistic))
                .onTapGesture { screenCoordinate in
                    if let coordinate = reader.convert(screenCoordinate, from: .local) {
                        handleTap(at: coordinate)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
                
                VStack {
                    Button(action: {
                        locationManager.centerOnUserLocation()
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Circle().fill(.white))
                            .shadow(radius: 2)
                    }
                    Spacer()
                }
                .padding(.leading, 8)
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

            VStack {
                Spacer()
                
                HStack {
                     Button(action: {
                        mostraBacheca = true
                    }) {
                        Image("bacheca")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .padding()
                    }
                    
                    Spacer()
                    Button(action: {
                        print("profilo")
                    }) {
                        Image("login")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .fullScreenCover(isPresented: $mostraBacheca) {
                BachecaTikTokView(store: store)
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
        }else if isPointInPolygon(point: coordinate, polygon: edificioDCoordinates) {
            selectedBuilding = "D"
        } else if isPointInPolygon(point: coordinate, polygon: edificioD1Coordinates) {
            selectedBuilding = "D1"
        }else if isPointInPolygon(point: coordinate, polygon: edificioD2Coordinates) {
            selectedBuilding = "D2"
        } else if isPointInPolygon(point: coordinate, polygon: edificioD3Coordinates) {
            selectedBuilding = "D3"
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



private let centroEdificioE = CLLocationCoordinate2D(latitude: 40.772885, longitude: 14.790675)
private let centroEdificioE1 = CLLocationCoordinate2D(latitude: 40.772832, longitude: 14.790132)
private let centroEdificioE2 = CLLocationCoordinate2D(latitude: 40.772135, longitude: 14.791490)
private let centroEdificioD = CLLocationCoordinate2D(latitude: 40.77156, longitude: 14.79138)
private let centroEdificioD1 = CLLocationCoordinate2D(latitude: 40.77135, longitude: 14.79216)
private let centroEdificioD2 = CLLocationCoordinate2D(latitude: 40.77105, longitude: 14.79137)
private let centroEdificioD3 = CLLocationCoordinate2D(latitude: 40.77164, longitude: 14.79077)
private let centroEdificioC = CLLocationCoordinate2D(latitude: 40.77136, longitude: 14.79265)
private let centroEdificioC1 = CLLocationCoordinate2D(latitude: 40.77070, longitude: 14.79360)
private let centroEdificioC2 = CLLocationCoordinate2D(latitude: 40.77168, longitude: 14.79295)
private let centroEdificioF = CLLocationCoordinate2D(latitude: 40.77457, longitude: 14.78887)
private let centroEdificioF1 = CLLocationCoordinate2D(latitude: 40.77363, longitude: 14.78893)
private let centroEdificioF2 = CLLocationCoordinate2D(latitude: 40.77449, longitude: 14.78972)
private let centroEdificioF3 = CLLocationCoordinate2D(latitude: 40.77510, longitude: 14.78919)
private let centroEdificioB = CLLocationCoordinate2D(latitude: 40.77014, longitude: 14.79328)
private let centroEdificioB1 = CLLocationCoordinate2D(latitude: 40.76954, longitude: 14.79329)
private let centroEdificioB2 = CLLocationCoordinate2D(latitude: 40.77007, longitude: 14.79259)


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
        .edgesIgnoringSafeArea(.bottom)
    }
}


#Preview {
    CampusMapView()
}
