//
//  EasyMapApp.swift
//  EasyMap
//
//  Created by Studente on 21/06/25.
//

import SwiftUI
import PhotosUI

struct NuovoAnnuncioView: View {
    var onSalva: (Annuncio) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: Step = .categoria
    @State private var animationDirection: AnimationDirection = .forward
    @State private var categoriaSelezionata: CategoriaAnnuncio = .evento
    @State private var titolo: String = ""
    @State private var descrizione: String = ""
    @State private var dataEvento: Date = Date()
    @State private var luogo: String = ""
    @State private var immagini: [UIImage] = []
    @State private var mostraGalleria = false
    @State private var mostraFotocamera = false
    @FocusState private var isTitoloFocused: Bool
    @FocusState private var isDescrizioneFocused: Bool
    @FocusState private var isLuogoFocused: Bool
    
    enum Step: Int, CaseIterable {
        case categoria = 0
        case titolo = 1
        case descrizione = 2
        case foto = 3
        case dettagli = 4
        case recap = 5
        
        var title: String {
            switch self {
            case .categoria: return "Che tipo di annuncio vuoi creare?"
            case .titolo: return "Come vuoi intitolare il tuo annuncio?"
            case .descrizione: return "Descrivi il tuo annuncio"
            case .foto: return "Aggiungi una foto (opzionale)"
            case .dettagli: return "Aggiungi i dettagli"
            case .recap: return "Riepilogo"
            }
        }
    }
    
    enum AnimationDirection {
        case forward, backward
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    HStack {
                        Button("Annulla") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            ForEach(0..<Step.allCases.count, id: \.self) { index in
                                Rectangle()
                                    .fill(index <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 16, height: 8)
                            }
                        }
                        
                        Spacer()
                        
                        if currentStep != .recap {
                            Button("Salta") {
                                prossimoStep()
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    VStack(spacing: 4) {
                        Text(currentStep.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(.systemBackground))
                
                ScrollView {
                    VStack {
                        stepContent
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }
                }
                .background(Color(.systemGray6))
                
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        if currentStep.rawValue > 0 {
                            Button("Indietro") {
                                stepIndietro()
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(currentStep == .recap ? "Pubblica" : "Continua") {
                            if currentStep == .recap {
                                pubblicaAnnuncio()
                            } else {
                                prossimoStep()
                            }
                        }
                        .bold()
                        .disabled(!canProceed)
                    }
                    .padding(20)
                }
                .background(Color(.systemBackground))
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    isTitoloFocused = false
                    isDescrizioneFocused = false
                    isLuogoFocused = false
                    
                    if value.translation.width > 100 && currentStep.rawValue > 0 {
                        stepIndietro()
                    } else if value.translation.width < -100 && canProceed {
                        prossimoStep()
                    }
                }
        )

    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .categoria:
            categoriaView
        case .titolo:
            titoloView
        case .descrizione:
            descrizioneView
        case .foto:
            fotoView
        case .dettagli:
            dettagliView
        case .recap:
            recapView
        }
    }
    
    private var categoriaView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(CategoriaAnnuncio.allCases) { categoria in
                Button {
                    categoriaSelezionata = categoria
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        prossimoStep()
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(categoria.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                        
                        Text(categoria.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(categoriaSelezionata == categoria ? categoria.color : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var titoloView: some View {
        VStack(spacing: 20) {
            TextField("Inserisci il titolo...", text: $titolo)
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )
                .focused($isTitoloFocused)
                .onSubmit {
                    if !titolo.isEmpty {
                        prossimoStep()
                    }
                }
            Spacer()
        }
        .onTapGesture {
        }
    }
    
    private var descrizioneView: some View {
        VStack(spacing: 20) {
            TextField("Descrivi il tuo annuncio...", text: $descrizione, axis: .vertical)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 100)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )
                .lineLimit(3...8)
                .focused($isDescrizioneFocused)
        
            Spacer()
        }
        .onTapGesture {
        }
    }
    
    private var fotoView: some View {
        VStack(spacing: 20) {
            if immagini.isEmpty {
                VStack(spacing: 16) {
                    Button {
                        mostraGalleria = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("Aggiungi una foto")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        mostraFotocamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera")
                            Text("Scatta una foto")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }

            } else {
                VStack(spacing: 16) {
                    if let immagine = immagini.first {
                        Image(uiImage: immagine)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(16)
                            .clipped()
                    }
                    
                    Button("Cambia foto") {
                        immagini.removeAll()
                    }
                    .foregroundColor(.blue)
                }
            }

            Spacer()
        }
        .sheet(isPresented: $mostraGalleria){
            ImagePicker(immagini: $immagini)
        }
        .sheet(isPresented: $mostraFotocamera){
            CameraPicker(immagini: $immagini)
        }
    }
    
    private var dettagliView: some View {
        VStack(spacing: 20) {
            if categoriaSelezionata == .evento || categoriaSelezionata == .annuncio || categoriaSelezionata == .spot || categoriaSelezionata == .smarrimenti{
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quando?")
                            .font(.headline)
                        
                        DatePicker("", selection: $dataEvento, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dove?")
                            .font(.headline)
                        
                        TextField("Inserisci il luogo...", text: $luogo)
                            .font(.body)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                            )
                            .focused($isLuogoFocused)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("Perfetto!")
                        .font(.title2.bold())
                    
                    Text("Il tuo annuncio è stato creato con successo!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
        }
    }
    
    private var recapView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(categoriaSelezionata.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text(categoriaSelezionata.rawValue)
                        .font(.headline)
                        .foregroundColor(categoriaSelezionata.color)
                    Spacer()
                }
                Text(titolo)
                    .font(.title2.bold())
                
                Text(descrizione)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if !immagini.isEmpty, let immagine = immagini.first {
                    Image(uiImage: immagine)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .cornerRadius(12)
                        .clipped()
                }
                
                if categoriaSelezionata == .evento || categoriaSelezionata == .annuncio || categoriaSelezionata == .spot || categoriaSelezionata == .smarrimenti {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text(dataEvento.formatted(date: .abbreviated, time: .shortened))
                    }
                    
                    if !luogo.isEmpty {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text(luogo)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2)
            )
            
            Spacer()
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .categoria:
            return true
        case .titolo:
            return !titolo.isEmpty
        case .descrizione:
            return true
        case .foto:
            return true
        case .dettagli:
            if categoriaSelezionata == .evento {
                return !luogo.isEmpty
            }
            return true
        case .recap:
            return true
        }
    }
    
    private func prossimoStep() {
        guard canProceed else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep.rawValue < Step.allCases.count - 1 {
                animationDirection = .forward
                currentStep = Step(rawValue: currentStep.rawValue + 1) ?? currentStep
            }
        }
    }
    
    private func stepIndietro() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep.rawValue > 0 {
                animationDirection = .backward
                currentStep = Step(rawValue: currentStep.rawValue - 1) ?? currentStep
            }
        }
    }
    
    private func pubblicaAnnuncio() {
        let nuovo = Annuncio(
            titolo: titolo,
            descrizione: descrizione,
            data: dataEvento,
            luogo: luogo,
            immagini: immagini,
            autore: "Anonymous",
            categoria: categoriaSelezionata
        )
        onSalva(nuovo)
        dismiss()
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
