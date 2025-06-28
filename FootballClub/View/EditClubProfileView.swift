import SwiftUI
import PhotosUI

struct EditClubProfileView: View {
    @EnvironmentObject var clubManager: ClubManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var clubProfile: ClubProfile
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var newAchievement = ""
    @State private var showingAddAchievement = false
    
    init() {
        // Initialize with current club profile
        let manager = ClubManager()
        self._clubProfile = State(initialValue: manager.clubProfile)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Club Name", text: $clubProfile.name)
                    
                    HStack {
                        Text("Founded")
                        Spacer()
                        Stepper("\(clubProfile.founded)", value: $clubProfile.founded, in: 1800...2024)
                    }
                    
                    TextField("Stadium Name", text: $clubProfile.stadium)
                    
                    HStack {
                        Text("Stadium Capacity")
                        Spacer()
                        Stepper("\(clubProfile.capacity)", value: $clubProfile.capacity, in: 1000...200000, step: 1000)
                    }
                    
                    TextField("Manager", text: $clubProfile.manager)
                    TextField("Club Motto", text: $clubProfile.motto)
                    TextField("Nickname", text: $clubProfile.nickname)
                }
                
                Section("Description") {
                    TextField("Club description...", text: $clubProfile.description, axis: .vertical)
                        .lineLimit(4...8)
                }
                
                Section("Club Logo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            AsyncImage(url: URL(string: "https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "camera")
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text("Club Logo")
                                    .font(.headline)
                                Text("Tap to change logo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Section("Club Colors") {
                    ColorPicker("Primary Color", selection: Binding(
                        get: { Color(clubProfile.primaryColor) },
                        set: { clubProfile.primaryColor = $0.toHex() }
                    ))
                    
                    ColorPicker("Secondary Color", selection: Binding(
                        get: { Color(clubProfile.secondaryColor) },
                        set: { clubProfile.secondaryColor = $0.toHex() }
                    ))
                }
                
                Section("Achievements") {
                    ForEach(Array(clubProfile.achievements.enumerated()), id: \.offset) { index, achievement in
                        HStack {
                            Text(achievement)
                            Spacer()
                            Button {
                                clubProfile.achievements.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button {
                        showingAddAchievement = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add Achievement")
                        }
                    }
                }
                
                Section("Social Media") {
                    TextField("Website", text: Binding(
                        get: { clubProfile.socialMedia.website ?? "" },
                        set: { clubProfile.socialMedia.website = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    
                    TextField("Instagram", text: Binding(
                        get: { clubProfile.socialMedia.instagram ?? "" },
                        set: { clubProfile.socialMedia.instagram = $0.isEmpty ? nil : $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    
                    TextField("Twitter", text: Binding(
                        get: { clubProfile.socialMedia.twitter ?? "" },
                        set: { clubProfile.socialMedia.twitter = $0.isEmpty ? nil : $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    
                    TextField("Facebook", text: Binding(
                        get: { clubProfile.socialMedia.facebook ?? "" },
                        set: { clubProfile.socialMedia.facebook = $0.isEmpty ? nil : $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    
                    TextField("YouTube", text: Binding(
                        get: { clubProfile.socialMedia.youtube ?? "" },
                        set: { clubProfile.socialMedia.youtube = $0.isEmpty ? nil : $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    
                    TextField("TikTok", text: Binding(
                        get: { clubProfile.socialMedia.tiktok ?? "" },
                        set: { clubProfile.socialMedia.tiktok = $0.isEmpty ? nil : $0 }
                    ))
                    .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Edit Club Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(clubProfile.name.isEmpty)
                }
            }
            .alert("Add Achievement", isPresented: $showingAddAchievement) {
                TextField("Achievement", text: $newAchievement)
                Button("Add") {
                    if !newAchievement.isEmpty {
                        clubProfile.achievements.append(newAchievement)
                        newAchievement = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newAchievement = ""
                }
            } message: {
                Text("Enter a new achievement for your club")
            }
        }
    }
    
    private func saveProfile() {
        clubManager.clubProfile = clubProfile
        dismiss()
    }
}

// Color extension for hex conversion (Xcode 14 compatible)
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
        return String(format: "#%06x", rgb)
    }
    
    init(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//#Preview {
//    EditClubProfileView()
//        .environmentObject(ClubManager())
//}
