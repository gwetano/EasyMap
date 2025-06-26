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
            PhotosPicker("Modifica immagine", selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) { newItem in
                    guard let newItem = newItem else { return }

                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {

                            let fileName = "profile.png"
                            let url = getDocumentsDirectory().appendingPathComponent(fileName)
                            if let imageData = uiImage.pngData() {
                                try? imageData.write(to: url)
                            }

                            UserSessionManager.shared.salvaImmagineProfilo(nomeFile: fileName)
                            profileImage = Image(uiImage: uiImage)
                        }
                    }
                }

            // Nome utente
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

            // Vista condizionata
            if selectedTab == "Salvati" {
                salvatiView()
            } else if selectedTab == "Missioni" {
                missioniView()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if let imageName = user?.immagineProfilo {
                let path = getDocumentsDirectory().appendingPathComponent(imageName)
                if let uiImage = UIImage(contentsOfFile: path.path) {
                    profileImage = Image(uiImage: uiImage)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
}
