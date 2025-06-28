import SwiftUI

struct TrainingDetailView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    let training: Training
    @State private var showingEditTraining = false
    
    var attendingPlayers: [Player] {
        clubManager.players.filter { player in
            training.attendees.contains(player.id)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Training Header
                    trainingHeaderSection
                    
                    // Training Details
                    trainingDetailsSection
                    
                    // Focus Areas
                    if !training.focus.isEmpty {
                        focusAreasSection
                    }
                    
                    // Description
                    if !training.description.isEmpty {
                        descriptionSection
                    }
                    
                    // Attendees
                    attendeesSection
                    
                    // Weather Info
                    if let weather = training.weatherConditions {
                        weatherSection(weather: weather)
                    }
                }
                .padding()
            }
            .navigationTitle("Training Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditTraining = true
                    }
                }
            }
            .sheet(isPresented: $showingEditTraining) {
                EditTrainingView(training: training)
            }
        }
    }
    
    private var trainingHeaderSection: some View {
        VStack(spacing: 16) {
            Text(training.type.rawValue)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(training.duration)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack {
                    Text(training.intensity.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(training.intensity.color)
                    Text("Intensity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(training.intensity.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack {
                    Text("\(training.attendees.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Players")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var trainingDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Information")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailRow(icon: "calendar", title: "Date", value: training.date.formatted(date: .complete, time: .shortened))
                DetailRow(icon: "location", title: "Location", value: training.location)
                DetailRow(icon: "info.circle", title: "Status", value: training.status.rawValue)
            }
        }
    }
    
    private var focusAreasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus Areas")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(training.focus, id: \.self) { focus in
                    Text(focus.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Description")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(training.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Attendees (\(attendingPlayers.count))")
                .font(.title2)
                .fontWeight(.semibold)
            
            if attendingPlayers.isEmpty {
                Text("No players selected for this training session")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(attendingPlayers) { player in
                        PlayerAttendeeRow(player: player)
                    }
                }
            }
        }
    }
    
    private func weatherSection(weather: WeatherCondition) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weather Conditions")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: weather.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(weather.rawValue)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PlayerAttendeeRow: View {
    let player: Player
    
    var body: some View {
        HStack {
            Circle()
                .fill(player.position.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(player.position.color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(player.position.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("#\(player.jerseyNumber)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct EditTrainingView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    @State private var training: Training
    @State private var selectedFocus: Set<TrainingFocus>
    @State private var selectedAttendees: Set<UUID>
    
    init(training: Training) {
        self._training = State(initialValue: training)
        self._selectedFocus = State(initialValue: Set(training.focus))
        self._selectedAttendees = State(initialValue: Set(training.attendees))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Training Details") {
                    DatePicker("Date & Time", selection: $training.date)
                    
                    Picker("Training Type", selection: $training.type) {
                        ForEach(TrainingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        Stepper("\(training.duration)", value: $training.duration, in: 30...180, step: 15)
                    }
                    
                    TextField("Location", text: $training.location)
                }
                
                Section("Configuration") {
                    Picker("Intensity", selection: $training.intensity) {
                        ForEach(TrainingIntensity.allCases, id: \.self) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    
                    Picker("Status", selection: $training.status) {
                        ForEach(TrainingStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section("Description") {
                    TextField("Training description...", text: $training.description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Training")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTraining()
                    }
                }
            }
        }
    }
    
    private func saveTraining() {
        training.focus = Array(selectedFocus)
        training.attendees = Array(selectedAttendees)
        clubManager.updateTraining(training)
        dismiss()
    }
}

struct TrainingDetailView_Preview: PreviewProvider {
static var previews: some View   {
        TrainingDetailView(training: Training(
            date: Date(),
            type: .tactical,
            duration: 90,
            location: "Training Ground A",
            description: "Focus on defensive formations and set pieces preparation for upcoming match.",
            attendees: [],
            status: .upcoming,
            intensity: .medium,
            focus: [.tactics, .setpieces],
            weatherConditions: .sunny
        ))
        .environmentObject(ClubManager())
    }
}
