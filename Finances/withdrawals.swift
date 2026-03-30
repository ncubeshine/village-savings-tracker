//
//  withdrawals.swift
//  village savings app
//
//  Created by Shine Ncube on 11/3/2026.

import SwiftUI
import Foundation

// MARK: - Withdrawal Model
struct Withdrawal: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var amount: Double           // total withdrawal
    var amountPaid: Double       // track how much has been paid
    var purpose: String
    var date: Date
    var repaymentStatus: String

    var balanceRemaining: Double {
        max(amount - amountPaid, 0)
    }

    mutating func addPayment(_ payment: Double) {
        amountPaid = min(amountPaid + payment, amount)
        updateStatus()
    }

    mutating func updateStatus() {
        if amountPaid == 0 {
            repaymentStatus = "Pending"
        } else if amountPaid < amount {
            repaymentStatus = "Partially Repaid"
        } else {
            repaymentStatus = "Fully Repaid"
        }
    }
    
    init(id: UUID = UUID(), name: String, amount: Double, amountPaid: Double = 0, purpose: String, date: Date = Date(), repaymentStatus: String = "Pending") {
        self.id = id
        self.name = name
        self.amount = amount
        self.amountPaid = amountPaid
        self.purpose = purpose
        self.date = date
        self.repaymentStatus = repaymentStatus
    }
}

// MARK: - Withdrawals Page
struct WithdrawalsPage: View {
    var currentUser: Member
    var isAdmin: Bool { currentUser.role.lowercased() == "admin" }

    @State private var withdrawals: [Withdrawal] = []
    
    // Form fields
    @State private var name = ""
    @State private var amount = ""
    @State private var amountPaid = ""
    @State private var purpose = "Loan"
    
    // For editing
    @State private var editingWithdrawal: Withdrawal? = nil
    @State private var showForm = false
    @State private var paymentAlertWithdrawal: Withdrawal? = nil
    @State private var paymentAmount = ""
    @State private var showPaymentAlert = false

    let purposes = ["Loan", "Emergency", "Other"]
    
    var totalWithdrawals: Double {
        withdrawals.reduce(0) { $0 + $1.amount }
    }
    
    var totalPaid: Double {
        withdrawals.reduce(0) { $0 + $1.amountPaid }
    }
    
    var totalRemaining: Double {
        totalWithdrawals - totalPaid
    }

    var body: some View {
        NavigationStack {
            VStack {
                totalsSection
                withdrawalsList

                if isAdmin {
                    addWithdrawalButton
                }
            }
            .navigationTitle("Withdrawals / Loans")
            
            // MARK: Add/Edit Form
            .sheet(isPresented: $showForm) {
                NavigationView {
                    Form {
                        Section(header: Text(editingWithdrawal == nil ? "Add Withdrawal" : "Edit Withdrawal")) {
                            TextField("Who withdrew", text: $name)
                            TextField("Total Amount", text: $amount)
                                .keyboardType(.decimalPad)
                            TextField("Amount Paid", text: $amountPaid)
                                .keyboardType(.decimalPad)
                            Picker("Purpose", selection: $purpose) {
                                ForEach(purposes, id: \.self) { Text($0) }
                            }
                        }
                        Button(editingWithdrawal == nil ? "Save" : "Update") {
                            guard let totalAmount = Double(amount) else { return }
                            let paidAmount = Double(amountPaid) ?? 0
                            
                            if let editing = editingWithdrawal,
                               let index = withdrawals.firstIndex(where: { $0.id == editing.id }) {
                                withdrawals[index].name = name
                                withdrawals[index].amount = totalAmount
                                withdrawals[index].amountPaid = paidAmount
                                withdrawals[index].purpose = purpose
                                withdrawals[index].date = Date()
                                withdrawals[index].updateStatus()
                            } else {
                                let newWithdrawal = Withdrawal(
                                    name: name,
                                    amount: totalAmount,
                                    amountPaid: paidAmount,
                                    purpose: purpose
                                )
                                withdrawals.append(newWithdrawal)
                            }
                            
                            editingWithdrawal = nil
                            showForm = false
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .navigationTitle(editingWithdrawal == nil ? "Add Withdrawal" : "Edit Withdrawal")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                editingWithdrawal = nil
                                showForm = false
                            }
                        }
                    }
                }
            }
            
            // MARK: Add Payment Alert
            .alert("Add Payment", isPresented: $showPaymentAlert, actions: {
                TextField("Amount", text: $paymentAmount)
                    .keyboardType(.decimalPad)
                Button("Add") {
                    if let withdrawal = paymentAlertWithdrawal,
                       let index = withdrawals.firstIndex(where: { $0.id == withdrawal.id }),
                       let payment = Double(paymentAmount) {
                        withdrawals[index].addPayment(payment)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }, message: {
                Text("Enter the payment amount to apply to this withdrawal.")
            })
            
            // MARK: Persistence
            .onAppear { loadWithdrawals() }
            .onChange(of: withdrawals) { _, _ in
                saveWithdrawals()
            }
        }
    }

    private var totalsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Total Withdrawals: $\(totalWithdrawals, specifier: "%.2f")")
            Text("Total Paid: $\(totalPaid, specifier: "%.2f")")
            Text("Total Remaining: $\(totalRemaining, specifier: "%.2f")")
        }
        .font(.headline)
        .padding()
    }

    private var withdrawalsList: some View {
        List {
            ForEach(withdrawals) { withdrawal in
                withdrawalRow(for: withdrawal)
            }
        }
    }

    private var addWithdrawalButton: some View {
        Button("Add Withdrawal") {
            showForm = true
            editingWithdrawal = nil
            name = ""
            amount = ""
            amountPaid = ""
            purpose = "Loan"
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func withdrawalRow(for withdrawal: Withdrawal) -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(withdrawal.name) – $\(withdrawal.amount, specifier: "%.2f")")
                        .font(.headline)
                    Text("Paid: $\(withdrawal.amountPaid, specifier: "%.2f") | Remaining: $\(withdrawal.balanceRemaining, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Purpose: \(withdrawal.purpose)")
                        .font(.caption)
                }

                Spacer()

                statusBadge(for: withdrawal.repaymentStatus)
            }

            Text("Date: \(withdrawal.date.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
        }
        .padding(.vertical, 5)
        .contextMenu {
            if isAdmin {
                Button("Add Payment") {
                    paymentAlertWithdrawal = withdrawal
                    paymentAmount = ""
                    showPaymentAlert = true
                }

                Button("Edit") {
                    editingWithdrawal = withdrawal
                    name = withdrawal.name
                    amount = "\(withdrawal.amount)"
                    amountPaid = "\(withdrawal.amountPaid)"
                    purpose = withdrawal.purpose
                    showForm = true
                }

                Button("Delete", role: .destructive) {
                    if let index = withdrawals.firstIndex(where: { $0.id == withdrawal.id }) {
                        withdrawals.remove(at: index)
                    }
                }
            }
        }
    }

    private func statusBadge(for status: String) -> some View {
        let statusColor = color(for: status)

        return Text(status)
            .font(.subheadline)
            .padding(5)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(5)
    }
    
    // MARK: Helper to color code status
    private func color(for status: String) -> Color {
        switch status {
        case "Pending": return .red
        case "Partially Repaid": return .orange
        case "Fully Repaid": return .green
        default: return .primary
        }
    }
    
    // MARK: Persistence
    func saveWithdrawals() {
        if let encoded = try? JSONEncoder().encode(withdrawals) {
            UserDefaults.standard.set(encoded, forKey: "savedWithdrawals")
        }
    }
    
    func loadWithdrawals() {
        if let data = UserDefaults.standard.data(forKey: "savedWithdrawals"),
           let decoded = try? JSONDecoder().decode([Withdrawal].self, from: data) {
            withdrawals = decoded
        }
    }
}

// MARK: - Preview
struct WithdrawalsPage_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalsPage(
            currentUser: Member(
                name: "Preview Admin",
                email: "preview@example.com",
                role: "Admin",
                phone: "+1 555 0100"
            )
        )
    }
}


//import SwiftUI
//import Foundation
//
//// Model for a Withdrawal/Loan
//struct Withdrawal: Identifiable, Codable, Equatable {
//    let id: UUID
//    var name: String
//    var amount: Double
//    var purpose: String
//    var date: Date
//    var repaymentStatus: String
//    
//    init(id: UUID = UUID(), name: String, amount: Double, purpose: String, date: Date = Date(), repaymentStatus: String = "Pending") {
//        self.id = id
//        self.name = name
//        self.amount = amount
//        self.purpose = purpose
//        self.date = date
//        self.repaymentStatus = repaymentStatus
//    }
//}
//
//struct WithdrawalsPage: View {
//    var currentUser: Member
//
//    var isAdmin: Bool {
//        currentUser.role.lowercased() == "admin"
//    }
//
//    @State private var withdrawals: [Withdrawal] = []
//    
//    // Form fields
//    @State private var name = ""
//    @State private var amount = ""
//    @State private var purpose = "Loan"
//    @State private var repaymentStatus = "Pending"
//    
//    // For editing via form
//    @State private var editingWithdrawal: Withdrawal? = nil
//    @State private var showForm = false
//    
//    let purposes = ["Loan", "Emergency", "Other"]
//    let statuses = ["Pending", "Partially Repaid", "Fully Repaid"]
//    
//    var totalWithdrawals: Double {
//        withdrawals.reduce(0) { $0 + $1.amount }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Text("Total Withdrawals: $\(totalWithdrawals, specifier: "%.2f")")
//                    .font(.title2)
//                    .padding()
//                
//                List {
//                    ForEach(withdrawals) { withdrawal in
//                        VStack(alignment: .leading) {
//                            HStack {
//                                VStack(alignment: .leading) {
//                                    Text("\(withdrawal.name) – $\(withdrawal.amount, specifier: "%.2f")")
//                                        .font(.headline)
//                                    Text("Purpose: \(withdrawal.purpose)")
//                                }
//                                Spacer()
//                                
//                                // Picker with dynamic button color
//                                Picker("", selection: binding(for: withdrawal)) {
//                                    ForEach(statuses, id: \.self) { status in
//                                        Text(status)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(width: 150)
//                                .accentColor(color(for: withdrawal.repaymentStatus)) // Button color changes
//                            }
//                            Text("Date: \(withdrawal.date.formatted(date: .abbreviated, time: .shortened))")
//                                .font(.caption)
//                        }
//                        .padding(.vertical, 5)
//                        .contextMenu {
//                            Button("Edit") {
//                                editingWithdrawal = withdrawal
//                                name = withdrawal.name
//                                amount = "\(withdrawal.amount)"
//                                purpose = withdrawal.purpose
//                                repaymentStatus = withdrawal.repaymentStatus
//                                showForm = true
//                            }
//                            Button("Delete", role: .destructive) {
//                                if let index = withdrawals.firstIndex(where: { $0.id == withdrawal.id }) {
//                                    withdrawals.remove(at: index)
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                // Add new withdrawal button
//                Button("Add Withdrawal") {
//                    showForm = true
//                    editingWithdrawal = nil
//                    name = ""
//                    amount = ""
//                    purpose = "Loan"
//                    repaymentStatus = "Pending"
//                }
//                .disabled(!isAdmin)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .padding(.horizontal)
//            }
//            .navigationTitle("Withdrawals / Loans")
//            
//            // MARK: Add/Edit Form
//            .sheet(isPresented: $showForm) {
//                NavigationView {
//                    Form {
//                        Section(header: Text(editingWithdrawal == nil ? "Add Withdrawal" : "Edit Withdrawal")) {
//                            TextField("Who withdrew", text: $name)
//                            TextField("Amount", text: $amount)
//                                .keyboardType(.decimalPad)
//                            Picker("Purpose", selection: $purpose) {
//                                ForEach(purposes, id: \.self) { Text($0) }
//                            }
//                            Picker("Repayment Status", selection: $repaymentStatus) {
//                                ForEach(statuses, id: \.self) { status in
//                                    Text(status)
//                                }
//                            }
//                        }
//                        Button(editingWithdrawal == nil ? "Save" : "Update") {
//                            guard let amountValue = Double(amount) else { return }
//                            
//                            if let editing = editingWithdrawal,
//                               let index = withdrawals.firstIndex(where: { $0.id == editing.id }) {
//                                // Update existing withdrawal
//                                withdrawals[index].name = name
//                                withdrawals[index].amount = amountValue
//                                withdrawals[index].purpose = purpose
//                                withdrawals[index].repaymentStatus = repaymentStatus
//                                withdrawals[index].date = Date()
//                            } else {
//                                // Add new withdrawal
//                                let newWithdrawal = Withdrawal(
//                                    name: name,
//                                    amount: amountValue,
//                                    purpose: purpose,
//                                    date: Date(),
//                                    repaymentStatus: repaymentStatus
//                                )
//                                withdrawals.append(newWithdrawal)
//                            }
//                            
//                            editingWithdrawal = nil
//                            showForm = false
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.green)
//                        .cornerRadius(8)
//                    }
//                    .navigationTitle(editingWithdrawal == nil ? "Add Withdrawal" : "Edit Withdrawal")
//                    .toolbar {
//                        ToolbarItem(placement: .cancellationAction) {
//                            Button("Cancel") {
//                                editingWithdrawal = nil
//                                showForm = false
//                            }
//                        }
//                    }
//                }
//            }
//            
//            // MARK: Persistence
//            .onAppear { loadWithdrawals() }
//            .onChange(of: withdrawals) { _ in saveWithdrawals() }
//        }
//    }
//    
//    // MARK: - Helper to bind Picker to array
//    private func binding(for withdrawal: Withdrawal) -> Binding<String> {
//        guard let index = withdrawals.firstIndex(where: { $0.id == withdrawal.id }) else {
//            return .constant(withdrawal.repaymentStatus)
//        }
//        return $withdrawals[index].repaymentStatus
//    }
//    
//    // MARK: - Helper to get color for current status
//    private func color(for status: String) -> Color {
//        switch status {
//        case "Pending": return .red
//        case "Partially Repaid": return .orange
//        case "Fully Repaid": return .green
//        default: return .primary
//        }
//    }
//    
//    // MARK: - Persistence
//    func saveWithdrawals() {
//        if let encoded = try? JSONEncoder().encode(withdrawals) {
//            UserDefaults.standard.set(encoded, forKey: "savedWithdrawals")
//        }
//    }
//    
//    func loadWithdrawals() {
//        if let data = UserDefaults.standard.data(forKey: "savedWithdrawals"),
//           let decoded = try? JSONDecoder().decode([Withdrawal].self, from: data) {
//            withdrawals = decoded
//        }
//    }
//}
//
//struct WithdrawalsPage_Previews: PreviewProvider {
//    static var previews: some View {
//        WithdrawalsPage(
//            currentUser: Member(
//                name: "Preview Admin",
//                email: "preview@example.com",
//                role: "Admin",
//                phone: "+1 555 0100"
//            )
//        )
//    }
//}
