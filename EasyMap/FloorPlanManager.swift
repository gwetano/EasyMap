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
        
        return .yellow
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
        
        return "Dati non disponibili"
    }
    
    func getAula(for room: RoomImage) -> Aula? {
        guard let giornata = giornata else { return nil }
        
        return giornata.aule.first { aula in
            aula.nome == room.name && aula.edificio == room.buildingName
        }
    }
    
    func isRoomInJSON(room: RoomImage) -> Bool {
        guard let giornata = giornata else { return false }
        
        return giornata.aule.contains { aula in
            aula.nome == room.name && aula.edificio == room.buildingName
        }
    }
}


class BuildingDataManager: ObservableObject {
    static let shared = BuildingDataManager()
    
    private init() {}
  
    func getBuilding(named name: String) -> Building? {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        switch normalizedName {
        case "E":
            return createBuildingE()
        case "E1":
            return createBuildingE1()
        case "E2":
            return createBuildingE2()
        case "F3":
            return createBuildingF3()
        case "D3":
            return createBuildingD3()
        case "C1":
            return createBuildingC1()
        case "C2":
            return createBuildingC2()
        case "F2":
            return createBuildingF2()
        case "F1":
            return createBuildingF1()
        case "D1":
            return createBuildingD1()
        case "D2":
            return createBuildingD2()
        case "D":
            return createBuildingD()
        case "C":
            return createBuildingC()
        case "B":
            return createBuildingB()
/*
        case "F":
            return createBuildingF()
        case "B1":
            return createBuildingB1()
        case "B2":
            return createBuildingB2()*/
        default:
            return nil
        }
    }
    
    private func createBuildingB() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_b_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula 18",
                    position: CGPoint(x: 0.2099, y: 0.4413),
                    size: CGSize(width: 0.0445, height: 0.1392),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula 17",
                    position: CGPoint(x: 0.2597, y: 0.4410),
                    size: CGSize(width: 0.0449, height: 0.1372),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula 12 - DISPAC",
                    position: CGPoint(x: 0.2352, y: 0.6463),
                    size: CGSize(width: 0.0961, height: 0.1603),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula 16",
                    position: CGPoint(x: 0.3529, y: 0.4413),
                    size: CGSize(width: 0.0451, height: 0.1389),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula 15",
                    position: CGPoint(x: 0.4036, y: 0.4408),
                    size: CGSize(width: 0.0459, height: 0.1386),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula 13",
                    position: CGPoint(x: 0.3540, y: 0.6455),
                    size: CGSize(width: 0.0466, height: 0.1617),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula 14 - Multimediale",
                    position: CGPoint(x: 0.4035, y: 0.6455),
                    size: CGSize(width: 0.0441, height: 0.1623),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Associazione Studenti Giurisprudenza",
                    position: CGPoint(x: 0.3075, y: 0.6542),
                    size: CGSize(width: 0.0394, height: 0.1453),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Agora",
                    position: CGPoint(x: 0.5920, y: 0.6526),
                    size: CGSize(width: 0.0404, height: 0.1480),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula Mancini",
                    position: CGPoint(x: 0.5472, y: 0.4421),
                    size: CGSize(width: 0.0468, height: 0.1385),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula D'Ambrosio",
                    position: CGPoint(x: 0.4973, y: 0.4425),
                    size: CGSize(width: 0.0437, height: 0.1392),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula Pugliatti",
                    position: CGPoint(x: 0.6390, y: 0.4417),
                    size: CGSize(width: 0.0463, height: 0.1412),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula Castellano",
                    position: CGPoint(x: 0.6902, y: 0.4418),
                    size: CGSize(width: 0.0466, height: 0.1381),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula 6 - Di Rago",
                    position: CGPoint(x: 0.5217, y: 0.6442),
                    size: CGSize(width: 0.0933, height: 0.1651),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula De Capraris",
                    position: CGPoint(x: 0.6899, y: 0.6440),
                    size: CGSize(width: 0.0454, height: 0.1639),
                    description: "",
                    buildingName: "B"
                ),
                RoomImage(
                    name: "Aula Fenucci",
                    position: CGPoint(x: 0.8194, y: 0.5232),
                    size: CGSize(width: 0.1192, height: 0.3090),
                    description: "",
                    buildingName: "B"
                )
                ,
                RoomImage(
                    name: "Aula Volterra",
                    position: CGPoint(x: 0.6392, y: 0.6446),
                    size: CGSize(width: 0.0459, height: 0.1618),
                    description: "",
                    buildingName: "B"
                )
                

            ]
        )
        
        return Building(
            name: "B",
            floors: [floor0])
    }
    
    private func createBuildingC() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_c_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula 14",
                    position: CGPoint(x: 0.0949, y: 0.4480),
                    size: CGSize(width: 0.0294, height: 0.1202),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 13",
                    position: CGPoint(x: 0.1269, y: 0.4491),
                    size: CGSize(width: 0.0286, height: 0.1241),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 12",
                    position: CGPoint(x: 0.1843, y: 0.4482),
                    size: CGSize(width: 0.0284, height: 0.1214),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 11",
                    position: CGPoint(x: 0.2160, y: 0.4487),
                    size: CGSize(width: 0.0293, height: 0.1216),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 1 -  SCIENZE DELLA FORMAZIONE",
                    position: CGPoint(x: 0.1109, y: 0.6295),
                    size: CGSize(width: 0.0609, height: 0.1433),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 2 /3",
                    position: CGPoint(x: 0.2003, y: 0.6281),
                    size: CGSize(width: 0.0609, height: 0.1414),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Associazione Futura",
                    position: CGPoint(x: 0.1557, y: 0.6334),
                    size: CGSize(width: 0.0239, height: 0.1283),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 10",
                    position: CGPoint(x: 0.2739, y: 0.4492),
                    size: CGSize(width: 0.0292, height: 0.1201),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 9",
                    position: CGPoint(x: 0.3045, y: 0.4482),
                    size: CGSize(width: 0.0289, height: 0.1265),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 8 - SF",
                    position: CGPoint(x: 0.3629, y: 0.4486),
                    size: CGSize(width: 0.0281, height: 0.1221),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 7 - SF",
                    position: CGPoint(x: 0.3941, y: 0.4490),
                    size: CGSize(width: 0.0284, height: 0.1212),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 4 - SCIENZE DELLA FORMAZIONE",
                    position: CGPoint(x: 0.2892, y: 0.6293),
                    size: CGSize(width: 0.0585, height: 0.1403),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 5/6",
                    position: CGPoint(x: 0.3787, y: 0.6280),
                    size: CGSize(width: 0.0589, height: 0.1408),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula Studio",
                    position: CGPoint(x: 0.4737, y: 0.4559),
                    size: CGSize(width: 0.0725, height: 0.1321),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Information Desk",
                    position: CGPoint(x: 0.4734, y: 0.6447),
                    size: CGSize(width: 0.0523, height: 0.0230),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 4 - ECONOMIA",
                    position: CGPoint(x: 0.5556, y: 0.6297),
                    size: CGSize(width: 0.0589, height: 0.1393),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 7 - ECONOMIA",
                    position: CGPoint(x: 0.5403, y: 0.4496),
                    size: CGSize(width: 0.0281, height: 0.1260),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 8 - ECONOMIA",
                    position: CGPoint(x: 0.5707, y: 0.4492),
                    size: CGSize(width: 0.0281, height: 0.1237),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Forma Mentis",
                    position: CGPoint(x: 0.5999, y: 0.6349),
                    size: CGSize(width: 0.0247, height: 0.1272),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 3",
                    position: CGPoint(x: 0.6290, y: 0.6301),
                    size: CGSize(width: 0.0283, height: 0.1401),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 4",
                    position: CGPoint(x: 0.6601, y: 0.6295),
                    size: CGSize(width: 0.0283, height: 0.1405),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 2",
                    position: CGPoint(x: 0.6292, y: 0.4486),
                    size: CGSize(width: 0.0284, height: 0.1239),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 1",
                    position: CGPoint(x: 0.6602, y: 0.4499),
                    size: CGSize(width: 0.0282, height: 0.1247),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 8",
                    position: CGPoint(x: 0.7178, y: 0.4491),
                    size: CGSize(width: 0.0297, height: 0.1218),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 10",
                    position: CGPoint(x: 0.7499, y: 0.4491),
                    size: CGSize(width: 0.0286, height: 0.1223),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 5",
                    position: CGPoint(x: 0.7337, y: 0.6287),
                    size: CGSize(width: 0.0587, height: 0.1403),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 9",
                    position: CGPoint(x: 0.8073, y: 0.4488),
                    size: CGSize(width: 0.0276, height: 0.1236),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula 11",
                    position: CGPoint(x: 0.8383, y: 0.4492),
                    size: CGSize(width: 0.0291, height: 0.1239),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Cartoleria CUSL",
                    position: CGPoint(x: 0.7783, y: 0.6298),
                    size: CGSize(width: 0.0245, height: 0.1402),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula SSC 6/7",
                    position: CGPoint(x: 0.8228, y: 0.6296),
                    size: CGSize(width: 0.0589, height: 0.1391),
                    description: "",
                    buildingName: "C"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_c_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula Alfonso Catania",
                    position: CGPoint(x: 0.8152, y: 0.5179),
                    size: CGSize(width: 0.0279, height: 0.0839),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Aula Dario Santamaria",
                    position: CGPoint(x: 0.7861, y: 0.5188),
                    size: CGSize(width: 0.0249, height: 0.0853),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Segreteria Scientifica Didattica",
                    position: CGPoint(x: 0.7941, y: 0.6431),
                    size: CGSize(width: 0.0410, height: 0.0910),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Segreteria Amministrativa",
                    position: CGPoint(x: 0.8241, y: 0.6418),
                    size: CGSize(width: 0.0137, height: 0.0916),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Mersa SNA Lab",
                    position: CGPoint(x: 0.7362, y: 0.4007),
                    size: CGSize(width: 0.0223, height: 0.0817),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Laboratorio Di Analisi Dati",
                    position: CGPoint(x: 0.7121, y: 0.4002),
                    size: CGSize(width: 0.0219, height: 0.0817),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Biblioteca Antonio Santucci",
                    position: CGPoint(x: 0.7190, y: 0.5204),
                    size: CGSize(width: 0.0555, height: 0.0883),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Osservatorio sui diritti umani",
                    position: CGPoint(x: 0.7264, y: 0.6421),
                    size: CGSize(width: 0.0122, height: 0.0913),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Center For European Studies",
                    position: CGPoint(x: 0.7119, y: 0.6418),
                    size: CGSize(width: 0.0128, height: 0.0943),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Centro Studi Sui Diritti Dell'Antico Oriente Mediterraneo",
                    position: CGPoint(x: 0.6952, y: 0.6442),
                    size: CGSize(width: 0.0151, height: 0.0932),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Laboratorio Made in Italy",
                    position: CGPoint(x: 0.6449, y: 0.3985),
                    size: CGSize(width: 0.0123, height: 0.0855),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Giuliano Grieco",
                    position: CGPoint(x: 0.6297, y: 0.3985),
                    size: CGSize(width: 0.0137, height: 0.0876),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Laboratorio Didattico e di Ricerca Gaetano Vardano",
                    position: CGPoint(x: 0.6146, y: 0.3987),
                    size: CGSize(width: 0.0110, height: 0.0872),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Biblioteca Alberto Trabocchi",
                    position: CGPoint(x: 0.6483, y: 0.5170),
                    size: CGSize(width: 0.0322, height: 0.0872),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Biblioteca Alessandro Graziani",
                    position: CGPoint(x: 0.6175, y: 0.5184),
                    size: CGSize(width: 0.0239, height: 0.0859),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Laboratorio Ligogi",
                    position: CGPoint(x: 0.6519, y: 0.6420),
                    size: CGSize(width: 0.0271, height: 0.0943),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Osservatorio Giuridico Sull'Impresa",
                    position: CGPoint(x: 0.6297, y: 0.6420),
                    size: CGSize(width: 0.0124, height: 0.0943),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "LABESS",
                    position: CGPoint(x: 0.5765, y: 0.4247),
                    size: CGSize(width: 0.0117, height: 0.1386),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Sala Master",
                    position: CGPoint(x: 0.5549, y: 0.4244),
                    size: CGSize(width: 0.0263, height: 0.1380),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Laboratorio Indico",
                    position: CGPoint(x: 0.5320, y: 0.4229),
                    size: CGSize(width: 0.0139, height: 0.1356),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "OPSAT",
                    position: CGPoint(x: 0.5686, y: 0.6168),
                    size: CGSize(width: 0.0269, height: 0.1454),
                    description: "",
                    buildingName: "C"
                ),
                RoomImage(
                    name: "Laboratorio Archeologia",
                    position: CGPoint(x: 0.5384, y: 0.6171),
                    size: CGSize(width: 0.0280, height: 0.1461),
                    description: "",
                    buildingName: "C"
                )
            ]
        )
        
        return Building(
            name: "C",
            floors: [floor0,floor1])
    }

    private func createBuildingC1() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_c1_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula delle Lauree - Nicola Cilento",
                    position: CGPoint(x: 0.4955, y: 0.4162),
                    size: CGSize(width: 0.4228, height: 0.1628),
                    description: "Aula",
                    buildingName: "C1"
                ),
                RoomImage(
                    name: "Aula Pecoraro",
                    position: CGPoint(x: 0.6239, y: 0.6661),
                    size: CGSize(width: 0.1633, height: 0.1640),
                    description: "Aula",
                    buildingName: "C1"
                )
            ]
        )
        
        return Building(
            name: "C1",
            floors: [floor0])
    }
    
    private func createBuildingD() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_d_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula 1",
                    position: CGPoint(x: 0.5124, y: 0.4347),
                    size: CGSize(width: 0.1075, height: 0.1490),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Aula 2",
                    position: CGPoint(x: 0.5154, y: 0.6604),
                    size: CGSize(width: 0.1154, height: 0.1846),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Aula 3",
                    position: CGPoint(x: 0.3838, y: 0.4386),
                    size: CGSize(width: 0.0601, height: 0.1555),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Aula 4",
                    position: CGPoint(x: 0.3427, y: 0.6565),
                    size: CGSize(width: 0.0879, height: 0.1867),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Aula 5",
                    position: CGPoint(x: 0.3241, y: 0.4351),
                    size: CGSize(width: 0.0504, height: 0.1530),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Aula Ex Centro Stampa",
                    position: CGPoint(x: 0.1923, y: 0.5545),
                    size: CGSize(width: 0.1074, height: 0.3921),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Sui Generis - Associazione",
                    position: CGPoint(x: 0.5952, y: 0.6776),
                    size: CGSize(width: 0.0365, height: 0.1574),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Aula C11",
                    position: CGPoint(x: 0.6726, y: 0.5553),
                    size: CGSize(width: 0.1107, height: 0.3979),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio P",
                    position: CGPoint(x: 0.8446, y: 0.4998),
                    size: CGSize(width: 0.1306, height: 0.2818),
                    description: "Aula",
                    buildingName: "D"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_d_piano_1",
            rooms: [
                RoomImage(
                    name: "Laboratorio F",
                    position: CGPoint(x: 0.3472, y: 0.3656),
                    size: CGSize(width: 0.0498, height: 0.0967),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio H",
                    position: CGPoint(x: 0.3462, y: 0.5253),
                    size: CGSize(width: 0.1052, height: 0.1268),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio E",
                    position: CGPoint(x: 0.4671, y: 0.4516),
                    size: CGSize(width: 0.0414, height: 0.2698),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio C",
                    position: CGPoint(x: 0.5220, y: 0.4545),
                    size: CGSize(width: 0.0601, height: 0.2746),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio D",
                    position: CGPoint(x: 0.4841, y: 0.6926),
                    size: CGSize(width: 0.0809, height: 0.1095),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio B",
                    position: CGPoint(x: 0.6126, y: 0.4519),
                    size: CGSize(width: 0.0237, height: 0.2720),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio A",
                    position: CGPoint(x: 0.6679, y: 0.4516),
                    size: CGSize(width: 0.0799, height: 0.2764),
                    description: "Nessuna Descrizione",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Laboratorio Sperimentazione",
                    position: CGPoint(x: 0.3197, y: 0.6927),
                    size: CGSize(width: 0.0491, height: 0.1098),
                    description: "Aula",
                    buildingName: "D"
                ),
                RoomImage(
                    name: "Ufficio Amministrativo",
                    position: CGPoint(x: 0.3064, y: 0.3657),
                    size: CGSize(width: 0.0224, height: 0.0989),
                    description: "Aula",
                    buildingName: "D"
                )
            ]
        )
        
        return Building(
            name: "D",
            floors: [floor0,floor1])
    }
    
    private func createBuildingD1() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_d1_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula A - ECONOMIA",
                    position: CGPoint(x: 0.6488, y: 0.4455),
                    size: CGSize(width: 0.1839, height: 0.3125),
                    description: "Nessuna Descrizione",
                    buildingName: "D1"
                ),
                RoomImage(
                    name: "Aula B - ECONOMIA",
                    position: CGPoint(x: 0.4067, y: 0.2950),
                    size: CGSize(width: 0.2855, height: 0.1307),
                    description: "Nessuna Descrizione",
                    buildingName: "D1"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_d1_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula Informatica - DISES",
                    position: CGPoint(x: 0.3501, y: 0.3226),
                    size: CGSize(width: 0.2121, height: 0.1214),
                    description: "Nessuna descrizione",
                    buildingName: "D1"
                ),
                RoomImage(
                    name: "Aula D",
                    position: CGPoint(x: 0.6312, y: 0.4060),
                    size: CGSize(width: 0.2173, height: 0.1193),
                    description: "Nessuna Descrizione",
                    buildingName: "D1"
                ),
                RoomImage(
                    name: "Laboratorio Informatico E Multimediale",
                    position: CGPoint(x: 0.6568, y: 0.4917),
                    size: CGSize(width: 0.1660, height: 0.0475),
                    description: "Nessuna Descrizione",
                    buildingName: "D1"
                )
            ]
        )

        
        let floor2 = Floor(
            number: 2,
            name: "Secondo Piano",
            imageName: "edificio_d1_piano_2",
            rooms: [
                RoomImage(
                    name: "Centro Elaborazione Dati",
                    position: CGPoint(x: 0.5942, y: 0.4321),
                    size: CGSize(width: 0.1229, height: 0.0994),
                    description: "Nessuna Descrizione",
                    buildingName: "D1"
                ),
                RoomImage(
                    name: "Aula del Consiglio",
                    position: CGPoint(x: 0.5930, y: 0.5418),
                    size: CGSize(width: 0.1249, height: 0.1013),
                    description: "Nessuna Descrizione",
                    buildingName: "D1"
                ),
                RoomImage(
                    name: "Biblioteca",
                    position: CGPoint(x: 0.5926, y: 0.6491),
                    size: CGSize(width: 0.1227, height: 0.0942),
                    description: "Nessuna Descrizione",
                    buildingName: "D1"
                )
            ]
        )


        return Building(
            name: "D1",
            floors: [floor0,floor1,floor2])
    }
    
    private func createBuildingD2() -> Building {
        let floorm1 = Floor(
            number: -1,
            name: "Sottoscala",
            imageName: "edificio_d2_piano_-1",
            rooms: [
                RoomImage(
                    name: "Aula SP7",
                    position: CGPoint(x: 0.3039, y: 0.5892),
                    size: CGSize(width: 0.0922, height: 0.1045),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Aula SP8",
                    position: CGPoint(x: 0.3434, y: 0.4969),
                    size: CGSize(width: 0.1671, height: 0.0596),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Aula SP9",
                    position: CGPoint(x: 0.3936, y: 0.5883),
                    size: CGSize(width: 0.0674, height: 0.1048),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Aula SPB",
                    position: CGPoint(x: 0.6188, y: 0.5912),
                    size: CGSize(width: 0.2467, height: 0.2493),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                )
            ]
        )
        
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_d2_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula SP3",
                    position: CGPoint(x: 0.6091, y: 0.3693),
                    size: CGSize(width: 0.1732, height: 0.1535),
                    description: "Nessuna descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Aula SP4",
                    position: CGPoint(x: 0.3742, y: 0.3671),
                    size: CGSize(width: 0.1641, height: 0.1527),
                    description: "Nessuna descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Laboratorio SP5",
                    position: CGPoint(x: 0.3746, y: 0.5686),
                    size: CGSize(width: 0.1621, height: 0.0640),
                    description: "Nessuna descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Aula SP6",
                    position: CGPoint(x: 0.3758, y: 0.6503),
                    size: CGSize(width: 0.1613, height: 0.0808),
                    description: "Nessuna descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Aula SPA",
                    position: CGPoint(x: 0.6702, y: 0.6713),
                    size: CGSize(width: 0.2830, height: 0.2692),
                    description: "Nessuna descrizione",
                    buildingName: "D2"
                )
            ]
        )

        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_d2_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula Valdo D'Arienzo (Ex SP2)",
                    position: CGPoint(x: 0.6452, y: 0.4250),
                    size: CGSize(width: 0.1545, height: 0.0832),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                ),
                RoomImage(
                    name: "Aula Angelo Saturno (Ex SP1)",
                    position: CGPoint(x: 0.6453, y: 0.3262),
                    size: CGSize(width: 0.1528, height: 0.0939),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                ),RoomImage(
                    name: "Aula del Consiglio - 'Vittorio Foa'",
                    position: CGPoint(x: 0.3492, y: 0.4279),
                    size: CGSize(width: 0.1547, height: 0.0916),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                ),RoomImage(
                    name: "Aula delle Lauree - 'Gabriele De Rosa'",
                    position: CGPoint(x: 0.7073, y: 0.6347),
                    size: CGSize(width: 0.1690, height: 0.1858),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                ),RoomImage(
                    name: "Aula Multimediale D2LAB",
                    position: CGPoint(x: 0.3542, y: 0.3078),
                    size: CGSize(width: 0.1486, height: 0.1333),
                    description: "Nessuna Descrizione",
                    buildingName: "D2"
                )
            ]
        )


        return Building(
            name: "D2",
            floors: [floorm1,floor0,floor1])
    }
    
    private func createBuildingF1() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_f1_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula 1",
                    position: CGPoint(x: 0.3614, y: 0.6009),
                    size: CGSize(width: 0.2048, height: 0.2844),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 2",
                    position: CGPoint(x: 0.6419, y: 0.6404),
                    size: CGSize(width: 0.1961, height: 0.2004),
                    description: "",
                    buildingName: "F1"
                )
                ,
                RoomImage(
                    name: "Laboratorio 3 - Farmiolab",
                    position: CGPoint(x: 0.6590, y: 0.3122),
                    size: CGSize(width: 0.1659, height: 0.1199),
                    description: "",
                    buildingName: "F1"
                )
                ,
                RoomImage(
                    name: "Laboratorio 4 - Farmiolab",
                    position: CGPoint(x: 0.6638, y: 0.4145),
                    size: CGSize(width: 0.1535, height: 0.0667),
                    description: "",
                    buildingName: "F1"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_f1_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula 8",
                    position: CGPoint(x: 0.6197, y: 0.3168),
                    size: CGSize(width: 0.1603, height: 0.0738),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 7",
                    position: CGPoint(x: 0.6191, y: 0.3949),
                    size: CGSize(width: 0.1599, height: 0.0662),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 6",
                    position: CGPoint(x: 0.6196, y: 0.5656),
                    size: CGSize(width: 0.1605, height: 0.0701),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 5",
                    position: CGPoint(x: 0.6203, y: 0.6449),
                    size: CGSize(width: 0.1615, height: 0.0728),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 4",
                    position: CGPoint(x: 0.3827, y: 0.6707),
                    size: CGSize(width: 0.1694, height: 0.1018),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 3",
                    position: CGPoint(x: 0.3828, y: 0.5669),
                    size: CGSize(width: 0.1711, height: 0.0897),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 9",
                    position: CGPoint(x: 0.3536, y: 0.4767),
                    size: CGSize(width: 0.1135, height: 0.0706),
                    description: "",
                    buildingName: "F1"
                )
            ]
        )
        
        let floor2 = Floor(
            number: 2,
            name: "Secondo Piano",
            imageName: "edificio_f1_piano_2",
            rooms: [
                RoomImage(
                    name: "Aula 10",
                    position: CGPoint(x: 0.3656, y: 0.5661),
                    size: CGSize(width: 0.2107, height: 0.0834),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula 11",
                    position: CGPoint(x: 0.3877, y: 0.4786),
                    size: CGSize(width: 0.1664, height: 0.0723),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula AGR/1",
                    position: CGPoint(x: 0.6427, y: 0.2871),
                    size: CGSize(width: 0.2038, height: 0.1019),
                    description: "",
                    buildingName: "F1"
                ),
                RoomImage(
                    name: "Aula AGR/2",
                    position: CGPoint(x: 0.6421, y: 0.3907),
                    size: CGSize(width: 0.2010, height: 0.0866),
                    description: "",
                    buildingName: "F1"
                )
            ]
        )
        
        return Building(
            name: "F1",
            floors: [floor0,floor1,floor2])
    }
    
    private func createBuildingC2() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_c2_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula 1 - Marrazzo",
                    position: CGPoint(x: 0.6571, y: 0.3434),
                    size: CGSize(width: 0.3118, height: 0.2983),
                    description: "Aula",
                    buildingName: "C2"
                ),
                RoomImage(
                    name: "Aula 6",
                    position: CGPoint(x: 0.3228, y: 0.4123),
                    size: CGSize(width: 0.1846, height: 0.1890),
                    description: "Aula",
                    buildingName: "C2"
                ),
                RoomImage(
                    name: "Aula 5 - Pugliese",
                    position: CGPoint(x: 0.5996, y: 0.6788),
                    size: CGSize(width: 0.1821, height: 0.1744),
                    description: "Aula",
                    buildingName: "C2"
                )
            ]
        )
        
        return Building(
            name: "C2",
            floors: [floor0])
    }
    
    private func createBuildingD3() -> Building {
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_d3_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula 6",
                    position: CGPoint(x: 0.6562, y: 0.3572),
                    size: CGSize(width: 0.2301, height: 0.2355),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Cappella",
                    position: CGPoint(x: 0.4126, y: 0.6349),
                    size: CGSize(width: 0.2622, height: 0.1769),
                    description: "Cappella Unisa",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Sala Comunitaria Ufficio Equipe",
                    position: CGPoint(x: 0.5961, y: 0.6334),
                    size: CGSize(width: 0.1013, height: 0.1698),
                    description: "Ufficio Equipe",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Ufficio Carriere DIPSUM",
                    position: CGPoint(x: 0.7121, y: 0.6354),
                    size: CGSize(width: 0.1147, height: 0.1668),
                    description: "DIPSUM",
                    buildingName: "D3"
                )
                
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_d3_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula 10",
                    position: CGPoint(x: 0.5977, y: 0.3439),
                    size: CGSize(width: 0.0979, height: 0.2269),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Aula 9",
                    position: CGPoint(x: 0.7089, y: 0.6504),
                    size: CGSize(width: 0.1225, height: 0.2314),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Aula 8",
                    position: CGPoint(x: 0.5697, y: 0.6507),
                    size: CGSize(width: 0.1307, height: 0.2313),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Aula 7",
                    position: CGPoint(x: 0.4369, y: 0.6513),
                    size: CGSize(width: 0.1159, height: 0.2314),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Laboratorio Multimediale A.Russo",
                    position: CGPoint(x: 0.2997, y: 0.6526),
                    size: CGSize(width: 0.1368, height: 0.2287),
                    description: "Laboratorio",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Ufficio Didattica, Organi Collegiali, Alta Formazione Carriere ",
                    position: CGPoint(x: 0.7127, y: 0.3433),
                    size: CGSize(width: 0.1207, height: 0.2278),
                    description: "Laboratorio",
                    buildingName: "D3"
                )
                
            ]
        )
        
        let floor2 = Floor(
            number: 2,
            name: "Secondo Piano",
            imageName: "edificio_d3_piano_2",
            rooms: [
                RoomImage(
                    name: "Aula 13",
                    position: CGPoint(x: 0.6043, y: 0.3425),
                    size: CGSize(width: 0.1072, height: 0.2263),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Aula 12",
                    position: CGPoint(x: 0.5632, y: 0.6584),
                    size: CGSize(width: 0.1185, height: 0.2178),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Aula 11",
                    position: CGPoint(x: 0.4387, y: 0.6601),
                    size: CGSize(width: 0.1204, height: 0.2224),
                    description: "Aula",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Ufficio Carriere DIPSUM Ex Facolta Lettere",
                    position: CGPoint(x: 0.3017, y: 0.6523),
                    size: CGSize(width: 0.1420, height: 0.2336),
                    description: "Ufficio",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "DIPSUM Direzione Sala Giunta",
                    position: CGPoint(x: 0.7207, y: 0.3462),
                    size: CGSize(width: 0.1063, height: 0.2311),
                    description: "Nessuna Descrizione",
                    buildingName: "D3"
                ),
                RoomImage(
                    name: "Studi Docenti e PTA",
                    position: CGPoint(x: 0.6987, y: 0.6514),
                    size: CGSize(width: 0.1412, height: 0.2326),
                    description: "Nessuna Descrizione",
                    buildingName: "D3"
                )
                
            ]
        )
        
        return Building(
            name: "D3",
            floors: [floor0,floor1,floor2]
            )
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
                    description: "Aula non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 23",
                    position: CGPoint(x: 0.802, y: 0.423),
                    size: CGSize(width: 0.0287, height: 0.125),
                    description: "Aula non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 21",
                    position: CGPoint(x: 0.713, y: 0.423),
                    size: CGSize(width: 0.0287, height: 0.125),
                    description: "Aula non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 22",
                    position: CGPoint(x: 0.744, y: 0.423),
                    size: CGSize(width: 0.0287, height: 0.125),
                    description: "Aula non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 16",
                    position: CGPoint(x: 0.533, y: 0.423),
                    size: CGSize(width: 0.03, height: 0.125),
                    description: "LCEM - Caratterizzazione Elettromagnetica dei Materiali",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 18",
                    position: CGPoint(x: 0.565, y: 0.423),
                    size: CGSize(width: 0.028, height: 0.125),
                    description: "TETI - Telecomunicazioni e Teoria dell'Informazione",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 19",
                    position: CGPoint(x: 0.6236, y: 0.423),
                    size: CGSize(width: 0.028, height: 0.125),
                    description: "TAU - Trasduttori Acustoelettronica Ultrasuoni",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 20",
                    position: CGPoint(x: 0.655, y: 0.423),
                    size: CGSize(width: 0.028, height: 0.125),
                    description: "MOT - Microwave and Optical Technology",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "CUES",
                    position: CGPoint(x: 0.4136, y: 0.39),
                    size: CGSize(width: 0.0235, height: 0.14),
                    description: "Cooperativa universitaria - cartolibreria",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 12a",
                    position: CGPoint(x: 0.3845, y: 0.394),
                    size: CGSize(width: 0.0295, height: 0.145),
                    description: "Impianti industriali meccanici",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 12b",
                    position: CGPoint(x: 0.3533, y: 0.394),
                    size: CGSize(width: 0.0295, height: 0.145),
                    description: "Impianti industriali meccanici",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 10",
                    position: CGPoint(x: 0.279, y: 0.394),
                    size: CGSize(width: 0.062, height: 0.145),
                    description: "Disegno e metodi per l'ingengeria industriale",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 2",
                    position: CGPoint(x: 0.0873, y: 0.396),
                    size: CGSize(width: 0.0355, height: 0.145),
                    description: "Proprietà termodinamiche e di trasporto",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 4",
                    position: CGPoint(x: 0.1175, y: 0.396),
                    size: CGSize(width: 0.022, height: 0.145),
                    description: "Caratterizzazione chimico-fisica",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab T0",
                    position: CGPoint(x: 0.144, y: 0.396),
                    size: CGSize(width: 0.026, height: 0.145),
                    description: "Laboratorio analisi dei materiali",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 6",
                    position: CGPoint(x: 0.179, y: 0.396),
                    size: CGSize(width: 0.039, height: 0.145),
                    description: "Laboratorio analisi dei materiali",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 8",
                    position: CGPoint(x: 0.2107, y: 0.396),
                    size: CGSize(width: 0.0204, height: 0.145),
                    description: "Fluidi supercritici",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula Ex-Cues",
                    position: CGPoint(x: 0.4585, y: 0.3765),
                    size: CGSize(width: 0.063, height: 0.085),
                    description: "Aula elettrificata con prese per ogni banco",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula Studio",
                    position: CGPoint(x: 0.461, y: 0.6328),
                    size: CGSize(width: 0.067, height: 0.073),
                    description: "De Candida - orario: 09:00-13:00 - 15:00-18:00",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 14",
                    position: CGPoint(x: 0.3845, y: 0.576),
                    size: CGSize(width: 0.0295, height: 0.12),
                    description: "Trasmissione del calore",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 14",
                    position: CGPoint(x: 0.3533, y: 0.576),
                    size: CGSize(width: 0.0295, height: 0.12),
                    description: "Tecniche del freddo",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 15",
                    position: CGPoint(x: 0.532, y: 0.605),
                    size: CGSize(width: 0.032, height: 0.145),
                    description: "MISTRAL - Misure, Strumentazione ed algoritmi",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 15/1",
                    position: CGPoint(x: 0.5645, y: 0.605),
                    size: CGSize(width: 0.028, height: 0.145),
                    description: "Power system",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 17",
                    position: CGPoint(x: 0.623, y: 0.605),
                    size: CGSize(width: 0.0293, height: 0.145),
                    description: "tecnologie elettriche/circuiti elettrici di potenza",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 18/1",
                    position: CGPoint(x: 0.655, y: 0.605),
                    size: CGSize(width: 0.0293, height: 0.145),
                    description: "MIVIA",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Laboratorio T25 - Informatica di base",
                    position: CGPoint(x: 0.7229, y: 0.605),
                    size: CGSize(width: 0.0515, height: 0.145),
                    description: "Laboratorio con Pc",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Laboratorio T26",
                    position: CGPoint(x: 0.818, y: 0.605),
                    size: CGSize(width: 0.06, height: 0.145),
                    description: "Laboratorio di Ingegneria edile-architettura",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "SI",
                    position: CGPoint(x: 0.773, y: 0.605),
                    size: CGSize(width: 0.025, height: 0.145),
                    description: "Sede Studenti Ingegneria",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 9",
                    position: CGPoint(x: 0.264, y: 0.576),
                    size: CGSize(width: 0.0295, height: 0.12),
                    description: "termodinamica applicata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 11",
                    position: CGPoint(x: 0.295, y: 0.576),
                    size: CGSize(width: 0.0295, height: 0.12),
                    description: "fisica tecnica ambientale",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 1",
                    position: CGPoint(x: 0.0829, y: 0.576),
                    size: CGSize(width: 0.0292, height: 0.12),
                    description: "Trasmissione del calore",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 2",
                    position: CGPoint(x: 0.1146, y: 0.576),
                    size: CGSize(width: 0.0292, height: 0.12),
                    description: "proprietà termodinamiche",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 5a",
                    position: CGPoint(x: 0.1815, y: 0.576),
                    size: CGSize(width: 0.014, height: 0.12),
                    description: "fenomeni di trasporto in farmacologia",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 5b",
                    position: CGPoint(x: 0.165, y: 0.576),
                    size: CGSize(width: 0.014, height: 0.12),
                    description: "industrial microbiology",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 7",
                    position: CGPoint(x: 0.206, y: 0.576),
                    size: CGSize(width: 0.0295, height: 0.12),
                    description: "tecnologie alimentari",
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
                    description: "Aula elettrificata con lavagna interattiva",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 133",
                    position: CGPoint(x: 0.5278, y: 0.365),
                    size: CGSize(width: 0.0268, height: 0.1),
                    description: "Aula non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 136",
                    position: CGPoint(x: 0.5576, y: 0.365),
                    size: CGSize(width: 0.0286, height: 0.1),
                    description: "Aula non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 134",
                    position: CGPoint(x: 0.526, y: 0.5),
                    size: CGSize(width: 0.017, height: 0.1),
                    description: "Aula elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab Salvatore Bellone",
                    position: CGPoint(x: 0.555, y: 0.5),
                    size: CGSize(width: 0.035, height: 0.1),
                    description: "Laboratorio Salvatore Bellone",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 137",
                    position: CGPoint(x: 0.5446, y: 0.638),
                    size: CGSize(width: 0.0547, height: 0.1),
                    description: "Non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Sala videoconferenze",
                    position: CGPoint(x: 0.614, y: 0.478),
                    size: CGSize(width: 0.024, height: 0.055),
                    description: "Sala videoconferenze",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Archivio 1",
                    position: CGPoint(x: 0.614, y: 0.53),
                    size: CGSize(width: 0.024, height: 0.035),
                    description: "Archivio 1",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Easy 1",
                    position: CGPoint(x: 0.461, y: 0.6605),
                    size: CGSize(width: 0.067, height: 0.031),
                    description: "Aula Studio - orario: 09:00-13:00 15:00-18:00",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula Mangrella - Teledottorato",
                    position: CGPoint(x: 0.6465, y: 0.5),
                    size: CGSize(width: 0.036, height: 0.1),
                    description: "Aula Maurizio Mangrella",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 143",
                    position: CGPoint(x: 0.6248, y: 0.3645),
                    size: CGSize(width: 0.044, height: 0.098),
                    description: "Laboratorio 143",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 054",
                    position: CGPoint(x: 0.6578, y: 0.3645),
                    size: CGSize(width: 0.017, height: 0.098),
                    description: "Energy Storage and Energy source",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Ufficio Tortorella",
                    position: CGPoint(x: 0.659, y: 0.638),
                    size: CGSize(width: 0.017, height: 0.1),
                    description: "Ufficio Francesco Tortorella",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "147",
                    position: CGPoint(x: 0.641, y: 0.638),
                    size: CGSize(width: 0.014, height: 0.1),
                    description: "Ufficio Cinzia Forgione",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "148",
                    position: CGPoint(x: 0.625, y: 0.638),
                    size: CGSize(width: 0.014, height: 0.1),
                    description: "Ufficio tirocinio - Distretto 2",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Ufficio Percannella",
                    position: CGPoint(x: 0.609, y: 0.638),
                    size: CGSize(width: 0.013, height: 0.1),
                    description: "Ufficio Gennaro Percannella",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab Know mis",
                    position: CGPoint(x: 0.699, y: 0.638),
                    size: CGSize(width: 0.015, height: 0.1),
                    description: "Lab KNOWLEDGE MANAGEMENT AND INFORMATION SYSTEMS - Matteo Gaeta",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "S^3",
                    position: CGPoint(x: 0.7163, y: 0.638),
                    size: CGSize(width: 0.013, height: 0.1),
                    description: "Lab - SECURITY, SEMANTICS AND SOCIAL NETWORKS",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 161",
                    position: CGPoint(x: 0.74, y: 0.638),
                    size: CGSize(width: 0.0294, height: 0.1),
                    description: "Laboratorio Didattico Software",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Computer Science Lab",
                    position: CGPoint(x: 0.705, y: 0.5),
                    size: CGSize(width: 0.0245, height: 0.1),
                    description: "Computer Science Lab",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Embedded Intelligent System",
                    position: CGPoint(x: 0.737, y: 0.5),
                    size: CGSize(width: 0.035, height: 0.1),
                    description: "Embedded Intelligent System",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 155",
                    position: CGPoint(x: 0.7965, y: 0.5),
                    size: CGSize(width: 0.025, height: 0.1),
                    description: "InBit - Intelligent Bioengineering Technologies",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 167 - Sala Seminari Graffi",
                    position: CGPoint(x: 0.829, y: 0.5),
                    size: CGSize(width: 0.0368, height: 0.1),
                    description: "Sala Seminari",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 166",
                    position: CGPoint(x: 0.832, y: 0.638),
                    size: CGSize(width: 0.031, height: 0.105),
                    description: "Laboratorio didattico sistemi",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 163",
                    position: CGPoint(x: 0.7915, y: 0.638),
                    size: CGSize(width: 0.013, height: 0.105),
                    description: "Lab 163",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab calcolo e servizi",
                    position: CGPoint(x: 0.7915, y: 0.365),
                    size: CGSize(width: 0.013, height: 0.1),
                    description: "Centro di calcolo e servizi di rete",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab controllo",
                    position: CGPoint(x: 0.807, y: 0.365),
                    size: CGSize(width: 0.013, height: 0.1),
                    description: "Ingegneria del controllo",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab sim e ottimizzazione",
                    position: CGPoint(x: 0.832, y: 0.365),
                    size: CGSize(width: 0.031, height: 0.1),
                    description: "Simulazione ed ottimizzazione",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 129",
                    position: CGPoint(x: 0.37, y: 0.633),
                    size: CGSize(width: 0.065, height: 0.095),
                    description: "Aula elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 126",
                    position: CGPoint(x: 0.369, y: 0.36),
                    size: CGSize(width: 0.063, height: 0.1),
                    description: "Aula non elettrificata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula Multimediale 132",
                    position: CGPoint(x: 0.3855, y: 0.498),
                    size: CGSize(width: 0.0315, height: 0.098),
                    description: "Aula 132",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula Studio 130",
                    position: CGPoint(x: 0.353, y: 0.498),
                    size: CGSize(width: 0.0313, height: 0.098),
                    description: "Aula Studio - orario: 09:00-13:00 15:00-18:00",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Laboratorio 118 - Grafica computerizzata",
                    position: CGPoint(x: 0.27, y: 0.36),
                    size: CGSize(width: 0.047, height: 0.1),
                    description: "Grafica computerizzata",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 120",
                    position: CGPoint(x: 0.302, y: 0.36),
                    size: CGSize(width: 0.013, height: 0.1),
                    description: "Segreteria Codic - CodiMeg",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Stanza 91",
                    position: CGPoint(x: 0.3016, y: 0.633),
                    size: CGSize(width: 0.0123, height: 0.089),
                    description: "stanza 91",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Stanza 34",
                    position: CGPoint(x: 0.2863, y: 0.633),
                    size: CGSize(width: 0.0125, height: 0.089),
                    description: "Ufficio - Stanza 34 - ELISA DE CHIARA - VINCENZO CUTRONEO - STEFANIA GRANATO",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Stanza 35",
                    position: CGPoint(x: 0.27, y: 0.633),
                    size: CGSize(width: 0.0124, height: 0.089),
                    description: "Ufficio Domenico Gentiluomo",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Stanza 36",
                    position: CGPoint(x: 0.2534, y: 0.633),
                    size: CGSize(width: 0.018, height: 0.089),
                    description: "Ufficio Consolatina Liguori",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "114",
                    position: CGPoint(x: 0.212, y: 0.633),
                    size: CGSize(width: 0.0135, height: 0.089),
                    description: "Direttore Dip. Ing civile",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "115",
                    position: CGPoint(x: 0.196, y: 0.633),
                    size: CGSize(width: 0.0135, height: 0.089),
                    description: "",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "116",
                    position: CGPoint(x: 0.18, y: 0.633),
                    size: CGSize(width: 0.0135, height: 0.089),
                    description: "",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "117",
                    position: CGPoint(x: 0.164, y: 0.633),
                    size: CGSize(width: 0.0135, height: 0.089),
                    description: "Ufficio - Carla Sodano",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "110",
                    position: CGPoint(x: 0.122, y: 0.633),
                    size: CGSize(width: 0.0135, height: 0.089),
                    description: "Ufficio - Francesco Marra",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "109",
                    position: CGPoint(x: 0.106, y: 0.633),
                    size: CGSize(width: 0.0135, height: 0.089),
                    description: "Ufficio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "108",
                    position: CGPoint(x: 0.09, y: 0.633),
                    size: CGSize(width: 0.0135, height: 0.089),
                    description: "Ufficio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "107",
                    position: CGPoint(x: 0.0725, y: 0.633),
                    size: CGSize(width: 0.0147, height: 0.089),
                    description: "Ufficio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "104",
                    position: CGPoint(x: 0.122, y: 0.36),
                    size: CGSize(width: 0.0135, height: 0.1),
                    description: "Ufficio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "103",
                    position: CGPoint(x: 0.106, y: 0.36),
                    size: CGSize(width: 0.0135, height: 0.1),
                    description: "Ufficio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "102",
                    position: CGPoint(x: 0.09, y: 0.36),
                    size: CGSize(width: 0.0135, height: 0.1),
                    description: "Ufficio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "101",
                    position: CGPoint(x: 0.0725, y: 0.36),
                    size: CGSize(width: 0.0147, height: 0.1),
                    description: "Ufficio",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Spazio per attivita' complementari_119",
                    position: CGPoint(x: 0.26, y: 0.498),
                    size: CGSize(width: 0.025, height: 0.1),
                    description: "",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Sala 125 'Biblioteca Berardi'",
                    position: CGPoint(x: 0.292, y: 0.498),
                    size: CGSize(width: 0.035, height: 0.1),
                    description: "Stanza 32 - Biblioteca Berardi",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula Studio 113",
                    position: CGPoint(x: 0.2065, y: 0.498),
                    size: CGSize(width: 0.025, height: 0.1),
                    description: "Ingegneria Civile - Aula studio 113 - orario: 09:00-13:30 15:00-18:30",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab IsThos",
                    position: CGPoint(x: 0.201, y: 0.36),
                    size: CGSize(width: 0.036, height: 0.1),
                    description: "Lab IsThos",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab 111/1",
                    position: CGPoint(x: 0.169, y: 0.36),
                    size: CGSize(width: 0.023, height: 0.1),
                    description: "Lab 111/1",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Aula 105",
                    position: CGPoint(x: 0.116, y: 0.498),
                    size: CGSize(width: 0.024, height: 0.1),
                    description: "Aula 105",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Spazio per attivita' complementari_106",
                    position: CGPoint(x: 0.0835, y: 0.498),
                    size: CGSize(width: 0.0353, height: 0.1),
                    description: "Aula 106",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Easy 2",
                    position: CGPoint(x: 0.045, y: 0.498),
                    size: CGSize(width: 0.0125, height: 0.195),
                    description: "Aula studio - orario: 09:00-13:00 15:00-18:00",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Spazio per attivita' complementari_112",
                    position: CGPoint(x: 0.174, y: 0.498),
                    size: CGSize(width: 0.035, height: 0.1),
                    description: "Aula 112",
                    buildingName: "E"
                ),
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
                    description: "Aula con Pc",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula N",
                    position: CGPoint(x: 0.654, y: 0.759),
                    size: CGSize(width: 0.212, height: 0.105),
                    description: "Aula non elettrificata",
                    buildingName: "E1"
                ),
                RoomImage(
                    name: "Aula 102 - CAD",
                    position: CGPoint(x: 0.654, y: 0.651),
                    size: CGSize(width: 0.212, height: 0.095),
                    description: "Aula con pc",
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
                    name: "Aula B",
                    position: CGPoint(x: 0.607, y: 0.384),
                    size: CGSize(width: 0.176, height: 0.17),
                    description: "Aula non elettrificata",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula A",
                    position: CGPoint(x: 0.615, y: 0.645),
                    size: CGSize(width: 0.16, height: 0.17),
                    description: "Aula non elettrificata",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula C",
                    position: CGPoint(x: 0.354, y: 0.388),
                    size: CGSize(width: 0.185, height: 0.185),
                    description: "Aula elettrificata con prese sotto i banchi",
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
                    description: "Aula elettrificata",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula H",
                    position: CGPoint(x: 0.632, y: 0.67),
                    size: CGSize(width: 0.21, height: 0.217),
                    description: "Aula elettrificata",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula L",
                    position: CGPoint(x: 0.323, y: 0.427),
                    size: CGSize(width: 0.22, height: 0.11),
                    description: "Aula non elettrificata",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula M",
                    position: CGPoint(x: 0.323, y: 0.308),
                    size: CGSize(width: 0.219, height: 0.11),
                    description: "Aula non elettrificata",
                    buildingName: "E2"
                )
            ]
        )
        return Building(
            name: "E2",
            floors: [floor0, floor1])
    }
    
    private func createBuildingF2() -> Building {
        let floorm1 = Floor(
            number: -1,
            name: "Sottoscala",
            imageName: "edificio_f2_piano_-1",
            rooms: [
                RoomImage(
                    name: "LAB CASA",
                    position: CGPoint(x: 0.3894, y: 0.2293),
                    size: CGSize(width: 0.1415, height: 0.1540),
                    description: "Context Area Security Analytics",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Laboratorio di Matematica",
                    position: CGPoint(x: 0.5086, y: 0.2701),
                    size: CGSize(width: 0.0853, height: 0.2375),
                    description: "Laboratorio di Matematica",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "L12",
                    position: CGPoint(x: 0.6355, y: 0.2475),
                    size: CGSize(width: 0.1480, height: 0.1940),
                    description: "Laboratorio 12",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Laboratorio L11",
                    position: CGPoint(x: 0.8039, y: 0.2695),
                    size: CGSize(width: 0.1722, height: 0.2385),
                    description: "Laboratorio 11",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "CG Lab",
                    position: CGPoint(x: 0.7672, y: 0.4367),
                    size: CGSize(width: 0.2392, height: 0.0777),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Lab GIS",
                    position: CGPoint(x: 0.7695, y: 0.5760),
                    size: CGSize(width: 0.2406, height: 0.1845),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Laboratorio Sammet",
                    position: CGPoint(x: 0.7211, y: 0.7913),
                    size: CGSize(width: 0.3416, height: 0.2349),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Laboratorio Hopper",
                    position: CGPoint(x: 0.3034, y: 0.7949),
                    size: CGSize(width: 0.3394, height: 0.2277),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "CORSIA",
                    position: CGPoint(x: 0.2510, y: 0.6273),
                    size: CGSize(width: 0.2358, height: 0.0915),
                    description: "Consorzio Di Ricerca Sistemi ad Agenti",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "SESE Lab",
                    position: CGPoint(x: 0.2128, y: 0.4149),
                    size: CGSize(width: 0.1558, height: 0.1337),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                )
            ]
        )
        
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_f2_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula F1",
                    position: CGPoint(x: 0.4837, y: 0.2487),
                    size: CGSize(width: 0.2344, height: 0.1281),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Aula F2",
                    position: CGPoint(x: 0.7475, y: 0.2379),
                    size: CGSize(width: 0.2811, height: 0.1078),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Aula F3",
                    position: CGPoint(x: 0.7701, y: 0.3525),
                    size: CGSize(width: 0.2339, height: 0.1042),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Aula F4",
                    position: CGPoint(x: 0.7838, y: 0.5005),
                    size: CGSize(width: 0.2096, height: 0.1729),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Aula F5",
                    position: CGPoint(x: 0.8078, y: 0.7252),
                    size: CGSize(width: 0.1617, height: 0.2559),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Aula F6",
                    position: CGPoint(x: 0.6585, y: 0.7497),
                    size: CGSize(width: 0.1241, height: 0.2081),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Aula F7",
                    position: CGPoint(x: 0.5165, y: 0.7484),
                    size: CGSize(width: 0.1498, height: 0.2112),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                ),
                RoomImage(
                    name: "Aula F8",
                    position: CGPoint(x: 0.3271, y: 0.7251),
                    size: CGSize(width: 0.2086, height: 0.2567),
                    description: "Nessuna Descrizione",
                    buildingName: "F2"
                )
            ]
        )
        
        return Building(
            name: "F2",
            floors: [floorm1,floor0])
    }
    
    private func createBuildingF3() -> Building {
        let floorm1 = Floor(
            number: -1,
            name: "Sottoscala",
            imageName: "edificio_f3_piano_-1",
            rooms: [
                RoomImage(
                    name: "Aula P1 - Aula Magna G. Sodano",
                    position: CGPoint(x: 0.6195, y: 0.4111),
                    size: CGSize(width: 0.1970, height: 0.1934),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P0",
                    position: CGPoint(x: 0.6187, y: 0.5433),
                    size: CGSize(width: 0.1977, height: 0.0559),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P2",
                    position: CGPoint(x: 0.6193, y: 0.6744),
                    size: CGSize(width: 0.1981, height: 0.1894),
                    description: "",
                    buildingName: "F3"
                )
            ]
        )
        
        let floor0 = Floor(
            number: 0,
            name: "Piano Terra",
            imageName: "edificio_f3_piano_0",
            rooms: [
                RoomImage(
                    name: "Aula P6",
                    position: CGPoint(x: 0.6134, y: 0.6769),
                    size: CGSize(width: 0.1599, height: 0.1042),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P5 - M. Transirico",
                    position: CGPoint(x: 0.6129, y: 0.5636),
                    size: CGSize(width: 0.1603, height: 0.1026),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P4 - Marinaro",
                    position: CGPoint(x: 0.6130, y: 0.4044),
                    size: CGSize(width: 0.1621, height: 0.1981),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P3 - Parmenter",
                    position: CGPoint(x: 0.3641, y: 0.4013),
                    size: CGSize(width: 0.2014, height: 0.1886),
                    description: "",
                    buildingName: "F3"
                )
            ]
        )
        
        let floor1 = Floor(
            number: 1,
            name: "Primo Piano",
            imageName: "edificio_f3_piano_1",
            rooms: [
                RoomImage(
                    name: "Aula P10",
                    position: CGPoint(x: 0.3672, y: 0.4545),
                    size: CGSize(width: 0.1977, height: 0.0775),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P9",
                    position: CGPoint(x: 0.3071, y: 0.3577),
                    size: CGSize(width: 0.0791, height: 0.0986),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P8",
                    position: CGPoint(x: 0.4082, y: 0.3466),
                    size: CGSize(width: 0.1089, height: 0.0774),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P7",
                    position: CGPoint(x: 0.6364, y: 0.3455),
                    size: CGSize(width: 0.1914, height: 0.0761),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P11",
                    position: CGPoint(x: 0.6324, y: 0.4438),
                    size: CGSize(width: 0.1977, height: 0.1016),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Laboratorio P12 - Multimediale",
                    position: CGPoint(x: 0.6321, y: 0.5601),
                    size: CGSize(width: 0.1972, height: 0.1124),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Laboratorio P13",
                    position: CGPoint(x: 0.6329, y: 0.6980),
                    size: CGSize(width: 0.1954, height: 0.1474),
                    description: "",
                    buildingName: "F3"
                )
            ]
        )
        
        let floor2 = Floor(
            number: 2,
            name: "Secondo Piano",
            imageName: "edificio_f3_piano_2",
            rooms: [
                RoomImage(
                    name: "Aula P17",
                    position: CGPoint(x: 0.3160, y: 0.4448),
                    size: CGSize(width: 0.0957, height: 0.0970),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "SAC18",
                    position: CGPoint(x: 0.4187, y: 0.4338),
                    size: CGSize(width: 0.0957, height: 0.0750),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "SAC19",
                    position: CGPoint(x: 0.5870, y: 0.4398),
                    size: CGSize(width: 0.1108, height: 0.0864),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P20",
                    position: CGPoint(x: 0.5872, y: 0.5393),
                    size: CGSize(width: 0.1091, height: 0.0916),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P21",
                    position: CGPoint(x: 0.5876, y: 0.6379),
                    size: CGSize(width: 0.1098, height: 0.0874),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P14",
                    position: CGPoint(x: 0.7027, y: 0.4460),
                    size: CGSize(width: 0.0544, height: 0.1058),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P15",
                    position: CGPoint(x: 0.7044, y: 0.6343),
                    size: CGSize(width: 0.0544, height: 0.1002),
                    description: "",
                    buildingName: "F3"
                ),
                RoomImage(
                    name: "Aula P16",
                    position: CGPoint(x: 0.5880, y: 0.7428),
                    size: CGSize(width: 0.1126, height: 0.0560),
                    description: "",
                    buildingName: "F3"
                )
            ]
        )
        
        return Building(
            name: "F3",
            floors: [floorm1,floor0,floor1,floor2]
            )
    }
    
}

