import Foundation
import CoreLocation

// MARK: - Scooter Model
struct Scooter: Identifiable, Codable {
    let id: String
    let model: String
    let batteryLevel: Int
    let isAvailable: Bool
    let location: CLLocationCoordinate2D
    let hourlyRate: Double
    let maxSpeed: Double
    let range: Double
    let lastMaintenance: Date
    let qrCode: String
    
    init(id: String, model: String, batteryLevel: Int, isAvailable: Bool, latitude: Double, longitude: Double, hourlyRate: Double, maxSpeed: Double, range: Double, lastMaintenance: Date, qrCode: String) {
        self.id = id
        self.model = model
        self.batteryLevel = batteryLevel
        self.isAvailable = isAvailable
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.hourlyRate = hourlyRate
        self.maxSpeed = maxSpeed
        self.range = range
        self.lastMaintenance = lastMaintenance
        self.qrCode = qrCode
    }
    
    enum CodingKeys: String, CodingKey {
        case id, model, batteryLevel, isAvailable, hourlyRate, maxSpeed, range, lastMaintenance, qrCode
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        model = try container.decode(String.self, forKey: .model)
        batteryLevel = try container.decode(Int.self, forKey: .batteryLevel)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        hourlyRate = try container.decode(Double.self, forKey: .hourlyRate)
        maxSpeed = try container.decode(Double.self, forKey: .maxSpeed)
        range = try container.decode(Double.self, forKey: .range)
        lastMaintenance = try container.decode(Date.self, forKey: .lastMaintenance)
        qrCode = try container.decode(String.self, forKey: .qrCode)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(model, forKey: .model)
        try container.encode(batteryLevel, forKey: .batteryLevel)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encode(hourlyRate, forKey: .hourlyRate)
        try container.encode(maxSpeed, forKey: .maxSpeed)
        try container.encode(range, forKey: .range)
        try container.encode(lastMaintenance, forKey: .lastMaintenance)
        try container.encode(qrCode, forKey: .qrCode)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
    }
}

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let phoneNumber: String
    let profileImage: String?
    let rating: Double
    let totalRides: Int
    let memberSince: Date
    let paymentMethods: [PaymentMethod]
    
    init(id: String, name: String, email: String, phoneNumber: String, profileImage: String? = nil, rating: Double = 0.0, totalRides: Int = 0, memberSince: Date = Date(), paymentMethods: [PaymentMethod] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
        self.rating = rating
        self.totalRides = totalRides
        self.memberSince = memberSince
        self.paymentMethods = paymentMethods
    }
}

// MARK: - Payment Method Model
struct PaymentMethod: Identifiable, Codable {
    let id: String
    let type: PaymentType
    let lastFourDigits: String
    let expiryDate: String
    let isDefault: Bool
    
    enum PaymentType: String, Codable, CaseIterable {
        case creditCard = "Credit Card"
        case debitCard = "Debit Card"
        case applePay = "Apple Pay"
        case paypal = "PayPal"
    }
}

// MARK: - Ride Model
struct Ride: Identifiable, Codable {
    let id: String
    let userId: String
    let scooterId: String
    let startTime: Date
    let endTime: Date?
    let startLocation: CLLocationCoordinate2D
    let endLocation: CLLocationCoordinate2D?
    let distance: Double
    let duration: TimeInterval
    let cost: Double
    let status: RideStatus
    let paymentId: String?
    
    enum RideStatus: String, Codable, CaseIterable {
        case active = "Active"
        case completed = "Completed"
        case cancelled = "Cancelled"
        case paused = "Paused"
    }
    
    init(id: String, userId: String, scooterId: String, startTime: Date, startLocation: CLLocationCoordinate2D, status: RideStatus = .active) {
        self.id = id
        self.userId = userId
        self.scooterId = scooterId
        self.startTime = startTime
        self.endTime = nil
        self.startLocation = startLocation
        self.endLocation = nil
        self.distance = 0.0
        self.duration = 0.0
        self.cost = 0.0
        self.status = status
        self.paymentId = nil
    }
}

// MARK: - Payment Model
struct Payment: Identifiable, Codable {
    let id: String
    let rideId: String
    let amount: Double
    let currency: String
    let status: PaymentStatus
    let paymentMethodId: String
    let timestamp: Date
    let description: String
    
    enum PaymentStatus: String, Codable, CaseIterable {
        case pending = "Pending"
        case completed = "Completed"
        case failed = "Failed"
        case refunded = "Refunded"
    }
}

// MARK: - Mock Data
extension Scooter {
    static let mockScooters: [Scooter] = [
        Scooter(id: "scooter_001", model: "SwiftX Pro", batteryLevel: 85, isAvailable: true, latitude: 37.7749, longitude: -122.4194, hourlyRate: 0.25, maxSpeed: 25.0, range: 50.0, lastMaintenance: Date().addingTimeInterval(-86400 * 7), qrCode: "SWIFT001"),
        Scooter(id: "scooter_002", model: "EcoRide Plus", batteryLevel: 92, isAvailable: true, latitude: 37.7849, longitude: -122.4094, hourlyRate: 0.30, maxSpeed: 30.0, range: 60.0, lastMaintenance: Date().addingTimeInterval(-86400 * 3), qrCode: "SWIFT002"),
        Scooter(id: "scooter_003", model: "SwiftX Pro", batteryLevel: 45, isAvailable: false, latitude: 37.7649, longitude: -122.4294, hourlyRate: 0.25, maxSpeed: 25.0, range: 50.0, lastMaintenance: Date().addingTimeInterval(-86400 * 14), qrCode: "SWIFT003"),
        Scooter(id: "scooter_004", model: "EcoRide Plus", batteryLevel: 78, isAvailable: true, latitude: 37.7949, longitude: -122.3994, hourlyRate: 0.30, maxSpeed: 30.0, range: 60.0, lastMaintenance: Date().addingTimeInterval(-86400 * 1), qrCode: "SWIFT004"),
        Scooter(id: "scooter_005", model: "SwiftX Pro", batteryLevel: 95, isAvailable: true, latitude: 37.7549, longitude: -122.4394, hourlyRate: 0.25, maxSpeed: 25.0, range: 50.0, lastMaintenance: Date().addingTimeInterval(-86400 * 5), qrCode: "SWIFT005")
    ]
}

extension User {
    static let mockUser = User(
        id: "user_001",
        name: "John Doe",
        email: "john.doe@example.com",
        phoneNumber: "+1 (555) 123-4567",
        rating: 4.8,
        totalRides: 47,
        memberSince: Date().addingTimeInterval(-86400 * 365),
        paymentMethods: [
            PaymentMethod(id: "pm_001", type: .creditCard, lastFourDigits: "1234", expiryDate: "12/25", isDefault: true),
            PaymentMethod(id: "pm_002", type: .applePay, lastFourDigits: "", expiryDate: "", isDefault: false)
        ]
    )
}