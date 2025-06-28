import SwiftUI

struct AdminView: View {
    @EnvironmentObject var clubManager: ClubManager
    @State private var showingColorCustomization = false
    @State private var showingDataExport = false
    @State private var showingAnalytics = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview Stats
                    overviewSection
                    
                    // Customization
                    customizationSection
                    
                    // Analytics
                    analyticsSection
                    
                    // Data Management
                    dataManagementSection
                    
                    // Advanced Features
                    advancedFeaturesSection
                }
                .padding()
            }
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                AdminStatCard(title: "Total Players", value: "\(clubManager.players.count)", icon: "person.3.fill", color: .green)
                AdminStatCard(title: "Total Matches", value: "\(clubManager.matches.count)", icon: "trophy.fill", color: .blue)
                AdminStatCard(title: "Training Sessions", value: "\(clubManager.trainings.count)", icon: "calendar", color: .orange)
                AdminStatCard(title: "News Articles", value: "\(clubManager.news.count)", icon: "newspaper", color: .purple)
            }
        }
    }
    
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customization")
                .font(.title2)
                .fontWeight(.semibold)
            
            AdminActionCard(
                title: "Club Colors",
                description: "Customize your club's primary and secondary colors",
                icon: "paintbrush.fill",
                color: .orange
            ) {
                showingColorCustomization = true
            }
            
            AdminActionCard(
                title: "Club Branding",
                description: "Update logo, motto, and visual identity",
                icon: "photo.fill",
                color: .blue
            ) {
                // Handle branding customization
            }
        }
    }
    
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics & Insights")
                .font(.title2)
                .fontWeight(.semibold)
            
            AdminActionCard(
                title: "Performance Analytics",
                description: "View detailed player and team performance metrics",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            ) {
                showingAnalytics = true
            }
            
            AdminActionCard(
                title: "Match Statistics",
                description: "Analyze match results and team performance trends",
                icon: "chart.bar.fill",
                color: .blue
            ) {
                // Handle match statistics
            }
            
            AdminActionCard(
                title: "Training Insights",
                description: "Track training effectiveness and player development",
                icon: "figure.run",
                color: .purple
            ) {
                // Handle training insights
            }
        }
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.title2)
                .fontWeight(.semibold)
            
            AdminActionCard(
                title: "Export Data",
                description: "Download all your club data as a backup",
                icon: "square.and.arrow.up",
                color: .green
            ) {
                showingDataExport = true
            }
            
            AdminActionCard(
                title: "Import Data",
                description: "Restore club data from a backup file",
                icon: "square.and.arrow.down",
                color: .blue
            ) {
                // Handle data import
            }
            
            AdminActionCard(
                title: "Sync Settings",
                description: "Configure cloud sync and backup preferences",
                icon: "icloud.fill",
                color: .cyan
            ) {
                // Handle sync settings
            }
        }
    }
    
    private var advancedFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Features")
                .font(.title2)
                .fontWeight(.semibold)
            
            AdminActionCard(
                title: "AI Insights",
                description: "Get AI-powered recommendations for team improvement",
                icon: "brain.head.profile",
                color: .pink
            ) {
                // Handle AI insights
            }
            
            AdminActionCard(
                title: "Weather Integration",
                description: "Automatic weather updates for matches and training",
                icon: "cloud.sun.fill",
                color: .yellow
            ) {
                // Handle weather integration
            }
            
            AdminActionCard(
                title: "Notifications",
                description: "Configure push notifications and alerts",
                icon: "bell.fill",
                color: .red
            ) {
                // Handle notifications
            }
        }
    }
}

struct AdminStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AdminActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//#Preview {
//    AdminView()
//        .environmentObject(ClubManager())
//}
