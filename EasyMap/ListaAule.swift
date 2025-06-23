//
//  ListaAule.swift
//  EasyMap
//
//  Created by Lorenzo Campagna on 23/06/25.
//

import SwiftUI

struct ListaAule: View {
    
    var giornata: Giornata? = leggiJSON()
    
    var body: some View {
        NavigationStack{
            List{
                if var aule = giornata?.aule{
                    ForEach(aule.indices, id:\.self) { i in
                        var aula = aule[i]
                        if aula.edificio == "E" || aula.edificio == "E2" ||
                            aula.edificio == "E1"{
                            VStack(alignment: .leading) {
                                    Text(aula.nome)
                                   .font(.headline)
                               Text("Edificio: \(aula.edificio)")
                                   .font(.subheadline)
                           }
                        }
                    }
                } else {
                    Text("Nessuna aula trovata").foregroundColor(.red)
                }
            }.navigationTitle("lista aule")
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
}

// -> DATA ODIERNA <-
struct Giornata: Codable{
    var data: String
    var aule: [Aula]
}

// -> Legge dal JSON restituendo Giornata
// Giornata -> Aula -> Prenotazione
func leggiJSON() -> Giornata?{
    //Ricerca file nella directory
    guard let url = Bundle.main.url(forResource: "prenotazioni", withExtension: "json") else {
        print("File non Trovato")
        return nil
    }
    
    do{
        //Decodifica il JSON
        var data = try Data(contentsOf: url)
        var decoder = JSONDecoder()
        //Inserisce in
        var giornata = try decoder.decode(Giornata.self, from: data)
        return giornata
    } catch {
        print("Errore nella lettura")
        return nil
    }
}

#Preview {
    ListaAule()
}
