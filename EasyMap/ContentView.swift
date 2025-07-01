//
//  CampusMapView.swift
//  EasyMap
//
//  Created by Studente on 21/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AnnuncioStore()

    var body: some View {
        //ListaAule()
        CampusMapView(store: store)
    }
}

#Preview {
    ContentView()
}
