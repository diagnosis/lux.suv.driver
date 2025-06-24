//
//  RideDetailView.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import SwiftUI

struct RideDetailView: View {
    let ride: Ride
    @StateObject private var rideService = RideService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingUpdateSheet = false
    @State private var showingDeleteAlert = false
    @State private var isUpdating = false
    
    private var statusColor: Color {
        guard let status = ride.status else { return .gray }
        switch status {
        case .requested: return .blue
        case .accepted: return .green
        case .inProgress: return .orange
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
    
    private var formattedDateTime: String {
        return "\(ride.date) at \(ride.time)"
    }
    
    private var rideTypeDisplay: String {
        guard let rideType = ride.rideType else { return "Standard" }
        return RideType(rawValue: rideType)?.displayName ?? rideType.capitalized
    }
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ride.customerName)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Ride #\(String(ride.id.prefix(8)))")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    if let status = ride.status {
                                        Text(status.displayName)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(statusColor)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(statusColor.opacity(0.2))
                                            )
                                    }
                                    
                                    if let fare = ride.fare {
                                        Text("$\(fare, specifier: "%.2f")")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Ride Type & Schedule
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ride Information")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "car.fill")
                                        .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Ride Type")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text(rideTypeDisplay)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Scheduled Time")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text(formattedDateTime)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Passenger and luggage info
                                if let passengers = ride.numberOfPassengers {
                                    HStack {
                                        Image(systemName: "person.2.fill")
                                            .foregroundColor(.purple)
                                            .frame(width: 20)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Passengers")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white.opacity(0.7))
                                            
                                            Text("\(passengers) passenger\(passengers == 1 ? "" : "s")")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        if let luggage = ride.numberOfLuggage {
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text("Luggage")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                                
                                                Text("\(luggage) bag\(luggage == 1 ? "" : "s")")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Route Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Route")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Pickup Location")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text(ride.pickup)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dropoff Location")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text(ride.dropoff)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Customer Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Customer")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 20)
                                    
                                    Text(ride.customerName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                
                                if let email = ride.email {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        
                                        Text(email)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            if let url = URL(string: "mailto:\(email)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Image(systemName: "envelope.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                
                                if let phone = ride.customerPhone {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.green)
                                            .frame(width: 20)
                                        
                                        Text(phone)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            if let url = URL(string: "tel:\(phone)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Image(systemName: "phone.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Trip Details
                        if ride.distance != nil || ride.duration != nil {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Trip Details")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 24) {
                                    if let distance = ride.distance {
                                        VStack(spacing: 4) {
                                            Text("\(distance, specifier: "%.1f")")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text("miles")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    
                                    if let duration = ride.duration {
                                        VStack(spacing: 4) {
                                            Text("\(duration)")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text("minutes")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Notes
                        if let notes = ride.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Additional Notes")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(notes)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Action Buttons
                        if let status = ride.status, status == .requested || status == .accepted {
                            VStack(spacing: 12) {
                                Button(action: {
                                    showingUpdateSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 18))
                                        Text("Update Status")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.8, green: 0.7, blue: 0.2),
                                                Color(red: 0.9, green: 0.8, blue: 0.3)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .disabled(isUpdating)
                                
                                Button(action: {
                                    showingDeleteAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.system(size: 18))
                                        Text("Cancel Ride")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red.opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                                }
                                .disabled(isUpdating)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Ride Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                }
            }
        }
        .sheet(isPresented: $showingUpdateSheet) {
            if let status = ride.status {
                RideUpdateSheet(ride: ride, currentStatus: status) { newStatus, notes in
                    Task {
                        isUpdating = true
                        let success = await rideService.updateRide(id: ride.id, status: newStatus, notes: notes)
                        isUpdating = false
                        if success {
                            dismiss()
                        }
                    }
                }
            }
        }
        .alert("Cancel Ride", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    isUpdating = true
                    let success = await rideService.deleteRide(id: ride.id)
                    isUpdating = false
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to cancel this ride? This action cannot be undone.")
        }
    }
}

struct RideUpdateSheet: View {
    let ride: Ride
    let currentStatus: RideStatus
    let onUpdate: (RideStatus, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus: RideStatus
    @State private var notes: String = ""
    
    init(ride: Ride, currentStatus: RideStatus, onUpdate: @escaping (RideStatus, String?) -> Void) {
        self.ride = ride
        self.currentStatus = currentStatus
        self.onUpdate = onUpdate
        self._selectedStatus = State(initialValue: currentStatus)
        self._notes = State(initialValue: ride.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Update Status")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            ForEach(RideStatus.allCases, id: \.self) { status in
                                Button(action: {
                                    selectedStatus = status
                                }) {
                                    HStack {
                                        Text(status.displayName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if selectedStatus == status {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                                        } else {
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedStatus == status ? Color.white.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notes (Optional)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Add any notes about this ride...", text: $notes, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .lineLimit(3...6)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onUpdate(selectedStatus, notes.isEmpty ? nil : notes)
                        dismiss()
                    }) {
                        Text("Update Ride")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.8, green: 0.7, blue: 0.2),
                                        Color(red: 0.9, green: 0.8, blue: 0.3)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
            .navigationTitle("Update Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    RideDetailView(ride: Ride(
        id: "1",
        name: "John Doe",
        email: "john@example.com",
        phoneNumber: "123-456-7890",
        rideType: "hourly",
        pickup: "123 Main St",
        dropoff: "456 Elm St",
        date: "2025-06-23",
        time: "14:30",
        numberOfPassengers: 2,
        numberOfLuggage: 1,
        additionalNotes: "Please arrive early",
        status: .requested,
        fare: 150.0,
        distance: 25.5,
        duration: 120,
        createdAt: nil,
        updatedAt: nil
    ))
}