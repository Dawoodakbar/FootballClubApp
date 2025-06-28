import SwiftUI

struct AddMatchView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var opponent = ""
    @State private var date = Date()
    @State private var venue = Venue.home
    @State private var competition = ""
    @State private var status = MatchStatus.upcoming
    @State private var homeScore = ""
    @State private var awayScore = ""
    @State private var weather = WeatherCondition.sunny
    @State private var formation = Formation.f442
    @State private var attendance = ""
    
    let competitions = ["Premier League", "La Liga", "Serie A", "Bundesliga", "Champions League", "Europa League", "FA Cup", "Copa del Rey", "Coppa Italia", "DFB-Pokal", "Friendly"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Match Details") {
                    TextField("Opponent", text: $opponent)
                    
                    DatePicker("Date & Time", selection: $date)
                    
                    Picker("Venue", selection: $venue) {
                        ForEach(Venue.allCases, id: \.self) { venue in
                            Text(venue.rawValue).tag(venue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Competition", selection: $competition) {
                        ForEach(competitions, id: \.self) { comp in
                            Text(comp).tag(comp)
                        }
                    }
                }
                
                Section("Match Status") {
                    Picker("Status", selection: $status) {
                        ForEach(MatchStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if status == .completed {
                        HStack {
                            TextField("Home Score", text: $homeScore)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("-")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            TextField("Away Score", text: $awayScore)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                Section("Additional Information") {
                    Picker("Weather", selection: $weather) {
                        ForEach(WeatherCondition.allCases, id: \.self) { weather in
                            HStack {
                                Image(systemName: weather.icon)
                                Text(weather.rawValue)
                            }.tag(weather)
                        }
                    }
                    
                    Picker("Formation", selection: $formation) {
                        ForEach(Formation.allCases, id: \.self) { formation in
                            Text(formation.rawValue).tag(formation)
                        }
                    }
                    
                    if status == .completed {
                        TextField("Attendance", text: $attendance)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("Add Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMatch()
                    }
                    .disabled(opponent.isEmpty || competition.isEmpty)
                }
            }
        }
    }
    
    private func saveMatch() {
        let newMatch = Match(
            opponent: opponent,
            date: date,
            venue: venue,
            competition: competition,
            status: status,
            homeScore: status == .completed ? Int(homeScore) : nil,
            awayScore: status == .completed ? Int(awayScore) : nil,
            homeTeam: venue == .home ? clubManager.clubProfile.name : opponent,
            awayTeam: venue == .home ? opponent : clubManager.clubProfile.name,
            weather: weather,
            attendance: status == .completed ? Int(attendance) : nil,
            matchEvents: [],
            formation: formation
        )
        
        clubManager.addMatch(newMatch)
        dismiss()
    }
}

//#Preview {
//    AddMatchView()
//        .environmentObject(ClubManager())
//}
