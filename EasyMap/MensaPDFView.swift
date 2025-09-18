//
//  MensaPDFView.swift
//  EasyMap
//
//  Created by Lorenzo Campagna on 10/07/25.
//

import SwiftUI
import PDFKit

//MensaPDFView
struct MensaPDFView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = true
    @State private var loadedURL: URL?
    @State private var errorMessage: String?

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
                        Text("Sto cucinando...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }.toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Chiudi") {
                                dismiss()
                            }
                        }
                    }
                }
                
                if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Errore nel caricamento")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Riprova") {
                            loadMenu()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
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
            }
        }
        .onAppear {
            loadMenu()
        }
    }
    
    private func loadMenu() {
        guard let targetURL = url else {
            errorMessage = "URL non valido"
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        if let cachedURL = getCachedPDFURL(for: targetURL) {
            print("Utilizzo PDF cached: \(cachedURL.path)")
            loadedURL = cachedURL
            isLoading = false
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: targetURL)
                
                let savedURL = try savePDFToDevice(data: data, originalURL: targetURL)
                
                await MainActor.run {
                    loadedURL = savedURL
                    isLoading = false
                    print("PDF scaricato e salvato: \(savedURL.path)")
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Impossibile scaricare il menu: \(error.localizedDescription)"
                    isLoading = false
                    print("Errore nel download del PDF: \(error)")
                }
            }
        }
    }
    
    private func getCachedPDFURL(for url: URL) -> URL? {
        let fileName = generatePDFFileName(for: url)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if let creationDate = attributes[.creationDate] as? Date {
                    let calendar = Calendar.current
                    if calendar.isDate(creationDate, inSameDayAs: Date()) {
                        return fileURL
                    } else {
                        try FileManager.default.removeItem(at: fileURL)
                        print("PDF vecchio eliminato: \(fileURL.path)")
                    }
                }
            } catch {
                print("Errore nel controllo del file PDF: \(error)")
            }
        }
        
        return nil
    }
    
    private func savePDFToDevice(data: Data, originalURL: URL) throws -> URL {
        let fileName = generatePDFFileName(for: originalURL)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func generatePDFFileName(for url: URL) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        let fileName = url.lastPathComponent.replacingOccurrences(of: ".pdf", with: "")
        return "\(fileName)_\(today).pdf"
    }
}

//PDFKitView
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}

//PDFViewerView
struct PDFViewerView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Chiudi") {
                    dismiss()
                }
                .padding()
                .foregroundColor(.blue)
                Spacer()
            }

            Divider()

            PDFKitView(url: url)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}
