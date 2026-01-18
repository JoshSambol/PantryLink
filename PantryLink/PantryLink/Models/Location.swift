//
//  Location.swift
//  PantryLink
//
//  Created by Michael Youtz on 10/1/25.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Contacts

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    // Singleton instance
    static let shared = LocationManager()
    
    //controls user location
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var locationReady: Bool = false
    
    //controls authentication
    var manager = CLLocationManager()
    
    @Published var allPantries: [MKMapItem] = [] // Combined list including all known pantries
    @Published var isLoadingPantries: Bool = false
    @Published var pantries: [MKMapItem] = []
    @Published var montgomery: MKMapItem = {
        let coordinate = CLLocationCoordinate2D(latitude: 40.42146272431577, longitude: -74.70969731904897)
        var addressDict: [String: Any] = [:]
        addressDict[CNPostalAddressStreetKey] = "356 Skillman Rd"
        addressDict[CNPostalAddressCityKey] = "Skillman"
        addressDict[CNPostalAddressStateKey] = "NJ"
        addressDict[CNPostalAddressPostalCodeKey] = "08558"
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Montgomery Food Pantry"
        mapItem.phoneNumber = "609-446-1054"
        mapItem.url = URL(string: "https://www.montgomerynj.gov/600/Food-Resources")
        return mapItem
    }()
    
    // Comprehensive list of known NJ food pantries with full details
    lazy var knownNJPantries: [MKMapItem] = {
        var pantries: [MKMapItem] = []
        
        // Central NJ Pantries
        pantries.append(createPantry(name: "Trenton Area Soup Kitchen", address: "72 Carroll St", city: "Trenton", state: "NJ", zip: "08609", phone: "609-695-5456", website: "https://www.trentonsoupkitchen.org", lat: 40.2206, lon: -74.7597))
        pantries.append(createPantry(name: "Montgomery Food Pantry", address: "356 Skillman Rd", city: "Skillman", state: "NJ", zip: "08558", phone: "609-446-1054", website: "https://www.montgomerynj.gov/600/Food-Resources", lat: 40.4214, lon: -74.7096))
        pantries.append(createPantry(name: "Mercer Street Friends", address: "150 Spruce St", city: "Princeton", state: "NJ", zip: "08540", phone: "609-989-9417", website: "https://www.mercerstreetfriends.org", lat: 40.3573, lon: -74.6672))
        pantries.append(createPantry(name: "Princeton Community Food Pantry", address: "105 John St", city: "Princeton", state: "NJ", zip: "08542", phone: "609-924-2613", website: nil, lat: 40.3499, lon: -74.6597))
        pantries.append(createPantry(name: "Franklin Food Bank", address: "1091 Hamilton St", city: "Somerset", state: "NJ", zip: "08873", phone: "732-249-5502", website: "https://www.franklinfoodbank.org", lat: 40.4796, lon: -74.5458))
        pantries.append(createPantry(name: "Hillsborough Emergency Food Pantry", address: "29 Raider Blvd", city: "Hillsborough", state: "NJ", zip: "08844", phone: "908-369-4012", website: nil, lat: 40.4992, lon: -74.6438))
        pantries.append(createPantry(name: "Bridgewater Food Pantry", address: "1200 US Highway 22", city: "Bridgewater", state: "NJ", zip: "08807", phone: "908-722-1881", website: nil, lat: 40.5938, lon: -74.6104))
        pantries.append(createPantry(name: "Somerset Food Bank", address: "27-31 North Bridge St", city: "Somerville", state: "NJ", zip: "08876", phone: "908-429-0144", website: nil, lat: 40.5615, lon: -74.6104))
        pantries.append(createPantry(name: "Bound Brook Food Pantry", address: "409 Hamilton St", city: "Bound Brook", state: "NJ", zip: "08805", phone: "732-356-0027", website: nil, lat: 40.5681, lon: -74.5385))
        pantries.append(createPantry(name: "Manville Food Pantry", address: "120 Brooks Blvd", city: "Manville", state: "NJ", zip: "08835", phone: "908-722-9356", website: nil, lat: 40.5407, lon: -74.5879))
        pantries.append(createPantry(name: "East Brunswick Food Pantry", address: "511 Ryders Ln", city: "East Brunswick", state: "NJ", zip: "08816", phone: "732-257-3030", website: nil, lat: 40.4279, lon: -74.4160))
        
        // Northern NJ Pantries
        pantries.append(createPantry(name: "Community FoodBank of NJ", address: "31 Evans Terminal", city: "Hillside", state: "NJ", zip: "07205", phone: "908-355-3663", website: "https://www.cfbnj.org", lat: 40.7001, lon: -74.2293))
        pantries.append(createPantry(name: "Newark Community Food Pantry", address: "150 Mulberry St", city: "Newark", state: "NJ", zip: "07102", phone: "973-624-5800", website: nil, lat: 40.7357, lon: -74.1724))
        pantries.append(createPantry(name: "Jersey City Food Pantry", address: "219 Coles St", city: "Jersey City", state: "NJ", zip: "07302", phone: "201-332-6613", website: nil, lat: 40.7178, lon: -74.0431))
        pantries.append(createPantry(name: "Paterson Task Force", address: "100 Hamilton Plaza", city: "Paterson", state: "NJ", zip: "07505", phone: "973-881-8900", website: nil, lat: 40.9168, lon: -74.1718))
        pantries.append(createPantry(name: "Elizabeth Coalition Food Pantry", address: "505 Madison Ave", city: "Elizabeth", state: "NJ", zip: "07201", phone: "908-355-7949", website: nil, lat: 40.6640, lon: -74.2107))
        pantries.append(createPantry(name: "Montclair Bread of Life", address: "240 Valley Rd", city: "Montclair", state: "NJ", zip: "07042", phone: "973-744-4336", website: nil, lat: 40.8259, lon: -74.2090))
        pantries.append(createPantry(name: "Morristown Food Pantry", address: "62 Elm St", city: "Morristown", state: "NJ", zip: "07960", phone: "973-538-5252", website: nil, lat: 40.7968, lon: -74.4815))
        pantries.append(createPantry(name: "Wayne Interfaith Food Pantry", address: "1 Hinchman Ave", city: "Wayne", state: "NJ", zip: "07470", phone: "973-694-5589", website: nil, lat: 40.9254, lon: -74.2765))
        pantries.append(createPantry(name: "Passaic County Food Pantry", address: "750 Hamburg Tpke", city: "Wayne", state: "NJ", zip: "07470", phone: "973-247-3727", website: nil, lat: 40.8573, lon: -74.1710))
        
        // Shore Area Pantries
        pantries.append(createPantry(name: "FoodBank of Monmouth & Ocean", address: "3300 State Route 66", city: "Neptune", state: "NJ", zip: "07753", phone: "732-918-2600", website: "https://www.foodbanknj.org", lat: 40.1793, lon: -74.0693))
        pantries.append(createPantry(name: "Jersey Shore Dream Center", address: "703 Main St", city: "Asbury Park", state: "NJ", zip: "07712", phone: "732-774-7156", website: nil, lat: 40.2237, lon: -74.0154))
        pantries.append(createPantry(name: "Asbury Park Food Bank", address: "1201 Springwood Ave", city: "Asbury Park", state: "NJ", zip: "07712", phone: "732-775-4357", website: nil, lat: 40.2204, lon: -74.0121))
        pantries.append(createPantry(name: "Toms River Community Food Pantry", address: "1201 Hooper Ave", city: "Toms River", state: "NJ", zip: "08753", phone: "732-349-7855", website: nil, lat: 39.9537, lon: -74.1979))
        pantries.append(createPantry(name: "Lakewood Food Pantry", address: "200 Madison Ave", city: "Lakewood", state: "NJ", zip: "08701", phone: "732-364-7600", website: nil, lat: 40.0979, lon: -74.2176))
        pantries.append(createPantry(name: "Long Branch Food Pantry", address: "344 Broadway", city: "Long Branch", state: "NJ", zip: "07740", phone: "732-222-3367", website: nil, lat: 40.3043, lon: -73.9924))
        
        // South Jersey Pantries
        pantries.append(createPantry(name: "Food Bank of South Jersey", address: "6735 Black Horse Pike", city: "Pennsauken", state: "NJ", zip: "08109", phone: "856-662-4884", website: "https://www.foodbanksj.org", lat: 39.8562, lon: -75.0587))
        pantries.append(createPantry(name: "Camden County Food Pantry", address: "520 Market St", city: "Camden", state: "NJ", zip: "08102", phone: "856-964-1415", website: nil, lat: 39.9259, lon: -75.0196))
        pantries.append(createPantry(name: "Atlantic City Rescue Mission", address: "2009 Bacharach Blvd", city: "Atlantic City", state: "NJ", zip: "08401", phone: "609-345-5517", website: "https://www.acrescuemission.org", lat: 39.3643, lon: -74.4229))
        pantries.append(createPantry(name: "Vineland Food Bank", address: "540 N Main Rd", city: "Vineland", state: "NJ", zip: "08360", phone: "856-691-2395", website: nil, lat: 39.4864, lon: -75.0254))
        pantries.append(createPantry(name: "Gloucester Food Pantry", address: "420 Church St", city: "Woodbury", state: "NJ", zip: "08096", phone: "856-845-2888", website: nil, lat: 39.7429, lon: -75.1538))
        
        return pantries
    }()
    
    private func createPantry(name: String, address: String, city: String, state: String, zip: String, phone: String?, website: String?, lat: Double, lon: Double) -> MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        // Create a proper placemark with address info
        var addressDict: [String: Any] = [:]
        addressDict[CNPostalAddressStreetKey] = address
        addressDict[CNPostalAddressCityKey] = city
        addressDict[CNPostalAddressStateKey] = state
        addressDict[CNPostalAddressPostalCodeKey] = zip
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.phoneNumber = phone
        if let website = website {
            mapItem.url = URL(string: website)
        }
        
        // Debug: Verify placemark has location
        if mapItem.placemark.location == nil {
            print("⚠️ WARNING: Placemark for \(name) has no location!")
        }
        
        return mapItem
    }
    
    private override init() {
        super.init()
        print("🔵 LocationManager singleton initialized - will request location permission")
        manager.delegate = self
        // Request permission immediately when LocationManager is created
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization(){
        print("🔵 Checking location authorization status: \(manager.authorizationStatus.rawValue)")
        
        switch manager.authorizationStatus{
        case .notDetermined:
            print("📍 Location not determined - requesting permission NOW")
            locationReady = false
            manager.requestWhenInUseAuthorization()
            print("📍 Permission request sent - waiting for user response...")
            
        case .restricted:
            print("⛔️ Location restricted")
            locationReady = false
            
        case .denied:
            print("⛔️ Location denied by user")
            locationReady = false
            
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Location authorized - starting location updates")
            locationReady = false // Will be set to true when we get first location
            manager.startUpdatingLocation()
            
        @unknown default:
            print("⚠️ Location service disabled")
            locationReady = false
        }
    }
    
    //when location authorization changes, this function runs to check and save the new location authorization state
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        print("🔄 Location authorization changed to: \(manager.authorizationStatus.rawValue)")
        checkLocationAuthorization()
    }
    
    //updates location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        lastKnownLocation = location.coordinate
        
        if !locationReady {
            print("📍 First location received: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            locationReady = true
        }
    }
    
    func findPantries(){
        guard locationReady, let userLocation = lastKnownLocation else {
            print("Location not ready yet, cannot fetch pantries")
            return
        }
        
        isLoadingPantries = true
        
        //defining map and query
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "food bank, food pantry"
        request.region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        //search
        let search = MKLocalSearch(request: request)
        search.start{ (response, error) in
            guard let response = response else {
                print("Search Failed"+String(error?.localizedDescription ?? "Unknown Error"))
                self.isLoadingPantries = false
                return
            }
            let mapItems = response.mapItems
            
            //trying to remove convenience stores and other food related places
            let filteredPantries = mapItems.filter { item in
                if let category = item.pointOfInterestCategory {
                    if category == .restaurant || category == .foodMarket {
                        return false
                    }
                }
                return true
            }

            self.pantries = filteredPantries
            
            // Combine MapKit results with all known NJ pantries
            var combinedPantries = filteredPantries
            combinedPantries.append(contentsOf: self.knownNJPantries)
            
            // Sort all pantries by distance (closest first)
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            combinedPantries.sort(by: {
                let distance1 = $0.placemark.location?.distance(from: userCLLocation) ?? Double.greatestFiniteMagnitude
                let distance2 = $1.placemark.location?.distance(from: userCLLocation) ?? Double.greatestFiniteMagnitude
                return distance1 < distance2
            })
            
            // Limit to 20 pantries
            self.allPantries = Array(combinedPantries.prefix(20))
            
            // Debug output
            print("Found \(self.allPantries.count) pantries (including \(self.knownNJPantries.count) known NJ pantries + MapKit results)")
            for (index, pantry) in self.allPantries.enumerated() {
                let distance = pantry.placemark.location?.distance(from: userCLLocation) ?? 0
                let distanceInMiles = distance * 0.000621371
                print("\(index + 1). \(pantry.name ?? "Unknown") - \(String(format: "%.1f", distanceInMiles)) miles")
            }
            
            self.isLoadingPantries = false
        }
    }
    
    func generateSnapshot(for coordinate: CLLocationCoordinate2D, size: CGSize = CGSize(width: 200, height: 200), completion: @escaping (UIImage?) -> Void) {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        options.size = size
        options.scale = UIScreen.main.scale
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Snapshot error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            //code to get pin on the snapshot
            let image = snapshot.image
            let point = snapshot.point(for: coordinate)

            let format = UIGraphicsImageRendererFormat.default()
            format.scale = image.scale

            let renderer = UIGraphicsImageRenderer(size: image.size, format: format)

            let finalImage = renderer.image { context in
                image.draw(at: .zero)
                let marker = MKMarkerAnnotationView(annotation: nil, reuseIdentifier: nil)
                marker.markerTintColor = .red
                marker.glyphImage = UIImage()
                marker.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
                let markerRenderer = UIGraphicsImageRenderer(size: marker.bounds.size)
                let markerImage = markerRenderer.image { _ in
                    marker.drawHierarchy(in: marker.bounds, afterScreenUpdates: true)
                }
                
                markerImage.draw(at: point)
            }

            completion(finalImage)
        }
    }
}
