//
//  PantryScheduleDetailView.swift
//  PantryLink
//
//  Created for volunteer scheduling system
//

import SwiftUI

struct PantryScheduleDetailView: View {
    let pantry: Pantry
    @ObservedObject private var userManager = UserManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var shifts: [Shift] = []
    @State private var isLoading = false
    @State private var showAddSheet = false
    @State private var selectedShiftId: Int?
    @State private var userRole = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showEditSheet = false
    @State private var editingVolunteerShiftId: Int?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date Selector
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .background(Colors.flexibleLightGray.opacity(0.2))
                    .onChange(of: selectedDate) { _ in
                        fetchSchedule()
                    }
                
                Divider()
                
                // Content
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else if shifts.isEmpty {
                        VStack(spacing: 16) {
                            Text("No shifts have been created")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleDarkGray)
                                .padding(.top, 100)
                            
                            Text("You can still add yourself to volunteer for this day")
                                .font(.subheadline)
                                .foregroundColor(Colors.flexibleDarkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    } else {
                        VStack(spacing: 16) {
                            ForEach(shifts) { shift in
                                ShiftCard(
                                    shift: shift,
                                    currentUsername: userManager.currentUser?.username ?? "",
                                    onEdit: {
                                        editingVolunteerShiftId = shift.id
                                        if let volunteer = shift.volunteers.first(where: {
                                            $0.username?.lowercased() == userManager.currentUser?.username.lowercased()
                                        }) {
                                            userRole = volunteer.role
                                            showEditSheet = true
                                        }
                                    },
                                    onRemove: {
                                        removeFromShift(shiftId: shift.id)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(pantry.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if shifts.isEmpty {
                            // No shifts exist, add directly
                            selectedShiftId = nil
                            userRole = ""
                            showAddSheet = true
                        } else {
                            // Shifts exist, let user select
                            selectedShiftId = nil
                            userRole = ""
                            showAddSheet = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Colors.flexibleOrange)
                    }
                }
            }
            .onAppear {
                fetchSchedule()
            }
            .sheet(isPresented: $showAddSheet) {
                AddToScheduleSheet(
                    shifts: shifts,
                    selectedShiftId: $selectedShiftId,
                    userRole: $userRole,
                    onSave: {
                        addToSchedule()
                    }
                )
            }
            .sheet(isPresented: $showEditSheet) {
                EditScheduleSheet(
                    userRole: $userRole,
                    onSave: {
                        updateSchedule()
                    },
                    onRemove: {
                        if let shiftId = editingVolunteerShiftId {
                            removeFromShift(shiftId: shiftId)
                        }
                    }
                )
            }
            .alert("Schedule Update", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func fetchSchedule() {
        isLoading = true
        let dateKey = dateFormatter.string(from: selectedDate)
        
        guard let url = URL(string: "https://yellow-team.onrender.com/pantry/\(pantry._id)/schedule?date=\(dateKey)") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { DispatchQueue.main.async { isLoading = false } }
            
            guard let data = data, error == nil else {
                print("Error fetching schedule: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            do {
                let scheduleResponse = try JSONDecoder().decode(ScheduleResponse.self, from: data)
                DispatchQueue.main.async {
                    self.shifts = scheduleResponse.schedule
                }
            } catch {
                print("Error decoding schedule: \(error)")
                DispatchQueue.main.async {
                    self.shifts = []
                }
            }
        }.resume()
    }
    
    private func addToSchedule() {
        guard let username = userManager.currentUser?.username,
              let firstName = userManager.currentUser?.first_name,
              let lastName = userManager.currentUser?.last_name,
              let email = userManager.currentUser?.email else {
            alertMessage = "User information not available"
            showAlert = true
            return
        }
        
        let dateKey = dateFormatter.string(from: selectedDate)
        
        var updatedShifts = shifts
        let volunteerName = "\(firstName) \(lastName)"
        
        let newVolunteer = ShiftVolunteer(
            name: volunteerName,
            role: userRole,
            email: email,
            username: username
        )
        
        if let shiftId = selectedShiftId {
            // Add to specific shift
            if let index = updatedShifts.firstIndex(where: { $0.id == shiftId }) {
                var updatedShift = updatedShifts[index]
                var volunteers = updatedShift.volunteers
                volunteers.append(newVolunteer)
                updatedShifts[index] = Shift(
                    id: updatedShift.id,
                    time: updatedShift.time,
                    shift: updatedShift.shift,
                    volunteers: volunteers
                )
            }
        } else if shifts.isEmpty {
            // No shifts exist, create a general volunteer entry
            updatedShifts = [Shift(
                id: 1,
                time: "Available",
                shift: "General Volunteer",
                volunteers: [newVolunteer]
            )]
        }
        
        saveSchedule(updatedShifts: updatedShifts, dateKey: dateKey)
    }
    
    private func updateSchedule() {
        guard let username = userManager.currentUser?.username,
              let shiftId = editingVolunteerShiftId else { return }
        
        let dateKey = dateFormatter.string(from: selectedDate)
        var updatedShifts = shifts
        
        if let shiftIndex = updatedShifts.firstIndex(where: { $0.id == shiftId }),
           let volunteerIndex = updatedShifts[shiftIndex].volunteers.firstIndex(where: {
               $0.username?.lowercased() == username.lowercased()
           }) {
            var volunteers = updatedShifts[shiftIndex].volunteers
            volunteers[volunteerIndex] = ShiftVolunteer(
                name: volunteers[volunteerIndex].name,
                role: userRole,
                email: volunteers[volunteerIndex].email,
                username: volunteers[volunteerIndex].username
            )
            updatedShifts[shiftIndex] = Shift(
                id: updatedShifts[shiftIndex].id,
                time: updatedShifts[shiftIndex].time,
                shift: updatedShifts[shiftIndex].shift,
                volunteers: volunteers
            )
        }
        
        saveSchedule(updatedShifts: updatedShifts, dateKey: dateKey)
    }
    
    private func removeFromShift(shiftId: Int) {
        guard let username = userManager.currentUser?.username else { return }
        
        let dateKey = dateFormatter.string(from: selectedDate)
        var updatedShifts = shifts
        
        if let shiftIndex = updatedShifts.firstIndex(where: { $0.id == shiftId }) {
            var volunteers = updatedShifts[shiftIndex].volunteers.filter {
                $0.username?.lowercased() != username.lowercased()
            }
            updatedShifts[shiftIndex] = Shift(
                id: updatedShifts[shiftIndex].id,
                time: updatedShifts[shiftIndex].time,
                shift: updatedShifts[shiftIndex].shift,
                volunteers: volunteers
            )
        }
        
        saveSchedule(updatedShifts: updatedShifts, dateKey: dateKey)
    }
    
    private func saveSchedule(updatedShifts: [Shift], dateKey: String) {
        guard let url = URL(string: "https://yellow-team.onrender.com/pantry/\(pantry._id)/schedule/\(dateKey)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = ["schedule": try! JSONSerialization.jsonObject(with: JSONEncoder().encode(updatedShifts))]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    alertMessage = "Failed to update schedule"
                    showAlert = true
                } else {
                    alertMessage = "Schedule updated successfully"
                    showAlert = true
                    fetchSchedule()
                }
                showAddSheet = false
                showEditSheet = false
            }
        }.resume()
    }
}

struct ShiftCard: View {
    let shift: Shift
    let currentUsername: String
    let onEdit: () -> Void
    let onRemove: () -> Void
    
    var isUserInShift: Bool {
        shift.volunteers.contains(where: { $0.username?.lowercased() == currentUsername.lowercased() })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shift.shift)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.flexibleBlack)
                    
                    Text(shift.time)
                        .font(.subheadline)
                        .foregroundColor(Colors.flexibleDarkGray)
                }
                
                Spacer()
                
                if isUserInShift {
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit Role", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: onRemove) {
                            Label("Remove", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(Colors.flexibleOrange)
                    }
                }
            }
            
            if !shift.volunteers.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Volunteers:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Colors.flexibleBlack)
                    
                    ForEach(shift.volunteers) { volunteer in
                        HStack {
                            Circle()
                                .fill(volunteer.username?.lowercased() == currentUsername.lowercased() ?
                                      Colors.flexibleOrange : Colors.flexibleLightGray)
                                .frame(width: 6, height: 6)
                            
                            Text(volunteer.name)
                                .font(.subheadline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            Text("•")
                                .foregroundColor(Colors.flexibleDarkGray)
                            
                            Text(volunteer.role)
                                .font(.subheadline)
                                .foregroundColor(Colors.flexibleDarkGray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(isUserInShift ? Colors.flexibleOrange.opacity(0.1) : Colors.flexibleLightGray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUserInShift ? Colors.flexibleOrange : Colors.flexibleLightGray, lineWidth: isUserInShift ? 1.5 : 1)
        )
    }
}

struct AddToScheduleSheet: View {
    let shifts: [Shift]
    @Binding var selectedShiftId: Int?
    @Binding var userRole: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                if !shifts.isEmpty {
                    Section("Select Shift") {
                        Picker("Shift", selection: $selectedShiftId) {
                            Text("Select a shift").tag(nil as Int?)
                            ForEach(shifts) { shift in
                                Text("\(shift.shift) - \(shift.time)").tag(shift.id as Int?)
                            }
                        }
                    }
                }
                
                Section("Your Role") {
                    TextField("Enter your role (e.g., Food Sorter, Delivery)", text: $userRole)
                }
            }
            .navigationTitle("Add to Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if shifts.isEmpty || selectedShiftId != nil {
                            onSave()
                        }
                    }
                    .disabled(userRole.isEmpty || (!shifts.isEmpty && selectedShiftId == nil))
                }
            }
        }
    }
}

struct EditScheduleSheet: View {
    @Binding var userRole: String
    let onSave: () -> Void
    let onRemove: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Your Role") {
                    TextField("Enter your role", text: $userRole)
                }
                
                Section {
                    Button(role: .destructive, action: {
                        onRemove()
                        dismiss()
                    }) {
                        Text("Remove from Schedule")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Edit Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(userRole.isEmpty)
                }
            }
        }
    }
}
