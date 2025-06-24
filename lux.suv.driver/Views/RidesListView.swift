//
//  RidesListView.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import SwiftUI

struct RidesListView: View {
    @StateObject private var rideService = RideService.shared
    @State private var selectedRide: Ride?
    @State private var showingRideDetail = false
    @State private var refreshing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("My Rides")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await refreshRides()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .disabled(rideService.isLoading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Content
                    if rideService.isLoading && rideService.rides.isEmpty {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        Spacer()
                    } else if rideService.rides.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "car.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("No rides available")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("New ride requests will appear here")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(rideService.rides) { ride in
                                    RideCard(ride: ride) {
                                        selectedRide = ride
                                        showingRideDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100)
                        }
                        .refreshable {
                            await refreshRides()
                        }
                    }
                }
                
                // Error message
                if let errorMessage = rideService.errorMessage {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingRideDetail) {
            if let ride = selectedRide {
                RideDetailView(ride: ride)
            }
        }
        .task {
            await rideService.fetchRides()
        }
    }
    
    private func refreshRides() async {
        refreshing = true
        await rideService.fetchRides()
        refreshing = false
    }
}

struct RideCard: View {
    let ride: Ride
    let onTap: () -> Void
    
    private var statusColor: Color {
        switch ride.status {
        case .requested: return .blue
        case .accepted: return .green
        case .inProgress: return .orange
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
    
    private var formattedTime: String {
        guard let pickupDate = ride.pickupDate else { return "Invalid time" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: pickupDate)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ride.customerName ?? "Unknown Customer")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(formattedTime)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(ride.status.displayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(statusColor.opacity(0.2))
                            )
                        
                        if let fare = ride.fare {
                            Text("$\(fare, specifier: "%.2f")")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                        }
                    }
                }
                
                // Locations
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text(ride.pickupLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(ride.dropoffLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                
                // Additional info
                if let distance = ride.distance, let duration = ride.duration {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(distance, specifier: "%.1f") mi")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(duration) min")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RidesListView()
}