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
    let phoneNumber: String?
    let rideType: String?
    let pickup: String
    let dropoff: String
    let date: String
    let time: String
    let numberOfPassengers: Int?
    let numberOfLuggage: Int?
    let additionalNotes: String?
    let status: RideStatus?
    let fare: Double?
    let distance: Double?
    let duration: Int? // in minutes
    let createdAt: String?
    let updatedAt: String?
    
    // Computed properties for better UI display
    var customerName: String {
        return name ?? "Unknown Customer"
    }
    
    var customerEmail: String? {
        return email
    }
    
    var customerPhone: String? {
        return phoneNumber
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
    
    var notes: String? {
        return additionalNotes
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

// API Response model that matches your exact API format
struct APIRideResponse: Codable {
    let id: Int
    let yourName: String?
    let email: String?
    let phoneNumber: String?
    let rideType: String?
    let pickupLocation: String
    let dropoffLocation: String
    let date: String
    let time: String
    let numberOfPassengers: Int?
    let numberOfLuggage: Int?
    let additionalNotes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case yourName = "your_name"
        case email
        case phoneNumber = "phone_number"
        case rideType = "ride_type"
        case pickupLocation = "pickup_location"
        case dropoffLocation = "dropoff_location"
        case date
        case time
        case numberOfPassengers = "number_of_passengers"
        case numberOfLuggage = "number_of_luggage"
        case additionalNotes = "additional_notes"
    }
    
    // Convert to our internal Ride model
    func toRide() -> Ride {
        return Ride(
            id: String(id), // Convert Int to String
            name: yourName,
            email: email,
            phoneNumber: phoneNumber,
            rideType: rideType,
            pickup: pickupLocation,
            dropoff: dropoffLocation,
            date: date,
            time: time,
            numberOfPassengers: numberOfPassengers,
            numberOfLuggage: numberOfLuggage,
            additionalNotes: additionalNotes,
            status: .requested, // Default status for new rides
            fare: nil,
            distance: nil,
            duration: nil,
            createdAt: nil,
            updatedAt: nil
        )
    }
}