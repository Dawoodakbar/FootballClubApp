import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var clubManager: ClubManager
    @State private var selectedTimeframe: Timeframe = .season
    @State private var selectedMetric: AnalyticsMetric = .performance
    
    enum Timeframe: String, CaseIterable {
        case month = "Last Month"
        case season = "This Season"
        case year = "Last Year"
        case allTime = "All Time"
    }
    
    enum AnalyticsMetric: String, CaseIterable {
        case performance = "Performance"
        case goals = "Goals"
        case fitness = "Fitness"
        case attendance = "Attendance"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time and Metric Selectors
                    selectionSection
                    
                    // Team Overview
                    teamOverviewSection
                    
                    // Performance Charts
                    performanceChartsSection
                    
                    // Player Rankings
                    playerRankingsSection
                    
                    // Match Analysis
                    matchAnalysisSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var selectionSection: some View {
        VStack(spacing: 16) {
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Picker("Metric", selection: $selectedMetric) {
                ForEach(AnalyticsMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var teamOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Overview")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                AnalyticsCard(
                    title: "Win Rate",
                    value: "\(Int(Double(clubManager.teamAnalytics.wins) / Double(clubManager.teamAnalytics.totalMatches) * 100))%",
                    trend: .up,
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Goals/Match",
                    value: String(format: "%.1f", Double(clubManager.teamAnalytics.goalsFor) / Double(clubManager.teamAnalytics.totalMatches)),
                    trend: .up,
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Clean Sheets",
                    value: "\(clubManager.teamAnalytics.cleanSheets)",
                    trend: .stable,
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Avg Attendance",
                    value: "\(clubManager.teamAnalytics.averageAttendance.formatted())",
                    trend: .up,
                    color: .purple
                )
            }
        }
    }
    
    private var performanceChartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Trends")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Sample performance data for Xcode 14 compatibility
            let performanceData = (1...12).map { month in
                MonthlyPerformance(
                    month: month,
                    wins: Int.random(in: 2...6),
                    draws: Int.random(in: 0...3),
                    losses: Int.random(in: 0...2),
                    goalsFor: Int.random(in: 8...20),
                    goalsAgainst: Int.random(in: 2...12)
                )
            }
            
            VStack(spacing: 20) {
                // Custom Chart Views for Xcode 14 compatibility
                VStack(alignment: .leading) {
                    Text("Monthly Results")
                        .font(.headline)
                    
                    CustomBarChart(data: performanceData.map { data in
                        ChartDataPoint(
                            month: "Month \(data.month)",
                            wins: data.wins,
                            draws: data.draws,
                            losses: data.losses
                        )
                    })
                    .frame(height: 200)
                }
                
                VStack(alignment: .leading) {
                    Text("Goals Scored vs Conceded")
                        .font(.headline)
                    
                    CustomLineChart(data: performanceData.map { data in
                        GoalsChartData(
                            month: "M\(data.month)",
                            goalsFor: data.goalsFor,
                            goalsAgainst: data.goalsAgainst
                        )
                    })
                    .frame(height: 200)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var playerRankingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Performers")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Top Scorers - Fixed ForEach for Xcode 14
                PlayerRankingCard(
                    title: "Top Scorer",
                    players: Array(clubManager.players.sorted { $0.goals > $1.goals }.prefix(3)),
                    metricKeyPath: \.goals,
                    metricName: "Goals",
                    color: .orange
                )
                
                // Top Assisters
                PlayerRankingCard(
                    title: "Top Assists",
                    players: Array(clubManager.players.sorted { $0.assists > $1.assists }.prefix(3)),
                    metricKeyPath: \.assists,
                    metricName: "Assists",
                    color: .green
                )
                
                // Most Appearances
                PlayerRankingCard(
                    title: "Most Appearances",
                    players: Array(clubManager.players.sorted { $0.appearances > $1.appearances }.prefix(3)),
                    metricKeyPath: \.appearances,
                    metricName: "Apps",
                    color: .blue
                )
            }
        }
    }
    
    private var matchAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Match Analysis")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Home vs Away Performance
                HStack {
                    VStack {
                        Text("Home Record")
                            .font(.headline)
                        Text("\(clubManager.teamAnalytics.homeRecord.wins)W-\(clubManager.teamAnalytics.homeRecord.draws)D-\(clubManager.teamAnalytics.homeRecord.losses)L")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack {
                        Text("Away Record")
                            .font(.headline)
                        Text("\(clubManager.teamAnalytics.awayRecord.wins)W-\(clubManager.teamAnalytics.awayRecord.draws)D-\(clubManager.teamAnalytics.awayRecord.losses)L")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Recent Form
                VStack(alignment: .leading) {
                    Text("Recent Form (Last 5 Games)")
                        .font(.headline)
                    
                    HStack {
                        ForEach(Array(clubManager.teamAnalytics.formLast5.enumerated()), id: \.offset) { index, result in
                            Text(result.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(result.color)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let color: Color
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .orange
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct PlayerRankingCard: View {
    let title: String
    let players: [Player]
    let metricKeyPath: KeyPath<Player, Int>
    let metricName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            // Fixed ForEach for Xcode 14 compatibility
            ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                HStack {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(color)
                        .clipShape(Circle())
                    
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(player[keyPath: metricKeyPath]) \(metricName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Custom Chart Data Models for Xcode 14 compatibility
struct MonthlyPerformance: Identifiable {
    let id = UUID()
    let month: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let wins: Int
    let draws: Int
    let losses: Int
}

struct GoalsChartData: Identifiable {
    let id = UUID()
    let month: String
    let goalsFor: Int
    let goalsAgainst: Int
}

// Custom Chart Views for Xcode 14 compatibility
struct CustomBarChart: View {
    let data: [ChartDataPoint]
    
    var body: some View {
        VStack {
            Text("Custom Bar Chart")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(data.prefix(6)) { point in
                    VStack {
                        VStack(spacing: 2) {
                            Rectangle()
                                .fill(Color.green)
                                .frame(height: CGFloat(point.wins * 10))
                            Rectangle()
                                .fill(Color.orange)
                                .frame(height: CGFloat(point.draws * 10))
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: CGFloat(point.losses * 10))
                        }
                        .frame(width: 30)
                        
                        Text(String(point.month.suffix(2)))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 150)
        }
    }
}

struct CustomLineChart: View {
    let data: [GoalsChartData]
    
    var body: some View {
        VStack {
            Text("Goals Trend")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data.prefix(6)) { point in
                    VStack {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .offset(y: CGFloat(-point.goalsFor * 5))
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(y: CGFloat(-point.goalsAgainst * 5))
                        }
                        .frame(height: 100)
                        
                        Text(point.month)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
//struct AnalyticsView_Preview: PreviewProvider {
//    typealias Previews = <#type#>
//    
//    static var preview: some View {
//        AnalyticsView()
//            .environmentObject(ClubManager())
//    }
//}
