import SwiftUI

// MARK: - Modello Annuncio
struct Annuncio: Identifiable, Hashable {
    let id = UUID()
    let titolo: String
    let descrizione: String
    let data: Date
    let luogo: String
    let immagini: [UIImage]
    let autore: String
    
}


struct BachecaTikTokView: View {
    @ObservedObject var store: AnnuncioStore
    @State private var mostraCreazione = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(store.annunci) { annuncio in
                            AnnuncioCardView(annuncio: annuncio)
                                .frame(height: UIScreen.main.bounds.height)
                                .id(annuncio.id)
                        }
                    }
                }
                .ignoresSafeArea()
            }

            
            Button {
                mostraCreazione = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding()
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $mostraCreazione) {
            NuovoAnnuncioView { nuovo in
                store.aggiungi(nuovo)
                mostraCreazione = false
            }
        }
    }
}



struct AnnuncioCardView: View {
    let annuncio: Annuncio
    @State private var isPreferito: Bool = false

    
    private var giorno: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d"
        return formatter.string(from: annuncio.data)
    }

    private var mese: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: annuncio.data).capitalized
    }
    private var orario : String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: annuncio.data)

    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }

            if let immagine = annuncio.immagini.first {
                Image(uiImage: immagine)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .cornerRadius(20)
                    .padding(.horizontal)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
                    .cornerRadius(20)
                    .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(annuncio.titolo)
                    .font(.system(size: 35))
                    .bold()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(giorno)
                            .font(.system(size: 50).bold())
                        Text(mese)
                            .font(.system(size: 30))
                    }

                    Text(annuncio.luogo)
                        .font(.system(size: 28).bold())
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 60) {
                    HStack {
                        Text(orario)
                            .font(.system(size: 28, weight: .bold))

                        Spacer()

                        Button(action: {
                            isPreferito.toggle()
                        }) {
                            Image(systemName: isPreferito ? "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(isPreferito ? .blue : .gray)
                        }
                    }

                    Text(annuncio.descrizione)
                        .font(.body)
                        .padding(.top, 8)
                }

                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)

                    Text(annuncio.autore)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.top, 35)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal)

            Spacer()

            Image(systemName: "chevron.up")
                .font(.title2)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    
    }
