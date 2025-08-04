import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var scooters = Scooter.mockScooters
    @State private var currentUser = User.mockUser
    @State private var activeRide: Ride?
    @State private var showingQRScanner = false
    @State private var scannedCode = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView(
                scooters: $scooters,
                locationManager: locationManager,
                onScooterSelected: { scooter in
                    selectedTab = 1 // Switch to scooter detail
                }
            )
            .tabItem {
                Image(systemName: "map")
                Text("Map")
            }
            .tag(0)
            
            ScooterDetailView(
                scooter: scooters.first ?? Scooter.mockScooters[0],
                locationManager: locationManager,
                onUnlockScooter: { scooter in
                    unlockScooter(scooter)
                }
            )
            .tabItem {
                Image(systemName: "scooter")
                Text("Scooter")
            }
            .tag(1)
            
            RideHistoryView(rides: mockRides)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(2)
            
            ProfileView(user: currentUser)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView(
                isPresented: $showingQRScanner,
                scannedCode: $scannedCode
            ) { code in
                handleQRCodeScanned(code)
            }
        }
    }
    
    private func unlockScooter(_ scooter: Scooter) {
        showingQRScanner = true
    }
    
    private func handleQRCodeScanned(_ code: String) {
        // Find scooter with matching QR code
        if let scooterIndex = scooters.firstIndex(where: { $0.qrCode == code }) {
            // Start ride
            let ride = Ride(
                id: UUID().uuidString,
                userId: currentUser.id,
                scooterId: scooters[scooterIndex].id,
                startTime: Date(),
                startLocation: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            )
            activeRide = ride
            
            // Update scooter availability
            scooters[scooterIndex] = Scooter(
                id: scooters[scooterIndex].id,
                model: scooters[scooterIndex].model,
                batteryLevel: scooters[scooterIndex].batteryLevel,
                isAvailable: false,
                latitude: scooters[scooterIndex].location.latitude,
                longitude: scooters[scooterIndex].location.longitude,
                hourlyRate: scooters[scooterIndex].hourlyRate,
                maxSpeed: scooters[scooterIndex].maxSpeed,
                range: scooters[scooterIndex].range,
                lastMaintenance: scooters[scooterIndex].lastMaintenance,
                qrCode: scooters[scooterIndex].qrCode
            )
            
            // Show success message
            print("Scooter unlocked successfully! Ride started.")
        } else {
            print("Invalid QR code or scooter not found")
        }
    }
}

// MARK: - Mock Data
private let mockRides: [Ride] = [
    Ride(id: "ride_001", userId: "user_001", scooterId: "scooter_001", startTime: Date().addingTimeInterval(-3600), startLocation: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
    Ride(id: "ride_002", userId: "user_001", scooterId: "scooter_002", startTime: Date().addingTimeInterval(-7200), startLocation: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094)),
    Ride(id: "ride_003", userId: "user_001", scooterId: "scooter_003", startTime: Date().addingTimeInterval(-86400), startLocation: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294))
]

#Preview {
    ContentView()
}