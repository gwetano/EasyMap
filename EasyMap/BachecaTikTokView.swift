import SwiftUI

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
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AnnuncioStore
    @State private var mostraCreazione = false

    var body: some View {
        GeometryReader { geometry in
            let headerHeight: CGFloat = 60
            let safeAreaTop = geometry.safeAreaInsets.top
            let availableHeight = geometry.size.height - safeAreaTop - headerHeight
            let availableWidth = geometry.size.width
            
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.title3)
                                .padding()
                        }
                        Spacer()
                        Button {
                            mostraCreazione = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.title3)
                                .padding()
                        }
                    }
                }
                .frame(height: headerHeight)
                .zIndex(1)
                
                TabView {
                    ForEach(store.annunci) { annuncio in
                        AnnuncioCardView(
                            annuncio: annuncio,
                            availableSize: CGSize(width: availableWidth, height: availableHeight)
                        )
                        .frame(width: availableWidth, height: availableHeight)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: availableHeight)

            }
        }
        .fullScreenCover(isPresented: $mostraCreazione) {
            NuovoAnnuncioView { nuovo in
                store.aggiungi(nuovo)
                mostraCreazione = false
            }
        }
    }
}

struct AnnuncioCardView: View {
    let annuncio: Annuncio
    let availableSize: CGSize
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
    
    private var orario: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: annuncio.data)
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            let padding: CGFloat = 20
            let safeAreaTop = geometry.safeAreaInsets.top
            let availableHeight = screenHeight - safeAreaTop - 60
            
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if let immagine = annuncio.immagini.first {
                        Image(uiImage: immagine)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: screenWidth - (padding * 2),
                                height: availableHeight * 0.3
                            )
                            .clipped()
                            .cornerRadius(20)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(
                                width: screenWidth - (padding * 2),
                                height: availableHeight * 0.3
                            )
                            .cornerRadius(20)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: min(screenWidth, availableHeight) * 0.08))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .padding(.horizontal, padding)
                .padding(.top, padding)
                
                VStack(alignment: .leading) {
                    Text(annuncio.titolo)
                        .font(.system(size: min(screenWidth * 0.07, 35), weight: .bold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom) {
                            Text(giorno)
                                .font(.system(size: min(screenWidth * 0.1, 50), weight: .bold))
                            Text(mese)
                                .font(.system(size: min(screenWidth * 0.06, 30)))
                                .offset(y: -3)
                        }
                        
                        Text(annuncio.luogo)
                            .font(.system(size: min(screenWidth * 0.055, 28), weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(orario)
                            .font(.system(size: min(screenWidth * 0.055, 28), weight: .bold))
                        
                        Spacer()
                        
                        Button(action: {
                            isPreferito.toggle()
                        }) {
                            Image(systemName: isPreferito ? "bookmark.fill" : "bookmark")
                                .font(.system(size: min(screenWidth * 0.05, 25)))
                                .foregroundColor(isPreferito ? .blue : .gray)
                        }
                    }
                    
                    let remainingSpace = availableHeight * 0.5 - (availableHeight * 0.12)
                    
                    Text(annuncio.descrizione)
                        .font(.system(size: min(screenWidth * 0.035, 16)))
                        .lineSpacing(3)
                        .frame(maxHeight: remainingSpace, alignment: .top)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 10, height: 10)
                        
                        Text(annuncio.autore)
                            .font(.system(size: min(screenWidth * 0.032, 15)))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, padding)
                
                }
                .padding(.horizontal, padding)
                .padding(.top, padding)
            }
            .frame(width: screenWidth, height: availableHeight)
        }
        .background(Color.white)
    }
}

#Preview {
}
