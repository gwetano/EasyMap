// NuovoAnnuncioView.swift
import SwiftUI
import PhotosUI

struct NuovoAnnuncioView: View {
    var onSalva: (Annuncio) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var titolo: String = ""
    @State private var descrizione: String = ""
    @State private var dataEvento: Date = Date()
    @State private var luogo: String = ""
    @State private var immagini: [UIImage] = []
    @State private var mostraGalleria = false
    @State private var mostraFotocamera = false
    @State private var isEvento: Bool = true

    
    @State private var categoriaSelezionata: CategoriaAnnuncio? = .evento
    @State private var mostraPicker: Bool = false

    
    
    
    enum CategoriaAnnuncio: String, CaseIterable, Identifiable {
        case evento = "Evento"
        case annuncio = "Annuncio"
        case spott = "Spott"
        case lavoro = "Lavoro"
        case info = "Info"
        case smarrimenti = "Smarrimenti"

        var id: String { rawValue }
    }


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button("Annulla") {
                            dismiss()
                        }
                        Spacer()
                        Button("Pubblica") {
                            let nuovo = Annuncio(
                                titolo: titolo,
                                descrizione: descrizione,
                                data: dataEvento,
                                luogo: luogo,
                                immagini: immagini,
                                autore: "Utente anonimo"
                            )
                            onSalva(nuovo)
                            dismiss()
                        }.bold()
                    }
                    .padding(.horizontal)

                    Text("Nuovo Annuncio")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    if immagini.isEmpty {
                        Menu {
                            Button {
                                mostraGalleria = true
                            } label: {
                                Label("Scegli dalla galleria", systemImage: "photo")
                            }
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                Button {
                                    mostraFotocamera = true
                                } label: {
                                    Label("Scatta foto", systemImage: "camera")
                                }
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                Text("Aggiungi Foto")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    } else {
                        if let immagine = immagini.first {
                            ZStack(alignment: .bottomTrailing) {
                                Image(uiImage: immagine)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .cornerRadius(12)
                                    .padding(.horizontal)

                                Button(action: {
                                    immagini = []
                                }) {
                                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.blue).frame(width: 40, height: 40))
                                        .padding(12)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Categoria")
                            .font(.headline)
                            .padding(.horizontal)

                        Picker("Categoria", selection: $categoriaSelezionata) {
                            ForEach(CategoriaAnnuncio.allCases) { categoria in
                                Text(categoria.rawValue).tag(Optional(categoria))
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: mostraPicker ? 150 : 60)
                        .clipped()
                        .onTapGesture {
                            withAnimation {
                                mostraPicker.toggle()
                            }
                        }
                        .padding(.horizontal)
                    }

                    VStack(spacing: 16) {
                        TextField("Titolo", text: $titolo)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        TextField("Descrizione", text: $descrizione, axis: .vertical)
                            .lineLimit(4...8)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        if categoriaSelezionata == .evento {
                            DatePicker("Data e Ora", selection: $dataEvento, displayedComponents: [.date, .hourAndMinute])
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            TextField("Luogo", text: $luogo)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.bottom, 100) // Per evitare taglio da tastiera
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(.keyboard) // Tastiera non sovrappone contenuti
            .background(Color.white)
            .sheet(isPresented: $mostraGalleria) {
                ImagePicker(immagini: $immagini)
            }
            .sheet(isPresented: $mostraFotocamera) {
                CameraPicker(immagini: $immagini)
            }
        }
    }

}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var immagini: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.immagini.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var immagini: [UIImage]

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            if let image = info[.originalImage] as? UIImage {
                parent.immagini.append(image)
            }
        }
    }
}

#Preview {
    NuovoAnnuncioView { _ in }
}
