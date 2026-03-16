//
//  contributions page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/23/25.



import SwiftUI
import Foundation

// MARK: - Model
struct Contribution: Identifiable, Codable, Equatable {
    var id = UUID()
    var memberName: String
    var amount: Double
    var date: Date
    var notes: String
}

// MARK: - View
struct ContributionsPage: View {
    let isAdmin: Bool  // Role-based access

    @State private var contributions: [Contribution] = []

    // Form fields
    @State private var memberName = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var notes = ""

    // Editing
    @State private var editingContribution: Contribution? = nil
    @State private var showForm = false

    var totalContributions: Double {
        contributions.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack {
            Text("Total Contributions: $\(totalContributions, specifier: "%.2f")")
                .font(.title2)
                .padding()

            List {
                ForEach(contributions) { contribution in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(contribution.memberName).bold()
                            Spacer()
                            Text("$\(contribution.amount, specifier: "%.2f")").bold()
                        }
                        Text("Date: \(contribution.date.formatted(date: .abbreviated, time: .omitted))")
                        if !contribution.notes.isEmpty {
                            Text("Notes: \(contribution.notes)").italic()
                        }
                    }
                    .contextMenu {
                        if isAdmin {
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
                                    saveContributions()
                                }
                            }
                        }
                    }
                }
            }

            if isAdmin {
                Button("Add Contribution") {
                    editingContribution = nil
                    memberName = ""
                    amount = ""
                    date = Date()
                    notes = ""
                    showForm = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
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
                            contributions.append(
                                Contribution(memberName: memberName, amount: amountValue, date: date, notes: notes)
                            )
                        }

                        editingContribution = nil
                        showForm = false
                        saveContributions()
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
        .onAppear { loadContributions() }
    }

    // MARK: - Persistence
    func saveContributions() {
        if let encoded = try? JSONEncoder().encode(contributions) {
            UserDefaults.standard.set(encoded, forKey: "savedContributions")
        }
    }

    func loadContributions() {
        if let data = UserDefaults.standard.data(forKey: "savedContributions"),
           let decoded = try? JSONDecoder().decode([Contribution].self, from: data) {
            contributions = decoded
        }
    }
}

// MARK: - Preview
struct ContributionsPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContributionsPage(isAdmin: true)
                .previewDisplayName("Admin View")
            ContributionsPage(isAdmin: false)
                .previewDisplayName("Member View")
        }
    }
}






