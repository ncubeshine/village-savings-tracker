//
//  withdrawals.swift
//  village savings app
//
//  Created by Shine Ncube on 11/3/2026.
//
import SwiftUI
import Foundation

// Model for a Withdrawal/Loan
struct Withdrawal: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
    var purpose: String
    var date: Date
    var repaymentStatus: String
}

struct WithdrawalsPage: View {
    @State private var withdrawals: [Withdrawal] = []
    
    // Form fields
    @State private var name = ""
    @State private var amount = ""
    @State private var purpose = "Loan"
    @State private var repaymentStatus = "Pending"
    
    let purposes = ["Loan", "Emergency", "Other"]
    let statuses = ["Pending", "Partially Repaid", "Fully Repaid"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Form to add new withdrawal
                Form {
                    Section(header: Text("Add Withdrawal / Loan")) {
                        TextField("Who withdrew", text: $name)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        Picker("Purpose", selection: $purpose) {
                            ForEach(purposes, id: \.self) { Text($0) }
                        }
                        Picker("Repayment Status", selection: $repaymentStatus) {
                            ForEach(statuses, id: \.self) { Text($0) }
                        }
                        
                        Button("Add Withdrawal") {
                            if let amountValue = Double(amount) {
                                let newWithdrawal = Withdrawal(
                                    name: name,
                                    amount: amountValue,
                                    purpose: purpose,
                                    date: Date(),
                                    repaymentStatus: repaymentStatus
                                )
                                withdrawals.append(newWithdrawal)
                                
                                // Reset form
                                name = ""
                                amount = ""
                                purpose = "Loan"
                                repaymentStatus = "Pending"
                            }
                        }
                    }
                }
                
                // List of withdrawals
                List(withdrawals) { withdrawal in
                    VStack(alignment: .leading) {
                        Text("\(withdrawal.name) – $\(withdrawal.amount, specifier: "%.2f")")
                            .font(.headline)
                        Text("Purpose: \(withdrawal.purpose)")
                        Text("Date: \(withdrawal.date.formatted(date: .abbreviated, time: .shortened))")
                        Text("Status: \(withdrawal.repaymentStatus)")
                            .foregroundColor(withdrawal.repaymentStatus == "Pending" ? .red : .green)
                    }
                }
            }
            .navigationTitle("Withdrawals / Loans")
        }
    }
}

struct WithdrawalsPage_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalsPage()
    }
}
