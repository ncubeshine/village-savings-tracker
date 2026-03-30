//
//  home page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/17/25.
//

import SwiftUI
import Combine

// Uses shared Member, Contribution, and Withdrawal models defined in other files.

// MARK: - SHARED DATA SOURCE
class AppData: ObservableObject {
    @Published var members: [Member] = []
    @Published var contributions: [Contribution] = []
    @Published var withdrawals: [Withdrawal] = []
    
    // Computed Dashboard Values
    var numberOfMembers: Int {
        members.count
    }
    
    var totalContributions: Double {
        contributions.reduce(0) { $0 + $1.amount }
    }
    
    var totalWithdrawals: Double {
        withdrawals.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - HOME PAGE
struct HomePage: View {
    
    var currentUser: Member
    
    @EnvironmentObject var appData: AppData   // 👈 Shared data
    
    var isAdmin: Bool {
        currentUser.role.lowercased() == "admin"
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color.orange.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        Text("Summary Dashboard")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Logged in as: \(currentUser.name) (\(currentUser.role))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 20) {
                            
                            NavigationLink {
                                MembersPage(currentUser: currentUser)
                            } label: {
                                SummaryCard(
                                    title: "Number of Members",
                                    value: "\(appData.numberOfMembers)",
                                    color: .gray
                                )
                            }
                            
                            NavigationLink {
                                ContributionsPage(currentUser: currentUser)
                            } label: {
                                SummaryCard(
                                    title: "Recent Contributions",
                                    value: "$\(String(format: "%.2f", appData.totalContributions))",
                                    color: .gray
                                )
                            }
                            
                            NavigationLink {
                                WithdrawalsPage(currentUser: currentUser)
                            } label: {
                                SummaryCard(
                                    title: "Withdrawals",
                                    value: "$\(String(format: "%.2f", appData.totalWithdrawals))",
                                    color: .brown
                                )
                            }
                            
                            SummaryCard(
                                title: "Upcoming meetings/targets",
                                value: "No upcoming events",
                                color: .brown
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - SUMMARY CARD
struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 250)
        .padding()
        .background(color)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - PREVIEW
#Preview {
    HomePage(
        currentUser: Member(
            name: "Preview User",
            email: "preview@example.com",
            role: "Admin",
            phone: "+1 555 0100"
        )
    )
    .environmentObject(AppData()) // 👈 REQUIRED
}



