//
//  Sessione.swift
//  loginRegServer
//
//  Created by Lorenzo Campagna on 26/06/25.
//

import Foundation

struct UserSession: Codable {
    let nome: String
    let email: String
    let isAuthenticated: Bool
    let immagineProfilo: String?
}

class UserSessionManager {
    static let shared = UserSessionManager()
    private init() {}

    let fileName = "utente.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    func scriviJSON(nome: String, email: String) {
        let session = UserSession(nome: nome, email: email, isAuthenticated: true, immagineProfilo: nil)
        if let data = try? JSONEncoder().encode(session) {
            try? data.write(to: fileURL)
        }
    }

    func leggiSessione() -> UserSession? {
        guard let data = try? Data(contentsOf: fileURL),
              let session = try? JSONDecoder().decode(UserSession.self, from: data) else {
            return nil
        }
        return session
    }

    func isLoggedIn() -> Bool {
        leggiSessione()?.isAuthenticated == true
    }
    
    func salvaImmagineProfilo(nomeFile: String) {
        guard let session = leggiSessione() else { return }

        // aggiorna solo il campo immagine
        let nuovaSessione = UserSession(
            nome: session.nome,
            email: session.email,
            isAuthenticated: session.isAuthenticated,
            immagineProfilo: nomeFile
        )

        if let data = try? JSONEncoder().encode(nuovaSessione) {
            try? data.write(to: fileURL)
        }
    }
}
