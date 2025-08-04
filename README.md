# SwiftRide 🚲

SwiftRide is a mobile app for discovering and renting e-scooters on the go. Users can locate scooters via GPS, unlock them with a QR code, and pay per minute—all within the app.

## Features
- Locate and unlock scooters via map
- Real-time tracking and battery info
- In-app payments and ride history
- User profiles and scooter health reporting
- QR code scanning for scooter unlocking
- Location-based scooter discovery
- Payment method management
- Ride history and statistics

## Available Platforms

### iOS App (Native Swift/SwiftUI)
- **Location**: `SwiftRide/` directory
- **Technology**: Swift, SwiftUI, CoreLocation, MapKit, AVFoundation
- **Features**:
  - Native iOS experience with SwiftUI
  - Real-time GPS location tracking
  - Interactive map with scooter annotations
  - QR code scanner for unlocking scooters
  - Payment processing with multiple payment methods
  - Comprehensive ride history and statistics
  - User profile management
  - Settings and preferences

### React Native App (Cross-platform)
- **Location**: `mobile-app/` directory
- **Technology**: React Native, Node.js, Express, Firebase/MongoDB
- **Features**:
  - Cross-platform support (iOS & Android)
  - Google Maps integration
  - Stripe payment processing
  - Real-time data synchronization

## iOS App Structure

```
SwiftRide/
├── SwiftRideApp.swift          # Main app entry point
├── ContentView.swift           # Main tab navigation
├── MapView.swift              # Interactive map with scooters
├── ScooterDetailView.swift    # Detailed scooter information
├── PaymentView.swift          # Payment processing
├── RideHistoryView.swift      # Ride history and statistics
├── ProfileView.swift          # User profile and settings
├── ScooterModel.swift         # Data models
├── LocationManager.swift      # GPS location services
├── QRCodeScanner.swift        # QR code scanning functionality
└── Assets.xcassets/           # App icons and assets
```

## Getting Started

### iOS App
1. Open `SwiftRide.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

### React Native App
```bash
cd mobile-app
npm install
npx expo start
```

## Requirements

### iOS App
- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+
- Location permissions for GPS functionality
- Camera permissions for QR code scanning

### React Native App
- Node.js 16+
- Expo CLI
- iOS Simulator or physical device

## Key Features

### Map & Location
- Real-time GPS tracking
- Interactive map with scooter locations
- Distance calculation to nearby scooters
- Battery level indicators on map

### Scooter Management
- Detailed scooter information
- Battery level monitoring
- Maintenance status
- Availability status

### Payment System
- Multiple payment methods (Credit Card, Apple Pay, PayPal)
- Secure payment processing
- Ride cost calculation
- Payment history

### User Experience
- Intuitive tab-based navigation
- Modern SwiftUI interface
- Smooth animations and transitions
- Accessibility support

## Architecture

The iOS app follows MVVM (Model-View-ViewModel) architecture:
- **Models**: Data structures for Scooter, User, Ride, Payment
- **Views**: SwiftUI views for UI components
- **ViewModels**: Observable objects for state management
- **Services**: LocationManager, QRCodeScanner for system integration

## Permissions

The app requires the following permissions:
- **Location**: To show nearby scooters and track rides
- **Camera**: To scan QR codes for unlocking scooters

## Development

### Adding New Features
1. Create new SwiftUI views in the `SwiftRide/` directory
2. Update the Xcode project file if needed
3. Add any required permissions to Info.plist
4. Test on both simulator and physical device

### Data Models
All data models are defined in `ScooterModel.swift`:
- `Scooter`: Represents individual scooters
- `User`: User account information
- `Ride`: Ride session data
- `Payment`: Payment transaction data
- `PaymentMethod`: Payment method information

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
