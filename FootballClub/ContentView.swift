//
//  ContentView.swift
//  FootballClub
//
//  Created by Dawood Akbar on 28/06/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var clubManager = ClubManager()
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoading = false
                    }
                }
            } else {
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    
                    PlayersView()
                        .tabItem {
                            Image(systemName: "person.3.fill")
                            Text("Players")
                        }
                    
                    MatchesView()
                        .tabItem {
                            Image(systemName: "trophy.fill")
                            Text("Matches")
                        }
                    
                    ScheduleView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Schedule")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "building.2.fill")
                            Text("Club")
                        }
                    
                    AdminView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Admin")
                        }
                }
                .environmentObject(clubManager)
                .accentColor(Color(clubManager.clubProfile.primaryColor))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
