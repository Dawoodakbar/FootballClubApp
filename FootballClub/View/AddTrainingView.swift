import SwiftUI

struct AddTrainingView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var type = TrainingType.tactical
    @State private var duration = 90
    @State private var location = ""
    @State private var description = ""
    @State private var intensity = TrainingIntensity.medium
    @State private var selectedFocus: Set<TrainingFocus> = []
    @State private var selectedAttendees: Set<UUID> = []
    @State private var weatherConditions = WeatherCondition.sunny
    
    var body: some View {
        NavigationView {
            Form {
                Section("Training Details") {
                    DatePicker("Date & Time", selection: $date)
                    
                    Picker("Training Type", selection: $type) {
                        ForEach(TrainingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        Stepper("\(duration)", value: $duration, in: 30...180, step: 15)
                    }
                    
                    TextField("Location", text: $location)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Training Configuration") {
                    Picker("Intensity", selection: $intensity) {
                        ForEach(TrainingIntensity.allCases, id: \.self) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Weather", selection: $weatherConditions) {
                        ForEach(WeatherCondition.allCases, id: \.self) { weather in
                            HStack {
                                Image(systemName: weather.icon)
                                Text(weather.rawValue)
                            }.tag(weather)
                        }
                    }
                }
                
                Section("Focus Areas") {
                    ForEach(TrainingFocus.allCases, id: \.self) { focus in
                        HStack {
                            Text(focus.rawValue)
                            Spacer()
                            if selectedFocus.contains(focus) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedFocus.contains(focus) {
                                selectedFocus.remove(focus)
                            } else {
                                selectedFocus.insert(focus)
                            }
                        }
                    }
                }
                
                Section("Description") {
                    TextField("Training description...", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Attendees") {
                    ForEach(clubManager.players) { player in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(player.name)
                                    .font(.subheadline)
                                Text(player.position.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedAttendees.contains(player.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedAttendees.contains(player.id) {
                                selectedAttendees.remove(player.id)
                            } else {
                                selectedAttendees.insert(player.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Training")
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
                    .disabled(location.isEmpty)
                }
            }
        }
    }
    
    private func saveTraining() {
        let newTraining = Training(
            date: date,
            type: type,
            duration: duration,
            location: location,
            description: description,
            attendees: Array(selectedAttendees),
            status: .upcoming,
            intensity: intensity,
            focus: Array(selectedFocus),
            weatherConditions: weatherConditions
        )
        
        clubManager.addTraining(newTraining)
        dismiss()
    }
}
//
//#Preview {
//    AddTrainingView()
//        .environmentObject(ClubManager())
//}
