//
//  Reports: History .swift
//  village savings app
//
//  Created by Shine Ncube on 11/3/2026.
//

import Foundation
import SwiftUI

struct ReportsPage: View {
    
    var contributions: [Contribution]
    
    @State private var selectedPeriod = "Monthly"
    let periods = ["Weekly", "Monthly", "Custom"]
    
    var totalSavings: Double {
        contributions.reduce(0) { $0 + $1.amount }
    }
    
    var contributionsByMember: [String: Double] {
        Dictionary(grouping: contributions, by: { $0.memberName })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Picker("Select Period", selection: $selectedPeriod) {
                    ForEach(periods, id: \.self) { Text($0) }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("Total Savings: $\(totalSavings, specifier: "%.2f")")
                            .font(.title2)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            Text("Contributions per Member")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(contributionsByMember.keys.sorted(), id: \.self) { member in
                                HStack {
                                    Text(member)
                                    Spacer()
                                    Text("$\(contributionsByMember[member] ?? 0, specifier: "%.2f")")
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reports / History")
        }
    }
}
//
//
//// Dummy Models
//struct MemberContribution: Identifiable {
//    let id = UUID()
//    var memberName: String
//    var contributions: Double
//    var missedContributions: Int
//}
//
//struct LoanProgress: Identifiable {
//    let id = UUID()
//    var memberName: String
//    var loanAmount: Double
//    var repaidAmount: Double
//    
//    var remaining: Double { loanAmount - repaidAmount }
//    var status: String {
//        if remaining == 0 { return "Fully Repaid" }
//        else if remaining < loanAmount { return "Partially Repaid" }
//        else { return "Pending" }
//    }
//}
//
//struct ReportsPage: View {
//    // Dummy data
//    @State private var contributions: [MemberContribution] = [
//        MemberContribution(memberName: "John Doe", contributions: 500, missedContributions: 1),
//        MemberContribution(memberName: "Jane Smith", contributions: 700, missedContributions: 0)
//    ]
//    
//    @State private var loans: [LoanProgress] = [
//        LoanProgress(memberName: "John Doe", loanAmount: 1000, repaidAmount: 600),
//        LoanProgress(memberName: "Jane Smith", loanAmount: 500, repaidAmount: 500)
//    ]
//    
//    // Date filter
//    @State private var selectedPeriod = "Monthly"
//    let periods = ["Weekly", "Monthly", "Custom"]
//    
//    var totalSavings: Double {
//        contributions.reduce(0) { $0 + $1.contributions }
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Period Picker
//                Picker("Select Period", selection: $selectedPeriod) {
//                    ForEach(periods, id: \.self) { Text($0) }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding()
//                
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        // Total Savings
//                        Text("Total Savings: $\(totalSavings, specifier: "%.2f")")
//                            .font(.title2)
//                            .padding(.horizontal)
//                        
//                        // Contributions Table
//                        VStack(alignment: .leading) {
//                            Text("Contributions per Member")
//                                .font(.headline)
//                                .padding(.horizontal)
//                            
//                            ForEach(contributions) { contribution in
//                                HStack {
//                                    Text(contribution.memberName)
//                                    Spacer()
//                                    Text("$\(contribution.contributions, specifier: "%.2f")")
//                                    Spacer()
//                                    Text("Missed: \(contribution.missedContributions)")
//                                }
//                                .padding(.horizontal)
//                            }
//                        }
//                        
//                        // Loan Repayment Progress
//                        VStack(alignment: .leading) {
//                            Text("Loan Repayment Progress")
//                                .font(.headline)
//                                .padding(.horizontal)
//                            
//                            ForEach(loans) { loan in
//                                HStack {
//                                    Text(loan.memberName)
//                                    Spacer()
//                                    Text("Loan: $\(loan.loanAmount, specifier: "%.2f")")
//                                    Spacer()
//                                    Text("Repaid: $\(loan.repaidAmount, specifier: "%.2f")")
//                                    Spacer()
//                                    Text("Remaining: $\(loan.remaining, specifier: "%.2f")")
//                                    Spacer()
//                                    Text(loan.status)
//                                        .foregroundColor(
//                                            loan.status == "Fully Repaid" ? .green :
//                                            loan.status == "Partially Repaid" ? .orange : .red
//                                        )
//                                }
//                                .padding(.horizontal)
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Reports / History")
//        }
//    }
//}
//
struct ReportsPage_Previews: PreviewProvider {
    static var previews: some View {
        ReportsPage(contributions: [])
    }
}
