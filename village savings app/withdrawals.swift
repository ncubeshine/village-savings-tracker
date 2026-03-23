//
//  withdrawals.swift
//  village savings app
//
//  Created by Shine Ncube on 11/3/2026.

import SwiftUI
import Foundation

// Model for a Withdrawal/Loan
struct Withdrawal: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var amount: Double
    var purpose: String
    var date: Date
    var repaymentStatus: String
    
    init(id: UUID = UUID(), name: String, amount: Double, purpose: String, date: Date = Date(), repaymentStatus: String = "Pending") {
        self.id = id
        self.name = name
        self.amount = amount
        self.purpose = purpose
        self.date = date
        self.repaymentStatus = repaymentStatus
    }
}

struct WithdrawalsPage: View {
    var currentUser: Member

    var isAdmin: Bool {
        currentUser.role.lowercased() == "admin"
    }

    @State private var withdrawals: [Withdrawal] = []
    
    // Form fields
    @State private var name = ""
    @State private var amount = ""
    @State private var purpose = "Loan"
    @State private var repaymentStatus = "Pending"
    
    // For editing via form
    @State private var editingWithdrawal: Withdrawal? = nil
    @State private var showForm = false
    
    let purposes = ["Loan", "Emergency", "Other"]
    let statuses = ["Pending", "Partially Repaid", "Fully Repaid"]
    
    var totalWithdrawals: Double {
        withdrawals.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Total Withdrawals: $\(totalWithdrawals, specifier: "%.2f")")
                    .font(.title2)
                    .padding()
                
                List {
                    ForEach(withdrawals) { withdrawal in
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(withdrawal.name) – $\(withdrawal.amount, specifier: "%.2f")")
                                        .font(.headline)
                                    Text("Purpose: \(withdrawal.purpose)")
                                }
                                Spacer()
                                
                                // Picker with dynamic button color
                                Picker("", selection: binding(for: withdrawal)) {
                                    ForEach(statuses, id: \.self) { status in
                                        Text(status)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 150)
                                .accentColor(color(for: withdrawal.repaymentStatus)) // Button color changes
                            }
                            Text("Date: \(withdrawal.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                        }
                        .padding(.vertical, 5)
                        .contextMenu {
                            Button("Edit") {
                                editingWithdrawal = withdrawal
                                name = withdrawal.name
                                amount = "\(withdrawal.amount)"
                                purpose = withdrawal.purpose
                                repaymentStatus = withdrawal.repaymentStatus
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
                
                // Add new withdrawal button
                Button("Add Withdrawal") {
                    showForm = true
                    editingWithdrawal = nil
                    name = ""
                    amount = ""
                    purpose = "Loan"
                    repaymentStatus = "Pending"
                }
                .disabled(!isAdmin)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .navigationTitle("Withdrawals / Loans")
            
            // MARK: Add/Edit Form
            .sheet(isPresented: $showForm) {
                NavigationView {
                    Form {
                        Section(header: Text(editingWithdrawal == nil ? "Add Withdrawal" : "Edit Withdrawal")) {
                            TextField("Who withdrew", text: $name)
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                            Picker("Purpose", selection: $purpose) {
                                ForEach(purposes, id: \.self) { Text($0) }
                            }
                            Picker("Repayment Status", selection: $repaymentStatus) {
                                ForEach(statuses, id: \.self) { status in
                                    Text(status)
                                }
                            }
                        }
                        Button(editingWithdrawal == nil ? "Save" : "Update") {
                            guard let amountValue = Double(amount) else { return }
                            
                            if let editing = editingWithdrawal,
                               let index = withdrawals.firstIndex(where: { $0.id == editing.id }) {
                                // Update existing withdrawal
                                withdrawals[index].name = name
                                withdrawals[index].amount = amountValue
                                withdrawals[index].purpose = purpose
                                withdrawals[index].repaymentStatus = repaymentStatus
                                withdrawals[index].date = Date()
                            } else {
                                // Add new withdrawal
                                let newWithdrawal = Withdrawal(
                                    name: name,
                                    amount: amountValue,
                                    purpose: purpose,
                                    date: Date(),
                                    repaymentStatus: repaymentStatus
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
            
            // MARK: Persistence
            .onAppear { loadWithdrawals() }
            .onChange(of: withdrawals) { _ in saveWithdrawals() }
        }
    }
    
    // MARK: - Helper to bind Picker to array
    private func binding(for withdrawal: Withdrawal) -> Binding<String> {
        guard let index = withdrawals.firstIndex(where: { $0.id == withdrawal.id }) else {
            return .constant(withdrawal.repaymentStatus)
        }
        return $withdrawals[index].repaymentStatus
    }
    
    // MARK: - Helper to get color for current status
    private func color(for status: String) -> Color {
        switch status {
        case "Pending": return .red
        case "Partially Repaid": return .orange
        case "Fully Repaid": return .green
        default: return .primary
        }
    }
    
    // MARK: - Persistence
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
