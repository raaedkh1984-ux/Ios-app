import SwiftUI
import MapKit

struct MapView: View {
    @Binding var scooters: [Scooter]
    @ObservedObject var locationManager: LocationManager
    let onScooterSelected: (Scooter) -> Void
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedScooter: Scooter?
    @State private var showingScooterDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: scooters.filter { $0.isAvailable }) { scooter in
                    MapAnnotation(coordinate: scooter.location) {
                        ScooterAnnotationView(scooter: scooter) {
                            selectedScooter = scooter
                            showingScooterDetail = true
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    updateRegionToUserLocation()
                }
                .onChange(of: locationManager.location) { _ in
                    updateRegionToUserLocation()
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            updateRegionToUserLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("SwiftRide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Refresh scooters
                        refreshScooters()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .sheet(isPresented: $showingScooterDetail) {
            if let scooter = selectedScooter {
                ScooterDetailView(
                    scooter: scooter,
                    locationManager: locationManager,
                    onUnlockScooter: onScooterSelected
                )
            }
        }
    }
    
    private func updateRegionToUserLocation() {
        guard let location = locationManager.location else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = location.coordinate
        }
    }
    
    private func refreshScooters() {
        // In a real app, this would fetch updated scooter data from the server
        // For now, we'll just simulate a refresh
        print("Refreshing scooters...")
    }
}

struct ScooterAnnotationView: View {
    let scooter: Scooter
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "scooter")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(batteryColor)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 3)
                
                Text("\(scooter.batteryLevel)%")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
            }
        }
    }
    
    private var batteryColor: Color {
        switch scooter.batteryLevel {
        case 80...100:
            return .green
        case 50...79:
            return .yellow
        case 20...49:
            return .orange
        default:
            return .red
        }
    }
}

struct ScooterDetailView: View {
    let scooter: Scooter
    @ObservedObject var locationManager: LocationManager
    let onUnlockScooter: (Scooter) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var distance: Double?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Scooter Image Placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "scooter")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(12)
                    
                    // Scooter Info
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(scooter.model)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", scooter.hourlyRate))/min")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        // Battery Level
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Battery Level")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(scooter.batteryLevel)%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            ProgressView(value: Double(scooter.batteryLevel), total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: batteryColor))
                        }
                        
                        // Distance
                        if let distance = distance {
                            HStack {
                                Text("Distance")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1f", distance))m")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        // Scooter Details
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(title: "Max Speed", value: "\(Int(scooter.maxSpeed)) km/h")
                            DetailRow(title: "Range", value: "\(Int(scooter.range)) km")
                            DetailRow(title: "Last Maintenance", value: formatDate(scooter.lastMaintenance))
                        }
                        
                        // Unlock Button
                        Button(action: {
                            onUnlockScooter(scooter)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Unlock Scooter")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(!scooter.isAvailable)
                        .opacity(scooter.isAvailable ? 1.0 : 0.6)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scooter Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            calculateDistance()
        }
    }
    
    private var batteryColor: Color {
        switch scooter.batteryLevel {
        case 80...100:
            return .green
        case 50...79:
            return .yellow
        case 20...49:
            return .orange
        default:
            return .red
        }
    }
    
    private func calculateDistance() {
        distance = locationManager.calculateDistance(to: scooter.location)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    MapView(
        scooters: .constant(Scooter.mockScooters),
        locationManager: LocationManager(),
        onScooterSelected: { _ in }
    )
}