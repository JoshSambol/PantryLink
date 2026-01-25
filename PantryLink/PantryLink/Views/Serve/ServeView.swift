//
//  ServeView.swift
//  PantryLink
//
//  Created by Joshua Sambol on 1/25/26.
//
import SwiftUI

struct ServePageView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("isGuest") private var isGuest = false
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    VStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Colors.flexibleOrange,
                                        Colors.flexibleGreen
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 20)
                        
                        Text("Serve Your Community")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Colors.flexibleBlack)
                        
                        Text("Make a difference in your local area")
                            .font(.subheadline)
                            .foregroundColor(Colors.flexibleDarkGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    
                    if isGuest == true {
                        // Guest View - Prompt to Sign Up
                        VStack(spacing: 20) {
                            Text("We're glad you're interested in serving your community!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.flexibleBlack)
                                .multilineTextAlignment(.center)
                            
                            Text("To get started, please create an account")
                                .font(.body)
                                .foregroundColor(Colors.flexibleDarkGray)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                print("Log Out")
                                isLoggedIn = false
                                isGuest = false
                            } label: {
                                Text("Sign up")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Colors.flexibleOrange,
                                                Colors.flexibleGreen
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                            .padding(.top, 20)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 40)
                    } else {
                        // Logged-in User View - Service Options
                        VStack(spacing: 20) {
                            // Volunteer Sign Up Button
                            Button(action: {
                                path.append("Volunteer")
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.badge.plus")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Volunteer Sign Up")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text("Register to volunteer at local pantries")
                                            .font(.caption)
                                            .opacity(0.9)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Colors.flexibleGreen)
                                .cornerRadius(16)
                                .shadow(color: Colors.flexibleGreen.opacity(0.3), radius: 8, y: 4)
                            }
                            
                            // Volunteer Scheduling Button
                            Button(action: {
                                path.append("Schedule")
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Volunteer Scheduling")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text("View and manage your volunteer shifts")
                                            .font(.caption)
                                            .opacity(0.9)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Colors.flexibleBlue)
                                .cornerRadius(16)
                                .shadow(color: Colors.flexibleBlue.opacity(0.3), radius: 8, y: 4)
                            }
                            
                            // Donation Button
                            Button(action: {
                                path.append("Donation")
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "heart.fill")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Donation")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text("Support pantries with donations")
                                            .font(.caption)
                                            .opacity(0.9)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Colors.stockOrange)
                                .cornerRadius(16)
                                .shadow(color: Colors.stockOrange.opacity(0.3), radius: 8, y: 4)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 100)
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "Volunteer":
                    VolunteerView(path: $path)
                case "Schedule":
                    ScheduleView()
                case "Donation":
                    DonationView()
                default:
                    EmptyView()
                }
            }
        }
    }
}
