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
    
    /* Gestione Alert in caso di errore*/
    @State private var isError = false
    @State private var msgError = ""
    @EnvironmentObject var authManager: AuthManager
    
    /* Pulsante di Back */
    @Environment(\.dismiss) var dismiss

    /* Aggiorna il flag per abilitare o disabilitare i bottoni in base */
       var disabilitaBottoni: Bool {
           if isLogin{
               //Se sono in login page controllo solo i due fiel
               //Altrimenti tutti e 3
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
        print("🔵 INIZIO REGISTRAZIONE")
        guard let url = URL(string: "https://giotto.pythonanywhere.com/register") else {
            print("❌ URL non valida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["nome": nome, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🔵 Invio richiesta al server...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("🔵 RISPOSTA RICEVUTA DAL SERVER")
            
            if let error = error {
                print("❌ Errore di rete: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.msgError = "Errore di rete: \(error.localizedDescription)"
                    self.isError = true
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔵 Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ Nessun dato ricevuto")
                DispatchQueue.main.async {
                    self.msgError = "Nessun dato ricevuto dal server"
                    self.isError = true
                }
                return
            }
            
            // Stampa la risposta raw del server
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔵 Risposta server (raw): \(responseString)")
            }
            
            // Prova a parsare il JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("🔵 JSON parsato: \(json ?? [:])")
                
                if let success = json?["success"] as? Bool {
                    print("🔵 Success flag: \(success)")
                    
                    if success == true {
                        print("✅ REGISTRAZIONE RIUSCITA!")
                        DispatchQueue.main.async {
                            print("🔵 Tornando al main thread...")
                            // Usa il nome inserito dall'utente invece di quello dalla risposta del server
                            print("🔵 Usando nome inserito: \(self.nome)")
                            UserSessionManager.shared.scriviJSON(nome: self.nome, email: self.email)
                            print("🔵 Impostando authManager.isAuthenticated = true")
                            self.authManager.isAuthenticated = true
                            print("✅ authManager.isAuthenticated = \(self.authManager.isAuthenticated)")
                        }
                    } else {
                        print("❌ Success = false")
                        DispatchQueue.main.async {
                            self.msgError = "Registrazione fallita dal server"
                            self.isError = true
                        }
                    }
                } else {
                    print("❌ Campo 'success' non trovato o non è un Bool")
                    DispatchQueue.main.async {
                        self.msgError = "Risposta server non valida"
                        self.isError = true
                    }
                }
            } catch {
                print("❌ Errore parsing JSON: \(error)")
                DispatchQueue.main.async {
                    self.msgError = "Errore parsing risposta server"
                    self.isError = true
                }
            }
        }.resume()
        
        print("🔵 Task avviato")
    }
}

#Preview {
    LoginRegistrazione()
        .environmentObject(AuthManager())
}
