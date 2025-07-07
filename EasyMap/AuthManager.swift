//
//  AuthManager.swift
//  EasyMap
//
//  Created by Lorenzo Campagna on 28/06/25.
//

import SwiftUI

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    init() {
        // Controlla lo stato di autenticazione all'avvio
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        isAuthenticated = UserSessionManager.shared.isLoggedIn()
    }
    
    func login() {
        isAuthenticated = true
    }
    
    func logout() {
        isAuthenticated = false
        // Opzionale: cancella anche i dati di sessione
        UserSessionManager.shared.clearSession()
    }
}
