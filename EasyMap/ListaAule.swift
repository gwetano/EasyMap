//
//  ListaAule.swift
//  EasyMap
//
//  Created by Lorenzo Campagna on 23/06/25.
//

import SwiftUI

struct ListaAule: View {
    @State private var giornata: Giornata? = nil
    
    var body: some View {
        NavigationStack {
            List {
                if let aule = giornata?.aule {
                    ForEach(aule.indices, id: \.self) { i in
                        let aula = aule[i]
                        if aula.edificio == "E" || aula.edificio == "E1" || aula.edificio == "E2" {
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
                    }
                } else {
                    Text("Caricamento in corso o nessuna aula trovata").foregroundColor(.gray)
                }
            }
            .navigationTitle("Lista Aule")
            .task {
                self.giornata = await leggiJSONDaURL()
                print("Aule caricate: \(giornata?.aule.count ?? 0)")
            }
        }
    }
}


// Definizione delle strutture

//  -> PRENOTAZIONE <-
struct Prenotazione: Codable{
    var orario  : String
    var corso   : String
    var docente : String
    var tipo    : String
}

// -> AULA <-
struct Aula: Codable{
    var nome         : String
    var edificio     : String
    var posti        : Int
    var prenotazioni : [Prenotazione]
    
    // Funzione per controllare se l'aula è occupata ora
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

// -> DATA ODIERNA <-
struct Giornata: Codable{
    var data: String
    var aule: [Aula]
}

// -> Legge dal JSON restituendo Giornata
// Giornata -> Aula -> Prenotazione
func leggiJSONDaURL() async -> Giornata? {
    guard let url = URL(string: "https://giotto.pythonanywhere.com/www/prenotazioni.json") else {
        print("URL non valido")
        return nil
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        print("Dati JSON grezzi: \(String(data: data, encoding: .utf8) ?? "N/D")")
        let decoder = JSONDecoder()
        let giornata = try decoder.decode(Giornata.self, from: data)
        return giornata
    } catch {
        print("Errore nel caricamento JSON: \(error)")
        return nil
    }
}



#Preview {
    ListaAule()
}
