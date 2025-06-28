//
//  EasyMapApp.swift
//  EasyMap
//
//  Created by Studente on 21/06/25.
//

import SwiftUI

@main
struct EasyMapApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            CampusMapView()
                .environmentObject(authManager)
        }
    }
}
