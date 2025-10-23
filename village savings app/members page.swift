//
//  members page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/21/25.
//

import SwiftUI

// MARK: - Model
struct Member: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var email: String
    var role: String
    var phone: String
}

// MARK: - Main View
struct MembersPage: View {
    @State private var searchText = ""
    @State private var members: [Member] = [
        Member(name: "Shine", email: "shine@example.com", role: "Leader", phone: "+263 78 777 7890"),
        Member(name: "Sarah", email: "sarah@example.com", role: "Member", phone: " +263 77 567 8901"),
        Member(name: "Lucy", email: "lucy@example.com", role: "Secretary", phone: "+263 71 678 9012"),
        Member(name: "Tana", email: "tana@example.com", role: "Treasurer", phone: "+263 77 789 0123"),
        Member(name: "Boity", email: "boity@example.com", role: "Member", phone: "+263 77 789 0123"),
        Member(name: "Ama", email: "ama@example.com", role: "Member", phone: "+263 77 789 0123"),
        Member(name: "Privie", email: "privie@example.com", role: "Member", phone: "+263 77 789 0123"),
        Member(name: "Octie", email: "octie@example.com", role: "Member", phone: "+263 77 789 0123"),
    ]
    @State private var showingAddSheet = false
    @State private var showingRemoveSheet = false

    // Filtered search results
    var filteredMembers: [Member] {
        if searchText.isEmpty {
            return members
        } else {
            return members.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText) ||
                $0.role.localizedCaseInsensitiveContains(searchText) ||
                $0.phone.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.orange.opacity(0.3)
                    .ignoresSafeArea()

                VStack {
                    VStack {
                        List(filteredMembers) { member in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(member.name).font(.headline)
                                Text(member.email).font(.subheadline).foregroundColor(.gray)
                                Text("Role: \(member.role)").font(.subheadline)
                                Text("Phone: \(member.phone)").font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                        .listStyle(PlainListStyle())
                        .searchable(text: $searchText, prompt: "Search members")

                        Spacer()

                        // Buttons at the bottom
                        HStack(spacing: 16) {
                            Button(action: {
                                showingAddSheet = true
                            }) {
                                Text("Add")
                                    .frame(minWidth: 70)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                print("Edit tapped")
                            }) {
                                Text("Edit")
                                    .frame(minWidth: 70)
                                    .padding()
                                    .background(Color.brown)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                showingRemoveSheet = true
                            }) {
                                Text("Remove")
                                    .frame(minWidth: 70)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
                .navigationTitle("Members")
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddMemberSheet { newMember in
                members.append(newMember)
            }
        }
        .sheet(isPresented: $showingRemoveSheet) {
            RemoveMembersSheet(members: members) { selectedToRemove in
                members.removeAll { selectedToRemove.contains($0) }
            }
        }
    }
}

// MARK: - Add Member Sheet
struct AddMemberSheet: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var role = ""
    @State private var phone = ""

    var onAdd: (Member) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Info")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Role", text: $role)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Add Member")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newMember = Member(name: name, email: email, role: role, phone: phone)
                        onAdd(newMember)
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty || role.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}

// MARK: - Remove Members Sheet with ScrollView
struct RemoveMembersSheet: View {
    let members: [Member]
    var onRemove: ([Member]) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var selectedMembers: Set<Member> = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Remove Members")
                    .font(.headline)
                Spacer()
                Button("Remove") {
                    onRemove(Array(selectedMembers))
                    dismiss()
                }
                .foregroundColor(selectedMembers.isEmpty ? .gray : .red)
                .disabled(selectedMembers.isEmpty)
            }
            .padding()
            .background(Color(UIColor.systemGray6))

            Divider()

            // Member List in ScrollView
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(members) { member in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(member.name.prefix(1))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )

                            VStack(alignment: .leading) {
                                Text(member.name).font(.headline)
                                Text(member.role).font(.subheadline).foregroundColor(.gray)
                            }

                            Spacer()

                            Button(action: {
                                toggleSelection(member)
                            }) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    if selectedMembers.contains(member) {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 12, weight: .bold))
                                            )
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }

            Divider()

            // Optional bottom button
            Button(action: {
                onRemove(Array(selectedMembers))
                dismiss()
            }) {
                Text("Remove Selected Members")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedMembers.isEmpty ? Color.gray : Color.red)
                    .cornerRadius(10)
                    .padding([.horizontal, .bottom])
            }
            .disabled(selectedMembers.isEmpty)
        }
        .background(Color.white)
        .cornerRadius(20)
    }

    func toggleSelection(_ member: Member) {
        if selectedMembers.contains(member) {
            selectedMembers.remove(member)
        } else {
            selectedMembers.insert(member)
        }
    }
}

// MARK: - Preview
#Preview {
    MembersPage()
}
