import SwiftUI

struct BachecaTikTokView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AnnuncioStore
    @State private var mostraCreazione = false
    
    @State private var showLoginAlert = false
    @State private var mostraLoginView = false
    @State private var mostraProfilo = false
    
    @State private var mostraTutorial = false
    
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        GeometryReader { geometry in
            let headerHeight: CGFloat = 60
            let safeAreaTop = geometry.safeAreaInsets.top
            let availableHeight = geometry.size.height - safeAreaTop - headerHeight
            let availableWidth = geometry.size.width
            
            ZStack {
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
                    .onAppear{
                        store.caricaDaServer()
                        if !UserDefaults.standard.bool(forKey: "hasMostratoBachecaTutorial") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                mostraTutorial = true
                            }
                        }
                    }
                }
                
                if mostraTutorial {
                    TutorialOverlay {
                        mostraTutorial = false
                        UserDefaults.standard.set(true, forKey: "hasMostratoBachecaTutorial")
                    }
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
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
                    .environmentObject(authManager)
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
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
    }
}

struct TutorialOverlay: View {
    let onDismiss: () -> Void
    @State private var animazioneOffset: CGFloat = 0
    @State private var swipeOffset: CGFloat = 0
    @State private var opacityTransition: CGFloat = 1
    @State private var hasStartedSwipe: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("Scorri orizzontalmente")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Swipe per navigare")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 15) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(.white)
                        .opacity(opacityTransition)
                        .offset(x: animazioneOffset)
                    
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .offset(x: swipeOffset)
                    
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundColor(.white)
                        .opacity(opacityTransition)
                        .offset(x: -animazioneOffset)
                }
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        animazioneOffset = 20
                    }
                }
                
                VStack(spacing: 12) {
                    if !hasStartedSwipe {
                        Text("Prova ora! Scorri a destra o sinistra")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    } else {
                        Text("Continua a scorrere...")
                            .font(.headline)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                            .overlay(
                                HStack {
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: max(0, abs(swipeOffset) * 2), height: 4)
                                    Spacer()
                                }
                            )
                    }
                    .frame(maxWidth: 200)
                    .cornerRadius(2)
                }
                .animation(.easeInOut(duration: 0.3), value: hasStartedSwipe)
            }
            .padding()
            .offset(x: swipeOffset * 0.1)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    swipeOffset = value.translation.width
                    
                    if !hasStartedSwipe && abs(value.translation.width) > 20 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hasStartedSwipe = true
                            opacityTransition = 0
                        }
                    }
                }
                .onEnded { value in
                    if abs(value.translation.width) > 100 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            swipeOffset = value.translation.width > 0 ? 1000 : -1000
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDismiss()
                        }
                    } else {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            swipeOffset = 0
                        }
                        
                        if hasStartedSwipe && abs(value.translation.width) < 50 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                hasStartedSwipe = false
                                opacityTransition = 1
                            }
                        }
                    }
                }
        )
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
            
            ScrollView {
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
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack{
                            Text(annuncio.titolo)
                                .font(.system(size: min(screenWidth * 0.07, 35), weight: .bold))
                                .lineLimit(nil)
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            Image(annuncio.categoria.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
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
                                UserSessionManager.shared.salvaPost(annuncio)
                                isPreferito.toggle()
                            }) {
                                Image(systemName: isPreferito ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: min(screenWidth * 0.05, 25)))
                                    .foregroundColor(isPreferito ? .blue : .gray)
                            }
                        }
                        
                        Text(annuncio.descrizione)
                            .font(.system(size: min(screenWidth * 0.035, 16)))
                            .lineSpacing(3)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 8)
                        
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
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
}
