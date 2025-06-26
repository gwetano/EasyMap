//
//  accessPage.swift
//  loginRegServer
//
//  Created by Lorenzo Campagna on 25/06/25.
//
import SwiftUI

struct LoginRegistrazione: View {
    @State private var email = ""
    @State private var password = ""
    @State private var nome = ""
    @State private var isLogin = true //Mostra scritta Login/Registrazione e la label Nome
    @State private var message = ""
    @Binding var isAuthenticated: Bool
    @Environment(\.dismiss) var dismiss


    var body: some View {
        NavigationStack{
            VStack(spacing: 16) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title3)
                            .padding()
                    }
                    Spacer()
                }
                Text(isLogin ? "Login" : "Registrazione")
                    .font(.largeTitle)
                
                if !isLogin {
                    TextField("Nome", text: $nome)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .disableAutocorrection(true)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                Button(isLogin ? "Accedi" : "Registrati") {
                    isLogin ? login() : register()
                }
                
                Button(isLogin ? "Non hai un account? Registrati" : "Hai già un account? Accedi") {
                    isLogin.toggle()
                    message = ""
                }
                
                Text(message).foregroundColor(.gray)
            }
            .padding()
            Spacer()
        }
    }

    func login() {
        guard let url = URL(string: "https://giotto.pythonanywhere.com/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool, success == true {
                DispatchQueue.main.async {
                    if let nome = json["nome"] as? String {
                        UserSessionManager.shared.scriviJSON(nome: nome, email: email)
                        isAuthenticated = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    message = "Errore login"
                }
            }
        }.resume()
    }

    func register() {
        guard let url = URL(string: "https://giotto.pythonanywhere.com/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["nome": nome, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool, success == true {
                DispatchQueue.main.async {
                    if let nome = json["nome"] as? String {
                        UserSessionManager.shared.scriviJSON(nome: nome, email: email)
                        isAuthenticated = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    message = "Errore registrazione"
                }
            }
        }.resume()
    }
}

#Preview {
    LoginRegistrazione(isAuthenticated: .constant(false))
}
