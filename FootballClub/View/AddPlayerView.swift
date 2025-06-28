import SwiftUI
import PhotosUI

struct AddPlayerView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedPosition = PlayerPosition.forward
    @State private var age = 25
    @State private var jerseyNumber = 1
    @State private var height = 180
    @State private var weight = 75
    @State private var nationality = ""
    @State private var marketValue = 1000000
    @State private var goals = 0
    @State private var assists = 0
    @State private var appearances = 0
    @State private var joinDate = Date()
    @State private var contractExpiry = Date()
    @State private var fitnessLevel = 0.85
    @State private var selectedInjuryStatus = InjuryStatus.fit
    @State private var selectedPreferredFoot = PreferredFoot.right
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Player Name", text: $name)
                    
                    Picker("Position", selection: $selectedPosition) {
                        ForEach(PlayerPosition.allCases, id: \.self) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        Stepper("\(age)", value: $age, in: 16...45)
                    }
                    
                    HStack {
                        Text("Jersey Number")
                        Spacer()
                        Stepper("\(jerseyNumber)", value: $jerseyNumber, in: 1...99)
                    }
                    
                    TextField("Nationality", text: $nationality)
                }
                
                Section("Physical Attributes") {
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        Stepper("\(height)", value: $height, in: 150...220)
                    }
                    
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        Stepper("\(weight)", value: $weight, in: 50...120)
                    }
                    
                    Picker("Preferred Foot", selection: $selectedPreferredFoot) {
                        ForEach(PreferredFoot.allCases, id: \.self) { foot in
                            Text(foot.rawValue).tag(foot)
                        }
                    }
                }
                
                Section("Statistics") {
                    HStack {
                        Text("Goals")
                        Spacer()
                        Stepper("\(goals)", value: $goals, in: 0...100)
                    }
                    
                    HStack {
                        Text("Assists")
                        Spacer()
                        Stepper("\(assists)", value: $assists, in: 0...100)
                    }
                    
                    HStack {
                        Text("Appearances")
                        Spacer()
                        Stepper("\(appearances)", value: $appearances, in: 0...100)
                    }
                }
                
                Section("Contract & Status") {
                    DatePicker("Join Date", selection: $joinDate, displayedComponents: .date)
                    
                    DatePicker("Contract Expires", selection: $contractExpiry, displayedComponents: .date)
                    
                    HStack {
                        Text("Market Value (€)")
                        Spacer()
                        TextField("Market Value", value: $marketValue, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Injury Status", selection: $selectedInjuryStatus) {
                        ForEach(InjuryStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Fitness Level: \(Int(fitnessLevel * 100))%")
                        Slider(value: $fitnessLevel, in: 0...1)
                    }
                }
                
                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            if let photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "camera")
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Player Photo")
                                    .font(.headline)
                                Text("Tap to select photo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .onChange(of: selectedPhoto) { newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePlayer()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func savePlayer() {
        let newPlayer = Player(
            name: name,
            position: selectedPosition,
            age: age,
            jerseyNumber: jerseyNumber,
            goals: goals,
            assists: assists,
            appearances: appearances,
            joinDate: joinDate,
            height: height,
            weight: weight,
            nationality: nationality,
            marketValue: marketValue,
            fitnessLevel: fitnessLevel,
            injuryStatus: selectedInjuryStatus,
            preferredFoot: selectedPreferredFoot,
            contractExpiry: contractExpiry
        )
        
        clubManager.addPlayer(newPlayer)
        dismiss()
    }
}

//#Preview {
//    AddPlayerView()
//        .environmentObject(ClubManager())
//}
