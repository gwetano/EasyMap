import SwiftUI

struct BachecaTikTokView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AnnuncioStore
    @State private var mostraCreazione = false
    
    @State private var showLoginAlert = false
    @State private var mostraLoginView = false
    @State private var mostraProfilo = false
    
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        GeometryReader { geometry in
            let headerHeight: CGFloat = 60
            let safeAreaTop = geometry.safeAreaInsets.top
            let availableHeight = geometry.size.height - safeAreaTop - headerHeight
            let availableWidth = geometry.size.width
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 12)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Button(action: {
                            mostraProfilo = true
                        }) {
                            Image(systemName: "person.crop.circle")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .padding(.bottom, -5)
                        }
                        
                        Button {
                            if authManager.isAuthenticated {
                                mostraCreazione = true
                            } else {
                                showLoginAlert = true
                            }
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                        }
                        
                    }
                    .padding(.trailing, 5)
                }
                .frame(height: headerHeight)
                .background(Color(.systemBackground))

                TabView {
                    ForEach(store.annunci) { annuncio in
                        AnnuncioCardView(
                            annuncio: annuncio,
                            availableSize: CGSize(width: availableWidth, height: availableHeight)
                        )
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .fullScreenCover(isPresented: $mostraCreazione) {
            NuovoAnnuncioView { nuovo in
                store.aggiungi(nuovo)
                mostraCreazione = false
            }
        }
        .alert("Accesso richiesto", isPresented: $showLoginAlert) {
            Button("Login") {
                mostraLoginView = true
            }
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Per aggiungere un post devi effettuare il login.")
        }
        .fullScreenCover(isPresented: $mostraLoginView) {
            LoginRegistrazione()
                .environmentObject(authManager)
        }
        .fullScreenCover(isPresented: $mostraProfilo) {
            if authManager.isAuthenticated {
                Profilo()
            } else {
                LoginRegistrazione()
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated && mostraLoginView {
                mostraLoginView = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    mostraCreazione = true
                }
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
                ZStack(alignment: .topLeading) {
                    Group {
                        if let immagine = annuncio.immagini.first {
                            Image(uiImage: immagine)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: screenWidth - (padding * 2),
                                    height: availableHeight * 0.5
                                )
                                .clipped()
                                .cornerRadius(20)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(
                                    width: screenWidth - (padding * 2),
                                    height: availableHeight * 0.5
                                )
                                .cornerRadius(20)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: min(screenWidth, availableHeight) * 0.08))
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Image(annuncio.categoria.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                        
                        Text(annuncio.categoria.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(annuncio.categoria.color)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                    .padding(.top, 12)
                    .padding(.leading, 12)
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
