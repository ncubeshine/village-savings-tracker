//
//  contributions page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/23/25.
//
import Foundation

struct Contribution: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
    var email: String
    var phone: String
    var role: String
}

import SwiftUI
import Combine

class ContributionViewModel: ObservableObject {
    @Published var contributions: [Contribution] = []
    
    var totalSavings: Double {
        contributions.reduce(0) { $0 + $1.amount }
        
    }

    //func share(for member: Member) -> Double {
        //guard totalSavings > 0 else { return 0 }
        //return (member.amount / totalSavings) * 100
    }
    
    func addContribution(name: String, amount: Double) {
        guard !name.isEmpty, amount > 0 else { return }
        //contributions.append(contributions(name: name, email: email, role: role, phone: phone, amount: <#String#>))
    }
//}

import SwiftUI

struct ContributionView: View {
    @StateObject private var viewModel = ContributionViewModel()
    @State private var name = ""
    @State private var amount = ""
    @State private var email = ""
    @State private var role = ""
    @State private var phone = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add Contribution")) {
                        TextField("Member name", text: $name)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        
                       //Button(action: addContribution) {
                            Label("Add", systemImage: "plus.circle.fill")
//                        }
                        .disabled(name.isEmpty || amount.isEmpty)
                    }
                    
                    Section(header: Text("Total Savings")) {
                        Text("₦\(viewModel.totalSavings, specifier: "%.2f")")
                            .font(.headline)
                    }
                    
                    Section(header: Text("Members")) {
                        if $viewModel.contributions.isEmpty {
                            Text("No contributions yet.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach($viewModel.contributions) { member in
                                HStack {
                                    //Text(member.name)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        //Text("₦\(member.amount, specifier: "%.2f")")
                                        //Text("\(viewModel.share(for: //contributions), specifier: "%.2f")% share")
                                            //.font(.caption)
                                            //.foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Contributions")
            }
        }
    }
    
//    func addContribution() {
//        if let value = Double(amount) {
//            viewModel.addContribution(name: name, amount: value)
//            name = ""
//            amount = ""
        }
   // }
//}

#Preview {
    ContributionView()
}

