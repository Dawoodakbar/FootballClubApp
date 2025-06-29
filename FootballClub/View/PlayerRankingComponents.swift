//
//  PlayerRankingComponents.swift
//  FootballClub
//
//  Created by Dawood Akbar on 29/06/2025.
//

import SwiftUI



// MARK: - Player Ranking Card Component
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
            
            playersList
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var playersList: some View {
        VStack(spacing: 8) {
            ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                PlayerRankingRow(
                    position: index + 1,
                    player: player,
                    metricValue: player[keyPath: metricKeyPath],
                    metricName: metricName,
                    color: color
                )
            }
        }
    }
}

// MARK: - Player Ranking Row Component
struct PlayerRankingRow: View {
    let position: Int
    let player: Player
    let metricValue: Int
    let metricName: String
    let color: Color
    
    var body: some View {
        HStack {
            positionBadge
            playerInfo
            Spacer()
            metricDisplay
        }
    }
    
    private var positionBadge: some View {
        Text("\(position)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 20, height: 20)
            .background(color)
            .clipShape(Circle())
    }
    
    private var playerInfo: some View {
        Text(player.name)
            .font(.subheadline)
            .fontWeight(.medium)
    }
    
    private var metricDisplay: some View {
        Text("\(metricValue) \(metricName)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

// MARK: - Team Record Component
struct TeamRecordView: View {
    let title: String
    let record: TeamRecord
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("\(record.wins)W-\(record.draws)D-\(record.losses)L")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Form Display Component
struct FormDisplayView: View {
    let formResults: [MatchResult]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Form (Last 5 Games)")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                ForEach(Array(formResults.enumerated()), id: \.offset) { index, result in
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


//struct PlayerRankingComponents_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerRankingComponents()
//    }
//}
