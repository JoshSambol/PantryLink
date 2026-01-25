//
//  SearchView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 1/24/26.
//
import SwiftUI

struct SearchView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Search Pantries")
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                
                // Clickable search bar that navigates to SearchPantryView
                NavigationLink(destination: SearchPantryView()) {
                    HStack(spacing: 12) { 
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Colors.flexibleDarkGray)
                            .font(.system(size: 18))
                        
                        Text("Search by name, city, zip code, or item")
                            .foregroundColor(Colors.flexibleDarkGray)
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Colors.flexibleWhite)
                    .cornerRadius(12)
                    .frame(width: isIPad ? 550 : 320)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
