//
//  Sessione.swift
//  loginRegServer
//
//  Created by  Francesco Apicella on 26/06/25.
//

import Foundation
import UIKit

// MARK: - Modelli dati

struct AnnuncioCodificabile: Codable, Identifiable, Equatable {
    let id: Int
    let titolo: String
    let descrizione: String
    let data: Date
    let luogo: String
    let autore: String
    let categoria: String
    let immagineData: Data?

    static func == (lhs: AnnuncioCodificabile, rhs: AnnuncioCodificabile) -> Bool {
        lhs.id == rhs.id
    }
}

struct UserSession: Codable {
    let nome: String
    let email: String
    let isAuthenticated: Bool
    let immagineProfilo: String?
    var preferiti: [AnnuncioCodificabile]
}

// MARK: - Gestione sessione utente

class UserSessionManager {
    static let shared = UserSessionManager()
    private init() {}

    let fileName = "utente.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    func scriviJSON(nome: String, email: String) {
        let session = UserSession(nome: nome, email: email, isAuthenticated: true, immagineProfilo: nil, preferiti: [])
        if let data = try? JSONEncoder().encode(session) {
            try? data.write(to: fileURL)
        }
    }
    
    func salvaPost(_ annuncio: Annuncio) {
        guard var session = leggiSessione() else { return }

        let immagineData = annuncio.immagini.first?.jpegData(compressionQuality: 0.8)

        let codificabile = AnnuncioCodificabile(
            id: annuncio.id.hashValue,
            titolo: annuncio.titolo,
            descrizione: annuncio.descrizione,
            data: annuncio.data,
            luogo: annuncio.luogo,
            autore: annuncio.autore,
            categoria: annuncio.categoria.rawValue,
            immagineData: immagineData
        )

        if !session.preferiti.contains(codificabile) {
            session.preferiti.append(codificabile)
            if let data = try? JSONEncoder().encode(session) {
                try? data.write(to: fileURL)
            }
        }
    }

    func getPostSalvati() -> [Post] {
        guard let session = leggiSessione() else { return [] }

        return session.preferiti.map { fav in
            Post(
                id: String(fav.id),
                autore: fav.autore,
                contenuto: "\(fav.titolo)\n\(fav.descrizione)",
                dataCreazione: fav.data,
                immagine: nil,
                immagineUI: fav.immagineData.flatMap { UIImage(data: $0) },
                categoria: fav.categoria,
                luogo: fav.luogo
            )
        }
    }
    
    func leggiSessione() -> UserSession? {
        guard let data = try? Data(contentsOf: fileURL),
              let session = try? JSONDecoder().decode(UserSession.self, from: data) else {
            return nil
        }
        return session
    }
    
    func rimuoviPostSalvato(id: Int) {
        guard var session = leggiSessione() else { return }
        session.preferiti.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(session) {
            try? data.write(to: fileURL)
        }
    }

    func isLoggedIn() -> Bool {
        guard let session = leggiSessione() else { return false }
        return session.isAuthenticated
    }
    
    func clearSession() {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func salvaImmagineProfilo(nomeFile: String) {
        guard let session = leggiSessione() else { return }

        let nuovaSessione = UserSession(
            nome: session.nome,
            email: session.email,
            isAuthenticated: session.isAuthenticated,
            immagineProfilo: nomeFile,
            preferiti: session.preferiti
        )

        if let data = try? JSONEncoder().encode(nuovaSessione) {
            try? data.write(to: fileURL)
        }
    }
}

// MARK: - Gestione ricerche recenti

class SearchHistoryManager {
    static let shared = SearchHistoryManager()
    private init() {}

    private let fileName = "search_history.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    /// Salva una query nella cronologia (spostandola in cima e senza duplicati)
    func salva(query: String) {
        var history = leggi() ?? []

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedQuery.isEmpty {
            // rimuove duplicati
            history.removeAll { $0.lowercased() == trimmedQuery.lowercased() }
            history.insert(trimmedQuery, at: 0)

            // limita a massimo 10
            if history.count > 10 {
                history = Array(history.prefix(10))
            }

            if let data = try? JSONEncoder().encode(history) {
                try? data.write(to: fileURL)
            }
        }
    }

    /// Restituisce la cronologia
    func leggi() -> [String]? {
        guard let data = try? Data(contentsOf: fileURL),
              let history = try? JSONDecoder().decode([String].self, from: data) else {
            return nil
        }
        return history
    }

    /// Cancella una query specifica
    func cancella(query: String) {
        var history = leggi() ?? []
        history.removeAll { $0 == query }
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: fileURL)
        }
    }

    /// Cancella tutta la cronologia
    func cancellaTutto() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
