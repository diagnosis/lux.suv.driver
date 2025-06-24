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
        switch ride.status {
        case .requested: return .blue
        case .accepted: return .green
        case .inProgress: return .orange
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
    
    private var formattedPickupTime: String {
        guard let pickupDate = ride.pickupDate else { return "Invalid time" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: pickupDate)
    }
    
    private var formattedDropoffTime: String {
        guard let dropoffDate = ride.dropoffDate else { return "Not set" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: dropoffDate)
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
                                    Text(ride.customerName ?? "Unknown Customer")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Ride #\(String(ride.id.prefix(8)))")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text(ride.status.displayName)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(statusColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(statusColor.opacity(0.2))
                                        )
                                    
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
                        
                        // Time Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Schedule")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.green)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Pickup Time")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text(formattedPickupTime)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                }
                                
                                if ride.dropoffTime != nil {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(.red)
                                            .frame(width: 20)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Dropoff Time")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white.opacity(0.7))
                                            
                                            Text(formattedDropoffTime)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
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
                                        
                                        Text(ride.pickupLocation)
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
                                        
                                        Text(ride.dropoffLocation)
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
                        if ride.customerPhone != nil {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Customer")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    if let phone = ride.customerPhone {
                                        HStack {
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(.blue)
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
                                                    .foregroundColor(.blue)
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
                        }
                        
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
                                Text("Notes")
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
                        if ride.status == .requested || ride.status == .accepted {
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
            RideUpdateSheet(ride: ride) { newStatus, notes in
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
    let onUpdate: (RideStatus, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus: RideStatus
    @State private var notes: String = ""
    
    init(ride: Ride, onUpdate: @escaping (RideStatus, String?) -> Void) {
        self.ride = ride
        self.onUpdate = onUpdate
        self._selectedStatus = State(initialValue: ride.status)
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
        customerId: "customer1",
        customerName: "John Doe",
        customerPhone: "+1234567890",
        pickupLocation: "123 Main St, New York, NY",
        dropoffLocation: "456 Broadway, New York, NY",
        pickupTime: "2025-01-15T10:00:00Z",
        dropoffTime: nil,
        status: .requested,
        fare: 45.50,
        distance: 5.2,
        duration: 25,
        notes: "Customer prefers classical music",
        createdAt: "2025-01-14T15:30:00Z",
        updatedAt: "2025-01-14T15:30:00Z"
    ))
}