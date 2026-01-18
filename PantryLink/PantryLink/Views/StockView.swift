//
//  StockView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 5/29/25.
//
import SwiftUI
/*
class Pantry {
    let name = "Princeton Mobile"
    let stock = 78
    let items = ["Beans", "Soup", "Vegis"]
}
 */



//https://www.programiz.com/swift-programming/classes-objects
//https://developer.apple.com/documentation/swiftui/foreach
// StockPageView - Full page version for TabView
struct StockPageView: View {
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
        NavigationStack {
            ZStack{
                Rectangle()
                    .fill(.stockDarkTan)
                    .ignoresSafeArea()
                
                VStack(spacing: 0){
                    Text("Stock")
                        .foregroundColor(.white)
                        .bold()
                        .font(.largeTitle)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("This may take a moment...")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView{
                            // Use this spacing for space between stock items
                            VStack(spacing:24){
                                ForEach(pantries ?? []){pantry in
                                    PantryStockCard(pantry: pantry, onTap: {
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
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationDestination(isPresented: $showDetailView) {
                if let pantry = selectedPantry {
                    PantryDetailView(pantry: pantry)
                }
            }
        }
        .task{
            pantries = try? await streamViewViewModel.getStreams().pantries
            isLoading = false
        }
    }
}

// Legacy StockView (keeping for compatibility)
struct StockView: View{
    @StateObject var streamViewViewModel = StreamViewViewModel()
    @State var pantries: [Pantry]?
    @State var isLoading = true
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Colors.flexibleWhite)
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 15)
                .fill(.stockDarkTan)
                .frame(width:350, height:650)
                .shadow(radius: 10)
            VStack{
                Text("Stock")
                    .foregroundColor(.white)
                    .bold()
                    .font(.largeTitle)
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("This may take a moment...")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .frame(width: 340, height: 560)
                } else {
                    ScrollView{
                        // Use this spacing for space between stock items
                        VStack(spacing:24){
                            ForEach(pantries ?? []){pantry in
                                PantryStockCard(pantry: pantry)
                            }
                        }
                    }
                    .frame(width: 340, height: 560)
                }
            }
        }
        .task{
            pantries = try? await streamViewViewModel.getStreams().pantries
            isLoading = false
        }
    }
}

// Helper view to display a single pantry's stock card
struct PantryStockCard: View {
    let pantry: Pantry
    var onTap: () -> Void = {}
    
    var topItems: [PantryItem] {
        guard let stock = pantry.stock, !stock.isEmpty else { return [] }
        return Array(stock.prefix(3))
    }
    
    var body: some View {
        if !topItems.isEmpty {
            Button(action: onTap) {
                StockItemView(pantryName: pantry.name, topItems: topItems, pantryAddress: pantry.address)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
                                            
#Preview {
    StockView()
}

                            
