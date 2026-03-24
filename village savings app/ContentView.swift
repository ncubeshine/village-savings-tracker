//
//  authenticationPg.swift
//  village savings app
//
//  Created by Shine Ncube on 23/3/2026.
import SwiftUI
import CryptoKit
import Security

struct ContentView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showPassword: Bool = false
    @State private var showSuccessToast: Bool = false
    @State private var showErrorToast: Bool = false
    
    @State private var navigateToHome: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Background
                Color.orange.opacity(0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                    
                    // Username
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                    
                    // Password with toggle 👁
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // MARK: - Buttons
                    HStack(spacing: 15) {
                        
                        // SIGN UP (important so login works)
                        Button("Sign Up") {
                            let hashed = hashPassword(password)
                            let success = saveToKeychain(key: username, value: hashed)
                            
                            if success {
                                showSuccessToast = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showSuccessToast = false
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        // LOGIN
                        Button("Login") {
                            if verifyLogin(enteredPassword: password, keychainKey: username) {
                                
                                showSuccessToast = true
                                
                                // Reset fields
                                username = ""
                                password = ""
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showSuccessToast = false
                                    navigateToHome = true
                                }
                                
                            } else {
                                showErrorToast = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showErrorToast = false
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                  
                }
                
                // ✅ SUCCESS TOAST (Green)
                if showSuccessToast {
                    VStack {
                        Text("✅Sign in successful!")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                    .transition(.move(edge: .top))
                }
                
                // ❌ ERROR TOAST (Red)
                if showErrorToast {
                    VStack {
                        Text("✖ Invalid username or password")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                    .transition(.move(edge: .top))
                }
                
                // Navigation
                NavigationLink(destination: WelcomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            //.padding()
            .navigationTitle("Village Savings Tracker ")
        }
    }
}



// MARK: - SECURITY FUNCTIONS

// Hash password
func hashPassword(_ password: String) -> String {
    let data = Data(password.utf8)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}

// Save to Keychain
func saveToKeychain(key: String, value: String) -> Bool {
    guard let data = value.data(using: .utf8) else { return false }
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    
    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    
    return status == errSecSuccess
}

// Get from Keychain
func getFromKeychain(key: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == errSecSuccess,
       let data = dataTypeRef as? Data,
       let value = String(data: data, encoding: .utf8) {
        return value
    }
    
    return nil
}

// Verify login
func verifyLogin(enteredPassword: String, keychainKey: String) -> Bool {
    guard let storedHash = getFromKeychain(key: keychainKey) else {
        return false
    }
    
    let enteredHash = hashPassword(enteredPassword)
    return enteredHash == storedHash
}
    

// MARK: - Dashboard Placeholder
struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Welcome to your Dashboard!")
                .font(.title)
                .padding()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
       ContentView()
    }
}
