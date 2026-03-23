//
//  description page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/17/25.
//

import SwiftUI

struct DescriptionPage: View {
    
    // 👇 SAME members list used everywhere
    let members: [Member] = [
        Member(name: "Shine", email: "shine@example.com", role: "Admin", phone: "+263 78 777 7890"),
        Member(name: "Sarah", email: "sarah@example.com", role: "Member", phone: "+263 77 567 8901"),
        Member(name: "Lucy", email: "lucy@example.com", role: "Members", phone: "+263 71 678 9012"),
        Member(name: "Tana", email: "tana@example.com", role: "Member", phone: "+263 77 789 0123"),
        Member(name: "Boity", email: "boity@example.com", role: "Member", phone: "+263 77 789 0123"),
        Member(name: "Ama", email: "ama@example.com", role: "Admin", phone: "+263 77 789 0123"),
        Member(name: "Privie", email: "privie@example.com", role: "Member", phone: "+263 77 789 0123"),
        Member(name: "Octie", email: "octie@example.com", role: "Member", phone: "+263 77 789 0123"),
    ]
    
    @State private var showPopup = false
    @State private var selectedUser: Member? = nil
    @State private var goToHome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.orange.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 50) {
                    
                    Text("Communities always have challenges (e.g human error, lack of consistency, time consumed) when tracking savings. UbuntuFund Savings Tracker helps local savings groups track contributions, payouts, and interest.")
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                        .font(.headline)
                    
                    // 👇 BUTTON (NOT NavigationLink anymore)
                    Button("Next") {
                        showPopup = true
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // 👇 POPUP
            .sheet(isPresented: $showPopup) {
                RoleSelectionView(members: members) { user in
                    selectedUser = user
                    showPopup = false
                    goToHome = true
                }
            }
            
            // 👇 NAVIGATION AFTER SELECTION
            .background(
                NavigationLink(
                    destination: selectedUser.map { user in
                        AnyView(HomePage(currentUser: user))
                    } ?? AnyView(EmptyView()),
                    isActive: $goToHome
                ) {
                    EmptyView()
                }
            )
        }
    }
}

struct RoleSelectionView: View {
    let members: [Member]
    let onSelect: (Member) -> Void

    var body: some View {
        NavigationStack {
            List(members) { member in
                Button {
                    onSelect(member)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(member.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(member.role)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Choose Member")
        }
    }
}

#Preview {
    DescriptionPage()
}

//import SwiftUI
//
//struct descriptionPage: View {
//    
//    var body: some View {
//        NavigationStack{
//            ZStack{
//                Color.orange.opacity(0.3)
//                    .ignoresSafeArea()
//                VStack (spacing: 50){
//                    
//                    Text("Communities always have challenges (e.g human error, lack of consistence, time consumed ) when it comes to keeping  track of  savings progress as a result UbuntuFund Savings Tracker is here to save the purpose  of helping the local savings group(mukando/stokvel) track their contributions, payouts and the interests earned")
//                        .multilineTextAlignment(.center)
//                        .frame(width: 300)
//                        .font(.headline)
//                       //.padding(.trailing)
//                    
//                    
//                    
//                    //NavigationLink {
//                       // homePage()
//                    //} label: {
//                    NavigationLink(destination: HomePage()) {
//                        Text("Next")
//                            .padding()
//                            .background(Color.black)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                        
//                           
//                        
//                    }
//                    
//                }
//            }
//        }
//        
//        }
//        
//        
//    
//
//
//#Preview {
// descriptionPage()
//}
