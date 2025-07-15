//
//  CampusMapView.swift
//  EasyMap
//
//  Created by Studente on 21/06/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            CampusMapView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                Color(red: 184/255, green: 19/255, blue: 101/255)
                    .ignoresSafeArea()
                Image("easymap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
