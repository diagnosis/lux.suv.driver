//
//  LoginModels.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let driver: Driver?
    let message: String?
}

struct Driver: Codable {
    let id: String
    let username: String
    let name: String?
    let email: String?
    let phone: String?
    let status: String?
}

struct APIError: Codable {
    let message: String
    let error: String?
}