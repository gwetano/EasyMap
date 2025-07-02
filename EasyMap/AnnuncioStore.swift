//
//  AnnuncioStore.swift
//  EasyMap
//
//  Created by Francesco Apicella on 24/06/25.
//

import Foundation
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
        // lo aggiungi localmente
        self.annunci.append(annuncio)

        // e lo invii al server
        uploadAnnuncio(annuncio) { success in
            print(success ? "Inviato con successo" : "Errore nell'invio")
        }
    }
}
