import Foundation
import SwiftUI

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Player Analytics
    func calculatePlayerPerformanceScore(for player: Player, matches: [Match]) -> Double {
        let goalsWeight = 0.4
        let assistsWeight = 0.3
        let appearancesWeight = 0.2
        let fitnessWeight = 0.1
        
        let normalizedGoals = min(Double(player.goals) / 20.0, 1.0)
        let normalizedAssists = min(Double(player.assists) / 15.0, 1.0)
        let normalizedAppearances = min(Double(player.appearances) / 30.0, 1.0)
        let normalizedFitness = player.fitnessLevel
        
        let score = (normalizedGoals * goalsWeight) +
                   (normalizedAssists * assistsWeight) +
                   (normalizedAppearances * appearancesWeight) +
                   (normalizedFitness * fitnessWeight)
        
        return min(score * 10, 10.0) // Scale to 0-10
    }
    
    func getPlayerEfficiencyRating(for player: Player) -> Double {
        guard player.appearances > 0 else { return 0.0 }
        
        let totalContributions = player.goals + player.assists
        let efficiency = Double(totalContributions) / Double(player.appearances)
        
        return min(efficiency * 2, 10.0) // Scale to reasonable range
    }
    
    func getTopPerformers(from players: [Player], matches: [Match], limit: Int = 5) -> [Player] {
        return players
            .sorted { calculatePlayerPerformanceScore(for: $0, matches: matches) > calculatePlayerPerformanceScore(for: $1, matches: matches) }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Team Analytics
    func calculateTeamForm(from matches: [Match], limit: Int = 5) -> [MatchResult] {
        let recentMatches = matches
            .filter { $0.status == .completed }
            .sorted { $0.date > $1.date }
            .prefix(limit)
        
        return recentMatches.map { match in
            guard let homeScore = match.homeScore, let awayScore = match.awayScore else {
                return .draw
            }
            
            let isHomeMatch = match.venue == .home
            let ourScore = isHomeMatch ? homeScore : awayScore
            let theirScore = isHomeMatch ? awayScore : homeScore
            
            if ourScore > theirScore {
                return .win
            } else if ourScore < theirScore {
                return .loss
            } else {
                return .draw
            }
        }
    }
    
    func calculateWinPercentage(from matches: [Match]) -> Double {
        let completedMatches = matches.filter { $0.status == .completed }
        guard !completedMatches.isEmpty else { return 0.0 }
        
        let wins = completedMatches.filter { match in
            guard let homeScore = match.homeScore, let awayScore = match.awayScore else { return false }
            let isHomeMatch = match.venue == .home
            let ourScore = isHomeMatch ? homeScore : awayScore
            let theirScore = isHomeMatch ? awayScore : homeScore
            return ourScore > theirScore
        }.count
        
        return Double(wins) / Double(completedMatches.count) * 100
    }
    
    func calculateGoalsPerMatch(from matches: [Match]) -> Double {
        let completedMatches = matches.filter { $0.status == .completed }
        guard !completedMatches.isEmpty else { return 0.0 }
        
        let totalGoals = completedMatches.reduce(0) { total, match in
            guard let homeScore = match.homeScore, let awayScore = match.awayScore else { return total }
            let isHomeMatch = match.venue == .home
            let ourScore = isHomeMatch ? homeScore : awayScore
            return total + ourScore
        }
        
        return Double(totalGoals) / Double(completedMatches.count)
    }
    
    // MARK: - Training Analytics
    func calculateTrainingEffectiveness(trainings: [Training], players: [Player]) -> Double {
        let completedTrainings = trainings.filter { $0.status == .completed }
        guard !completedTrainings.isEmpty else { return 0.0 }
        
        let totalAttendance = completedTrainings.reduce(0) { $0 + $1.attendees.count }
        let averageAttendance = Double(totalAttendance) / Double(completedTrainings.count)
        let maxPossibleAttendance = Double(players.count)
        
        return (averageAttendance / maxPossibleAttendance) * 100
    }
    
    func getTrainingIntensityDistribution(from trainings: [Training]) -> [TrainingIntensity: Int] {
        var distribution: [TrainingIntensity: Int] = [:]
        
        for training in trainings {
            distribution[training.intensity, default: 0] += 1
        }
        
        return distribution
    }
    
    // MARK: - Injury Analytics
    func calculateInjuryRate(from players: [Player]) -> Double {
        let injuredPlayers = players.filter { $0.injuryStatus != .fit }.count
        guard !players.isEmpty else { return 0.0 }
        
        return Double(injuredPlayers) / Double(players.count) * 100
    }
    
    func getInjuryTrends(from players: [Player]) -> [InjuryStatus: Int] {
        var trends: [InjuryStatus: Int] = [:]
        
        for player in players {
            trends[player.injuryStatus, default: 0] += 1
        }
        
        return trends
    }
    
    // MARK: - Financial Analytics
    func calculateTotalSquadValue(from players: [Player]) -> Int {
        return players.reduce(0) { $0 + $1.marketValue }
    }
    
    func getAveragePlayerValue(from players: [Player]) -> Int {
        guard !players.isEmpty else { return 0 }
        return calculateTotalSquadValue(from: players) / players.count
    }
    
    func getMostValuablePlayers(from players: [Player], limit: Int = 5) -> [Player] {
        return players
            .sorted { $0.marketValue > $1.marketValue }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Age Analytics
    func calculateAverageAge(from players: [Player]) -> Double {
        guard !players.isEmpty else { return 0.0 }
        let totalAge = players.reduce(0) { $0 + $1.age }
        return Double(totalAge) / Double(players.count)
    }
    
    func getAgeDistribution(from players: [Player]) -> [String: Int] {
        var distribution: [String: Int] = [:]
        
        for player in players {
            let ageGroup: String
            switch player.age {
            case 16...20:
                ageGroup = "16-20"
            case 21...25:
                ageGroup = "21-25"
            case 26...30:
                ageGroup = "26-30"
            case 31...35:
                ageGroup = "31-35"
            default:
                ageGroup = "35+"
            }
            
            distribution[ageGroup, default: 0] += 1
        }
        
        return distribution
    }
    
    // MARK: - Position Analytics
    func getPositionDistribution(from players: [Player]) -> [PlayerPosition: Int] {
        var distribution: [PlayerPosition: Int] = [:]
        
        for player in players {
            distribution[player.position, default: 0] += 1
        }
        
        return distribution
    }
    
    func getPositionPerformance(from players: [Player]) -> [PlayerPosition: Double] {
        var performance: [PlayerPosition: Double] = [:]
        let positionGroups = Dictionary(grouping: players, by: { $0.position })
        
        for (position, positionPlayers) in positionGroups {
            let averageGoals = Double(positionPlayers.reduce(0) { $0 + $1.goals }) / Double(positionPlayers.count)
            let averageAssists = Double(positionPlayers.reduce(0) { $0 + $1.assists }) / Double(positionPlayers.count)
            
            performance[position] = averageGoals + averageAssists
        }
        
        return performance
    }
}

// MARK: - Chart Data Models
//struct ChartDataPoint: Identifiable {
//    let id = UUID()
//    let x: String
//    let y: Double
//    let category: String?
//}

struct PerformanceChartData: Identifiable {
    let id = UUID()
    let month: String
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
}

extension AnalyticsService {
    func generatePerformanceChartData(from matches: [Match]) -> [PerformanceChartData] {
        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let completedMatches = matches.filter { $0.status == .completed }
        let groupedByMonth = Dictionary(grouping: completedMatches) { match in
            monthFormatter.string(from: match.date)
        }
        
        return groupedByMonth.map { month, monthMatches in
            let wins = monthMatches.filter { match in
                guard let homeScore = match.homeScore, let awayScore = match.awayScore else { return false }
                let isHomeMatch = match.venue == .home
                let ourScore = isHomeMatch ? homeScore : awayScore
                let theirScore = isHomeMatch ? awayScore : homeScore
                return ourScore > theirScore
            }.count
            
            let draws = monthMatches.filter { match in
                guard let homeScore = match.homeScore, let awayScore = match.awayScore else { return false }
                return homeScore == awayScore
            }.count
            
            let losses = monthMatches.count - wins - draws
            
            let goalsFor = monthMatches.reduce(0) { total, match in
                guard let homeScore = match.homeScore, let awayScore = match.awayScore else { return total }
                let isHomeMatch = match.venue == .home
                let ourScore = isHomeMatch ? homeScore : awayScore
                return total + ourScore
            }
            
            let goalsAgainst = monthMatches.reduce(0) { total, match in
                guard let homeScore = match.homeScore, let awayScore = match.awayScore else { return total }
                let isHomeMatch = match.venue == .home
                let theirScore = isHomeMatch ? awayScore : homeScore
                return total + theirScore
            }
            
            return PerformanceChartData(
                month: month,
                wins: wins,
                draws: draws,
                losses: losses,
                goalsFor: goalsFor,
                goalsAgainst: goalsAgainst
            )
        }.sorted { $0.month < $1.month }
    }
}
