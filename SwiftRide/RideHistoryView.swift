import SwiftUI

struct RideHistoryView: View {
    let rides: [Ride]
    @State private var selectedFilter: RideFilter = .all
    @State private var searchText = ""
    
    enum RideFilter: String, CaseIterable {
        case all = "All"
        case completed = "Completed"
        case active = "Active"
        case cancelled = "Cancelled"
    }
    
    var filteredRides: [Ride] {
        let filtered = rides.filter { ride in
            if selectedFilter == .all {
                return true
            } else {
                return ride.status.rawValue == selectedFilter.rawValue
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { ride in
                ride.id.localizedCaseInsensitiveContains(searchText) ||
                ride.scooterId.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistics header
                statisticsHeader
                
                // Filter and search
                filterSection
                
                // Rides list
                ridesList
            }
            .navigationTitle("Ride History")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search rides...")
        }
    }
    
    private var statisticsHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Rides",
                    value: "\(rides.count)",
                    icon: "scooter",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Distance",
                    value: "\(Int(rides.reduce(0) { $0 + $1.distance }))km",
                    icon: "arrow.right.circle",
                    color: .green
                )
                
                StatCard(
                    title: "Total Cost",
                    value: "$\(String(format: "%.2f", rides.reduce(0) { $0 + $1.cost }))",
                    icon: "dollarsign.circle",
                    color: .orange
                )
            }
            
            Divider()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Filter by Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(RideFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
    
    private var ridesList: some View {
        Group {
            if filteredRides.isEmpty {
                emptyStateView
            } else {
                List(filteredRides) { ride in
                    RideHistoryRow(ride: ride)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Rides Found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Your ride history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RideHistoryRow: View {
    let ride: Ride
    @State private var showingRideDetail = false
    
    var body: some View {
        Button(action: {
            showingRideDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with ride ID and status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ride #\(ride.id.suffix(6))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Scooter: \(ride.scooterId)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: ride.status)
                }
                
                // Ride details
                HStack(spacing: 20) {
                    RideDetailItem(
                        icon: "calendar",
                        title: "Date",
                        value: formatDate(ride.startTime)
                    )
                    
                    RideDetailItem(
                        icon: "clock",
                        title: "Duration",
                        value: formatDuration(ride.duration)
                    )
                    
                    RideDetailItem(
                        icon: "arrow.right.circle",
                        title: "Distance",
                        value: "\(String(format: "%.1f", ride.distance))km"
                    )
                }
                
                // Cost
                HStack {
                    Text("Cost")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", ride.cost))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                // Location info
                if let endLocation = ride.endLocation {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text("From: \(formatCoordinate(ride.startLocation))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("To: \(formatCoordinate(endLocation))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingRideDetail) {
            RideDetailView(ride: ride)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        return String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
    }
}

struct StatusBadge: View {
    let status: Ride.RideStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case .active:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .red
        case .paused:
            return .orange
        }
    }
}

struct RideDetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct RideDetailView: View {
    let ride: Ride
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Ride header
                    rideHeaderSection
                    
                    // Ride details
                    rideDetailsSection
                    
                    // Location details
                    locationSection
                    
                    // Payment details
                    paymentSection
                }
                .padding()
            }
            .navigationTitle("Ride Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var rideHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ride #\(ride.id.suffix(6))")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                StatusBadge(status: ride.status)
            }
            
            Text("Scooter: \(ride.scooterId)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var rideDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ride Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                DetailRow(title: "Start Time", value: formatDate(ride.startTime))
                if let endTime = ride.endTime {
                    DetailRow(title: "End Time", value: formatDate(endTime))
                }
                DetailRow(title: "Duration", value: formatDuration(ride.duration))
                DetailRow(title: "Distance", value: "\(String(format: "%.2f", ride.distance)) km")
                DetailRow(title: "Cost", value: "$\(String(format: "%.2f", ride.cost))")
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                DetailRow(title: "Start Location", value: formatCoordinate(ride.startLocation))
                if let endLocation = ride.endLocation {
                    DetailRow(title: "End Location", value: formatCoordinate(endLocation))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let paymentId = ride.paymentId {
                DetailRow(title: "Payment ID", value: paymentId)
            } else {
                Text("No payment information available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    private func formatCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        return String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
}

#Preview {
    RideHistoryView(rides: [
        Ride(id: "ride_001", userId: "user_001", scooterId: "scooter_001", startTime: Date().addingTimeInterval(-3600), startLocation: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
        Ride(id: "ride_002", userId: "user_001", scooterId: "scooter_002", startTime: Date().addingTimeInterval(-7200), startLocation: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094))
    ])
}