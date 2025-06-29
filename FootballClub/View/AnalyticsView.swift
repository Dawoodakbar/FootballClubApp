import SwiftUI

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
                    selectionSection
                    teamOverviewSection
                    performanceChartsSection
                    playerRankingsSection
                    matchAnalysisSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Selection Section
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
    
    // MARK: - Team Overview Section
    private var teamOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Overview")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                AnalyticsCard(
                    title: "Win Rate",
                    value: "\(calculateWinRate())%",
                    trend: .up,
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Goals/Match",
                    value: String(format: "%.1f", calculateGoalsPerMatch()),
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
    
    // MARK: - Performance Charts Section
    private var performanceChartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Trends")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 20) {
                CustomBarChart(data: generatePerformanceData())
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                CustomLineChart(data: generateGoalsData())
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Player Rankings Section
    private var playerRankingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Performers")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PlayerRankingCard(
                    title: "Top Scorer",
                    players: Array(clubManager.players.sorted { $0.goals > $1.goals }.prefix(3)),
                    metricKeyPath: \.goals,
                    metricName: "Goals",
                    color: .orange
                )
                
                PlayerRankingCard(
                    title: "Top Assists",
                    players: Array(clubManager.players.sorted { $0.assists > $1.assists }.prefix(3)),
                    metricKeyPath: \.assists,
                    metricName: "Assists",
                    color: .green
                )
                
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
    
    // MARK: - Match Analysis Section
    private var matchAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Match Analysis")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                HStack {
                    TeamRecordView(
                        title: "Home Record",
                        record: clubManager.teamAnalytics.homeRecord,
                        color: .green
                    )
                    
                    TeamRecordView(
                        title: "Away Record",
                        record: clubManager.teamAnalytics.awayRecord,
                        color: .blue
                    )
                }
                
                FormDisplayView(formResults: clubManager.teamAnalytics.formLast5)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func calculateWinRate() -> Int {
        let totalMatches = clubManager.teamAnalytics.totalMatches
        guard totalMatches > 0 else { return 0 }
        return Int(Double(clubManager.teamAnalytics.wins) / Double(totalMatches) * 100)
    }
    
    private func calculateGoalsPerMatch() -> Double {
        let totalMatches = clubManager.teamAnalytics.totalMatches
        guard totalMatches > 0 else { return 0.0 }
        return Double(clubManager.teamAnalytics.goalsFor) / Double(totalMatches)
    }
    
    private func generatePerformanceData() -> [MonthlyPerformance] {
        return (1...12).map { month in
            MonthlyPerformance(
                month: month,
                wins: Int.random(in: 2...6),
                draws: Int.random(in: 0...3),
                losses: Int.random(in: 0...2),
                goalsFor: Int.random(in: 8...20),
                goalsAgainst: Int.random(in: 2...12)
            )
        }
    }
    
    private func generateGoalsData() -> [GoalsChartData] {
        return (1...6).map { month in
            GoalsChartData(
                month: "M\(month)",
                goalsFor: Int.random(in: 8...20),
                goalsAgainst: Int.random(in: 2...12)
            )
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
