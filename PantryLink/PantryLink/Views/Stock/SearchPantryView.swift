//
//  SearchPantryView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 1/24/26.
//

import SwiftUI
import MapKit

struct SearchPantryView: View {
    @StateObject private var viewModel = StreamViewViewModel()
    @ObservedObject var locationManager = LocationManager.shared
    @State private var searchText = ""
    @State private var pantryLinkPantries: [Pantry] = [] // Pantries with stock from API
    @State private var googleSheetPantries: [MKMapItem] = [] // Pantries from Google Sheets only
    @State private var isLoading = true
    @State private var selectedPantry: Pantry?
    @State private var selectedMapItem: MKMapItem?
    @State private var showDetailView = false
    @State private var showMapItemPopup = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    // Filter PantryLink pantries based on search text
    var filteredPantryLinkPantries: [Pantry] {
        if searchText.isEmpty {
            return pantryLinkPantries
        }
        
        let lowercasedSearch = searchText.lowercased()
        
        return pantryLinkPantries.filter { pantry in
            // Search by pantry name
            let nameMatch = pantry.name.lowercased().contains(lowercasedSearch)
            
            // Search by address (includes city, state, zip)
            let addressMatch = pantry.address?.lowercased().contains(lowercasedSearch) ?? false
            
            // Extract and search by zip code specifically
            let zipMatch = extractZipCode(from: pantry.address ?? "").contains(searchText)
            
            // Search by items in stock
            let itemMatch = pantry.stock?.contains { item in
                item.name.lowercased().contains(lowercasedSearch) ||
                item.type.lowercased().contains(lowercasedSearch)
            } ?? false
            
            return nameMatch || addressMatch || zipMatch || itemMatch
        }
    }
    
    // Filter Google Sheet pantries based on search text (no item search)
    var filteredGoogleSheetPantries: [MKMapItem] {
        if searchText.isEmpty {
            return googleSheetPantries
        }
        
        let lowercasedSearch = searchText.lowercased()
        
        return googleSheetPantries.filter { mapItem in
            // Search by pantry name
            let nameMatch = mapItem.name?.lowercased().contains(lowercasedSearch) ?? false
            
            // Search by city
            let cityMatch = mapItem.placemark.locality?.lowercased().contains(lowercasedSearch) ?? false
            
            // Search by state
            let stateMatch = mapItem.placemark.administrativeArea?.lowercased().contains(lowercasedSearch) ?? false
            
            // Search by zip code
            let zipMatch = mapItem.placemark.postalCode?.contains(searchText) ?? false
            
            return nameMatch || cityMatch || stateMatch || zipMatch
        }
    }
    
    // Get matching items for a pantry (for display purposes)
    func getMatchingItems(for pantry: Pantry) -> [PantryItem] {
        guard !searchText.isEmpty,
              let stock = pantry.stock else {
            return []
        }
        
        let lowercasedSearch = searchText.lowercased()
        return stock.filter { item in
            item.name.lowercased().contains(lowercasedSearch) ||
            item.type.lowercased().contains(lowercasedSearch)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(.stockDarkTan)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title
                    Text("Search Pantries")
                        .foregroundColor(.white)
                        .bold()
                        .font(.largeTitle)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Colors.flexibleDarkGray)
                            .padding(.leading, 12)
                        
                        TextField("Search by name, item, city, or zip code", text: $searchText)
                            .padding(.vertical, 12)
                            .foregroundColor(Colors.flexibleBlack)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Colors.flexibleDarkGray)
                                    .padding(.trailing, 12)
                            }
                        }
                    }
                    .background(Colors.flexibleWhite)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // Results
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Loading pantries...")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .frame(maxHeight: .infinity)
                    } else if filteredPantryLinkPantries.isEmpty && filteredGoogleSheetPantries.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: searchText.isEmpty ? "building.2" : "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            
                            Text(searchText.isEmpty ? "Start searching for pantries" : "No pantries found")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            if !searchText.isEmpty {
                                Text("Try searching by:\n• Pantry name\n• Item name (e.g., \"beans\", \"pasta\")\n• City or town\n• Zip code")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, 40)
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Show count of results
                                if !searchText.isEmpty {
                                    let totalResults = filteredPantryLinkPantries.count + filteredGoogleSheetPantries.count
                                    Text("\(totalResults) result\(totalResults == 1 ? "" : "s") found")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding(.top, 8)
                                }
                                
                                // PantryLink Pantries Section
                                if !filteredPantryLinkPantries.isEmpty {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("PantryLink Pantries")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.top, 8)
                                        
                                        ForEach(filteredPantryLinkPantries) { pantry in
                                            PantrySearchCard(
                                                pantry: pantry,
                                                searchText: searchText,
                                                matchingItems: getMatchingItems(for: pantry)
                                            ) {
                                                selectedPantry = pantry
                                                showDetailView = true
                                            }
                                        }
                                    }
                                }
                                
                                // Google Sheet Pantries Section
                                if !filteredGoogleSheetPantries.isEmpty {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Pantries not on PantryLink yet")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.top, filteredPantryLinkPantries.isEmpty ? 8 : 24)
                                        
                                        ForEach(Array(filteredGoogleSheetPantries.enumerated()), id: \.offset) { index, mapItem in
                                            BasicPantryCard(mapItem: mapItem) {
                                                selectedMapItem = mapItem
                                                showMapItemPopup = true
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 100)
                            .frame(maxWidth: isIPad ? 700 : 340)
                        }
                    }
                }
                .frame(maxWidth: isIPad ? 800 : .infinity)
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationDestination(isPresented: $showDetailView) {
                if let pantry = selectedPantry {
                    PantryDetailView(pantry: pantry)
                }
            }
            .sheet(isPresented: $showMapItemPopup) {
                if let mapItem = selectedMapItem {
                    BasicPantryPopUpView(mapItem: mapItem)
                        .presentationDetents([.medium, .large])
                }
            }
        }
        .task {
            await loadPantries()
        }
    }
    
    // Load pantries from both API and Google Sheets
    private func loadPantries() async {
        do {
            // Load PantryLink pantries from API
            let response = try await viewModel.getStreams()
            pantryLinkPantries = response.pantries
            
            // Get Google Sheet pantries from LocationManager
            let allGooglePantries = locationManager.knownNJPantries
            
            // Filter out pantries that are already on PantryLink
            // Compare by name (case-insensitive)
            let pantryLinkNames = Set(pantryLinkPantries.map { $0.name.lowercased() })
            googleSheetPantries = allGooglePantries.filter { mapItem in
                guard let name = mapItem.name else { return false }
                return !pantryLinkNames.contains(name.lowercased())
            }
            
            print("✅ Loaded \(pantryLinkPantries.count) PantryLink pantries")
            print("✅ Loaded \(googleSheetPantries.count) Google Sheet pantries not on PantryLink")
            
            isLoading = false
        } catch {
            print("Error loading pantries: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // Extract zip code from address string
    private func extractZipCode(from address: String) -> String {
        // Look for 5-digit zip code pattern
        let zipPattern = "\\b\\d{5}\\b"
        if let range = address.range(of: zipPattern, options: .regularExpression) {
            return String(address[range])
        }
        return ""
    }
}

// Helper view to display a single pantry in search results
struct PantrySearchCard: View {
    let pantry: Pantry
    let searchText: String
    let matchingItems: [PantryItem]
    let onTap: () -> Void
    
    // Show matching items if search found items, otherwise show top 3 items
    var displayItems: [PantryItem] {
        if !matchingItems.isEmpty {
            // Show up to 3 matching items
            return Array(matchingItems.prefix(3))
        } else {
            // Show top 3 items as default
            guard let stock = pantry.stock, !stock.isEmpty else { return [] }
            return Array(stock.prefix(3))
        }
    }
    
    var body: some View {
        if !displayItems.isEmpty {
            Button(action: onTap) {
                VStack(spacing: 0) {
                    StockItemView(
                        pantryName: pantry.name,
                        topItems: displayItems,
                        pantryAddress: pantry.address
                    )
                    
                    // Show indicator if items were matched by search
                    if !matchingItems.isEmpty && !searchText.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Colors.flexibleGreen)
                                .font(.caption)
                            Text("Has \(matchingItems.count) matching item\(matchingItems.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(Colors.flexibleGreen)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, -10)
                        .padding(.bottom, 4)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            // Show pantry even without stock items
            Button(action: onTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Colors.flexibleWhite)
                        .shadow(radius: 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(pantry.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Colors.flexibleOrange)
                        }
                        
                        if let address = pantry.address {
                            Text(address)
                                .font(.caption)
                                .foregroundColor(Colors.flexibleDarkGray)
                                .lineLimit(2)
                        }
                        
                        Text("No stock information available")
                            .font(.caption)
                            .foregroundColor(Colors.flexibleDarkGray.opacity(0.7))
                            .italic()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// Basic card for Google Sheet pantries (not on PantryLink yet)
struct BasicPantryCard: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Colors.flexibleWhite)
                    .shadow(radius: 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mapItem.name ?? "Unknown Pantry")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            if let city = mapItem.placemark.locality,
                               let state = mapItem.placemark.administrativeArea {
                                Text("\(city), \(state)")
                                    .font(.subheadline)
                                    .foregroundColor(Colors.flexibleDarkGray)
                            }
                        }
                        
                        Spacer()
                        
                        // Directions button
                        Button(action: {
                            openInMaps(mapItem: mapItem)
                        }) {
                            HStack(spacing: 4) {
                                Text("Directions")
                                    .font(.caption)
                                Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Colors.flexibleDarkGray.opacity(0.15))
                            .cornerRadius(6)
                            .foregroundColor(Colors.flexibleBlack)
                        }
                    }
                    
                    // Address
                    if let street = mapItem.placemark.thoroughfare,
                       let _ = mapItem.placemark.postalCode {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(Colors.flexibleDarkGray)
                            Text(street)
                                .font(.caption)
                                .foregroundColor(Colors.flexibleDarkGray)
                        }
                    }
                    
                    // Phone
                    if let phone = mapItem.phoneNumber {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.caption)
                                .foregroundColor(Colors.flexibleDarkGray)
                            Text(phone)
                                .font(.caption)
                                .foregroundColor(Colors.flexibleDarkGray)
                        }
                    }
                    
                    // Website
                    if let url = mapItem.url {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.caption)
                                .foregroundColor(Colors.flexibleBlue)
                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundColor(Colors.flexibleBlue)
                                .lineLimit(1)
                        }
                    }
                    
                    // Info indicator
                    HStack {
                        Spacer()
                        Text("Tap for more info")
                            .font(.caption)
                            .foregroundColor(Colors.flexibleOrange)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Colors.flexibleOrange)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func openInMaps(mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// Popup view for basic pantry information
struct BasicPantryPopUpView: View {
    let mapItem: MKMapItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name
                    Text(mapItem.name ?? "Unknown Pantry")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.flexibleBlack)
                    
                    // Address Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Address", systemImage: "location.fill")
                            .font(.headline)
                            .foregroundColor(Colors.flexibleBlack)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let street = mapItem.placemark.thoroughfare {
                                Text(street)
                                    .foregroundColor(Colors.flexibleDarkGray)
                            }
                            if let city = mapItem.placemark.locality,
                               let state = mapItem.placemark.administrativeArea,
                               let zip = mapItem.placemark.postalCode {
                                Text("\(city), \(state) \(zip)")
                                    .foregroundColor(Colors.flexibleDarkGray)
                            }
                        }
                        
                        Button(action: {
                            mapItem.openInMaps(launchOptions: [
                                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                            ])
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                Text("Get Directions")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Colors.flexibleBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Colors.flexibleLightGray.opacity(0.3))
                    .cornerRadius(12)
                    
                    // Phone Section
                    if let phone = mapItem.phoneNumber {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Phone", systemImage: "phone.fill")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            if let phoneURL = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                Link(destination: phoneURL) {
                                    HStack {
                                        Text(phone)
                                            .foregroundColor(Colors.flexibleBlue)
                                        Spacer()
                                        Image(systemName: "phone.circle.fill")
                                            .foregroundColor(Colors.flexibleBlue)
                                    }
                                }
                            } else {
                                Text(phone)
                                    .foregroundColor(Colors.flexibleDarkGray)
                            }
                        }
                        .padding()
                        .background(Colors.flexibleLightGray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    // Website Section
                    if let url = mapItem.url {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Website", systemImage: "globe")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            Link(destination: url) {
                                HStack {
                                    Text(url.absoluteString)
                                        .foregroundColor(Colors.flexibleBlue)
                                        .lineLimit(2)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(Colors.flexibleBlue)
                                }
                            }
                        }
                        .padding()
                        .background(Colors.flexibleLightGray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    // Info note
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(Colors.flexibleOrange)
                            Text("Not on PantryLink yet")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.flexibleOrange)
                        }
                        Text("This pantry is not currently reporting stock information through PantryLink.")
                            .font(.caption)
                            .foregroundColor(Colors.flexibleDarkGray)
                    }
                    .padding()
                    .background(Colors.flexibleOrange.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SearchPantryView()
}
