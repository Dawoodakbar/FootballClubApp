import SwiftUI
import Charts

struct PlayerDetailView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    let player: Player
    @State private var showingEditPlayer = false
    
    var playerAnalytics: PlayerAnalytics {
        clubManager.calculatePlayerAnalytics(for: player)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    playerHeaderSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Performance Chart
                    performanceChartSection
                    
                    // Detailed Stats
                    detailedStatsSection
                    
                    // Contract Info
                    contractInfoSection
                }
                .padding()
            }
            .navigationTitle(player.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditPlayer = true
                    }
                }
            }
            .sheet(isPresented: $showingEditPlayer) {
                EditPlayerView(player: player)
            }
        }
    }
    
    private var playerHeaderSection: some View {
        VStack(spacing: 16) {
            // Player Photo
            AsyncImage(url: URL(string: "https://images.pexels.com/photos/1884574/pexels-photo-1884574.jpeg")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(player.position.color, lineWidth: 4)
            )
            
            VStack(spacing: 8) {
                HStack {
                    Text(player.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("#\(player.jerseyNumber)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                
                Text(player.position.rawValue)
                    .font(.headline)
                    .foregroundColor(player.position.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(player.position.color.opacity(0.1))
                    .clipShape(Capsule())
                
                HStack(spacing: 16) {
                    Label("\(player.age) years", systemImage: "calendar")
                    Label(player.nationality, systemImage: "flag")
                    Label(player.preferredFoot.rawValue, systemImage: "figure.soccer")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                // Injury Status
                HStack {
                    Circle()
                        .fill(player.injuryStatus.color)
                        .frame(width: 8, height: 8)
                    Text(player.injuryStatus.rawValue)
                        .font(.subheadline)
                        .foregroundColor(player.injuryStatus.color)
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Season Statistics")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                StatCard(title: "Goals", value: "\(player.goals)", icon: "trophy.fill", color: .orange)
                StatCard(title: "Assists", value: "\(player.assists)", icon: "target", color: .green)
                StatCard(title: "Apps", value: "\(player.appearances)", icon: "calendar", color: .blue)
            }
            
            // Fitness and Performance
            HStack(spacing: 16) {
                VStack {
                    Text("Fitness Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        
                        Circle()
                            .trim(from: 0, to: player.fitnessLevel)
                            .stroke(
                                player.fitnessLevel >= 0.9 ? .green :
                                player.fitnessLevel >= 0.7 ? .orange : .red,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(player.fitnessLevel * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .frame(width: 80, height: 80)
                }
                
                Spacer()
                
                VStack {
                    Text("Performance Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f", playerAnalytics.performanceRating))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("out of 10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var performanceChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Trends")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Sample performance data for chart
            let performanceData = (1...10).map { week in
                PerformanceData(
                    week: week,
                    rating: Double.random(in: 6.0...9.5),
                    goals: Int.random(in: 0...3),
                    assists: Int.random(in: 0...2)
                )
            }
            
            Chart(performanceData) { data in
                LineMark(
                    x: .value("Week", data.week),
                    y: .value("Rating", data.rating)
                )
                .foregroundStyle(.blue)
                .symbol(Circle())
            }
            .frame(height: 200)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var detailedStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Statistics")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                StatRow(title: "Minutes Played", value: "\(playerAnalytics.minutesPlayed)")
                StatRow(title: "Pass Accuracy", value: "\(Int(playerAnalytics.passAccuracy * 100))%")
                StatRow(title: "Shots on Target", value: "\(playerAnalytics.shotsOnTarget)")
                StatRow(title: "Total Shots", value: "\(playerAnalytics.totalShots)")
                StatRow(title: "Tackles", value: "\(playerAnalytics.tackles)")
                StatRow(title: "Interceptions", value: "\(playerAnalytics.interceptions)")
                StatRow(title: "Yellow Cards", value: "\(playerAnalytics.yellowCards)")
                StatRow(title: "Red Cards", value: "\(playerAnalytics.redCards)")
                
                if player.position == .goalkeeper {
                    StatRow(title: "Clean Sheets", value: "\(playerAnalytics.cleanSheets)")
                    StatRow(title: "Saves", value: "\(playerAnalytics.saves)")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var contractInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contract Information")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                StatRow(title: "Market Value", value: "€\(player.marketValue.formatted())")
                StatRow(title: "Join Date", value: player.joinDate.formatted(date: .abbreviated, time: .omitted))
                StatRow(title: "Contract Expires", value: player.contractExpiry.formatted(date: .abbreviated, time: .omitted))
                StatRow(title: "Height", value: "\(player.height) cm")
                StatRow(title: "Weight", value: "\(player.weight) kg")
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct PerformanceData: Identifiable {
    let id = UUID()
    let week: Int
    let rating: Double
    let goals: Int
    let assists: Int
}

//#Preview {
//    PlayerDetailView(player: Player(
//        name: "Marco Silva",
//        position: .forward,
//        age: 25,
//        jerseyNumber: 10,
//        goals: 18,
//        assists: 12,
//        appearances: 28,
//        joinDate: Date(),
//        height: 180,
//        weight: 75,
//        nationality: "Brazil",
//        marketValue: 2500000,
//        fitnessLevel: 0.92,
//        injuryStatus: .fit,
//        preferredFoot: .right,
//        contractExpiry: Date()
//    ))
//    .environmentObject(ClubManager())
//}
