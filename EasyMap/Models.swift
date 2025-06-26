//
//  Models.swift
//  EasyMap
//
//  Created by Studente on 26/06/25.
//

import SwiftUI

enum CategoriaAnnuncio: String, CaseIterable, Identifiable {
    case evento = "Evento"
    case annuncio = "Annuncio"
    case spot = "Spot"
    case lavoro = "Lavoro"
    case info = "Info"
    case smarrimenti = "Smarrimenti"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .evento: return "calendar"
        case .annuncio: return "megaphone"
        case .spot: return "location"
        case .lavoro: return "briefcase"
        case .info: return "info"
        case .smarrimenti: return "questionmark"
        }
    }
    
    var color: Color {
        switch self {
        case .evento: return .blue
        case .annuncio: return .orange
        case .spot: return .green
        case .lavoro: return .purple
        case .info: return .cyan
        case .smarrimenti: return .red
        }
    }
}

struct Annuncio: Identifiable, Hashable {
    let id = UUID()
    let titolo: String
    let descrizione: String
    let data: Date
    let luogo: String
    let immagini: [UIImage]
    let autore: String
    let categoria: CategoriaAnnuncio
}
