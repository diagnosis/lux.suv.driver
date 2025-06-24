//
//  RideModels.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import Foundation

struct Ride: Codable, Identifiable {
    let id: String
    let customerId: String?
    let customerName: String?
    let customerPhone: String?
    let pickupLocation: String
    let dropoffLocation: String
    let pickupTime: String
    let dropoffTime: String?
    let status: RideStatus
    let fare: Double?
    let distance: Double?
    let duration: Int? // in minutes
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    // Computed property for Date conversion
    var pickupDate: Date? {
        return ISO8601DateFormatter().date(from: pickupTime)
    }
    
    var dropoffDate: Date? {
        guard let dropoffTime = dropoffTime else { return nil }
        return ISO8601DateFormatter().date(from: dropoffTime)
    }
}

enum RideStatus: String, Codable, CaseIterable {
    case requested = "requested"
    case accepted = "accepted"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .requested: return "Requested"
        case .accepted: return "Accepted"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .requested: return "blue"
        case .accepted: return "green"
        case .inProgress: return "orange"
        case .completed: return "gray"
        case .cancelled: return "red"
        }
    }
}

struct RideUpdateRequest: Codable {
    let status: RideStatus
    let notes: String?
}

struct RidesResponse: Codable {
    let rides: [Ride]
    let message: String?
}