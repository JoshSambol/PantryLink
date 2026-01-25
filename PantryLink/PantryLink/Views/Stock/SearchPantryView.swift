//
//  SearchPantryView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 1/24/26.
//

import SwiftUI

struct SearchPantryView: View {
    @StateObject private var viewModel = StreamViewViewModel()
    @State private var searchText = ""
    @State private var allPantries: [Pantry] = []
    @State private var isLoading = true
    @State private var selectedPantry: Pantry?
    @State private var showDetailView = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    // Filter pantries based on search text
    var filteredPantries: [Pantry] {
        if searchText.isEmpty {
            return allPantries
        }
        
        let lowercasedSearch = searchText.lowercased()
        
        return allPantries.filter { pantry in
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
                    } else if filteredPantries.isEmpty {
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
                                    Text("\(filteredPantries.count) result\(filteredPantries.count == 1 ? "" : "s") found")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding(.top, 8)
                                }
                                
                                ForEach(filteredPantries) { pantry in
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
        }
        .task {
            await loadPantries()
        }
    }
    
    // Load pantries from API
    private func loadPantries() async {
        do {
            let response = try await viewModel.getStreams()
            allPantries = response.pantries
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

#Preview {
    SearchPantryView()
}
