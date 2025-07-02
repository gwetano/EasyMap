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
    @State private var isLogin = true
    @State private var message = ""
    
    @State private var isError = false
    @State private var msgError = ""
    @EnvironmentObject var authManager: AuthManager
    
    @Environment(\.dismiss) var dismiss

       var disabilitaBottoni: Bool {
           if isLogin{
               return !email.isEmpty && !password.isEmpty
           }else{
               return !email.isEmpty && !password.isEmpty && !nome.isEmpty
           }
       }

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
                }.disabled(!disabilitaBottoni).opacity(disabilitaBottoni ? 1 : 0.5)
                
                Button(isLogin ? "Non hai un account? Registrati" : "Hai già un account? Accedi") {
                    isLogin.toggle()
                    message = ""
                }
                
                Text(message).foregroundColor(.gray)
            }
            .padding().alert("Errore", isPresented: $isError){
                Button("OK", role: .cancel) {}
            } message: {
                Text(msgError)
            }
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
                        authManager.isAuthenticated = true
                        dismiss()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    msgError = "Login fallito. Controlla le credenziali."
                    isError = true
                }
            }
        }.resume()
    }

    func register() {
        guard let url = URL(string: "https://giotto.pythonanywhere.com/register") else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["nome": nome, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("risposta server")
            
            if let error = error {
                DispatchQueue.main.async {
                    self.msgError = "Errore di rete: \(error.localizedDescription)"
                    self.isError = true
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.msgError = "Nessun dato ricevuto dal server"
                    self.isError = true
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Risposta server (raw): \(responseString)")
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("JSON parsato: \(json ?? [:])")
                
                if let success = json?["success"] as? Bool {
                    print("flag: \(success)")
                    
                    if success == true {
                        DispatchQueue.main.async {
                            UserSessionManager.shared.scriviJSON(nome: self.nome, email: self.email)
                            self.authManager.isAuthenticated = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.msgError = "Registrazione fallita dal server"
                            self.isError = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.msgError = "Risposta server non valida"
                        self.isError = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.msgError = "Errore parsing risposta server"
                    self.isError = true
                }
            }
        }.resume()
        
    }
}

#Preview {
    LoginRegistrazione()
        .environmentObject(AuthManager())
}
