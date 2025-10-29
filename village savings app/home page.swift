//
//  home page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/17/25.
//

import SwiftUI

struct HomePage: View{
    @State private var totalSavings = 2000
    @State private var NumberOfMembers = 8
    @State private var RecentContributions = 1250
    @State private var UpcomingMeetingsAndTargets = ""
    @State private var isTaped = false
    
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.orange.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 25){
                        Text("Summary Dashboard")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        
                        Spacer()
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    VStack{
                        VStack(spacing: 20) {
                            NavigationLink {
                                MembersPage()
                            } label: {
                                SummaryCard(title: "👥 Number of Members", value: "\(NumberOfMembers)", color: .gray)
                                
                                HStack(spacing: 20) {
                                    NavigationLink {
                                        ContributionView()
                                    }label:{
                                        SummaryCard(title: " 💰Recent Contributions", value: "\(RecentContributions)", color: .gray)
                                    }
                                    
                                    
                                }
                                
                            }
                           
                                HStack(spacing: 20){
                                    SummaryCard(title: "💰Total Savings", value: "\(totalSavings)", color: .brown)
                                }
                            
                            HStack(spacing: 20){
                                
                                SummaryCard(title: "📅Upcoming meetings/targets🎯", value: "\(UpcomingMeetingsAndTargets)", color: .brown)
                            }
                        }
                    }
                            .padding(.horizontal)
                            
                        }
                        
                    }
                }
            }
        }
    
    
    struct SummaryCard: View {
        var title: String
        var value: String
        var color: Color
        
        var body: some View {
            VStack {
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
        
        
        struct ActionButton: View {
            var title: String
            var icon: String
            var color: Color
            
            var body: some View {
                VStack(spacing: 10) {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text(title)
                        .font(.footnote)
                        .foregroundColor(.white)
                }
                .frame(width: 130, height: 100)
                .background(color)
                .cornerRadius(15)
                .shadow(radius: 3)
            }
        }
    }

#Preview {
    HomePage()
}
