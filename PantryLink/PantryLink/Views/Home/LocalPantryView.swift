//
//  LocalPantryView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 8/6/25.
//

import SwiftUI
import MapKit

struct LocalPantryView: View {
    @ObservedObject var location = LocationManager.shared
    let options: MKMapSnapshotter.Options = .init()
    @State var showPopup = false
    @State var selectedPantry: MKMapItem? = nil
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Colors.flexibleWhite)
                .ignoresSafeArea()
            
            VStack{
                Text("Local Pantries")
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.top, 20)
                
                // Show loading or location status
                if !location.locationReady {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Getting your location...")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        // Check if location is actually denied
                        if location.manager.authorizationStatus == .denied {
                            Text("Location access denied")
                                .foregroundColor(.white)
                                .font(.caption)
                                .padding(.top, 10)
                            Text("Please enable location access in Settings")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 40)
                } else if location.isLoadingPantries {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Finding nearby pantries...")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 40)
                } else if location.allPantries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("No pantries found nearby")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Button(action: {
                            location.findPantries()
                        }) {
                            Text("Retry")
                                .foregroundColor(.stockDarkTan)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 40)
                } else {
                    // Display all pantries (sorted by distance, max 20)
                    TabView{
                        ForEach(Array(location.allPantries.enumerated()), id: \.offset) { index, pantry in
                            VStack(spacing: 12){
                                Button(action: {
                                    DispatchQueue.main.async {
                                        openPantryInMaps(pantry: pantry)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Text("Directions")
                                            .font(.caption)
                                        Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Colors.flexibleWhite)
                                    .cornerRadius(6)
                                    .foregroundColor(Colors.flexibleBlack)
                                }
                                .contentShape(Rectangle())
                                .zIndex(1)
                                
                                SnapshotImageView(coordinate: pantry.placemark.coordinate, location: location)
                                    .frame(width: isIPad ? 550 : 300, height: isIPad ? 350 : 200)
                                    .cornerRadius(10)
                                    .allowsHitTesting(false)
                                
                                VStack(spacing: 4) {
                                    Button(action: {
                                        selectedPantry = pantry
                                        showPopup = true
                                    })
                                    {
                                        Text(pantry.name ?? "Unknown Pantry")
                                            .frame(maxWidth: isIPad ? 550 : 300)
                                            .foregroundStyle(.white)
                                            .underline()
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    
                                    // Show distance
                                    if let pantryLocation = pantry.placemark.location,
                                       let userLocation = location.lastKnownLocation {
                                        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                                        let distance = pantryLocation.distance(from: userCLLocation)
                                        let distanceInMiles = distance * 0.000621371
                                        Text(String(format: "%.1f miles away", distanceInMiles))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .padding(.bottom, 10)
                                .frame(maxWidth: isIPad ? 550 : 300)
                            }
                        }
                    }
                    .sheet(isPresented: $showPopup){
                        if let pantry = selectedPantry {
                            BasicPantryPopUpView(mapItem: pantry)
                                .presentationDetents([.medium, .large])
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(height: isIPad ? 485 : 395)
                    .padding(.vertical, 10)
                    
                    SearchView()
                        .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .frame(width: isIPad ? 600 : 350)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.stockDarkTan)
                    .shadow(radius: 10)
            )
        }
        .onAppear{
            location.checkLocationAuthorization()
        }
        .onChange(of: location.locationReady) { newValue in
            if newValue {
                location.findPantries()
            }
        }
    }
    
    // Open Apple Maps with the pantry location
    func openPantryInMaps(pantry: MKMapItem) {
        print("🗺️ Opening directions for: \(pantry.name ?? "Unknown")")
        print("🗺️ Placemark coordinate: \(pantry.placemark.coordinate.latitude), \(pantry.placemark.coordinate.longitude)")
        print("🗺️ Placemark location: \(pantry.placemark.location?.coordinate.latitude ?? -1), \(pantry.placemark.location?.coordinate.longitude ?? -1)")
        
        // If placemark.location is nil, create a new placemark with just coordinate
        if pantry.placemark.location == nil {
            print("⚠️ Location is nil, creating new placemark")
            let coordinate = pantry.placemark.coordinate
            let newPlacemark = MKPlacemark(coordinate: coordinate)
            let newMapItem = MKMapItem(placemark: newPlacemark)
            newMapItem.name = pantry.name
            newMapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        } else {
            // Use the pantry MKMapItem directly - it already has all the data configured
            pantry.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }
    
}

#Preview {
    LocalPantryView()
}
