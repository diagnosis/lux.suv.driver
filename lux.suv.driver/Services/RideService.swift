//
//  RideService.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import Foundation
import Combine

class RideService: ObservableObject {
    static let shared = RideService()
    
    @Published var rides: [Ride] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://luxsuv-backend.fly.dev"
    private let authService = AuthService.shared
    
    private init() {}
    
    func fetchRides() async {
        guard let token = authService.getStoredToken() else {
            DispatchQueue.main.async {
                self.errorMessage = "No authentication token found"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard let url = URL(string: "\(baseURL)/driver/book-rides") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response"
                    self.isLoading = false
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                // Try to decode as array of rides directly first
                if let ridesArray = try? JSONDecoder().decode([Ride].self, from: data) {
                    DispatchQueue.main.async {
                        self.rides = ridesArray
                        self.isLoading = false
                    }
                }
                // If that fails, try the wrapped response format
                else if let ridesResponse = try? JSONDecoder().decode(RidesResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.rides = ridesResponse.rides
                        self.isLoading = false
                    }
                }
                // If both fail, try the API response format you provided
                else if let apiRides = try? JSONDecoder().decode([APIRideResponse].self, from: data) {
                    let convertedRides = apiRides.map { $0.toRide() }
                    DispatchQueue.main.async {
                        self.rides = convertedRides
                        self.isLoading = false
                    }
                }
                else {
                    // Debug: Print the raw response
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw API Response: \(jsonString)")
                    }
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse rides data"
                        self.isLoading = false
                    }
                }
            } else {
                if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                    DispatchQueue.main.async {
                        self.errorMessage = errorResponse.message
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch rides (Status: \(httpResponse.statusCode))"
                        self.isLoading = false
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func updateRide(id: String, status: RideStatus, notes: String? = nil) async -> Bool {
        guard let token = authService.getStoredToken() else {
            DispatchQueue.main.async {
                self.errorMessage = "No authentication token found"
            }
            return false
        }
        
        guard let url = URL(string: "\(baseURL)/driver/book-ride/\(id)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return false
        }
        
        let updateRequest = RideUpdateRequest(status: status, notes: notes)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(updateRequest)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response"
                }
                return false
            }
            
            if httpResponse.statusCode == 200 {
                // Refresh rides after successful update
                await fetchRides()
                return true
            } else {
                if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                    DispatchQueue.main.async {
                        self.errorMessage = errorResponse.message
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to update ride (Status: \(httpResponse.statusCode))"
                    }
                }
                return false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func deleteRide(id: String) async -> Bool {
        guard let token = authService.getStoredToken() else {
            DispatchQueue.main.async {
                self.errorMessage = "No authentication token found"
            }
            return false
        }
        
        guard let url = URL(string: "\(baseURL)/driver/book-ride/\(id)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response"
                }
                return false
            }
            
            if httpResponse.statusCode == 200 {
                // Refresh rides after successful deletion
                await fetchRides()
                return true
            } else {
                if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                    DispatchQueue.main.async {
                        self.errorMessage = errorResponse.message
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to delete ride (Status: \(httpResponse.statusCode))"
                    }
                }
                return false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // Helper methods for filtering rides
    func ridesForDate(_ date: Date) -> [Ride] {
        let calendar = Calendar.current
        return rides.filter { ride in
            guard let pickupDate = ride.pickupDate else { return false }
            return calendar.isDate(pickupDate, inSameDayAs: date)
        }
    }
    
    func upcomingRides() -> [Ride] {
        let now = Date()
        return rides.filter { ride in
            guard let pickupDate = ride.pickupDate else { return false }
            return pickupDate > now && (ride.status == .requested || ride.status == .accepted)
        }.sorted { ride1, ride2 in
            guard let date1 = ride1.pickupDate, let date2 = ride2.pickupDate else { return false }
            return date1 < date2
        }
    }
    
    // Add sample data for testing
    func addSampleRide() {
        let sampleRide = Ride(
            id: "1",
            name: "John Doe",
            email: "john@example.com",
            rideType: "hourly",
            pickup: "123 Main St",
            dropoff: "456 Elm St",
            date: "2025-06-23",
            time: "14:30",
            status: .requested,
            fare: 150.0,
            distance: 25.5,
            duration: 120,
            notes: "VIP client - prefer classical music",
            createdAt: nil,
            updatedAt: nil
        )
        
        DispatchQueue.main.async {
            self.rides.append(sampleRide)
        }
    }
}