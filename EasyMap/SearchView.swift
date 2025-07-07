//
//  SearchView.swift
//  EasyMap
//
//  Created by Francesco Apicella on 07/07/25.
//

import SwiftUI

struct SearchView: View {
    @State private var giornata: Giornata? = nil
    @State private var searchText: String = ""

    var shouldFocusOnAppear: Bool = false

    let edificiValidi: Set<String> = [
        "E", "E1", "E2", "D", "D1", "D2", "D3", "C", "C1", "C2", "B", "B1", "B2", "F", "F1", "F2", "F3"
    ]

    var filteredAule: [Aula] {
        guard let aule = giornata?.aule else { return [] }
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if query.isEmpty {
            return []
        } else {
            return aule.filter { aula in
                edificiValidi.contains(aula.edificio) &&
                aula.nome.lowercased().contains(query)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if giornata == nil {
                    ProgressView("Caricamento...")
                        .padding()
                } else if filteredAule.isEmpty {
                    if !searchText.isEmpty {
                        Text("Nessuna aula trovata.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    List(filteredAule, id: \.nome) { aula in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(aula.nome)
                                    .font(.headline)
                                Spacer()
                                Circle()
                                    .fill(aula.isOccupiedNow() ? .red : .green)
                                    .frame(width: 12, height: 12)
                            }
                            Text("Edificio: \(aula.edificio)")
                                .font(.subheadline)
                        }
                    }
                    .background(.ultraThinMaterial)
                }
            }
            .searchable(text: $searchText, prompt: "Cerca aula...")
            .padding(.bottom, 50)
            .task {
                self.giornata = await leggiJSONDaURL()
            }
        }
        .background(.ultraThinMaterial)
    }
}


#Preview {
    SearchView()
}

