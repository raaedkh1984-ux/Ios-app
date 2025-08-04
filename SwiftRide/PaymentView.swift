import SwiftUI

struct PaymentView: View {
    let scooter: Scooter
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var showingAddPaymentMethod = false
    @State private var paymentMethods = User.mockUser.paymentMethods
    @State private var isProcessingPayment = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with scooter info
                headerSection
                
                // Payment methods list
                paymentMethodsSection
                
                // Payment summary
                paymentSummarySection
                
                // Action buttons
                actionSection
                
                Spacer()
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPaymentMethod) {
            AddPaymentMethodView { newMethod in
                paymentMethods.append(newMethod)
                if selectedPaymentMethod == nil {
                    selectedPaymentMethod = newMethod
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Scooter info
            HStack {
                Image(systemName: "scooter")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(scooter.model)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Rate: $\(String(format: "%.2f", scooter.hourlyRate))/min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Battery")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(scooter.batteryLevel)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(batteryColor)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Divider()
        }
        .padding()
    }
    
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Payment Methods")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add New") {
                    showingAddPaymentMethod = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if paymentMethods.isEmpty {
                emptyPaymentMethodsView
            } else {
                paymentMethodsList
            }
        }
        .padding()
    }
    
    private var emptyPaymentMethodsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No Payment Methods")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add a payment method to start riding")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Payment Method") {
                showingAddPaymentMethod = true
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var paymentMethodsList: some View {
        VStack(spacing: 8) {
            ForEach(paymentMethods) { method in
                PaymentMethodRow(
                    method: method,
                    isSelected: selectedPaymentMethod?.id == method.id
                ) {
                    selectedPaymentMethod = method
                }
            }
        }
    }
    
    private var paymentSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                SummaryRow(title: "Rate per minute", value: "$\(String(format: "%.2f", scooter.hourlyRate))")
                SummaryRow(title: "Estimated ride (15 min)", value: "$\(String(format: "%.2f", scooter.hourlyRate * 15))")
                SummaryRow(title: "Service fee", value: "$0.50")
                
                Divider()
                
                SummaryRow(title: "Total", value: "$\(String(format: "%.2f", scooter.hourlyRate * 15 + 0.50))", isTotal: true)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                processPayment()
            }) {
                HStack {
                    if isProcessingPayment {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "lock.fill")
                    }
                    
                    Text(isProcessingPayment ? "Processing..." : "Unlock Scooter")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selectedPaymentMethod != nil ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(selectedPaymentMethod == nil || isProcessingPayment)
            
            Text("You'll only be charged for the time you ride")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
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
    
    private func processPayment() {
        guard let paymentMethod = selectedPaymentMethod else { return }
        
        isProcessingPayment = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessingPayment = false
            dismiss()
            // In a real app, you would handle the payment result here
        }
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if !method.lastFourDigits.isEmpty {
                        Text("•••• \(method.lastFourDigits)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if method.isDefault {
                    Text("Default")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        switch method.type {
        case .creditCard, .debitCard:
            return "creditcard"
        case .applePay:
            return "applelogo"
        case .paypal:
            return "p.circle"
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    let isTotal: Bool
    
    init(title: String, value: String, isTotal: Bool = false) {
        self.title = title
        self.value = value
        self.isTotal = isTotal
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .medium)
                .foregroundColor(isTotal ? .primary : .secondary)
            
            Spacer()
            
            Text(value)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .medium)
                .foregroundColor(isTotal ? .blue : .primary)
        }
    }
}

struct AddPaymentMethodView: View {
    let onAdd: (PaymentMethod) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: PaymentMethod.PaymentType = .creditCard
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardholderName = ""
    @State private var isDefault = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Payment Method Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(PaymentMethod.PaymentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if selectedType == .creditCard || selectedType == .debitCard {
                    Section("Card Details") {
                        TextField("Card Number", text: $cardNumber)
                            .keyboardType(.numberPad)
                        
                        HStack {
                            TextField("MM/YY", text: $expiryDate)
                                .keyboardType(.numberPad)
                            
                            TextField("CVV", text: $cvv)
                                .keyboardType(.numberPad)
                        }
                        
                        TextField("Cardholder Name", text: $cardholderName)
                    }
                }
                
                Section {
                    Toggle("Set as default payment method", isOn: $isDefault)
                }
            }
            .navigationTitle("Add Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addPaymentMethod()
                    }
                    .disabled(!isValidForm)
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        if selectedType == .creditCard || selectedType == .debitCard {
            return !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty && !cardholderName.isEmpty
        }
        return true
    }
    
    private func addPaymentMethod() {
        let lastFourDigits = cardNumber.count >= 4 ? String(cardNumber.suffix(4)) : ""
        
        let newMethod = PaymentMethod(
            id: UUID().uuidString,
            type: selectedType,
            lastFourDigits: lastFourDigits,
            expiryDate: expiryDate,
            isDefault: isDefault
        )
        
        onAdd(newMethod)
        dismiss()
    }
}

#Preview {
    PaymentView(scooter: Scooter.mockScooters[0])
}