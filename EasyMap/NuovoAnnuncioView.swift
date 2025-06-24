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

    var body: some View {
        NavigationStack {
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

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(immagini, id: \.self) { img in
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
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

                    DatePicker("Data e Ora", selection: $dataEvento, displayedComponents: [.date, .hourAndMinute])
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    TextField("Luogo", text: $luogo)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
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
