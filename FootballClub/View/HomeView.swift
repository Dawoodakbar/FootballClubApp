import SwiftUI

struct HomeView: View {
    @EnvironmentObject var clubManager: ClubManager
        @State private var showCalendar = false
        @State private var showStatsAdjustment = false
        @State private var statsValues: [String: Int] = [:]
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Enhanced Header with Calendar Toggle
                        headerSection
                        
                        // Calendar View (toggleable)
                        if showCalendar {
                            CalendarView()
                                .transition(.slide)
                        }
                        
                        // Interactive Stats with Adjustment
                        interactiveStatsSection
                        
                        // Interactive Charts
                        chartsSection
                        
                        // Upcoming Events
                        upcomingEventsSection
                        
                        // Recent News
                        recentNewsSection
                    }
                    .padding()
                }
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    setupStatsValues()
                }
            }
        }
        
        private var headerSection: some View {
            ZStack {
                LinearGradient(
                    colors: [Color(clubManager.clubProfile.primaryColor), Color(clubManager.clubProfile.secondaryColor)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(clubManager.clubProfile.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Manage your club with excellence")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showCalendar.toggle()
                        }
                    }) {
                        Image(systemName: showCalendar ? "calendar.badge.minus" : "calendar")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        
        private var interactiveStatsSection: some View {
            VStack(spacing: 16) {
                HStack {
                    Text("Club Statistics")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: { showStatsAdjustment = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                            Text("Adjust")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(
                        title: "Total Players",
                        value: "\(clubManager.players.count)",
                        icon: "person.3.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Total Goals",
                        value: "\(statsValues["goals", default: 0])",
                        icon: "trophy.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Total Assists",
                        value: "\(statsValues["assists", default: 0])",
                        icon: "target",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Appearances",
                        value: "\(statsValues["appearances", default: 0])",
                        icon: "calendar",
                        color: .purple
                    )
                }
            }
            .sheet(isPresented: $showStatsAdjustment) {
                ValueAdjustmentView(
                    isPresented: $showStatsAdjustment,
                    title: "Adjust Club Statistics",
                    values: statsValues,
                    valueLabels: [
                        "goals": "Total Goals",
                        "assists": "Total Assists",
                        "appearances": "Total Appearances",
                        "wins": "Wins",
                        "draws": "Draws",
                        "losses": "Losses"
                    ],
                    minValues: [
                        "goals": 0, "assists": 0, "appearances": 0,
                        "wins": 0, "draws": 0, "losses": 0
                    ],
                    maxValues: [
                        "goals": 200, "assists": 150, "appearances": 500,
                        "wins": 50, "draws": 30, "losses": 20
                    ],
                    onSave: { newValues in
                        statsValues = newValues
                    }
                )
            }
        }
        
        private var chartsSection: some View {
            VStack(spacing: 20) {
                // Performance Chart
                InteractiveChartView(
                    data: [
                        ChartDataPoint(label: "Wins", value: Double(statsValues["wins", default: 15]), color: .green, trend: .up),
                        ChartDataPoint(label: "Draws", value: Double(statsValues["draws", default: 8]), color: .orange, trend: .stable),
                        ChartDataPoint(label: "Losses", value: Double(statsValues["losses", default: 4]), color: .red, trend: .down)
                    ],
                    title: "Team Performance",
                    type: .bar,
                    onDataPointPress: { dataPoint, index in
                        print("Selected: \(dataPoint.label)")
                    }
                )
                
                // Player Statistics Distribution
                InteractiveChartView(
                    data: [
                        ChartDataPoint(label: "Goals", value: Double(statsValues["goals", default: 25]), color: .blue, trend: nil),
                        ChartDataPoint(label: "Assists", value: Double(statsValues["assists", default: 15]), color: .green, trend: nil),
                        ChartDataPoint(label: "Apps", value: Double(statsValues["appearances", default: 30]), color: .purple, trend: nil)
                    ],
                    title: "Player Statistics Distribution",
                    type: .pie,
                    onDataPointPress: { dataPoint, index in
                        print("Selected: \(dataPoint.label)")
                    }
                )
            }
        }
        
        private var upcomingEventsSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Upcoming Events")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    // Upcoming Matches
                    ForEach(clubManager.getUpcomingMatches().prefix(2), id: \.id) { match in
                        EventCard(
                            title: "vs \(match.opponent)",
                            subtitle: "\(match.date.formatted(date: .abbreviated, time: .shortened))",
                            location: match.venue.rawValue,
                            type: .match
                        )
                    }
                    
                    // Upcoming Training
                    ForEach(clubManager.getUpcomingTrainings().prefix(2), id: \.id) { training in
                        EventCard(
                            title: training.type.rawValue,
                            subtitle: "\(training.date.formatted(date: .abbreviated, time: .shortened))",
                            location: training.location,
                            type: .training
                        )
                    }
                }
            }
        }
        
        private var recentNewsSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Latest News")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                ForEach(clubManager.getRecentNews()) { newsItem in
                    NewsCard(news: newsItem)
                }
            }
        }
        
        private func setupStatsValues() {
            statsValues = [
                "goals": clubManager.players.reduce(0) { $0 + $1.goals },
                "assists": clubManager.players.reduce(0) { $0 + $1.assists },
                "appearances": clubManager.players.reduce(0) { $0 + $1.appearances },
                "wins": 15,
                "draws": 8,
                "losses": 4
            ]
        }
    }

    struct StatCard: View {
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

    struct EventCard: View {
        let title: String
        let subtitle: String
        let location: String
        let type: CalendarEvent.EventType
        
        var body: some View {
            HStack {
                Rectangle()
                    .fill(type.color)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Label(location, systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }

    struct NewsCard: View {
        let news: ClubNews
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if news.isBreaking {
                        Text("BREAKING")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    
                    Text(news.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(news.category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(news.category.color.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text(news.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(news.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(news.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }


//#Preview {
//    HomeView()
//        .environmentObject(ClubManager())
//}
