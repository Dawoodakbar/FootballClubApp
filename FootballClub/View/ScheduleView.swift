import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var clubManager: ClubManager
    @State private var searchText = ""
    @State private var selectedType: TrainingType?
    @State private var showingAddTraining = false
    @State private var selectedTraining: Training?
    
    var filteredTrainings: [Training] {
        var trainings = clubManager.trainings
        
        if !searchText.isEmpty {
            trainings = trainings.filter { training in
                training.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
                training.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let type = selectedType {
            trainings = trainings.filter { $0.type == type }
        }
        
        return trainings.sorted { $0.date < $1.date }
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
                                isSelected: selectedType == nil
                            ) {
                                selectedType = nil
                            }
                            
                            ForEach(TrainingType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = selectedType == type ? nil : type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                // Training List
                if filteredTrainings.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No training sessions found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Schedule your first training session")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTrainings) { training in
                                TrainingRowView(training: training) {
                                    selectedTraining = training
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Training Schedule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTraining = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTraining) {
                AddTrainingView()
            }
            .sheet(item: $selectedTraining) { training in
                TrainingDetailView(training: training)
            }
        }
    }
}

struct TrainingRowView: View {
    @EnvironmentObject var clubManager: ClubManager
    let training: Training
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(training.type.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(training.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.secondary)
                            Text(training.location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let weather = training.weatherConditions {
                            HStack {
                                Image(systemName: weather.icon)
                                    .foregroundColor(.secondary)
                                Text(weather.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("\(training.duration)min")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(training.intensity.color)
                            .clipShape(Capsule())
                        
                        Text("\(training.attendees.count) players")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(training.status.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(training.status == .upcoming ? .blue : .green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((training.status == .upcoming ? Color.blue : Color.green).opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                if !training.description.isEmpty {
                    HStack {
                        Text(training.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        Spacer()
                    }
                }
                
                // Training Focus Tags
                if !training.focus.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(training.focus, id: \.self) { focus in
                                Text(focus.rawValue)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
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

//#Preview {
//    ScheduleView()
//        .environmentObject(ClubManager())
//}
