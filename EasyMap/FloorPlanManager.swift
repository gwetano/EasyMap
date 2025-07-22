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
                    name: "Lab 25",
                    position: CGPoint(x: 0.7229, y: 0.605),
                    size: CGSize(width: 0.0515, height: 0.145),
                    description: "Laboratorio di Didattica di base T25",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Lab T-26",
                    position: CGPoint(x: 0.818, y: 0.605),
                    size: CGSize(width: 0.06, height: 0.145),
                    description: "Ingegneria edile-architettura",
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
                    name: "Lab 137",
                    position: CGPoint(x: 0.5446, y: 0.638),
                    size: CGSize(width: 0.0547, height: 0.1),
                    description: "Laboratorio 137",
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
                    name: "Aula Maurizio Mangrella",
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
                    description: "Ufficio Tortorella",
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
                    description: "Ufficio Percannella",
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
                    name: "Lab 167",
                    position: CGPoint(x: 0.829, y: 0.5),
                    size: CGSize(width: 0.0368, height: 0.1),
                    description: "Didattico Sistemi",
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
                    name: "Aula 118",
                    position: CGPoint(x: 0.27, y: 0.36),
                    size: CGSize(width: 0.047, height: 0.1),
                    description: "Aula 118 - multimediale",
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
                    name: "Aula 119",
                    position: CGPoint(x: 0.26, y: 0.498),
                    size: CGSize(width: 0.025, height: 0.1),
                    description: "",
                    buildingName: "E"
                ),
                RoomImage(
                    name: "Biblioteca Berardi",
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
                    name: "Aula 106",
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
                    name: "Aula 112",
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
                    name: "Aula B",
                    position: CGPoint(x: 0.607, y: 0.384),
                    size: CGSize(width: 0.176, height: 0.17),
                    description: "Aula per lezioni frontali con proiettore",
                    buildingName: "E2"
                ),
                RoomImage(
                    name: "Aula A",
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

