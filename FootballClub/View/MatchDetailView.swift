import SwiftUI

struct MatchDetailView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    let match: Match
    @State private var showingEditMatch = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Match Header
                    matchHeaderSection
                    
                    // Score Section (if completed)
                    if match.status == .completed {
                        scoreSection
                    }
                    
                    // Match Details
                    matchDetailsSection
                    
                    // Weather & Stadium Info
                    additionalInfoSection
                    
                    // Match Events (if any)
                    if !match.matchEvents.isEmpty {
                        matchEventsSection
                    }
                    
                    // Formation
                    if let formation = match.formation {
                        formationSection(formation: formation)
                    }
                }
                .padding()
            }
            .navigationTitle("Match Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditMatch = true
                    }
                }
            }
            .sheet(isPresented: $showingEditMatch) {
                EditMatchView(match: match)
            }
        }
    }
    
    private var matchHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack {
                    Text(match.homeTeam)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if match.venue == .home {
                        Text("(Home)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text("VS")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                VStack {
                    Text(match.awayTeam)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if match.venue == .away {
                        Text("(Away)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            Text(match.competition)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
        }
    }
    
    private var scoreSection: some View {
        VStack(spacing: 16) {
            if let homeScore = match.homeScore, let awayScore = match.awayScore {
                HStack {
                    Text("\(homeScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("-")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Text("\(awayScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                // Result indicator
                let isWin = (match.venue == .home && homeScore > awayScore) ||
                           (match.venue == .away && awayScore > homeScore)
                let isDraw = homeScore == awayScore
                
                Text(isWin ? "Victory" : isDraw ? "Draw" : "Defeat")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isWin ? .green : isDraw ? .orange : .red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background((isWin ? Color.green : isDraw ? Color.orange : Color.red).opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var matchDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Match Information")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailRow(icon: "calendar", title: "Date", value: match.date.formatted(date: .complete, time: .shortened))
                DetailRow(icon: "location", title: "Venue", value: match.venue.rawValue)
                DetailRow(icon: "info.circle", title: "Status", value: match.status.rawValue)
                
                if let attendance = match.attendance {
                    DetailRow(icon: "person.3", title: "Attendance", value: "\(attendance.formatted())")
                }
            }
        }
    }
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let weather = match.weather {
                HStack {
                    Image(systemName: weather.icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Weather: \(weather.rawValue)")
                        .font(.subheadline)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var matchEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Match Events")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(match.matchEvents.sorted { $0.minute < $1.minute }) { event in
                    MatchEventRow(event: event)
                }
            }
        }
    }
    
    private func formationSection(formation: Formation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Formation")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: "person.3")
                    .foregroundColor(.blue)
                Text(formation.rawValue)
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct MatchEventRow: View {
    let event: MatchEvent
    
    var body: some View {
        HStack {
            Text("\(event.minute)'")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 20)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(event.player)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EditMatchView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    @State private var match: Match
    
    init(match: Match) {
        self._match = State(initialValue: match)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Match Details") {
                    TextField("Opponent", text: $match.opponent)
                    DatePicker("Date & Time", selection: $match.date)
                    
                    Picker("Venue", selection: $match.venue) {
                        ForEach(Venue.allCases, id: \.self) { venue in
                            Text(venue.rawValue).tag(venue)
                        }
                    }
                    
                    TextField("Competition", text: $match.competition)
                }
                
                Section("Status & Score") {
                    Picker("Status", selection: $match.status) {
                        ForEach(MatchStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    if match.status == .completed {
                        HStack {
                            Text("Home Score")
                            Spacer()
                            TextField("0", value: Binding(
                                get: { match.homeScore ?? 0 },
                                set: { match.homeScore = $0 }
                            ), format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                        }
                        
                        HStack {
                            Text("Away Score")
                            Spacer()
                            TextField("0", value: Binding(
                                get: { match.awayScore ?? 0 },
                                set: { match.awayScore = $0 }
                            ), format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                        }
                    }
                }
            }
            .navigationTitle("Edit Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        clubManager.updateMatch(match)
                        dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    MatchDetailView(match: Match(
//        opponent: "Real Madrid",
//        date: Date(),
//        venue: .home,
//        competition: "La Liga",
//        status: .completed,
//        homeScore: 3,
//        awayScore: 2,
//        homeTeam: "FC Champions",
//        awayTeam: "Real Madrid",
//        weather: .sunny,
//        attendance: 45000,
//        matchEvents: [
//            MatchEvent(minute: 15, type: .goal, player: "Marco Silva", description: "Header from corner"),
//            MatchEvent(minute: 32, type: .goal, player: "David Johnson", description: "Long range shot")
//        ],
//        formation: .f433
//    ))
//    .environmentObject(ClubManager())
//}
