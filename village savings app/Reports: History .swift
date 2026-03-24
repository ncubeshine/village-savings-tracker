//
//  Reports: History .swift
//  village savings app
//
//  Created by Shine Ncube on 11/3/2026.
import Foundation
import SwiftUI

struct ReportsPage: View {
    
    @State private var contributions: [Contribution] = []
    
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
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    
                    Text("Total Savings: $\(totalSavings, specifier: "%.2f")")
                        .font(.title2)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Contributions per Member")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(contributionsByMember.keys.sorted(), id: \.self) { member in
                            
                            let amount = contributionsByMember[member] ?? 0
                            let percentage = totalSavings > 0 ? (amount / totalSavings) * 100 : 0
                            
                            VStack(alignment: .leading) {
                                
                                HStack {
                                    Text(member)
                                    Spacer()
                                    Text("$\(amount, specifier: "%.2f")")
                                }
                                
                                Text("Share: \(percentage, specifier: "%.1f")%")
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Reports / History")
            .onAppear {
                loadContributions()
            }
        }
    }
    
    func loadContributions() {
        if let data = UserDefaults.standard.data(forKey: "savedContributions") {
            if let decoded = try? JSONDecoder().decode([Contribution].self, from: data) {
                contributions = decoded
            }
        }
    }
}

struct ReportsPage_Previews: PreviewProvider {
    static var previews: some View {
        ReportsPage()
    }
}
