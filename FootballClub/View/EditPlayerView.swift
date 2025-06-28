import SwiftUI
import PhotosUI

struct EditPlayerView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    @State private var player: Player
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    
    init(player: Player) {
        self._player = State(initialValue: player)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Player Name", text: $player.name)
                    
                    Picker("Position", selection: $player.position) {
                        ForEach(PlayerPosition.allCases, id: \.self) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        Stepper("\(player.age)", value: $player.age, in: 16...45)
                    }
                    
                    HStack {
                        Text("Jersey Number")
                        Spacer()
                        Stepper("\(player.jerseyNumber)", value: $player.jerseyNumber, in: 1...99)
                    }
                    
                    TextField("Nationality", text: $player.nationality)
                }
                
                Section("Physical Attributes") {
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        Stepper("\(player.height)", value: $player.height, in: 150...220)
                    }
                    
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        Stepper("\(player.weight)", value: $player.weight, in: 50...120)
                    }
                    
                    Picker("Preferred Foot", selection: $player.preferredFoot) {
                        ForEach(PreferredFoot.allCases, id: \.self) { foot in
                            Text(foot.rawValue).tag(foot)
                        }
                    }
                }
                
                Section("Statistics") {
                    HStack {
                        Text("Goals")
                        Spacer()
                        Stepper("\(player.goals)", value: $player.goals, in: 0...100)
                    }
                    
                    HStack {
                        Text("Assists")
                        Spacer()
                        Stepper("\(player.assists)", value: $player.assists, in: 0...100)
                    }
                    
                    HStack {
                        Text("Appearances")
                        Spacer()
                        Stepper("\(player.appearances)", value: $player.appearances, in: 0...100)
                    }
                }
                
                Section("Contract & Status") {
                    DatePicker("Join Date", selection: $player.joinDate, displayedComponents: .date)
                    
                    DatePicker("Contract Expires", selection: $player.contractExpiry, displayedComponents: .date)
                    
                    HStack {
                        Text("Market Value (€)")
                        Spacer()
                        TextField("Market Value", value: $player.marketValue, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Injury Status", selection: $player.injuryStatus) {
                        ForEach(InjuryStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Fitness Level: \(Int(player.fitnessLevel * 100))%")
                        Slider(value: $player.fitnessLevel, in: 0...1)
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
                                Text("Tap to change photo")
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
            .navigationTitle("Edit Player")
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
                    .disabled(player.name.isEmpty)
                }
            }
        }
    }
    
    private func savePlayer() {
        clubManager.updatePlayer(player)
        dismiss()
    }
}

//#Preview {
//    EditPlayerView(player: Player(
//        name: "Marco Silva",
//        position: .forward,
//        age: 25,
//        jerseyNumber: 10,
//        goals: 18,
//        assists: 12,
//        appearances: 28,
//        joinDate: Date(),
//        height: 180,
//        weight: 75,
//        nationality: "Brazil",
//        marketValue: 2500000,
//        fitnessLevel: 0.92,
//        injuryStatus: .fit,
//        preferredFoot: .right,
//        contractExpiry: Date()
//    ))
//    .environmentObject(ClubManager())
//}
