//
//  RideModels.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import Foundation

struct Ride: Codable, Identifiable {
    let id: String
    let name: String?
    let email: String?
    let rideType: String?
    let pickup: String
    let dropoff: String
    let date: String
    let time: String
    let status: RideStatus?
    let fare: Double?
    let distance: Double?
    let duration: Int? // in minutes
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
    
    // Computed properties for better UI display
    var customerName: String {
        return name ?? "Unknown Customer"
    }
    
    var customerEmail: String? {
        return email
    }
    
    var pickupLocation: String {
        return pickup
    }
    
    var dropoffLocation: String {
        return dropoff
    }
    
    var rideDate: String {
        return date
    }
    
    var rideTime: String {
        return time
    }
    
    // Computed property for Date conversion
    var pickupDateTime: Date? {
        let dateTimeString = "\(date) \(time)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: dateTimeString)
    }
    
    var pickupDate: Date? {
        return pickupDateTime
    }
    
    var dropoffDate: Date? {
        // For now, we don't have dropoff time in the response
        return nil
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

enum RideType: String, Codable, CaseIterable {
    case hourly = "hourly"
    case pointToPoint = "point_to_point"
    case airport = "airport"
    case event = "event"
    
    var displayName: String {
        switch self {
        case .hourly: return "Hourly"
        case .pointToPoint: return "Point to Point"
        case .airport: return "Airport Transfer"
        case .event: return "Event"
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

// For handling the API response format you provided
struct APIRideResponse: Codable {
    let id: String
    let name: String?
    let email: String?
    let rideType: String?
    let pickup: String
    let dropoff: String
    let date: String
    let time: String
    
    // Convert to our internal Ride model
    func toRide() -> Ride {
        return Ride(
            id: id,
            name: name,
            email: email,
            rideType: rideType,
            pickup: pickup,
            dropoff: dropoff,
            date: date,
            time: time,
            status: .requested, // Default status
            fare: nil,
            distance: nil,
            duration: nil,
            notes: nil,
            createdAt: nil,
            updatedAt: nil
        )
    }
}