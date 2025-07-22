//
//  AnnuncioStore.swift
//  EasyMap
//
//  Created by Francesco Apicella on 24/06/25.
//

import SwiftUI

class AnnuncioStore: ObservableObject {
    @Published var annunci: [Annuncio] = []

    func caricaDaServer() {
        fetchAnnunci { annunci in
            DispatchQueue.main.async {
                self.annunci = annunci
            }
        }
    }

    func aggiungi(_ annuncio: Annuncio) {
        self.annunci.append(annuncio)

        uploadAnnuncio(annuncio) { success in
            print(success ? "Inviato con successo" : "Errore nell'invio")
        }
    }
}
