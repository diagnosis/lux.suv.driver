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
            
            // Debug: Print response status and data
            print("API Response Status: \(httpResponse.statusCode)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(jsonString)")
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    // Parse the API response format that matches your backend
                    let apiRides = try JSONDecoder().decode([APIRideResponse].self, from: data)
                    let convertedRides = apiRides.map { $0.toRide() }
                    
                    DispatchQueue.main.async {
                        self.rides = convertedRides
                        self.isLoading = false
                        print("✅ Successfully parsed \(convertedRides.count) rides from API")
                    }
                } catch let decodingError {
                    print("❌ Failed to decode API response: \(decodingError)")
                    
                    // Try fallback parsing methods
                    do {
                        // Try to decode as array of rides directly
                        let ridesArray = try JSONDecoder().decode([Ride].self, from: data)
                        DispatchQueue.main.async {
                            self.rides = ridesArray
                            self.isLoading = false
                            print("✅ Successfully parsed \(ridesArray.count) rides (direct format)")
                        }
                    } catch {
                        // Try the wrapped response format
                        do {
                            let ridesResponse = try JSONDecoder().decode(RidesResponse.self, from: data)
                            DispatchQueue.main.async {
                                self.rides = ridesResponse.rides
                                self.isLoading = false
                                print("✅ Successfully parsed wrapped response with \(ridesResponse.rides.count) rides")
                            }
                        } catch {
                            print("❌ All parsing methods failed")
                            DispatchQueue.main.async {
                                self.errorMessage = "Failed to parse rides data. Please check the API response format."
                                self.isLoading = false
                            }
                        }
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
            print("❌ Network error: \(error)")
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
            
            print("Update Ride Response Status: \(httpResponse.statusCode)")
            
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
            print("❌ Update ride error: \(error)")
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
            
            print("Delete Ride Response Status: \(httpResponse.statusCode)")
            
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
            print("❌ Delete ride error: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // Helper methods for filtering rides
    func ridesForDate(_ date: Date) -> [Ride] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let targetDateString = dateFormatter.string(from: date)
        
        return rides.filter { ride in
            return ride.date == targetDateString
        }
    }
    
    func upcomingRides() -> [Ride] {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return rides.filter { ride in
            let dateTimeString = "\(ride.date) \(ride.time)"
            guard let rideDateTime = dateFormatter.date(from: dateTimeString) else { return false }
            return rideDateTime > now && (ride.status == .requested || ride.status == .accepted)
        }.sorted { ride1, ride2 in
            let dateTimeString1 = "\(ride1.date) \(ride1.time)"
            let dateTimeString2 = "\(ride2.date) \(ride2.time)"
            guard let date1 = dateFormatter.date(from: dateTimeString1),
                  let date2 = dateFormatter.date(from: dateTimeString2) else { return false }
            return date1 < date2
        }
    }
    
    // Add sample data for testing
    func addSampleRide() {
        let sampleRide = Ride(
            id: "sample-\(Date().timeIntervalSince1970)",
            name: "Sample Customer",
            email: "sample@example.com",
            phoneNumber: "555-0123",
            rideType: "hourly",
            pickup: "Sample Pickup Location",
            dropoff: "Sample Dropoff Location",
            date: "2025-06-25",
            time: "15:30",
            numberOfPassengers: 2,
            numberOfLuggage: 1,
            additionalNotes: "This is a sample ride for testing",
            status: .requested,
            fare: 150.0,
            distance: 25.5,
            duration: 120,
            createdAt: nil,
            updatedAt: nil
        )
        
        DispatchQueue.main.async {
            self.rides.append(sampleRide)
            print("✅ Added sample ride for testing")
        }
    }
}