//
//  DashboardView.swift
//  lux.suv.driver
//
//  Created by Safa Demirkan on 6/24/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var rideService = RideService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Rides List Tab
            RidesListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Rides")
                }
                .tag(1)
            
            // Calendar Tab
            RideCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.8, green: 0.7, blue: 0.2))
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
            
            // Set selected item tint color
            UITabBar.appearance().tintColor = UIColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 1.0)
            UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct DashboardHomeView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var rideService = RideService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
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
                                    Text("Welcome back,")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(authService.currentDriver?.name ?? authService.currentDriver?.username ?? "Driver")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    authService.logout()
                                }) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                        )
                                }
                            }
                            
                            // Status Card
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Status")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 12, height: 12)
                                        
                                        Text("Available")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Today's Rides")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("\(todaysRideCount)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
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
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Upcoming Rides
                        if !rideService.upcomingRides().isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Upcoming Rides")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(rideService.upcomingRides().count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(red: 0.8, green: 0.7, blue: 0.2).opacity(0.2))
                                        )
                                }
                                .padding(.horizontal, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(Array(rideService.upcomingRides().prefix(5))) { ride in
                                            UpcomingRideCard(ride: ride)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        // Quick Actions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Actions")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                QuickActionCard(
                                    icon: "location.circle.fill",
                                    title: "Go Online",
                                    subtitle: "Start accepting rides",
                                    color: Color.green
                                )
                                
                                QuickActionCard(
                                    icon: "clock.fill",
                                    title: "Schedule",
                                    subtitle: "View your schedule",
                                    color: Color.blue
                                )
                                
                                QuickActionCard(
                                    icon: "chart.bar.fill",
                                    title: "Earnings",
                                    subtitle: "Check your earnings",
                                    color: Color(red: 0.8, green: 0.7, blue: 0.2)
                                )
                                
                                QuickActionCard(
                                    icon: "person.fill",
                                    title: "Profile",
                                    subtitle: "Update your info",
                                    color: Color.purple
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Debug section - remove this in production
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Debug Actions")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                            
                            Button(action: {
                                rideService.addSampleRide()
                            }) {
                                Text("Add Sample Ride")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        Color(red: 0.8, green: 0.7, blue: 0.2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
        }
        .task {
            await rideService.fetchRides()
        }
    }
    
    private var todaysRideCount: Int {
        let today = Date()
        return rideService.ridesForDate(today).count
    }
}

struct UpcomingRideCard: View {
    let ride: Ride
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(ride.time)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let fare = ride.fare {
                    Text("$\(fare, specifier: "%.0f")")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.2))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    
                    Text(ride.pickup)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                    
                    Text(ride.dropoff)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    
    private var profileInitial: String {
        if let name = authService.currentDriver?.name, let firstChar = name.first {
            return String(firstChar).uppercased()
        } else if let username = authService.currentDriver?.username, let firstChar = username.first {
            return String(firstChar).uppercased()
        } else {
            return "D"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.8, green: 0.7, blue: 0.2),
                                        Color(red: 0.9, green: 0.8, blue: 0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(profileInitial)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.black)
                            )
                        
                        VStack(spacing: 4) {
                            Text(authService.currentDriver?.name ?? authService.currentDriver?.username ?? "Driver")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            if let email = authService.currentDriver?.email {
                                Text(email)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        authService.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Sign Out")
                                .font(.system(size: 18, weight: .semibold))
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
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Handle action
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DashboardView()
}