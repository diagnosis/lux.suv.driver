//
//  RideCalendarView.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import SwiftUI

struct RideCalendarView: View {
    @StateObject private var rideService = RideService.shared
    @State private var selectedDate = Date()
    @State private var selectedRide: Ride?
    @State private var showingRideDetail = false
    
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
                        Text("Schedule")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await rideService.fetchRides()
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
                    
                    // Calendar
                    CalendarView(
                        selectedDate: $selectedDate,
                        rides: rideService.rides
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    // Selected Date Rides
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(selectedDateString)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(ridesForSelectedDate.count) rides")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 24)
                        
                        if ridesForSelectedDate.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.4))
                                
                                Text("No rides scheduled")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(ridesForSelectedDate) { ride in
                                        CompactRideCard(ride: ride) {
                                            selectedRide = ride
                                            showingRideDetail = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                    
                    Spacer()
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
    
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var ridesForSelectedDate: [Ride] {
        rideService.ridesForDate(selectedDate).sorted { ride1, ride2 in
            guard let date1 = ride1.pickupDate, let date2 = ride2.pickupDate else { return false }
            return date1 < date2
        }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    let rides: [Ride]
    
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            // Days of week
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasRides: hasRidesOnDate(date),
                        rideCount: rideCountForDate(date)
                    ) {
                        selectedDate = date
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
    
    private var monthYearString: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: currentMonth)
    }
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end) else {
            return []
        }
        
        var days: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func hasRidesOnDate(_ date: Date) -> Bool {
        return rides.contains { ride in
            guard let pickupDate = ride.pickupDate else { return false }
            return calendar.isDate(pickupDate, inSameDayAs: date)
        }
    }
    
    private func rideCountForDate(_ date: Date) -> Int {
        return rides.filter { ride in
            guard let pickupDate = ride.pickupDate else { return false }
            return calendar.isDate(pickupDate, inSameDayAs: date)
        }.count
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasRides: Bool
    let rideCount: Int
    let onTap: () -> Void
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayString)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(textColor)
                
                if hasRides {
                    Circle()
                        .fill(Color(red: 0.8, green: 0.7, blue: 0.2))
                        .frame(width: 6, height: 6)
                    
                    if rideCount > 1 {
                        Text("\(rideCount)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.black)
                            .padding(2)
                            .background(
                                Circle()
                                    .fill(Color(red: 0.8, green: 0.7, blue: 0.2))
                            )
                    }
                } else {
                    Spacer()
                        .frame(height: 6)
                }
            }
            .frame(width: 40, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .white.opacity(0.3)
        } else if isSelected {
            return .black
        } else {
            return .white
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color(red: 0.8, green: 0.7, blue: 0.2)
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        return Color(red: 0.8, green: 0.7, blue: 0.2)
    }
}

struct CompactRideCard: View {
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
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: pickupDate)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Time
                VStack {
                    Text(formattedTime)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(ride.status.displayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(statusColor.opacity(0.2))
                        )
                }
                .frame(width: 80)
                
                // Route
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        
                        Text(ride.pickupLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        
                        Text(ride.dropoffLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Fare
                if let fare = ride.fare {
                    Text("$\(fare, specifier: "%.2f")")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RideCalendarView()
}