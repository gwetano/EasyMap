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
    
    // La vecchia logica dell'URL è stata spostata e migliorata in getMenuURL()
    
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
    
    // NUOVA LOGICA PER CALCOLARE L'URL CORRETTO
    private func getMenuURL() -> URL? {
        let calendar = Calendar(identifier: .iso8601)
        
        // --- IMPOSTAZIONI DI RIFERIMENTO ---
        // Stesso riferimento usato nello script Python
        guard let referenceDate = calendar.date(from: DateComponents(year: 2025, month: 10, day: 13)) else { return nil }
        let referenceWeekMenu = 3
        
        // --- CALCOLO ATTUALE ---
        let today = Date()
        
        // Troviamo il lunedì della settimana corrente e di quella di riferimento
        guard let currentMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let referenceMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate))
        else { return nil }

        // Calcoliamo le settimane trascorse
        guard let weeksPassed = calendar.dateComponents([.weekOfYear], from: referenceMonday, to: currentMonday).weekOfYear else { return nil }
        
        // Calcoliamo la settimana del menu (ciclo 1-4)
        let menuWeek = ((referenceWeekMenu - 1 + weeksPassed) % 4 + 4) % 4 + 1

        // Determiniamo il giorno e il tipo di pasto
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "E" // Es: "Lun", "Mar", etc.
        let dayAbbreviation = formatter.string(from: today).capitalized
        
        // Sabato e Domenica non hanno menu
        if dayAbbreviation == "Sab" || dayAbbreviation == "Dom" {
            errorMessage = "Nessun menu disponibile per oggi."
            return nil
        }
        
        let isDinner = calendar.component(.hour, from: today) >= 15
        
        // --- COSTRUZIONE DEL NOME FILE ---
        // Questa parte replica la struttura dei nomi file originali
        var fileName = ""
        if isDinner {
            // I nomi per la cena hanno una struttura diversa per le settimane 1/2 e 3/4
            if menuWeek == 1 || menuWeek == 2 {
                fileName = "\(menuWeek)aCena\(dayAbbreviation).pdf"
            } else {
                // Notare l'inversione Giorno/Cena per le settimane 3 e 4
                fileName = "\(menuWeek)a\(dayAbbreviation)Cena.pdf"
            }
        } else {
            // Pranzo ha una struttura consistente
            fileName = "\(menuWeek)aPra\(dayAbbreviation).pdf"
        }
        
        let urlString = "https://giotto.pythonanywhere.com/\(fileName)"
        return URL(string: urlString)
    }
    
    private func loadMenu() {
        // La logica di caricamento ora usa la nuova funzione
        guard let targetURL = getMenuURL() else {
            // L'errorMessage potrebbe essere già stato impostato da getMenuURL
            if errorMessage == nil {
                errorMessage = "URL non valido o menu non disponibile."
            }
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
                let (data, response) = try await URLSession.shared.data(from: targetURL)
                
                // Controlliamo se il server ha risposto con un errore (es. 404 Not Found)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                let savedURL = try savePDFToDevice(data: data, originalURL: targetURL)
                
                await MainActor.run {
                    loadedURL = savedURL
                    isLoading = false
                    print("PDF scaricato e salvato: \(savedURL.path)")
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Il menu di oggi non è ancora stato caricato o non è disponibile."
                    isLoading = false
                    print("Errore nel download del PDF: \(error)")
                }
            }
        }
    }
    
    // Le funzioni di caching qui sotto non necessitano di alcuna modifica
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
