import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var clubManager: ClubManager
    @State private var searchText = ""
    @State private var selectedStatus: MatchStatus?
    @State private var showingAddMatch = false
    @State private var selectedMatch: Match?
    
    var filteredMatches: [Match] {
        var matches = clubManager.matches
        
        if !searchText.isEmpty {
            matches = matches.filter { match in
                match.opponent.localizedCaseInsensitiveContains(searchText) ||
                match.competition.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let status = selectedStatus {
            matches = matches.filter { $0.status == status }
        }
        
        return matches.sorted { $0.date > $1.date }
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
                                isSelected: selectedStatus == nil
                            ) {
                                selectedStatus = nil
                            }
                            
                            ForEach(MatchStatus.allCases, id: \.self) { status in
                                FilterChip(
                                    title: status.rawValue,
                                    isSelected: selectedStatus == status
                                ) {
                                    selectedStatus = selectedStatus == status ? nil : status
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                // Matches List
                if filteredMatches.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No matches found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Schedule your first match")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredMatches) { match in
                                MatchRowView(match: match) {
                                    selectedMatch = match
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddMatch = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMatch) {
                AddMatchView()
            }
            .sheet(item: $selectedMatch) { match in
                MatchDetailView(match: match)
            }
        }
    }
}

struct MatchRowView: View {
    let match: Match
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Match Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(match.homeTeam)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("vs")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(match.awayTeam)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        if match.status == .completed,
                           let homeScore = match.homeScore,
                           let awayScore = match.awayScore {
                            HStack {
                                Text("\(homeScore) - \(awayScore)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Result indicator
                                let isWin = (match.venue == .home && homeScore > awayScore) ||
                                           (match.venue == .away && awayScore > homeScore)
                                let isDraw = homeScore == awayScore
                                
                                Text(isWin ? "W" : isDraw ? "D" : "L")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(isWin ? .green : isDraw ? .orange : .red)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
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
                        }
                    }
                }
                
                // Match Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
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
                        
                        HStack {
                            Image(systemName: "trophy")
                                .foregroundColor(.secondary)
                            Text(match.competition)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let attendance = match.attendance {
                        VStack(alignment: .trailing) {
                            Text("Attendance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(attendance.formatted())")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                // Formation (if available)
                if let formation = match.formation {
                    HStack {
                        Image(systemName: "person.3")
                            .foregroundColor(.secondary)
                        Text("Formation: \(formation.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
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
//
//#Preview {
//    MatchesView()
//        .environmentObject(ClubManager())
//}
