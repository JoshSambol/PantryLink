//
//  DonationView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 1/25/26.
//
import SwiftUI
import MapKit

struct DonationView: View {
    @StateObject var streamViewViewModel = StreamViewViewModel()
    @State var pantries: [Pantry]?
    @State var isLoading = true
    @State var selectedPantry: Pantry?
    @State var showDetailView = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        ZStack {
            // Softer gradient background instead of solid red
            LinearGradient(
                gradient: Gradient(colors: [
                    Colors.flexibleOrange.opacity(0.4),
                    Colors.flexibleOrange.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 8) {
                    Text("Donation Needs")
                        .foregroundColor(.white)
                        .bold()
                        .font(.largeTitle)
                        .padding(.top, 20)
                    
                    Text("Items pantries need most")
                        .foregroundColor(.white.opacity(0.95))
                        .font(.subheadline)
                    
                    // Move footer message to header area where it's visible
                    Text("For monetary donations, visit pantry websites directly")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                }
                .padding(.bottom, 16)
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Loading donation needs...")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(pantries ?? []) { pantry in
                                PantryDonationCard(pantry: pantry, onTap: {
                                    selectedPantry = pantry
                                    showDetailView = true
                                })
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
        .navigationDestination(isPresented: $showDetailView) {
            if let pantry = selectedPantry {
                PantryDetailView(pantry: pantry)
            }
        }
        .task {
            pantries = try? await streamViewViewModel.getStreams().pantries
            isLoading = false
        }
    }
}

// Helper view to display a single pantry's donation needs card
struct PantryDonationCard: View {
    let pantry: Pantry
    var onTap: () -> Void = {}
    
    var bottomItems: [PantryItem] {
        guard let stock = pantry.stock, !stock.isEmpty else { return [] }
        // Sort by ratio (ascending) to get items with lowest stock
        let sorted = stock.sorted { $0.ratio < $1.ratio }
        return Array(sorted.prefix(3))
    }
    
    var body: some View {
        if !bottomItems.isEmpty {
            Button(action: onTap) {
                DonationItemView(pantryName: pantry.name, neededItems: bottomItems, pantryAddress: pantry.address)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// Card view for donation needs (volunteer-focused)
struct DonationItemView: View {
    let pantryName: String
    let neededItems: [PantryItem]
    let pantryAddress: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Colors.flexibleWhite)
                .shadow(radius: 10)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pantryName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Colors.flexibleBlack)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundColor(Colors.flexibleRed)
                            Text("Needs donations")
                                .font(.caption)
                                .foregroundColor(Colors.flexibleRed)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let address = pantryAddress {
                            openInMaps(address: address)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("Directions")
                                .font(.caption)
                            Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                .font(.caption)
                        }
                        .padding(6)
                        .background(Colors.flexibleDarkGray.opacity(0.15))
                        .cornerRadius(6)
                        .foregroundColor(Colors.flexibleBlack)
                    }
                }
                
                Text("Most Needed Items:")
                    .font(.subheadline)
                    .foregroundColor(Colors.flexibleBlack)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                
                HStack(spacing: 8) {
                    ForEach(neededItems) { item in
                        makeItemCard(item: item)
                    }
                }
                
                // Call to action for volunteers
                HStack {
                    Spacer()
                    Text("Tap to see all needed items")
                        .font(.caption)
                        .foregroundColor(Colors.flexibleOrange)
                        .fontWeight(.semibold)
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(Colors.flexibleOrange)
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
    // Create a card for each needed item with urgency indicator
    func makeItemCard(item: PantryItem) -> some View {
        VStack(spacing: 4) {
            Text(item.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(Colors.flexibleBlack)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            // Show current/full with color based on urgency
            Text("\(item.current)/\(item.full)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(urgencyColor(for: item.ratio))
            
            // Urgency indicator
            Text(urgencyText(for: item.ratio))
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(urgencyColor(for: item.ratio))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(urgencyColor(for: item.ratio).opacity(0.15))
                .cornerRadius(4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Colors.flexibleDarkGray.opacity(1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(urgencyColor(for: item.ratio).opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // Determine urgency color based on stock ratio
    func urgencyColor(for ratio: Double) -> Color {
        if ratio < 0.25 {
            return Colors.flexibleRed
        } else if ratio < 0.5 {
            return Colors.flexibleOrange
        } else {
            return Color.orange
        }
    }
    
    // Determine urgency text based on stock ratio
    func urgencyText(for ratio: Double) -> String {
        if ratio < 0.25 {
            return "URGENT"
        } else if ratio < 0.5 {
            return "LOW"
        } else {
            return "NEEDED"
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
            mapItem.name = pantryName
            
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ])
        }
    }
}

#Preview {
    DonationView()
}
