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
    
    @State private var postSalvati: [Post] = []
    @State private var postEspanso: Post? = nil
    
    @EnvironmentObject var authManager: AuthManager
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack() {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 0)
                            .padding(.vertical, 12)
                    }
                    
                    Text("Profilo")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    HStack{
                        Button(action: {
                            authManager.logout()
                            dismiss()
                        }) {
                            Image(systemName: "iphone.and.arrow.right.outward")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                
                HStack{
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
                    VStack{
                        if let nome = user?.nome {
                            Text(nome)
                                .font(.title)
                                .bold()
                        }
                        
                        Button("Modifica Foto") {
                            showImageSourceDialog = true
                        }.padding(.vertical, 5)
                            .confirmationDialog("Aggiungi da", isPresented: $showImageSourceDialog, titleVisibility: .visible) {
                                Button("Camera") {
                                    mostraCamera = true
                                }
                                Button("Foto") {
                                    mostraGalleria = true
                                }
                                Button("Annulla", role: .cancel) {}
                            }
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 10)
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
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.5))
            
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
                VStack(spacing: 16) {
                    ForEach(postSalvati) { post in
                        PostAnteprimaView(post: post) {
                            postEspanso = post
                        }
                    }
                }
                .frame(maxWidth: .infinity)
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

struct PostAnteprimaView: View {
    let post: Post
    let onTap: () -> Void

    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            if let uiImage = post.immagineUI {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
            } else {
                Color.gray.opacity(0.2)
                    .frame(height: 160)
            }

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.8), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 160)

            VStack(alignment: .leading, spacing: 6) {
                Spacer()

                Text(post.contenuto.components(separatedBy: "\n").first ?? "Post")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)

                HStack(spacing: 6) {
                    Text(post.categoria.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill((CategoriaAnnuncio(rawValue: post.categoria) ?? .info).color))
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .foregroundColor(.white).bold()
                        .cornerRadius(6)

                    if !post.luogo.isEmpty {
                        Text(post.luogo)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue).opacity(0.9)
                            .foregroundColor(.white).bold()
                            .cornerRadius(6)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .padding(.horizontal)
        .onTapGesture {
            onTap()
        }
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
struct Post: Identifiable {
    let id: String
    let autore: String
    let contenuto: String
    let dataCreazione: Date
    let immagine: String?
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
            luogo: "",
            immagini: immagineUI != nil ? [immagineUI!] : [],
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
    }
}
#Preview {
    Profilo()
}
