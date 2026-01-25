//
//  PantryDetailView.swift
//  PantryLink
//
//  Detailed view showing all items in a pantry with search and filter
//

import SwiftUI
import MapKit

struct PantryDetailView: View {
    let pantry: Pantry
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedFilter: ItemFilter = .all
    @State private var sortOption: SortOption = .name
    @State private var showInfoPopup = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    // Filter options
    enum ItemFilter: String, CaseIterable {
        case all = "All"
        case low = "Low Stock"
        case high = "Well Stocked"
        case produce = "Produce"
        case dryGoods = "Dry Goods"
        case protein = "Protein"
        case nonperishable = "Nonperishable"
        case cans = "Cans"
        case other = "Other"
    }
    
    // Sort options
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case stockLevel = "Stock Level"
        case type = "Type"
    }
    
    // Filtered and sorted items
    var filteredItems: [PantryItem] {
        guard let stock = pantry.stock else { return [] }
        
        var items = stock
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .low:
            items = items.filter { $0.ratio < 0.5 }
        case .high:
            items = items.filter { $0.ratio >= 0.5 }
        case .produce:
            items = items.filter { 
                $0.type.localizedCaseInsensitiveContains("produce") || 
                $0.type.localizedCaseInsensitiveContains("fresh") ||
                $0.type.localizedCaseInsensitiveContains("fruit") ||
                $0.type.localizedCaseInsensitiveContains("vegetable")
            }
        case .dryGoods:
            items = items.filter { 
                $0.type.localizedCaseInsensitiveContains("dry") ||
                $0.type.localizedCaseInsensitiveContains("pasta") ||
                $0.type.localizedCaseInsensitiveContains("rice") ||
                $0.type.localizedCaseInsensitiveContains("grain")
            }
        case .protein:
            items = items.filter { 
                $0.type.localizedCaseInsensitiveContains("protein") ||
                $0.type.localizedCaseInsensitiveContains("meat") ||
                $0.type.localizedCaseInsensitiveContains("chicken") ||
                $0.type.localizedCaseInsensitiveContains("beef") ||
                $0.type.localizedCaseInsensitiveContains("fish") ||
                $0.type.localizedCaseInsensitiveContains("egg")
            }
        case .nonperishable:
            items = items.filter { 
                $0.type.localizedCaseInsensitiveContains("nonperishable") ||
                $0.type.localizedCaseInsensitiveContains("shelf stable") ||
                $0.type.localizedCaseInsensitiveContains("preserved")
            }
        case .cans:
            items = items.filter { $0.type.localizedCaseInsensitiveContains("can") }
        case .other:
            let commonTypes = ["produce", "fresh", "fruit", "vegetable", "dry", "pasta", "rice", "grain", 
                             "protein", "meat", "chicken", "beef", "fish", "egg", "nonperishable", 
                             "shelf stable", "preserved", "can"]
            items = items.filter { item in
                !commonTypes.contains { item.type.localizedCaseInsensitiveContains($0) }
            }
        }
        
        // Apply sort
        switch sortOption {
        case .name:
            items = items.sorted { $0.name < $1.name }
        case .stockLevel:
            items = items.sorted { $0.ratio < $1.ratio }
        case .type:
            items = items.sorted { $0.type < $1.type }
        }
        
        return items
    }
    
    var body: some View {
        ZStack {
            // Background
            Colors.flexibleWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                VStack(spacing: 12) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(Colors.flexibleOrange)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            // Info button to show popup
                            Button(action: {
                                showInfoPopup = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Colors.flexibleBlue)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            }
                            
                            if let address = pantry.address {
                                Button(action: {
                                    openInMaps(address: address)
                                }) {
                                    HStack(spacing: 4) {
                                        Text("Directions")
                                            .font(.caption)
                                        Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Colors.flexibleOrange)
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Pantry Name and Stats
                    VStack(spacing: 8) {
                        Text(pantry.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Colors.flexibleBlack)
                            .multilineTextAlignment(.center)
                        
                        if let address = pantry.address {
                            Text(address)
                                .font(.system(size: 14))
                                .foregroundColor(Colors.flexibleBlack)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Stats
                        if let stock = pantry.stock, !stock.isEmpty {
                            HStack(spacing: 20) {
                                StatBadge(
                                    title: "Total Items",
                                    value: "\(stock.count)",
                                    color: Colors.flexibleBlue
                                )
                                
                                StatBadge(
                                    title: "Low Stock",
                                    value: "\(stock.filter { $0.ratio < 0.5 }.count)",
                                    color: Colors.flexibleRed
                                )
                                
                                StatBadge(
                                    title: "Well Stocked",
                                    value: "\(stock.filter { $0.ratio >= 0.5 }.count)",
                                    color: Colors.flexibleGreen
                                )
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .background(Colors.flexibleWhite)
                
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Colors.flexibleDarkGray)
                        
                        TextField("Search items...", text: $searchText)
                            .foregroundColor(Colors.flexibleBlack)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Colors.flexibleDarkGray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Colors.flexibleLightGray.opacity(0.5))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ItemFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter,
                                action: {
                                    selectedFilter = filter
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)
                
                // Sort Options
                HStack {
                    Text("Sort by:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Colors.flexibleDarkGray)
                    
                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // Items Grid
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(Colors.flexibleDarkGray.opacity(0.5))
                        
                        Text(searchText.isEmpty ? "No items available" : "No items match your search")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Colors.flexibleDarkGray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(filteredItems) { item in
                                ItemCard(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showInfoPopup) {
            PantryInfoPopUpView(pantry: pantry)
                .presentationDetents([.medium, .large])
        }
    }
    
    // Open Apple Maps with the pantry address
    func openInMaps(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let location = placemarks?.first?.location else {
                print("Failed to geocode address: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let regionDistance: CLLocationDistance = 500
            let coordinates = location.coordinate
            
            let regionSpan = MKCoordinateRegion(center: coordinates,
                                                latitudinalMeters: regionDistance,
                                                longitudinalMeters: regionDistance)
            
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
            mapItem.name = pantry.name
            
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }
}

// Helper view for stat badges
struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Colors.flexibleDarkGray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// Helper view for filter chips
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : Colors.flexibleBlack)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Colors.flexibleOrange : Colors.flexibleLightGray.opacity(0.5))
                .cornerRadius(20)
        }
    }
}

// Helper view for individual item card
struct ItemCard: View {
    let item: PantryItem
    
    var stockColor: Color {
        if item.ratio < 0.3 {
            return Colors.flexibleRed
        } else if item.ratio < 0.5 {
            return Colors.flexibleOrange
        } else {
            return Colors.flexibleGreen
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Item Name
            Text(item.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Colors.flexibleBlack)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Type Badge
            Text(item.type)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Colors.flexibleDarkGray)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Colors.flexibleLightGray.opacity(0.5))
                .cornerRadius(6)
            
            Spacer()
            
            // Stock Level
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(item.current)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(stockColor)
                    Text("/ \(item.full)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.flexibleDarkGray)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Colors.flexibleLightGray.opacity(0.3))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(stockColor)
                            .frame(width: geometry.size.width * item.ratio, height: 6)
                    }
                }
                .frame(height: 6)
                
                Text("\(Int(item.ratio * 100))% stocked")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Colors.flexibleDarkGray)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(Colors.flexibleWhite)
        .cornerRadius(12)
        .shadow(color: Colors.flexibleBlack.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Popup view for PantryLink pantry information
struct PantryInfoPopUpView: View {
    let pantry: Pantry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name
                    Text(pantry.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.flexibleBlack)
                    
                    // PantryLink Badge
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Colors.flexibleGreen)
                        Text("PantryLink Connected")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.flexibleGreen)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Colors.flexibleGreen.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Address Section
                    if let address = pantry.address {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Address", systemImage: "location.fill")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            Text(address)
                                .foregroundColor(Colors.flexibleDarkGray)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button(action: {
                                openInMaps(address: address)
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
                    }
                    
                    // Phone Section
                    if let phone = pantry.phone_number, !phone.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Phone", systemImage: "phone.fill")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            if let phoneURL = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))") {
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
                    
                    // Email Section
                    if let email = pantry.email, !email.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Email", systemImage: "envelope.fill")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            if let emailURL = URL(string: "mailto:\(email)") {
                                Link(destination: emailURL) {
                                    HStack {
                                        Text(email)
                                            .foregroundColor(Colors.flexibleBlue)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Spacer()
                                        Image(systemName: "envelope.circle.fill")
                                            .foregroundColor(Colors.flexibleBlue)
                                    }
                                }
                            } else {
                                Text(email)
                                    .foregroundColor(Colors.flexibleDarkGray)
                            }
                        }
                        .padding()
                        .background(Colors.flexibleLightGray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    // Website Section
                    if let website = pantry.website, !website.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Website", systemImage: "globe")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            if let url = URL(string: website) {
                                Link(destination: url) {
                                    HStack {
                                        Text(website)
                                            .foregroundColor(Colors.flexibleBlue)
                                            .lineLimit(2)
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(Colors.flexibleBlue)
                                    }
                                }
                            } else {
                                Text(website)
                                    .foregroundColor(Colors.flexibleDarkGray)
                            }
                        }
                        .padding()
                        .background(Colors.flexibleLightGray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    // Stock Information Section
                    if let stock = pantry.stock, !stock.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Inventory Status", systemImage: "cube.box.fill")
                                .font(.headline)
                                .foregroundColor(Colors.flexibleBlack)
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total Items")
                                        .font(.caption)
                                        .foregroundColor(Colors.flexibleDarkGray)
                                    Text("\(stock.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Colors.flexibleBlue)
                                }
                                
                                Divider()
                                    .frame(height: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Low Stock Items")
                                        .font(.caption)
                                        .foregroundColor(Colors.flexibleDarkGray)
                                    Text("\(stock.filter { $0.ratio < 0.5 }.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Colors.flexibleRed)
                                }
                                
                                Divider()
                                    .frame(height: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Well Stocked")
                                        .font(.caption)
                                        .foregroundColor(Colors.flexibleDarkGray)
                                    Text("\(stock.filter { $0.ratio >= 0.5 }.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Colors.flexibleGreen)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Colors.flexibleWhite)
                        .cornerRadius(12)
                    }
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("About", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundColor(Colors.flexibleBlack)
                        
                        Text("This pantry is connected to PantryLink, providing real-time inventory tracking and updates to help you know what items are available.")
                            .font(.body)
                            .foregroundColor(Colors.flexibleDarkGray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Colors.flexibleLightGray.opacity(0.3))
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
                    .foregroundColor(Colors.flexibleOrange)
                }
            }
        }
    }
    
    // Open Apple Maps with the pantry address
    func openInMaps(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let location = placemarks?.first?.location else {
                print("Failed to geocode address: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let regionDistance: CLLocationDistance = 500
            let coordinates = location.coordinate
            
            let regionSpan = MKCoordinateRegion(center: coordinates,
                                                latitudinalMeters: regionDistance,
                                                longitudinalMeters: regionDistance)
            
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
            mapItem.name = pantry.name
            
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }
}

#Preview {
    PantryDetailView(
        pantry: Pantry(
            _id: "1",
            name: "Montgomery Food Pantry",
            stock: [
                PantryItem(name: "Canned Beans", current: 3, full: 10, type: "Cans", ratio: 0.3),
                PantryItem(name: "Tomato Soup", current: 5, full: 10, type: "Cans", ratio: 0.5),
                PantryItem(name: "Pasta", current: 8, full: 10, type: "Dry Goods", ratio: 0.8),
                PantryItem(name: "Rice", current: 9, full: 10, type: "Dry Goods", ratio: 0.9),
                PantryItem(name: "Fresh Carrots", current: 2, full: 10, type: "Fresh", ratio: 0.2),
                PantryItem(name: "Frozen Chicken", current: 6, full: 10, type: "Frozen", ratio: 0.6)
            ],
            address: "356 Skillman Rd, Skillman, NJ 08558",
            stream: nil,
            email: "contact@montgomerypantry.org",
            phone_number: "(908) 555-1234",
            website: "https://montgomerypantry.org"
        )
    )
}
