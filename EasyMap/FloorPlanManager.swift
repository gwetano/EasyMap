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
    let description: String?
    let buildingName: String
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

class RoomStatusManager: ObservableObject {
    static let shared = RoomStatusManager()
    
    @Published var giornata: Giornata?
    
    private init() {}
    
    func loadData() async {
        giornata = await leggiJSONDaURL()
    }
    
    func getRoomColor(for room: RoomImage) -> Color {
        guard let giornata = giornata else {
            return .gray
        }
        
        for aula in giornata.aule {
            if aula.nome == room.name && aula.edificio == room.buildingName {
                return aula.isOccupiedNow() ? .red : .green
            }
        }
        return .green
    }
    
    func getOccupancyStatus(for room: RoomImage) -> String {
        guard let giornata = giornata else {
            return "Stato sconosciuto"
        }
        
        for aula in giornata.aule {
            if aula.nome == room.name && aula.edificio == room.buildingName {
                return aula.isOccupiedNow() ? "Occupata" : "Libera"
            }
        }
        return "Libera"
    }
    
    func getAula(for room: RoomImage) -> Aula? {
        guard let giornata = giornata else { return nil }
        
        return giornata.aule.first { aula in
            aula.nome == room.name && aula.edificio == room.buildingName
        }
    }
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
                    name: "Aula 24",
                    position: CGPoint(x: 0.8335, y: 0.423),
                    size: CGSize(width: 0.0287, height: 0.125),
                    description: "Aula magna con proiettore e sistema audio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 23",
                    position: CGPoint(x: 0.802, y: 0.423),
                    size: CGSize(width: 0.0287, height: 0.125),
                    description: "Aula magna con proiettore e sistema audio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 21",
                    position: CGPoint(x: 0.713, y: 0.423),
                    size: CGSize(width: 0.0287, height: 0.125),
                    description: "Aula magna con proiettore e sistema audio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 22",
                    position: CGPoint(x: 0.744, y: 0.423),
                    size: CGSize(width: 0.0287, height: 0.125),
                    description: "Aula magna con proiettore e sistema audio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula Ex-Cues",
                    position: CGPoint(x: 0.4585, y: 0.3765),
                    size: CGSize(width: 0.063, height: 0.085),
                    description: "Ufficio docenti - Piano terra",
                    buildingName: "E"
                ),
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_e_piano_1",
            rooms: [
                RoomImage(
                    name: "Laboratorio 152 - Software Matematico",
                    position: CGPoint(x: 0.724, y: 0.365),
                    size: CGSize(width: 0.063, height: 0.1),
                    description: "Aula con lavagna interattiva e sistema di videoconferenza",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 133",
                    position: CGPoint(x: 0.5278, y: 0.365),
                    size: CGSize(width: 0.0268, height: 0.1),
                    description: "Aula magna con proiettore e sistema audio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 136",
                    position: CGPoint(x: 0.5576, y: 0.365),
                    size: CGSize(width: 0.0286, height: 0.1),
                    description: "Aula magna con proiettore e sistema audio",
                    buildingName: "E"
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
                    description: "Sala deposito e archivio",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Laboratorio Icaro - ICT",
                    position: CGPoint(x: 0.653, y: 0.637),
                    size: CGSize(width: 0.263, height: 0.25),
                    description: "Ufficio tecnico",
                    buildingName: "E1"
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
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula D",
                    position: CGPoint(x: 0.625, y: 0.557),
                    size: CGSize(width: 0.22, height: 0.09),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula E",
                    position: CGPoint(x: 0.625, y: 0.665),
                    size: CGSize(width: 0.22, height: 0.11),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula F",
                    position: CGPoint(x: 0.352, y: 0.552),
                    size: CGSize(width: 0.176, height: 0.1),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula O",
                    position: CGPoint(x: 0.352, y: 0.436),
                    size: CGSize(width: 0.176, height: 0.11),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E1"
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
                    description: "Aula seminari con disposizione a ferro di cavallo",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula N",
                    position: CGPoint(x: 0.654, y: 0.759),
                    size: CGSize(width: 0.212, height: 0.105),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula 102 CAD",
                    position: CGPoint(x: 0.654, y: 0.651),
                    size: CGSize(width: 0.212, height: 0.095),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E1"
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
                    description: "Uffici amministrativi",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Sala 108/9C",
                    position: CGPoint(x: 0.404, y: 0.554),
                    size: CGSize(width: 0.12, height: 0.1),
                    description: "Uffici amministrativi",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Sala 109/9C",
                    position: CGPoint(x: 0.404, y: 0.666),
                    size: CGSize(width: 0.12, height: 0.1),
                    description: "Uffici amministrativi",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Laboratorio Modelli",
                    position: CGPoint(x: 0.653, y: 0.65),
                    size: CGSize(width: 0.22, height: 0.1),
                    description: "Uffici amministrativi",
                    buildingName: "E1"
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
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula B",
                    position: CGPoint(x: 0.615, y: 0.645),
                    size: CGSize(width: 0.16, height: 0.17),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula C",
                    position: CGPoint(x: 0.354, y: 0.388),
                    size: CGSize(width: 0.185, height: 0.185),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E2"
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
                    description: "Aula seminari con disposizione a ferro di cavallo",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula H",
                    position: CGPoint(x: 0.632, y: 0.67),
                    size: CGSize(width: 0.21, height: 0.217),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula L",
                    position: CGPoint(x: 0.323, y: 0.427),
                    size: CGSize(width: 0.22, height: 0.11),
                    description: "Aula seminari con disposizione a ferro di cavallo",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula M",
                    position: CGPoint(x: 0.323, y: 0.308),
                    size: CGSize(width: 0.219, height: 0.11),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E2"
                )
            ]
        )
        return Building(
            name: "E2",
            floors: [floor0, floor1])
    }
}

