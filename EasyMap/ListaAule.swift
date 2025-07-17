//
//  ListaAule.swift
//  EasyMap
//
//  Created by Lorenzo Campagna on 23/06/25.
//

import SwiftUI

struct Prenotazione: Codable{
    var orario  : String
    var corso   : String
    var docente : String
    var tipo    : String
}

struct Aula: Codable{
    var nome         : String
    var edificio     : String
    var posti        : Int
    var prenotazioni : [Prenotazione]
    var description  : String?
    
    func isOccupiedNow() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let now = dateFormatter.string(from: Date())
        
        for prenotazione in prenotazioni {
            let parts = prenotazione.orario.components(separatedBy: " - ")
            if parts.count == 2,
               let start = dateFormatter.date(from: parts[0].trimmingCharacters(in: .whitespaces)),
               let end = dateFormatter.date(from: parts[1].trimmingCharacters(in: .whitespaces)),
               let current = dateFormatter.date(from: now) {
                if current >= start && current <= end {
                    return true
                }
            }
        }
        return false
    }
}

struct Giornata: Codable{
    var data: String
    var aule: [Aula]
}

struct ListaAule: View {
    @State private var giornata: Giornata? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allRooms(), id: \.name) { room in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(room.name)
                                .font(.headline)
                            Spacer()
                            Circle()
                                .fill(colorForRoom(room))
                                .frame(width: 12, height: 12)
                        }
                        Text("Edificio: \(room.buildingName)")
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Lista Aule")
            .task {
                self.giornata = await leggiJSONDaURL()
                print("Aule caricate: \(giornata?.aule.count ?? 0)")
            }
        }
    }
    
    /// restituisce tutte le aule conosciute dei 3 edifici
    private func allRooms() -> [RoomImage] {
        let buildings = ["E", "E1", "E2"]
        var result: [RoomImage] = []
        for b in buildings {
            if let building = BuildingDataManager.shared.getBuilding(named: b) {
                for floor in building.floors {
                    result.append(contentsOf: floor.rooms)
                }
            }
        }
        return result
    }
    
    private func colorForRoom(_ room: RoomImage) -> Color {
        guard let giornata = giornata else {
            return .gray
        }
        if let aula = giornata.aule.first(where: {
            $0.nome.caseInsensitiveCompare(room.name) == .orderedSame &&
            $0.edificio.caseInsensitiveCompare(room.buildingName) == .orderedSame
        }) {
            return aula.isOccupiedNow() ? .red : .green
        } else {
            return .yellow
        }
    }
}


func salvaJSONNelDispositivo(_ giornata: Giornata) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(giornata) {
        do {
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = directoryURL.appendingPathComponent("giornata.json")
            
            try data.write(to: fileURL)
            print("File JSON salvato in: \(fileURL.path)")
        } catch {
            print("Errore nel salvataggio del file JSON: \(error)")
        }
    }
}

func leggiJSONDaURL() async -> Giornata? {
    guard let url = URL(string: "https://giotto.pythonanywhere.com/www/prenotazioni.json") else {
        print("URL non valido")
        return nil
    }
    if let giornata = leggiJSONDaFile() {
        let today = DateFormatter()
        today.dateFormat = "yyyy-MM-dd"
        let todayString = today.string(from: Date())
        
        let dataGiornata = DateNormalizer(giornata.data)
        let dataOggi = DateNormalizer(todayString)
        
        if dataGiornata == dataOggi {
            print("Utilizzo dati locali aggiornati per oggi: \(giornata.data)")
            return giornata
        } else {
            print("Dati locali non aggiornati (data: \(giornata.data), oggi: \(todayString))")
        }
    } else {
        print("Nessun dato locale trovato")
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let giornata = try decoder.decode(Giornata.self, from: data)
        print("Richiesta delle prenotazioni effettuata con successo")

        salvaJSONNelDispositivo(giornata)
        
        return giornata
    } catch {
        print("Errore nel caricamento JSON: \(error)")
        
        if let giornataLocale = leggiJSONDaFile() {
            print("Utilizzo dati locali come fallback dopo errore di rete")
            return giornataLocale
        }
        
        return nil
    }
}

func DateNormalizer(_ dataString: String) -> String {
    let formatters = [
        createDateFormatter("dd/MM/yyyy"),
        createDateFormatter("yyyy-MM-dd")
    ]
    
    for formatter in formatters {
        if let date = formatter.date(from: dataString) {
            let outputFormatter = createDateFormatter("yyyy-MM-dd")
            return outputFormatter.string(from: date)
        }
    }
    
    return dataString
}

func createDateFormatter(_ format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter
}

func leggiJSONDaFile() -> Giornata? {
    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = directoryURL.appendingPathComponent("giornata.json")
    
    if let data = try? Data(contentsOf: fileURL) {
        let decoder = JSONDecoder()
        do {
            let giornata = try decoder.decode(Giornata.self, from: data)
            print("File JSON letto correttamente dal dispositivo")
            return giornata
        } catch {
            print("Errore nella decodifica del file JSON: \(error)")
        }
    } else {
        print("File JSON non trovato sul dispositivo")
    }
    
    return nil
}

#Preview {
    ListaAule()
}
