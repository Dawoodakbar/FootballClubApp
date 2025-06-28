import SwiftUI

struct HomeView: View {
    @EnvironmentObject var clubManager: ClubManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Upcoming Matches
                    upcomingMatchesSection
                    
                    // Upcoming Training
                    upcomingTrainingSection
                    
                    // Recent News
                    recentNewsSection
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: "https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(clubManager.clubProfile.primaryColor), Color(clubManager.clubProfile.secondaryColor)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome to")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(clubManager.clubProfile.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Manage your club with excellence")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding()
                }
            )
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Club Statistics")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Total Players",
                    value: "\(clubManager.players.count)",
                    icon: "person.3.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Total Goals",
                    value: "\(clubManager.players.reduce(0) { $0 + $1.goals })",
                    icon: "trophy.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Assists",
                    value: "\(clubManager.players.reduce(0) { $0 + $1.assists })",
                    icon: "target",
                    color: .orange
                )
                
                StatCard(
                    title: "Appearances",
                    value: "\(clubManager.players.reduce(0) { $0 + $1.appearances })",
                    icon: "calendar",
                    color: .purple
                )
            }
        }
    }
    
    private var upcomingMatchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Matches")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                NavigationLink("See All", destination: MatchesView())
                    .foregroundColor(Color(clubManager.clubProfile.primaryColor))
            }
            
            let upcomingMatches = clubManager.getUpcomingMatches().prefix(2)
            
            if upcomingMatches.isEmpty {
                Text("No upcoming matches")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(upcomingMatches), id: \.id) { match in
                    MatchCard(match: match)
                }
            }
        }
    }
    
    private var upcomingTrainingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Training")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                NavigationLink("See All", destination: ScheduleView())
                    .foregroundColor(Color(clubManager.clubProfile.primaryColor))
            }
            
            let upcomingTrainings = clubManager.getUpcomingTrainings().prefix(2)
            
            if upcomingTrainings.isEmpty {
                Text("No upcoming training sessions")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(upcomingTrainings), id: \.id) { training in
                    TrainingCard(training: training)
                }
            }
        }
    }
    
    private var recentNewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Latest News")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("See All") {
                    // Navigate to news view
                }
                .foregroundColor(Color(clubManager.clubProfile.primaryColor))
            }
            
            ForEach(clubManager.getRecentNews()) { newsItem in
                NewsCard(news: newsItem)
            }
        }
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

struct MatchCard: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(match.opponent)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(match.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(match.venue.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text(match.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(match.status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(match.status.color.opacity(0.1))
                        .clipShape(Capsule())
                    
                    if let weather = match.weather {
                        Image(systemName: weather.icon)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TrainingCard: View {
    let training: Training
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(training.type.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(training.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(training.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("\(training.duration)min")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(training.intensity.color)
                        .clipShape(Capsule())
                    
                    Text("\(training.attendees.count) players")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                
                Text(news.date, style: .date)
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
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

//#Preview {
//    HomeView()
//        .environmentObject(ClubManager())
//}
