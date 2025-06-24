//
//  AuthService.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentDriver: Driver?
    
    private let baseURL = "https://luxsuv-backend.fly.dev"
    private let keychainService = KeychainService.shared
    
    private init() {
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        if let token = keychainService.getToken(), !token.isEmpty {
            isAuthenticated = true
            // You might want to validate the token with the server here
        } else {
            isAuthenticated = false
        }
    }
    
    func login(username: String, password: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/driver/login") else {
            throw URLError(.badURL)
        }
        
        let loginRequest = LoginRequest(username: username, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        } catch {
            throw error
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Save token to keychain
            let tokenSaved = keychainService.saveToken(loginResponse.token)
            
            if tokenSaved {
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.currentDriver = loginResponse.driver
                }
                return true
            } else {
                throw NSError(domain: "KeychainError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save token"])
            }
        } else {
            // Try to decode error response
            if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
            }
        }
    }
    
    func logout() {
        _ = keychainService.deleteToken()
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentDriver = nil
        }
    }
    
    func getStoredToken() -> String? {
        return keychainService.getToken()
    }
}