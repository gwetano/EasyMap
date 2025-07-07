//
//  CampusMapWithSearch.swift
//  EasyMap
//
//  Created by Francesco Apicella on 07/07/25.
//

import SwiftUI

struct CampusMapWithSearch: View {
    @State private var showSearchSheet = false

    var body: some View {
        ZStack {
            CampusMapView() // la tua mappa

            VStack {
                Spacer()

                Button {
                    showSearchSheet.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Search for rooms…")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(16)
                    
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                   
                }

                .sheet(isPresented: $showSearchSheet) {
                    SearchView()
                        .presentationDetents([.medium, .large]) 
                        .presentationDragIndicator(.visible)
                        
                }
            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    CampusMapWithSearch()
}
