//
//  ScheduleView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 1/25/26.
//

import SwiftUI
import MapKit

struct ScheduleView: View {
    @ObservedObject private var userManager = UserManager.shared
    @State private var pantries: [Pantry] = []
    @State private var todaysSchedule: [TodaysScheduleItem] = []
    @State private var isLoading = false
    @State private var selectedPantryId: String?
    @State private var showPantrySchedule = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's Schedule Section (if user has any)
                if !todaysSchedule.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Schedule")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Colors.flexibleBlack)
                            .padding(.horizontal)
                        
                        ForEach(todaysSchedule) { item in
                            TodaysScheduleCard(item: item)
                        }
                    }
                    .padding(.top)
                    
                    Divider()
                        .padding(.vertical)
                }
                
                // All Pantries Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(todaysSchedule.isEmpty ? "Volunteer Opportunities" : "All Food Pantries")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.flexibleBlack)
                        .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if pantries.isEmpty {
                        Text("No food pantries available")
                            .foregroundColor(Colors.flexibleDarkGray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        ForEach(pantries) { pantry in
                            PantryCard(pantry: pantry) {
                                selectedPantryId = pantry._id
                                showPantrySchedule = true
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("Volunteer Schedule")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            fetchPantries()
        }
        .sheet(isPresented: $showPantrySchedule) {
            if let pantryId = selectedPantryId,
               let pantry = pantries.first(where: { $0._id == pantryId }) {
                PantryScheduleDetailView(pantry: pantry)
            }
        }
    }
    
    private func fetchPantries() {
        isLoading = true
        
        guard let url = URL(string: "https://yellow-team.onrender.com/pantry/") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { DispatchQueue.main.async { isLoading = false } }
            
            guard let data = data, error == nil else {
                print("Error fetching pantries: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            do {
                let result = try JSONDecoder().decode([String: [Pantry]].self, from: data)
                if let fetchedPantries = result["pantries"] {
                    DispatchQueue.main.async {
                        self.pantries = fetchedPantries
                        // After loading pantries, check for user's today schedule
                        checkTodaysSchedule()
                    }
                }
            } catch {
                print("Error decoding pantries: \(error)")
            }
        }.resume()
    }
    
    private func checkTodaysSchedule() {
        guard let username = userManager.currentUser?.username else { return }
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayKey = dateFormatter.string(from: today)
        
        var foundSchedules: [TodaysScheduleItem] = []
        let group = DispatchGroup()
        
        for pantry in pantries {
            group.enter()
            
            guard let url = URL(string: "https://yellow-team.onrender.com/pantry/\(pantry._id)/schedule?date=\(todayKey)") else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { group.leave() }
                
                guard let data = data, error == nil else { return }
                
                do {
                    let scheduleResponse = try JSONDecoder().decode(ScheduleResponse.self, from: data)
                    
                    // Check if user is in any shift
                    for shift in scheduleResponse.schedule {
                        if let volunteer = shift.volunteers.first(where: { $0.username?.lowercased() == username.lowercased() }) {
                            let item = TodaysScheduleItem(
                                pantryId: pantry._id,
                                pantryName: pantry.name,
                                pantryAddress: pantry.address ?? "",
                                shift: shift.shift,
                                time: shift.time,
                                role: volunteer.role,
                                date: todayKey
                            )
                            foundSchedules.append(item)
                        }
                    }
                } catch {
                    print("Error decoding schedule for \(pantry.name): \(error)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            self.todaysSchedule = foundSchedules
        }
    }
}

struct PantryCard: View {
    let pantry: Pantry
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(pantry.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.flexibleBlack)
                
                if let address = pantry.address {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(Colors.flexibleDarkGray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Colors.flexibleLightGray.opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Colors.flexibleLightGray, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

struct TodaysScheduleCard: View {
    let item: TodaysScheduleItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.pantryName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.flexibleBlack)
                    
                    HStack(spacing: 4) {
                        Text(item.shift)
                            .font(.subheadline)
                            .foregroundColor(Colors.flexibleBlack)
                        Text("•")
                            .foregroundColor(Colors.flexibleDarkGray)
                        Text(item.time)
                            .font(.subheadline)
                            .foregroundColor(Colors.flexibleDarkGray)
                    }
                    
                    Text("Role: \(item.role)")
                        .font(.subheadline)
                        .foregroundColor(Colors.flexibleDarkGray)
                }
                
                Spacer()
                
                Button(action: {
                    openDirections(to: item.pantryAddress)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.title2)
                        Text("Directions")
                            .font(.caption)
                    }
                    .foregroundColor(Colors.flexibleOrange)
                }
            }
        }
        .padding()
        .background(Colors.flexibleOrange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Colors.flexibleOrange, lineWidth: 1.5)
        )
        .padding(.horizontal)
    }
    
    private func openDirections(to address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else { return }
            
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            mapItem.name = item.pantryName
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }
}
