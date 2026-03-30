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
    @Published var members: [String] = []
    @Published var contributions: [Double] = []
    @Published var withdrawals: [Double] = []
    
    // Computed Dashboard Values
    var numberOfMembers: Int {
        members.count
    }
    
    var totalContributions: Double {
        contributions.reduce(0, +)
    }
    
    var totalWithdrawals: Double {
        withdrawals.reduce(0, +)
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
        VStack{
            Text("Total Contribution: \(appData.totalContributions)")
            Text("Total Withdrawals: \(appData.totalWithdrawals)")
            Text(" Members: \(appData.numberOfMembers)")
        }
        
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



//import SwiftUI
//
//struct HomePage: View {
//    
//    var currentUser: Member   // 👈 RECEIVED FROM POPUP
//    
//    @State private var withdrawals = ""
//    @State private var NumberOfMembers = ""
//    @State private var RecentContributions = ""
//    @State private var UpcomingMeetingsAndTargets = ""
//    
//    var isAdmin: Bool {
//        currentUser.role.lowercased() == "admin"
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.orange.opacity(0.3)
//                    .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 25) {
//                        
//                        Text("Summary Dashboard")
//                            .font(.title)
//                            .fontWeight(.bold)
//                        
//                        Text("Logged in as: \(currentUser.name) (\(currentUser.role))")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        
//                        VStack(spacing: 20) {
//                            
//                            NavigationLink {
//                                MembersPage(currentUser: currentUser)
//                            } label: {
//                                SummaryCard(title: "Number of Members", value: NumberOfMembers, color: .gray)
//                            }
//                            
//                            NavigationLink {
//                                ContributionsPage(currentUser: currentUser)
//                            } label: {
//                                SummaryCard(title: "Recent Contributions", value: RecentContributions, color: .gray)
//                            }
//                            
//                            NavigationLink {
//                                WithdrawalsPage(currentUser: currentUser)
//                            } label: {
//                                SummaryCard(title: "Withdrawals", value: withdrawals, color: .brown)
//                            }
//                            
//                            
//                            SummaryCard(title: "Upcoming meetings/targets", value: UpcomingMeetingsAndTargets, color: .brown)
//                        }
//                    }
//                    .padding()
//                }
//            }
//        }
//    }
//}
//
//struct SummaryCard: View {
//    let title: String
//    let value: String
//    let color: Color
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 18) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white.opacity(0.8))
//
//            Text(value)
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//        }
//        .frame(maxWidth: .infinity, minHeight: 250)
//        .padding()
//        .background(color)
//        .cornerRadius(15)
//        .shadow(radius: 5)
//    }
//}
//
//#Preview {
//    HomePage(
//        currentUser: Member(
//            name: "Preview User",
//            email: "preview@example.com",
//            role: "Admin",
//            phone: "+1 555 0100"
//        )
//    )
//}

//import SwiftUI
//
//struct HomePage: View{
//    
//    @State private var withdrawals = ""
//    @State private var NumberOfMembers = ""
//    @State private var RecentContributions = ""
//    @State private var UpcomingMeetingsAndTargets = ""
//    @State private var isTaped = false
//    
//    
//    var body: some View {
//        NavigationStack{
//            ZStack{
//                Color.orange.opacity(0.3)
//                    .ignoresSafeArea()
//                
//                ScrollView{
//                    VStack(alignment: .leading, spacing: 25){
//                        Text("Summary Dashboard")
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                        
//                        
//                        Spacer()
//                        
//                        
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                    
//                    VStack{
//                        VStack(spacing: 20) {
//                            NavigationLink {
//                                MembersPage()
//                            } label: {
//                                SummaryCard(title: "Number of Members", value: "\(NumberOfMembers)", color: .gray)
//                                
//                                HStack(spacing: 20) {
//                                    NavigationLink {
//                                        ContributionsPage()
//                                    }label:{
//                                        SummaryCard(title: "  Recent Contributions", value: "\(RecentContributions)", color: .gray)
//                                    }
//                                    
//                                    
//                                }
//                                
//                            }
//                           
//                                HStack(spacing: 20){
//                                    NavigationLink {
//                                        WithdrawalsPage()
//                                    }label: {
//                                        SummaryCard(title: "withdrawals", value: "\(withdrawals)", color: .brown)
//                                    }
//                                    
//                                }
//                            
//                            HStack(spacing: 20){
//                                
//                                SummaryCard(title: "Upcoming meetings/targets", value: "\(UpcomingMeetingsAndTargets)", color: .brown)
//                            }
//                        }
//                    }
//                            .padding(.horizontal)
//                            
//                        }
//                        
//                    }
//                }
//            }
//        }
//    
//    
//    struct SummaryCard: View {
//        var title: String
//        var value: String
//        var color: Color
//        
//        var body: some View {
//            VStack {
//                VStack(alignment: .center, spacing: 18) {
//                    Text(title)
//                        .font(.headline)
//                        .foregroundColor(.white.opacity(0.8))
//                    Text(value)
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                }
//                .frame(maxWidth: .infinity, minHeight: 250)
//                .padding()
//                .background(color)
//                .cornerRadius(15)
//                .shadow(radius: 5)
//            }
//        }
//        
//        
//        struct ActionButton: View {
//            var title: String
//            var icon: String
//            var color: Color
//            
//            var body: some View {
//                VStack(spacing: 10) {
//                    Image(systemName: icon)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.white)
//                    Text(title)
//                        .font(.footnote)
//                        .foregroundColor(.white)
//                }
//                .frame(width: 130, height: 100)
//                .background(color)
//                .cornerRadius(15)
//                .shadow(radius: 3)
//            }
//        }
//    }
//
//#Preview {
//    HomePage()
//}
