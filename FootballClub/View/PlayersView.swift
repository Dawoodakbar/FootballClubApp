import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var clubManager: ClubManager
    @State private var searchText = ""
    @State private var selectedPosition: PlayerPosition?
    @State private var showingAddPlayer = false
    @State private var selectedPlayer: Player?
    
    var filteredPlayers: [Player] {
        var players = clubManager.players
        
        if !searchText.isEmpty {
            players = players.filter { player in
                player.name.localizedCaseInsensitiveContains(searchText) ||
                player.position.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let position = selectedPosition {
            players = players.filter { $0.position == position }
        }
        
        return players.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedPosition == nil
                            ) {
                                selectedPosition = nil
                            }
                            
                            ForEach(PlayerPosition.allCases, id: \.self) { position in
                                FilterChip(
                                    title: position.rawValue,
                                    isSelected: selectedPosition == position
                                ) {
                                    selectedPosition = selectedPosition == position ? nil : position
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                // Players List
                if filteredPlayers.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No players found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Add your first player to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPlayers) { player in
                                PlayerRowView(player: player) {
                                    selectedPlayer = player
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView()
            }
            .sheet(item: $selectedPlayer) { player in
                PlayerDetailView(player: player)
            }
        }
    }
}

struct PlayerRowView: View {
    let player: Player
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Player Avatar
                AsyncImage(url: URL(string: "https://images.pexels.com/photos/1884574/pexels-photo-1884574.jpeg")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                // Player Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(player.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("#\(player.jerseyNumber)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(player.position.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(player.position.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(player.position.color.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text(player.nationality)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Injury Status
                        Circle()
                            .fill(player.injuryStatus.color)
                            .frame(width: 8, height: 8)
                    }
                    
                    // Stats
                    HStack(spacing: 16) {
                        StatPill(icon: "trophy.fill", value: "\(player.goals)", color: .orange)
                        StatPill(icon: "target", value: "\(player.assists)", color: .green)
                        StatPill(icon: "calendar", value: "\(player.appearances)", color: .blue)
                        
                        Spacer()
                        
                        // Fitness Level
                        FitnessIndicator(level: player.fitnessLevel)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct FitnessIndicator: View {
    let level: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.caption2)
                .foregroundColor(fitnessColor)
            
            Text("\(Int(level * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(fitnessColor)
        }
    }
    
    private var fitnessColor: Color {
        if level >= 0.9 { return .green }
        else if level >= 0.7 { return .orange }
        else { return .red }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search players...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .clipShape(Capsule())
        }
    }
}
//
//#Preview {
//    PlayersView()
//        .environmentObject(ClubManager())
//}
