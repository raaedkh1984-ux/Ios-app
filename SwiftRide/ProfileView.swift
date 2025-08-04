import SwiftUI

struct ProfileView: View {
    let user: User
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingHelp = false
    @State private var showingLogout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeaderSection
                    
                    // Statistics section
                    statisticsSection
                    
                    // Account settings
                    accountSettingsSection
                    
                    // App settings
                    appSettingsSection
                    
                    // Support section
                    supportSection
                    
                    // Logout section
                    logoutSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(user: user)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .alert("Logout", isPresented: $showingLogout) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                // Handle logout
                print("User logged out")
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Profile image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                if let profileImage = user.profileImage {
                    AsyncImage(url: URL(string: profileImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
            }
            
            // User info
            VStack(spacing: 8) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("\(user.rating, specifier: "%.1f")")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Rating")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(user.totalRides)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Rides")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text(formatMemberSince(user.memberSince))
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Member")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Total Distance", value: "127.5 km", icon: "arrow.right.circle", color: .green)
                StatCard(title: "Total Spent", value: "$45.20", icon: "dollarsign.circle", color: .orange)
                StatCard(title: "Avg. Ride Time", value: "12 min", icon: "clock", color: .blue)
                StatCard(title: "Carbon Saved", value: "8.2 kg", icon: "leaf", color: .green)
            }
        }
    }
    
    private var accountSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "person.circle",
                    title: "Personal Information",
                    subtitle: "Name, email, phone",
                    action: { showingEditProfile = true }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileRow(
                    icon: "creditcard",
                    title: "Payment Methods",
                    subtitle: "\(user.paymentMethods.count) methods",
                    action: { /* Handle payment methods */ }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Push notifications",
                    action: { /* Handle notifications */ }
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "gear",
                    title: "Settings",
                    subtitle: "App preferences",
                    action: { showingSettings = true }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileRow(
                    icon: "location",
                    title: "Location Services",
                    subtitle: "GPS and tracking",
                    action: { /* Handle location settings */ }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileRow(
                    icon: "lock.shield",
                    title: "Privacy & Security",
                    subtitle: "Data and privacy",
                    action: { /* Handle privacy settings */ }
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "questionmark.circle",
                    title: "Help & FAQ",
                    subtitle: "Get help and answers",
                    action: { showingHelp = true }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileRow(
                    icon: "message",
                    title: "Contact Support",
                    subtitle: "Chat with us",
                    action: { /* Handle contact support */ }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileRow(
                    icon: "star",
                    title: "Rate App",
                    subtitle: "Rate us on App Store",
                    action: { /* Handle app rating */ }
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var logoutSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingLogout = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                    Text("Logout")
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            
            Text("SwiftRide v1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func formatMemberSince(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditProfileView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var email: String
    @State private var phoneNumber: String
    
    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
        _phoneNumber = State(initialValue: user.phoneNumber)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Profile Picture") {
                    HStack {
                        Text("Profile Picture")
                        Spacer()
                        Button("Change") {
                            // Handle profile picture change
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save changes
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var locationServices = true
    @State private var darkMode = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $pushNotifications)
                    Toggle("Email Notifications", isOn: $emailNotifications)
                }
                
                Section("Location") {
                    Toggle("Location Services", isOn: $locationServices)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                
                Section("Data & Privacy") {
                    Button("Export My Data") {
                        // Handle data export
                    }
                    .foregroundColor(.blue)
                    
                    Button("Delete Account") {
                        // Handle account deletion
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
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
}

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Getting Started") {
                    HelpRow(title: "How to unlock a scooter", subtitle: "Learn how to scan QR codes")
                    HelpRow(title: "Payment methods", subtitle: "Add and manage payment options")
                    HelpRow(title: "Safety guidelines", subtitle: "Important safety information")
                }
                
                Section("Troubleshooting") {
                    HelpRow(title: "Scooter won't unlock", subtitle: "Common unlock issues")
                    HelpRow(title: "Payment problems", subtitle: "Billing and payment help")
                    HelpRow(title: "App issues", subtitle: "Technical support")
                }
                
                Section("Contact") {
                    HelpRow(title: "Live Chat", subtitle: "Chat with support team")
                    HelpRow(title: "Email Support", subtitle: "support@swiftride.com")
                    HelpRow(title: "Phone Support", subtitle: "+1 (555) 123-4567")
                }
            }
            .navigationTitle("Help & FAQ")
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
}

struct HelpRow: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileView(user: User.mockUser)
}