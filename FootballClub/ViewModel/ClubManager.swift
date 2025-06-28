import SwiftUI
import Foundation
import Combine

class ClubManager: ObservableObject {
    @Published var players: [Player] = []
    @Published var matches: [Match] = []
    @Published var trainings: [Training] = []
    @Published var clubProfile: ClubProfile
    @Published var news: [ClubNews] = []
    @Published var playerAnalytics: [PlayerAnalytics] = []
    @Published var teamAnalytics: TeamAnalytics
    
    init() {
        // Initialize with sample data
        self.clubProfile = ClubProfile(
            name: "FC Champions",
            founded: 1965,
            stadium: "Champions Arena",
            capacity: 45000,
            manager: "Alex Rodriguez",
            description: "A legendary football club with a rich history of success and commitment to excellence.",
            primaryColor: "#22C55E",
            secondaryColor: "#3B82F6",
            achievements: [
                "League Champions (5x)",
                "Cup Winners (3x)",
                "International Trophy (2x)",
                "Youth Championship (4x)"
            ],
            socialMedia: SocialMedia(
                website: "https://fcchampions.com",
                instagram: "@fcchampions",
                twitter: "@fcchampions",
                facebook: "FC Champions Official"
            ),
            location: nil,
            motto: "Excellence Through Unity",
            nickname: "The Champions"
        )
        
        // Fixed TeamAnalytics initialization
        self.teamAnalytics = TeamAnalytics(
            totalMatches: 30,
            wins: 18,
            draws: 8,
            losses: 4,
            goalsFor: 65,
            goalsAgainst: 28,
            cleanSheets: 12,
            averageAttendance: 38500,
            homeRecord: TeamRecord(wins: 12, draws: 3, losses: 0),
            awayRecord: TeamRecord(wins: 6, draws: 5, losses: 4),
            formLast5: [.win, .win, .draw, .win, .loss]
        )
        
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample Players
        players = [
            Player(
                name: "Marco Silva",
                position: .forward,
                age: 25,
                jerseyNumber: 10,
                goals: 18,
                assists: 12,
                appearances: 28,
                joinDate: Date(),
                height: 180,
                weight: 75,
                nationality: "Brazil",
                marketValue: 2500000,
                fitnessLevel: 0.92,
                injuryStatus: .fit,
                preferredFoot: .right,
                contractExpiry: Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
            ),
            Player(
                name: "David Johnson",
                position: .midfielder,
                age: 28,
                jerseyNumber: 8,
                goals: 6,
                assists: 15,
                appearances: 30,
                joinDate: Date(),
                height: 175,
                weight: 72,
                nationality: "England",
                marketValue: 1800000,
                fitnessLevel: 0.88,
                injuryStatus: .fit,
                preferredFoot: .left,
                contractExpiry: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date()
            ),
            Player(
                name: "Carlos Rodriguez",
                position: .defender,
                age: 30,
                jerseyNumber: 4,
                goals: 2,
                assists: 3,
                appearances: 29,
                joinDate: Date(),
                height: 185,
                weight: 80,
                nationality: "Spain",
                marketValue: 1200000,
                fitnessLevel: 0.85,
                injuryStatus: .minor,
                preferredFoot: .right,
                contractExpiry: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
            )
        ]
        
        // Sample Matches
        matches = [
            Match(
                opponent: "Real Madrid",
                date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                venue: .home,
                competition: "La Liga",
                status: .upcoming,
                homeTeam: "FC Champions",
                awayTeam: "Real Madrid",
                weather: .sunny,
                matchEvents: [],
                formation: .f433
            ),
            Match(
                opponent: "Barcelona",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                venue: .away,
                competition: "La Liga",
                status: .completed,
                homeScore: 2,
                awayScore: 3,
                homeTeam: "Barcelona",
                awayTeam: "FC Champions",
                weather: .cloudy,
                attendance: 85000,
                matchEvents: [
                    MatchEvent(minute: 15, type: .goal, player: "Marco Silva", description: "Header from corner"),
                    MatchEvent(minute: 32, type: .goal, player: "David Johnson", description: "Long range shot"),
                    MatchEvent(minute: 78, type: .goal, player: "Marco Silva", description: "Penalty kick")
                ],
                formation: .f442
            )
        ]
        
        // Sample Training Sessions
        trainings = [
            Training(
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                type: .tactical,
                duration: 90,
                location: "Training Ground A",
                description: "Focus on defensive formations and set pieces",
                attendees: players.map { $0.id },
                status: .upcoming,
                intensity: .medium,
                focus: [.tactics, .setpieces],
                weatherConditions: .sunny
            ),
            Training(
                date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                type: .fitness,
                duration: 60,
                location: "Fitness Center",
                description: "Cardio and strength conditioning",
                attendees: Array(players.map { $0.id }.prefix(2)),
                status: .upcoming,
                intensity: .high,
                focus: [.fitness],
                weatherConditions: .cloudy
            )
        ]
        
        // Sample News
        news = [
            ClubNews(
                title: "New Signing: Marco Silva Joins FC Champions",
                content: "We are excited to announce the signing of Brazilian forward Marco Silva from Santos FC.",
                date: Date(),
                author: "Club Media Team",
                category: .transfer,
                isBreaking: true,
                tags: ["Transfer", "Marco Silva", "Forward"]
            ),
            ClubNews(
                title: "Victory Against Barcelona - Match Report",
                content: "An incredible comeback victory at Camp Nou! Despite going 2-0 down, our team showed tremendous character.",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                author: "Sports Reporter",
                category: .match,
                isBreaking: false,
                tags: ["Match Report", "Barcelona", "Victory"]
            )
        ]
    }
    
    // MARK: - Player Management
    func addPlayer(_ player: Player) {
        players.append(player)
    }
    
    func updatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
        }
    }
    
    func deletePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }
    
    // MARK: - Match Management
    func addMatch(_ match: Match) {
        matches.append(match)
    }
    
    func updateMatch(_ match: Match) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index] = match
        }
    }
    
    func deleteMatch(_ match: Match) {
        matches.removeAll { $0.id == match.id }
    }
    
    // MARK: - Training Management
    func addTraining(_ training: Training) {
        trainings.append(training)
    }
    
    func updateTraining(_ training: Training) {
        if let index = trainings.firstIndex(where: { $0.id == training.id }) {
            trainings[index] = training
        }
    }
    
    func deleteTraining(_ training: Training) {
        trainings.removeAll { $0.id == training.id }
    }
    
    // MARK: - News Management
    func addNews(_ newsItem: ClubNews) {
        news.insert(newsItem, at: 0)
    }
    
    func updateNews(_ newsItem: ClubNews) {
        if let index = news.firstIndex(where: { $0.id == newsItem.id }) {
            news[index] = newsItem
        }
    }
    
    func deleteNews(_ newsItem: ClubNews) {
        news.removeAll { $0.id == newsItem.id }
    }
    
    // MARK: - Analytics
    func calculatePlayerAnalytics(for player: Player) -> PlayerAnalytics {
        return PlayerAnalytics(
            playerId: player.id,
            matchesPlayed: player.appearances,
            minutesPlayed: player.appearances * 85, // Average minutes per game
            goals: player.goals,
            assists: player.assists,
            yellowCards: Int.random(in: 0...5),
            redCards: Int.random(in: 0...1),
            passAccuracy: Double.random(in: 0.75...0.95),
            shotsOnTarget: player.goals + Int.random(in: 5...15),
            totalShots: player.goals + Int.random(in: 15...30),
            tackles: Int.random(in: 20...60),
            interceptions: Int.random(in: 15...45),
            cleanSheets: player.position == .goalkeeper ? Int.random(in: 8...15) : 0,
            saves: player.position == .goalkeeper ? Int.random(in: 50...120) : 0,
            fitnessScore: player.fitnessLevel,
            performanceRating: Double.random(in: 6.5...9.2)
        )
    }
    
    func getUpcomingMatches() -> [Match] {
        return matches.filter { $0.status == .upcoming }
            .sorted { $0.date < $1.date }
    }
    
    func getUpcomingTrainings() -> [Training] {
        return trainings.filter { $0.status == .upcoming }
            .sorted { $0.date < $1.date }
    }
    
    func getRecentNews() -> [ClubNews] {
        return Array(news.prefix(5))
    }
}
