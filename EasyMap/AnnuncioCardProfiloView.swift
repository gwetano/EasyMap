import SwiftUI

struct AnnuncioCardProfiloView: View {
    private var categoriaEnum: CategoriaAnnuncio {
        CategoriaAnnuncio(rawValue: post.categoria) ?? .info
    }
    let post: Post
    let availableSize: CGSize

    private var giorno: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d"
        return formatter.string(from: post.dataCreazione)
    }

    private var mese: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: post.dataCreazione).capitalized
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let padding: CGFloat = 20
            let availableHeight = geometry.size.height

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let immagine = post.immagineUI {
                        ZStack(alignment: .topLeading) {
                            Image(uiImage: immagine)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: screenWidth - (padding * 2),
                                    height: availableHeight * 0.5
                                )
                                .clipped()
                                .cornerRadius(20)
                            
                            HStack(spacing: 8) {
                                Text(categoriaEnum.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(categoriaEnum.color)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .padding(.top, 12)
                            .padding(.leading, 12)
                        }
                        .padding(.horizontal, padding)
                        .padding(.top, padding)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text(post.contenuto.components(separatedBy: "\n").first ?? "Titolo")
                            .font(.system(size: min(screenWidth * 0.07, 35), weight: .bold))
                            .lineLimit(nil)
                            .minimumScaleFactor(0.8)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .bottom) {
                                Text(giorno)
                                    .font(.system(size: min(screenWidth * 0.1, 50), weight: .bold))
                                Text(mese)
                                    .font(.system(size: min(screenWidth * 0.06, 30)))
                                    .offset(y: -3)
                            }

                            Text(post.luogo.isEmpty ? "Luogo non specificato" : post.luogo)
                                .font(.system(size: min(screenWidth * 0.055, 28), weight: .bold))
                                .foregroundColor(.secondary)
                        }

                        Text(post.contenuto.components(separatedBy: "\n").dropFirst().joined(separator: "\n"))
                            .font(.system(size: min(screenWidth * 0.035, 16)))
                            .lineSpacing(3)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 8)

                        HStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 10, height: 10)

                            Text(post.autore)
                                .font(.system(size: min(screenWidth * 0.032, 15)))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, padding)
                    }
                    .padding(.horizontal, padding)
                }
            }
        }
    }
}
