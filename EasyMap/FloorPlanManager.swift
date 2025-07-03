//
//  FloorPlanManager.swift
//  EasyMap
//
//  Created by Studente on 03/07/25.
//

import SwiftUI

struct RoomImage: Identifiable {
    let id = UUID()
    let name: String
    let position: CGPoint
    let size: CGSize
    let capacity: Int?
    let description: String?
    
    var isSmall: Bool {
        return (capacity ?? 0) < 20
    }
    
}

struct Floor: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let imageName: String
    let rooms: [RoomImage]
}

struct Building {
    let name: String
    let floors: [Floor]
}

class BuildingDataManager: ObservableObject {
    static let shared = BuildingDataManager()
    
    private init() {}
    
    func getBuilding(named name: String) -> Building? {
        switch name {
        case "E":
            return createBuildingE()
        case "E1":
            return createBuildingE1()
        case "E2":
            return createBuildingE2()
        default:
            return nil
        }
    }
    
    private func createBuildingE() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_e_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula 21",
                    position: CGPoint(x: 0.15, y: 0.25),
                    size: CGSize(width: 0.15, height: 0.12),
                    capacity: 120,
                    description: "Aula magna con proiettore e sistema audio"
                ),
                RoomImage(
                    name: "Aula 22",
                    position: CGPoint(x: 0.65, y: 0.15),
                    size: CGSize(width: 0.12, height: 0.10),
                    capacity: 30,
                    description: "Laboratorio informatico con 30 postazioni"
                ),
                RoomImage(
                    name: "E03",
                    position: CGPoint(x: 0.45, y: 0.75),
                    size: CGSize(width: 0.10, height: 0.08),
                    capacity: nil,
                    description: "Ufficio docenti - Piano terra"
                ),
                RoomImage(
                    name: "WC",
                    position: CGPoint(x: 0.05, y: 0.65),
                    size: CGSize(width: 0.06, height: 0.08),
                    capacity: nil,
                    description: "Servizi igienici"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e_piano_1",
            rooms: [
                RoomImage(
                    name: "E11",
                    position: CGPoint(x: 0.25, y: 0.35),
                    size: CGSize(width: 0.14, height: 0.12),
                    capacity: 80,
                    description: "Aula con lavagna interattiva e sistema di videoconferenza"
                ),
                RoomImage(
                    name: "E12",
                    position: CGPoint(x: 0.55, y: 0.25),
                    size: CGSize(width: 0.12, height: 0.10),
                    capacity: 50,
                    description: "Sala studio e consultazione con accesso Wi-Fi"
                )
            ]
        )
        
        return Building(
            name: "E",
            floors: [floor0, floor1]
        )
    }
    
    private func createBuildingE1() -> Building {
        let floorm1 = Floor(
            number: -1,
            name: "Sottoscala",
            imageName: "edificio_e1_piano_-1",
            rooms: [
                RoomImage(
                    name: "Aula delle Lauree - V. Cardone",
                    position: CGPoint(x: 0.31, y: 0.45),
                    size: CGSize(width: 0.27, height: 0.40),
                    capacity: 15,
                    description: "Sala deposito e archivio"
                ),
                RoomImage(
                    name: "Laboratorio Icaro - ICT",
                    position: CGPoint(x: 0.653, y: 0.637),
                    size: CGSize(width: 0.263, height: 0.25),
                    capacity: nil,
                    description: "Ufficio tecnico"
                ),
            ]
        )
        
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_e1_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula G",
                    position: CGPoint(x: 0.352, y: 0.665),
                    size: CGSize(width: 0.176, height: 0.11),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula D",
                    position: CGPoint(x: 0.625, y: 0.557),
                    size: CGSize(width: 0.22, height: 0.09),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula E",
                    position: CGPoint(x: 0.625, y: 0.665),
                    size: CGSize(width: 0.22, height: 0.11),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula F",
                    position: CGPoint(x: 0.352, y: 0.552),
                    size: CGSize(width: 0.176, height: 0.1),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula O",
                    position: CGPoint(x: 0.352, y: 0.436),
                    size: CGSize(width: 0.176, height: 0.11),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e1_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula Infografica",
                    position: CGPoint(x: 0.352, y: 0.517),
                    size: CGSize(width: 0.217, height: 0.44),
                    capacity: 45,
                    description: "Aula seminari con disposizione a ferro di cavallo"
                ),
                RoomImage(
                    name: "Aula N",
                    position: CGPoint(x: 0.654, y: 0.759),
                    size: CGSize(width: 0.212, height: 0.105),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula 102 CAD",
                    position: CGPoint(x: 0.654, y: 0.651),
                    size: CGSize(width: 0.212, height: 0.095),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
            ]
        )
        
        let floor2 = Floor(
            number: 2,
            name: "Secondo Piano",
            imageName: "edificio_e1_piano_2",
            rooms: [
                RoomImage(
                    name: "Spazio per attivita' complementari_107",
                    position: CGPoint(x: 0.404, y: 0.445),
                    size: CGSize(width: 0.12, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
                RoomImage(
                    name: "Sala 108/9C",
                    position: CGPoint(x: 0.404, y: 0.554),
                    size: CGSize(width: 0.12, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
                RoomImage(
                    name: "Sala 109/9C",
                    position: CGPoint(x: 0.404, y: 0.666),
                    size: CGSize(width: 0.12, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
                RoomImage(
                    name: "Laboratorio Modelli",
                    position: CGPoint(x: 0.653, y: 0.65),
                    size: CGSize(width: 0.22, height: 0.1),
                    capacity: nil,
                    description: "Uffici amministrativi"
                ),
            ]
        )
        
        return Building(
            name: "E1",
            floors: [floorm1, floor0, floor1, floor2]
            )
    }
    
    private func createBuildingE2() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_e2_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula A",
                    position: CGPoint(x: 0.607, y: 0.384),
                    size: CGSize(width: 0.176, height: 0.17),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula B",
                    position: CGPoint(x: 0.615, y: 0.645),
                    size: CGSize(width: 0.16, height: 0.17),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula C",
                    position: CGPoint(x: 0.354, y: 0.388),
                    size: CGSize(width: 0.185, height: 0.185),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e2_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula I",
                    position: CGPoint(x: 0.6265, y: 0.361),
                    size: CGSize(width: 0.22, height: 0.216),
                    capacity: 45,
                    description: "Aula seminari con disposizione a ferro di cavallo"
                ),
                RoomImage(
                    name: "Aula H",
                    position: CGPoint(x: 0.632, y: 0.67),
                    size: CGSize(width: 0.21, height: 0.217),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                ),
                RoomImage(
                    name: "Aula L",
                    position: CGPoint(x: 0.323, y: 0.427),
                    size: CGSize(width: 0.22, height: 0.11),
                    capacity: 45,
                    description: "Aula seminari con disposizione a ferro di cavallo"
                ),
                RoomImage(
                    name: "Aula M",
                    position: CGPoint(x: 0.323, y: 0.308),
                    size: CGSize(width: 0.219, height: 0.11),
                    capacity: 60,
                    description: "Aula per lezioni frontali con proiettore"
                )
            ]
        )
        return Building(
            name: "E2",
            floors: [floor0, floor1])
    }
}

