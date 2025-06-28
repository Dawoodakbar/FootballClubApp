import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var clubManager: ClubManager
    @State private var showingEditProfile = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    clubHeaderSection
                    
                    // Quick Stats
                    clubStatsSection
                    
                    // About Section
                    aboutSection
                    
                    // Stadium Info
                    stadiumSection
                    
                    // Achievements
                    achievementsSection
                    
                    // Social Media
                    socialMediaSection
                    
                    // Club Colors
                    clubColorsSection
                }
                .padding()
            }
            .navigationTitle("Club Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditClubProfileView()
            }
        }
    }
    
    private var clubHeaderSection: some View {
        VStack(spacing: 16) {
            // Club Logo
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                AsyncImage(url: URL(string: "https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(clubManager.clubProfile.primaryColor), Color(clubManager.clubProfile.secondaryColor)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .overlay(
                            Image(systemName: "camera")
                                .font(.title)
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(clubManager.clubProfile.primaryColor), lineWidth: 4)
                )
                .overlay(
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                        .offset(x: 40, y: 40)
                )
            }
            
            VStack(spacing: 8) {
                Text(clubManager.clubProfile.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Est. \(clubManager.clubProfile.founded) • \(clubManager.clubProfile.stadium)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Manager: \(clubManager.clubProfile.manager)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !clubManager.clubProfile.motto.isEmpty {
                    Text("\"\(clubManager.clubProfile.motto)\"")
                        .font(.headline)
//                        .fontStyle(.italic)
//                        .foregroundColor(Color(clubManager.clubProfile.primaryColor))
//                        .padding(.top, 4)
                }
            }
        }
    }
    
    private var clubStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            StatCard(title: "Players", value: "\(clubManager.players.count)", icon: "person.3.fill", color: Color(clubManager.clubProfile.primaryColor))
            StatCard(title: "Matches", value: "\(clubManager.matches.count)", icon: "trophy.fill", color: .blue)
            StatCard(title: "News", value: "\(clubManager.news.count)", icon: "newspaper", color: .orange)
            StatCard(title: "Founded", value: "\(clubManager.clubProfile.founded)", icon: "calendar", color: .purple)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About the Club")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(clubManager.clubProfile.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    private var stadiumSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stadium Information")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(Color(clubManager.clubProfile.primaryColor))
                        .frame(width: 24)
                    Text(clubManager.clubProfile.stadium)
                        .font(.headline)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "person.3")
                        .foregroundColor(.secondary)
                        .frame(width: 24)
                    Text("Capacity: \(clubManager.clubProfile.capacity.formatted())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(clubManager.clubProfile.achievements, id: \.self) { achievement in
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.orange)
                        Text(achievement)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
        }
    }
    
    private var socialMediaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Social Media")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if let website = clubManager.clubProfile.socialMedia.website {
                    SocialMediaRow(icon: "globe", title: "Website", value: website, color: .blue)
                }
                
                if let instagram = clubManager.clubProfile.socialMedia.instagram {
                    SocialMediaRow(icon: "camera", title: "Instagram", value: instagram, color: .pink)
                }
                
                if let twitter = clubManager.clubProfile.socialMedia.twitter {
                    SocialMediaRow(icon: "bird", title: "Twitter", value: twitter, color: .blue)
                }
                
                if let facebook = clubManager.clubProfile.socialMedia.facebook {
                    SocialMediaRow(icon: "person.2", title: "Facebook", value: facebook, color: .blue)
                }
            }
        }
    }
    
    private var clubColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Club Colors")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 24) {
                VStack {
                    Circle()
                        .fill(Color(clubManager.clubProfile.primaryColor))
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Text("Primary")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Circle()
                        .fill(Color(clubManager.clubProfile.secondaryColor))
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Text("Secondary")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}

struct SocialMediaRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

//#Preview {
//    ProfileView()
//        .environmentObject(ClubManager())
//}
