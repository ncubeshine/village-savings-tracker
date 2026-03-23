//
//  contributions page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/23/25.
//
import SwiftUI
import Foundation

// Model for a Contribution
struct Contribution: Identifiable, Codable, Equatable {
    
   
    
    var id = UUID()
    var memberName: String
    var amount: Double
    var date: Date
    var time: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    var notes: String
}

struct ContributionsPage: View {
    var currentUser: Member
    
    var isAdmin: Bool {
        currentUser.role.lowercased() == "admin"
    }
    
    
    
    @State private var contributions: [Contribution] = []
    
    // Form fields
    @State private var memberName = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var notes = ""
    
    // For editing
    @State private var editingContribution: Contribution? = nil
    @State private var showForm = false
    
    // Alert navigation
    @State private var showPostContributionAlert = false
    @State private var navigateToWithdrawals = false
    @State private var navigateToReports = false
    
    var totalContributions: Double {
        contributions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // Total Contributions
                Text("Total Contributions: $\(totalContributions, specifier: "%.2f")")
                    .font(.title2)
                    .padding()
                
                List {
                    ForEach(contributions) { contribution in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(contribution.memberName)
                                    .font(.headline)
                                Spacer()
                                Text("$\(contribution.amount, specifier: "%.2f")")
                                    .bold()
                            }
                            
                            Text("Date: \(contribution.date.formatted(date: .abbreviated, time: .omitted))")
                            
                            if !contribution.notes.isEmpty {
                                Text("Notes: \(contribution.notes)").italic()
                            }
                        }
                        .contextMenu {
                            Button("Edit") {
                                editingContribution = contribution
                                memberName = contribution.memberName
                                amount = "\(contribution.amount)"
                                date = contribution.date
                                notes = contribution.notes
                                showForm = true
                            }
                            
                            Button("Delete", role: .destructive) {
                                if let index = contributions.firstIndex(where: { $0.id == contribution.id }) {
                                    contributions.remove(at: index)
                                }
                            }
                        }
                    }
                }
                
                // Add Contribution Button
                Button(action: {
                    showForm = true
                    
                    if editingContribution == nil {
                        memberName = ""
                        amount = ""
                        date = Date()
                        notes = ""
                    }
                }) {
                    Text(editingContribution == nil ? "Add Contribution" : "Edit Contribution")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .disabled(!isAdmin)
                
                // Reports Button
                Button(action: {
                    navigateToReports = true
                }) {
                    Text("View Reports / History")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                NavigationLink(destination: WithdrawalsPage(currentUser: currentUser), isActive: $navigateToWithdrawals) {
                    EmptyView()
                }
                
                NavigationLink(destination: ReportsPage(), isActive: $navigateToReports) {
                    EmptyView()
                }
            }
            .navigationTitle("Contributions")
            
            // Load saved contributions when app opens
            .onAppear {
                loadContributions()
            }
            
            // Automatically save whenever contributions change
            .onChange(of: contributions) { _ in
                saveContributions()
            }
            
            .sheet(isPresented: $showForm) {
                NavigationView {
                    Form {
                        Section(header: Text(editingContribution == nil ? "Add Contribution" : "Edit Contribution")) {
                            
                            TextField("Member Name", text: $memberName)
                            
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                            
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                            
                            TextField("Notes (Optional)", text: $notes)
                        }
                        
                        Button(editingContribution == nil ? "Save" : "Update") {
                            
                            guard let amountValue = Double(amount) else { return }
                            
                            if let editing = editingContribution,
                               let index = contributions.firstIndex(where: { $0.id == editing.id }) {
                                
                                contributions[index].memberName = memberName
                                contributions[index].amount = amountValue
                                contributions[index].date = date
                                contributions[index].notes = notes
                                
                            } else {
                                
                                let newContribution = Contribution(
                                    memberName: memberName,
                                    amount: amountValue,
                                    date: date,
                                    notes: notes
                                )
                                
                                contributions.append(newContribution)
                                showPostContributionAlert = true
                            }
                            
                            editingContribution = nil
                            showForm = false
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .navigationTitle(editingContribution == nil ? "Add Contribution" : "Edit Contribution")
                    
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                editingContribution = nil
                                showForm = false
                            }
                        }
                    }
                }
            }
            
            .alert("Contribution Added", isPresented: $showPostContributionAlert) {
                Button("Go to Withdrawals") {
                    navigateToWithdrawals = true
                }
                
                Button("Stay on Contributions", role: .cancel) { }
                
            } message: {
                Text("Do you want to go to the Withdrawals page or stay here?")
            }
        }
    }
    
    // MARK: - Persistence Functions
    
    func saveContributions() {
        if let encoded = try? JSONEncoder().encode(contributions) {
            UserDefaults.standard.set(encoded, forKey: "savedContributions")
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

struct ContributionsPage_Previews: PreviewProvider {
    static var previews: some View {
        ContributionsPage(
            currentUser: Member(
                name: "Preview User",
                email: "preview@example.com",
                role: "Admin",
                phone: "+1 555 0100"
            )
        )
    }
}
