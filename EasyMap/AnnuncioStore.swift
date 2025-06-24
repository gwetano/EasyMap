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
    
    func aggiungi(_ annuncio: Annuncio) {
        annunci.insert(annuncio, at: 0)
    }
}
