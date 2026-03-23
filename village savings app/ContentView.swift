//
//  authenticationPg.swift
//  village savings app
//
//  Created by Shine Ncube on 23/3/2026.
//
import SwiftUI
import Foundation
import CryptoKit
import Security

// MARK: - Keychain Helpers
func saveToKeychain(key: String, value: String) -> Bool {
    guard let data = value.data(using: .utf8) else { return false }
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemDelete(query as CFDictionary) // Delete old entry if exists
    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
}

func getFromKeychain(key: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    if status == errSecSuccess, let data = dataTypeRef as? Data, let value = String(data: data, encoding: .utf8) {
        return value
    }
    return nil
}

// MARK: - Password Helpers
func hashPassword(_ password: String) -> String {
    let data = Data(password.utf8)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}

func validatePassword(_ password: String) -> (Bool, String) {
    guard password.count >= 8 && password.count <= 12 else {
        return (false, "Password must be 8-12 characters long.")
    }
    let uppercase = CharacterSet.uppercaseLetters
    guard password.rangeOfCharacter(from: uppercase) != nil else {
        return (false, "Password must contain at least one uppercase letter.")
    }
    let lowercase = CharacterSet.lowercaseLetters
    guard password.rangeOfCharacter(from: lowercase) != nil else {
        return (false, "Password must contain at least one lowercase letter.")
    }
    let digits = CharacterSet.decimalDigits
    guard password.rangeOfCharacter(from: digits) != nil else {
        return (false, "Password must contain at least one number.")
    }
    let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{};':\"\\|,.<>/?")
    guard password.rangeOfCharacter(from: specialChars) != nil else {
        return (false, "Password must contain at least one special character.")
    }
    return (true, "Password is valid.")
}

func verifyLogin(enteredPassword: String, keychainKey: String) -> Bool {
    guard let storedHash = getFromKeychain(key: keychainKey) else { return false }
    let enteredHash = hashPassword(enteredPassword)
    return enteredHash == storedHash
}

// MARK: - SwiftUI Views
struct AuthenticationPage: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text(message)
                    .foregroundColor(.red)
                
                HStack(spacing: 20) {
                    Button("Sign Up") {
                        let (valid, msg) = validatePassword(password)
                        if !valid {
                            message = msg
                        } else {
                            let hashed = hashPassword(password)
                            if saveToKeychain(key: username, value: hashed) {
                                message = "Signup successful!"
                            } else {
                                message = "Error storing password."
                            }
                        }
                    }
                    
                    Button("Login") {
                        if verifyLogin(enteredPassword: password, keychainKey: username) {
                            message = "Login successful!"
                            isLoggedIn = true
                        } else {
                            message = "Invalid username or password."
                        }
                    }
                }
                
                NavigationLink(destination:WelcomeView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Savings Tracker Login")
        }
    }
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
struct AuthenticationPage_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationPage()
    }
}
