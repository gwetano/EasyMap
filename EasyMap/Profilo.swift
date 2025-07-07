//
//  Profilo.swift
//  loginRegServer
//
//  Created by Lorenzo Campagna on 26/06/25.
//

import SwiftUI
import PhotosUI

struct Profilo: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var user = UserSessionManager.shared.leggiSessione()
    
    @State private var mostraCamera = false
    @State private var mostraGalleria = false
    @State private var immaginiProfilo: [UIImage] = []
    
    @State private var showImageSourceDialog : Bool = false
    
    // Nuovi stati per i post salvati
    @State private var postSalvati: [Post] = []
    @State private var postEspanso: Post? = nil
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack{
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .padding()
                    }.padding()
                    Spacer()
                }
                
                // Immagine profilo
                if let image = profileImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                }
                
                // Bottone modifica immagine
                Button("Modifica Foto") {
                    showImageSourceDialog = true
                }
                .confirmationDialog("Aggiungi da", isPresented: $showImageSourceDialog, titleVisibility: .visible) {
                    Button("Camera") {
                        mostraCamera = true
                    }
                    Button("Foto") {
                        mostraGalleria = true
                    }
                    Button("Annulla", role: .cancel) {}
                }
                
                /* Mostra nome utente */
                if let nome = user?.nome {
                    Text(nome)
                        .font(.title)
                        .bold()
                }
                
                /* Sezione postSalvati*/
                salvatiView()
            }
            .padding()
        }
        .onAppear {
            if let imageName = user?.immagineProfilo, !imageName.isEmpty{
                let path = getDocumentsDirectory().appendingPathComponent(imageName)
                if let uiImage = UIImage(contentsOfFile: path.path) {
                    profileImage = Image(uiImage: uiImage)
                }else {
                    profileImage = Image(systemName: "person.crop.circle")
                }
            }else{
                profileImage = Image(systemName: "person.crop.circle")
            }
            
            // Carica i post salvati
            caricaPostSalvati()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $mostraCamera) {
            CameraPicker(immagini: $immaginiProfilo)
                .onDisappear{
                    aggiornaFoto()
                }
        }.sheet(isPresented: $mostraGalleria){
            ImagePicker(immagini: $immaginiProfilo)
                .onDisappear{
                    aggiornaFoto()
                }
        }
        // Sheet per post espanso
        .sheet(item: $postEspanso) { post in
            PostEspansoView(post: post)
        }.onChange(of: postEspanso) { nuovoValore in
            if nuovoValore == nil {
                caricaPostSalvati()
            }
        }
    }

    func salvatiView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Post salvati")
                .font(.headline)
                .padding(.horizontal)
            
            if postSalvati.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bookmark")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Nessun post salvato")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(postSalvati) { post in
                        PostAnteprimaView(post: post) {
                            postEspanso = post
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
        
    func aggiornaFoto() {
        guard let nuovaImmagine = immaginiProfilo.first else { return }

        let fileName = "profile.png"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let imageData = nuovaImmagine.pngData() {
            try? imageData.write(to: url)
            UserSessionManager.shared.salvaImmagineProfilo(nomeFile: fileName)
            profileImage = Image(uiImage: nuovaImmagine)
            immaginiProfilo.removeAll()
        }
    }
    
    func caricaPostSalvati() {
        postSalvati = UserSessionManager.shared.getPostSalvati()
    }
}

// MARK: - PostAnteprimaView
struct PostAnteprimaView: View {
    let post: Post
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header del post
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading) {
                    Text(post.autore)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(timeAgo(from: post.dataCreazione))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Contenuto del post (limitato)
            Text(post.contenuto)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Immagine se presente
            if let immagine = post.immagine {
                AsyncImage(url: URL(string: immagine)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 80)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 80)
                }
            }
            
            // Indicatore "Tocca per espandere"
            HStack {
                Spacer()
                Text("Tocca per espandere")
                    .font(.caption2)
                    .foregroundColor(.blue)
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onTapGesture {
            onTap()
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct PostEspansoView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            AnnuncioCardProfiloView(
                post: post,
                availableSize: UIScreen.main.bounds.size
            )
            .navigationTitle("Post Salvato")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        Button {
            if let intID = Int(post.id) {
                UserSessionManager.shared.rimuoviPostSalvato(id: intID)
                dismiss()
            }
        } label: {
            Label("Rimuovi dai preferiti", systemImage: "bookmark.slash")
                .foregroundColor(.red)
                .padding(.top)
        }
    }
}
// MARK: - Modello Post
struct Post: Identifiable {
    let id: String
    let autore: String
    let contenuto: String
    let dataCreazione: Date
    let immagine: String? // opzionale se non usi URL
    let immagineUI: UIImage?
    let categoria: String
    let luogo: String
}

extension Post {
    func toAnnuncio() -> Annuncio {
        let categoria = CategoriaAnnuncio(rawValue: self.categoria) ?? .info
        
        return Annuncio(
            titolo: contenuto.components(separatedBy: "\n").first ?? "Post",
            descrizione: contenuto.components(separatedBy: "\n").dropFirst().joined(separator: "\n"),
            data: dataCreazione,
            luogo: "", // opzionalmente puoi includerlo nel contenuto
            immagini: immagineUI != nil ? [immagineUI!] : [], // se presente, la include
            autore: autore,
            categoria: categoria
        )
    }
}

extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id &&
               lhs.autore == rhs.autore &&
               lhs.contenuto == rhs.contenuto &&
               lhs.dataCreazione == rhs.dataCreazione &&
               lhs.immagine == rhs.immagine &&
               lhs.categoria == rhs.categoria &&
               lhs.luogo == rhs.luogo
        //Non confrontiamo immagineUI perché UIImage non è Equatable
    }
}
#Preview {
    Profilo()
}
