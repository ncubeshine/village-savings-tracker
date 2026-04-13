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
    @EnvironmentObject var appData: AppData
    
    var isAdmin: Bool {
        currentUser.role.lowercased() == "admin"
    }
    
    
    
   
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
        appData.contributions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            mainContent
            .navigationTitle("Contributions")
            .navigationDestination(isPresented: $navigateToWithdrawals) {
                WithdrawalsPage(currentUser: currentUser)
            }
            .navigationDestination(isPresented: $navigateToReports) {
                ReportsPage()
            }
            
            // Load saved contributions when app opens
            .onAppear {
                loadContributions()
            }
            
            // Automatically save whenever contributions change
            .onChange(of: appData.contributions) {
                saveContributions()
            }
            
            .sheet(isPresented: $showForm) {
                /*appData.*/contributionFormView
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

    private var mainContent: some View {
        VStack {
            Text("Total Contributions: $\(totalContributions, specifier: "%.2f")")
                .font(.title2)
                .padding()

            List {
                ForEach(appData.contributions) { contribution in
                    contributionRow(for: contribution)
                }
            }

            addContributionButton
            reportsButton
        }
    }

    private func contributionRow(for contribution: Contribution) -> some View {
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
                Text("Notes: \(contribution.notes)")
                    .italic()
            }
        }
        .contextMenu {
            Button("Edit") {
                startEditing(contribution)
            }

            Button("Delete", role: .destructive) {
                deleteContribution(contribution)
            }
        }
    }

    private var addContributionButton: some View {
        Button(action: startAddingContribution) {
            Text(editingContribution == nil ? "Add Contribution" : "Edit Contribution")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
        }
        .disabled(!isAdmin)
    }

    private var reportsButton: some View {
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
    }

    private var contributionFormView: some View {
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
                    saveContribution()
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
                        cancelEditing()
                    }
                }
            }
        }
    }
    
    // MARK: - Persistence Functions
    
    func saveContributions() {
        if let encoded = try? JSONEncoder().encode(appData.contributions) {
            UserDefaults.standard.set(encoded, forKey: "savedContributions")
        }
    }
    
    func loadContributions() {
        if let data = UserDefaults.standard.data(forKey: "savedContributions") {
            if let decoded = try? JSONDecoder().decode([Contribution].self, from: data) {
                appData.contributions = decoded
            }
        }
    }

    private func startAddingContribution() {
        showForm = true

        if editingContribution == nil {
            memberName = ""
            amount = ""
            date = Date()
            notes = ""
        }
    }

    private func startEditing(_ contribution: Contribution) {
        editingContribution = contribution
        memberName = contribution.memberName
        amount = "\(contribution.amount)"
        date = contribution.date
        notes = contribution.notes
        showForm = true
    }

    private func deleteContribution(_ contribution: Contribution) {
        guard let index = appData.contributions.firstIndex(where: { $0.id == contribution.id }) else {
            return
        }

        appData.contributions.remove(at: index)
    }

    private func saveContribution() {
        guard let amountValue = Double(amount) else { return }

        if let editing = editingContribution,
           let index = appData.contributions.firstIndex(where: { $0.id == editing.id }) {
            appData.contributions[index].memberName = memberName
            appData.contributions[index].amount = amountValue
            appData.contributions[index].date = date
            appData.contributions[index].notes = notes
        } else {
            let newContribution = Contribution(
                memberName: memberName,
                amount: amountValue,
                date: date,
                notes: notes
            )

            appData.contributions.append(newContribution)
            showPostContributionAlert = true
        }

        editingContribution = nil
        showForm = false
    }

    private func cancelEditing() {
        editingContribution = nil
        showForm = false
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
        .environmentObject(AppData())
    }
}
