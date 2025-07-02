//
//  Models.swift
//  EasyMap
//
//  Created by Studente on 26/06/25.
//

import SwiftUI

enum CategoriaAnnuncio: String, CaseIterable, Identifiable {
    case evento = "Evento"
    case annuncio = "Annuncio"
    case spot = "Spot"
    case lavoro = "Lavoro"
    case info = "Info"
    case smarrimenti = "Smarrimenti"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .evento: return "calendar"
        case .annuncio: return "megaphone"
        case .spot: return "location"
        case .lavoro: return "briefcase"
        case .info: return "info"
        case .smarrimenti: return "questionmark"
        }
    }
    
    var color: Color {
        switch self {
        case .evento: return .blue
        case .annuncio: return .orange
        case .spot: return .green
        case .lavoro: return .purple
        case .info: return .cyan
        case .smarrimenti: return .red
        }
    }
}

struct Annuncio: Identifiable, Hashable {
    let id = UUID()
    let titolo: String
    let descrizione: String
    let data: Date
    let luogo: String
    let immagini: [UIImage]
    let autore: String
    let categoria: CategoriaAnnuncio
}

struct AnnuncioDTO: Codable, Identifiable {
    var id: Int
    var titolo: String
    var descrizione: String
    var data: String  // ISO string da server, es. "2025-07-02T14:30:00Z"
    var luogo: String
    var img_path: String?  // solo nome file
    var autore: String
    var categoria: String
}

extension AnnuncioDTO {
    func toAnnuncio(image: UIImage?) -> Annuncio {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let parsedDate = formatter.date(from: data) ?? Date()
        
        return Annuncio(
            titolo: titolo,
            descrizione: descrizione,
            data: parsedDate,
            luogo: luogo,
            immagini: image != nil ? [image!] : [],
            autore: autore,
            categoria: CategoriaAnnuncio(rawValue: categoria) ?? .info
        )
    }
}

func uploadAnnuncio(_ annuncio: Annuncio, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "https://giotto.pythonanywhere.com/api/annunci") else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()

    let dateString = ISO8601DateFormatter().string(from: annuncio.data)

    let fields: [String: String] = [
        "titolo": annuncio.titolo,
        "descrizione": annuncio.descrizione,
        "data": dateString,
        "luogo": annuncio.luogo,
        "autore": annuncio.autore,
        "categoria": annuncio.categoria.rawValue
    ]

    for (key, value) in fields {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    if let image = annuncio.immagini.first, let imageData = image.jpegData(compressionQuality: 0.7) {
        let filename = "\(UUID().uuidString).jpg"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
    }

    body.append("--\(boundary)--\r\n")
    request.httpBody = body

    URLSession.shared.dataTask(with: request) { _, response, error in
        DispatchQueue.main.async {
            completion(error == nil)
        }
    }.resume()
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

func fetchAnnunci(completion: @escaping ([Annuncio]) -> Void) {
    guard let url = URL(string: "https://giotto.pythonanywhere.com/api/annunci") else { return }

    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("Errore: \(error?.localizedDescription ?? "no data")")
            completion([])
            return
        }

        do {
            let decoder = JSONDecoder()
            let dtos = try decoder.decode([AnnuncioDTO].self, from: data)

            // carica immagini da img_path
            var annunci: [Annuncio] = []
            let group = DispatchGroup()

            for dto in dtos {
                group.enter()
                if let path = dto.img_path,
                   let imageURL = URL(string: "https://giotto.pythonanywhere.com/uploads/\(path)") {
                    URLSession.shared.dataTask(with: imageURL) { imgData, _, _ in
                        let image = imgData.flatMap { UIImage(data: $0) }
                        annunci.append(dto.toAnnuncio(image: image))
                        group.leave()
                    }.resume()
                } else {
                    annunci.append(dto.toAnnuncio(image: nil))
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("ANNUNCI CARICATI:", annunci.count)
                completion(annunci)
            }

        } catch {
            print("Errore parsing JSON: \(error)")
            completion([])
        }
    }.resume()
}
