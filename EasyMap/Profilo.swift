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
    
    @Environment(\.dismiss) var dismiss
    
    // Picker stato per mostrare Salvati o Medaglie
    @State private var selectedTab = "Salvati"
    private let tabs = ["Salvati", "Missioni"]

    var body: some View {
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
                // Mostra un dialogo di scelta
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
            
            // Picker segmentato per categorie
            Picker("Categoria", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 10)
            
            /* Sezione post-missioni*/
            if selectedTab == "Salvati" {
                salvatiView()
            } else if selectedTab == "Missioni" {
                missioniView()
            }
            
            Spacer()
        }
        .padding()
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
    }

    func salvatiView() -> some View {
        VStack {
            Text("Post salvati")
                .font(.headline)
            // Qui puoi aggiungere una lista o griglia dei post salvati
        }
        .padding()
    }

    func missioniView() -> some View {
        VStack {
            Text("Medaglie ricevute")
                .font(.headline)
            // Qui puoi aggiungere icone, badge, o altri elementi
        }
        .padding()
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
}
