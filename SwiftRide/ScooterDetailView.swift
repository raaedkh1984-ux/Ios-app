import SwiftUI
import CoreLocation

struct ScooterDetailView: View {
    let scooter: Scooter
    @ObservedObject var locationManager: LocationManager
    let onUnlockScooter: (Scooter) -> Void
    
    @State private var distance: Double?
    @State private var showingQRScanner = false
    @State private var showingPaymentSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with scooter image and basic info
                    headerSection
                    
                    // Battery and status section
                    batterySection
                    
                    // Location and distance section
                    locationSection
                    
                    // Scooter specifications
                    specificationsSection
                    
                    // Action buttons
                    actionSection
                }
                .padding()
            }
            .navigationTitle("Scooter Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        // Handle close action
                    }
                }
            }
        }
        .onAppear {
            calculateDistance()
        }
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView(
                isPresented: $showingQRScanner,
                scannedCode: .constant("")
            ) { code in
                handleQRCodeScanned(code)
            }
        }
        .sheet(isPresented: $showingPaymentSheet) {
            PaymentView(scooter: scooter)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Scooter image placeholder
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)
                    .cornerRadius(16)
                
                VStack(spacing: 12) {
                    Image(systemName: "scooter")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(scooter.model)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            // Price and availability
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", scooter.hourlyRate))/min")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(scooter.isAvailable ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(scooter.isAvailable ? "Available" : "In Use")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(scooter.isAvailable ? .green : .red)
                    }
                }
            }
        }
    }
    
    private var batterySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Battery Status")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Battery Level")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(scooter.batteryLevel)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(batteryColor)
                }
                
                ProgressView(value: Double(scooter.batteryLevel), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: batteryColor))
                    .frame(height: 8)
                
                Text(batteryStatusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                if let distance = distance {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("Distance from you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", distance))m")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text("Current Location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.4f", scooter.location.latitude)), \(String(format: "%.4f", scooter.location.longitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var specificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specifications")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                SpecRow(title: "Max Speed", value: "\(Int(scooter.maxSpeed)) km/h", icon: "speedometer")
                SpecRow(title: "Range", value: "\(Int(scooter.range)) km", icon: "arrow.right.circle")
                SpecRow(title: "Last Maintenance", value: formatDate(scooter.lastMaintenance), icon: "wrench.and.screwdriver")
                SpecRow(title: "QR Code", value: scooter.qrCode, icon: "qrcode")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            if scooter.isAvailable {
                Button(action: {
                    showingQRScanner = true
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Unlock with QR Code")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    showingPaymentSheet = true
                }) {
                    HStack {
                        Image(systemName: "creditcard")
                        Text("Add Payment Method")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            } else {
                Text("This scooter is currently in use")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
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
    
    private var batteryStatusText: String {
        switch scooter.batteryLevel {
        case 80...100:
            return "Excellent battery life"
        case 50...79:
            return "Good battery life"
        case 20...49:
            return "Low battery - consider charging"
        default:
            return "Very low battery - needs charging"
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
    
    private func handleQRCodeScanned(_ code: String) {
        if code == scooter.qrCode {
            onUnlockScooter(scooter)
        } else {
            // Show error message
            print("Invalid QR code")
        }
    }
}

struct SpecRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
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
    ScooterDetailView(
        scooter: Scooter.mockScooters[0],
        locationManager: LocationManager(),
        onUnlockScooter: { _ in }
    )
}