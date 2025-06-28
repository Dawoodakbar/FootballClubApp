import SwiftUI
import Foundation
import CoreLocation

// MARK: - Player Model
struct Player: Identifiable, Codable {
    let id = UUID()
    var name: String
    var position: PlayerPosition
    var age: Int
    var jerseyNumber: Int
    var photo: String?
    var goals: Int
    var assists: Int
    var appearances: Int
    var joinDate: Date
    var height: Int // in cm
    var weight: Int // in kg
    var nationality: String
    var marketValue: Int
    var fitnessLevel: Double // 0.0 to 1.0
    var injuryStatus: InjuryStatus
    var preferredFoot: PreferredFoot
    var contractExpiry: Date
}

enum PlayerPosition: String, CaseIterable, Codable {
    case goalkeeper = "Goalkeeper"
    case defender = "Defender"
    case midfielder = "Midfielder"
    case forward = "Forward"
    
    var color: Color {
        switch self {
        case .goalkeeper: return .orange
        case .defender: return .green
        case .midfielder: return .blue
        case .forward: return .red
        }
    }
}

enum InjuryStatus: String, CaseIterable, Codable {
    case fit = "Fit"
    case minor = "Minor Injury"
    case major = "Major Injury"
    case recovering = "Recovering"
    
    var color: Color {
        switch self {
        case .fit: return .green
        case .minor: return .yellow
        case .major: return .red
        case .recovering: return .orange
        }
    }
}

enum PreferredFoot: String, CaseIterable, Codable {
    case left = "Left"
    case right = "Right"
    case both = "Both"
}

// MARK: - Match Model
struct Match: Identifiable, Codable {
    let id = UUID()
    var opponent: String
    var date: Date
    var venue: Venue
    var competition: String
    var status: MatchStatus
    var homeScore: Int?
    var awayScore: Int?
    var homeTeam: String
    var awayTeam: String
    var weather: WeatherCondition?
    var attendance: Int?
    var matchEvents: [MatchEvent]
    var formation: Formation?
}

enum Venue: String, CaseIterable, Codable {
    case home = "Home"
    case away = "Away"
    case neutral = "Neutral"
}

enum MatchStatus: String, CaseIterable, Codable {
    case upcoming = "Upcoming"
    case live = "Live"
    case completed = "Completed"
    case postponed = "Postponed"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .upcoming: return .blue
        case .live: return .red
        case .completed: return .green
        case .postponed: return .orange
        case .cancelled: return .gray
        }
    }
}

enum WeatherCondition: String, CaseIterable, Codable {
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case windy = "Windy"
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .windy: return "wind"
        }
    }
}

struct MatchEvent: Identifiable, Codable {
    let id = UUID()
    var minute: Int
    var type: EventType
    var player: String
    var description: String
}

enum EventType: String, CaseIterable, Codable {
    case goal = "Goal"
    case assist = "Assist"
    case yellowCard = "Yellow Card"
    case redCard = "Red Card"
    case substitution = "Substitution"
    case injury = "Injury"
}

enum Formation: String, CaseIterable, Codable {
    case f442 = "4-4-2"
    case f433 = "4-3-3"
    case f352 = "3-5-2"
    case f451 = "4-5-1"
    case f343 = "3-4-3"
    case f532 = "5-3-2"
}

// MARK: - Training Model
struct Training: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var type: TrainingType
    var duration: Int // in minutes
    var location: String
    var description: String
    var attendees: [UUID] // Player IDs
    var status: TrainingStatus
    var intensity: TrainingIntensity
    var focus: [TrainingFocus]
    var weatherConditions: WeatherCondition?
}

enum TrainingType: String, CaseIterable, Codable {
    case tactical = "Tactical Training"
    case fitness = "Fitness Training"
    case technical = "Technical Skills"
    case setPieces = "Set Pieces"
    case matchPrep = "Match Preparation"
    case recovery = "Recovery Session"
    case strength = "Strength Training"
    case conditioning = "Conditioning"
    case scrimmage = "Scrimmage"
}

enum TrainingStatus: String, CaseIterable, Codable {
    case upcoming = "Upcoming"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

enum TrainingIntensity: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case maximum = "Maximum"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .maximum: return .red
        }
    }
}

enum TrainingFocus: String, CaseIterable, Codable {
    case passing = "Passing"
    case shooting = "Shooting"
    case defending = "Defending"
    case crossing = "Crossing"
    case finishing = "Finishing"
    case setpieces = "Set Pieces"
    case fitness = "Fitness"
    case tactics = "Tactics"
}

// MARK: - Club Profile Model
struct ClubProfile: Codable {
    var name: String
    var logo: String?
    var founded: Int
    var stadium: String
    var capacity: Int
    var manager: String
    var description: String
    var primaryColor: String
    var secondaryColor: String
    var achievements: [String]
    var socialMedia: SocialMedia
    var location: CodableCoordinate?
    var motto: String
    var nickname: String
}

// Custom Codable wrapper for CLLocationCoordinate2D
struct CodableCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct SocialMedia: Codable {
    var website: String?
    var instagram: String?
    var twitter: String?
    var facebook: String?
    var youtube: String?
    var tiktok: String?
}

// MARK: - News Model
struct ClubNews: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var image: String?
    var date: Date
    var author: String
    var category: NewsCategory
    var isBreaking: Bool
    var tags: [String]
}

enum NewsCategory: String, CaseIterable, Codable {
    case transfer = "Transfer"
    case match = "Match"
    case training = "Training"
    case general = "General"
    case injury = "Injury"
    case achievement = "Achievement"
    
    var color: Color {
        switch self {
        case .transfer: return .blue
        case .match: return .green
        case .training: return .orange
        case .general: return .gray
        case .injury: return .red
        case .achievement: return .purple
        }
    }
}

// MARK: - Analytics Model
struct PlayerAnalytics: Identifiable, Codable {
    let id = UUID()
    var playerId: UUID
    var matchesPlayed: Int
    var minutesPlayed: Int
    var goals: Int
    var assists: Int
    var yellowCards: Int
    var redCards: Int
    var passAccuracy: Double
    var shotsOnTarget: Int
    var totalShots: Int
    var tackles: Int
    var interceptions: Int
    var cleanSheets: Int // for goalkeepers
    var saves: Int // for goalkeepers
    var fitnessScore: Double
    var performanceRating: Double
}

// Fixed TeamAnalytics with Codable-compliant types
struct TeamAnalytics: Codable {
    var totalMatches: Int
    var wins: Int
    var draws: Int
    var losses: Int
    var goalsFor: Int
    var goalsAgainst: Int
    var cleanSheets: Int
    var averageAttendance: Int
    var homeRecord: TeamRecord
    var awayRecord: TeamRecord
    var formLast5: [MatchResult]
}

// Separate struct for team records to make it Codable
struct TeamRecord: Codable {
    var wins: Int
    var draws: Int
    var losses: Int
    
    init(wins: Int, draws: Int, losses: Int) {
        self.wins = wins
        self.draws = draws
        self.losses = losses
    }
}

enum MatchResult: String, CaseIterable, Codable {
    case win = "W"
    case draw = "D"
    case loss = "L"
    
    var color: Color {
        switch self {
        case .win: return .green
        case .draw: return .yellow
        case .loss: return .red
        }
    }
}
