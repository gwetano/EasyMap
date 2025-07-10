//
//  MensaPDFView.swift
//  EasyMap
//
//  Created by Lorenzo Campagna on 10/07/25.
//
import SwiftUI
import PDFKit

struct MensaPDFView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = true
    @State private var loadedURL: URL?

    var url: URL? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "E"
        let giorno = formatter.string(from: Date()).capitalized

        let isAfter3PM = Calendar.current.component(.hour, from: Date()) >= 15
        let tipo = isAfter3PM ? "cena" : "pranzo"
        let urlString = "https://giotto.pythonanywhere.com/menu_\(tipo)_\(giorno).pdf"
        return URL(string: urlString)
    }

    var body: some View {
        NavigationView {
            ZStack {
                if let url = loadedURL {
                    PDFKitView(url: url)
                        .navigationTitle("Menu Mensa")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Chiudi") {
                                    dismiss()
                                }
                            }
                        }
                }

                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Caricamento del menu...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.loadedURL = url
                self.isLoading = false
            }
        }
    }
}
