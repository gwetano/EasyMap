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
            CampusMapView()

            VStack {
                Spacer()

                Button {
                    showSearchSheet.toggle()
                } label: {
                    HStack() {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        Text("Cerca aula...")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(11)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal, 15)
                   
                }
                .sheet(isPresented: $showSearchSheet) {
                    SearchView(shouldFocusOnAppear: true)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

#Preview {
    CampusMapWithSearch()
}
