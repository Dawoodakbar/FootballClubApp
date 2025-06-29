//
//  CalendarView.swift
//  FootballClub
//
//  Created by Dawood Akbar on 29/06/2025.
//

import SwiftUI

struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let type: EventType
    let time: String?
    let location: String?
    
    enum EventType {
        case match, training
        
        var color: Color {
            switch self {
            case .match: return .blue
            case .training: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .match: return "trophy.fill"
            case .training: return "figure.run"
            }
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var clubManager: ClubManager
    @State private var currentDate = Date()
    @State private var selectedDate: Date? = nil
    
    private var events: [CalendarEvent] {
        var allEvents: [CalendarEvent] = []
        
        // Add matches
        allEvents.append(contentsOf: clubManager.matches.map { match in
            CalendarEvent(
                title: "vs \(match.opponent)",
                date: match.date,
                type: .match,
                time: match.date.formatted(date: .omitted, time: .shortened),
                location: match.venue.rawValue
            )
        })
        
        // Add trainings
        allEvents.append(contentsOf: clubManager.trainings.map { training in
            CalendarEvent(
                title: training.type.rawValue,
                date: training.date,
                type: .training,
                time: training.date.formatted(date: .omitted, time: .shortened),
                location: training.location
            )
        })
        
        return allEvents
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Calendar Header
            calendarHeader
            
            // Calendar Grid
            calendarGrid
            
            // Selected Date Events
            if let selectedDate = selectedDate {
                selectedDateEvents(for: selectedDate)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var calendarHeader: some View {
        HStack {
            Button(action: { navigateMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(currentDate.formatted(.dateTime.month(.wide).year()))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: { navigateMonth(1) }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Day names
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            let days = getDaysInMonth()
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    private func dayCell(for date: Date) -> some View {
        let dayEvents = getEventsForDate(date)
        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
        let isSelected = selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!)
        
        return Button(action: { selectedDate = date }) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                
                if !dayEvents.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(dayEvents.prefix(3)) { event in
                            Circle()
                                .fill(event.type.color)
                                .frame(width: 4, height: 4)
                        }
                        if dayEvents.count > 3 {
                            Text("+")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func selectedDateEvents(for date: Date) -> some View {
        let dayEvents = getEventsForDate(date)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Events for \(date.formatted(date: .abbreviated, time: .omitted))")
                .font(.headline)
                .fontWeight(.semibold)
            
            if dayEvents.isEmpty {
                Text("No events scheduled")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(dayEvents) { event in
                    eventCard(for: event)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func eventCard(for event: CalendarEvent) -> some View {
        HStack {
            Rectangle()
                .fill(event.type.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let time = event.time, let location = event.location {
                    HStack {
                        Label(time, systemImage: "clock")
                        Label(location, systemImage: "location")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: event.type.icon)
                .foregroundColor(event.type.color)
        }
        .padding(.vertical, 8)
    }
    
    private func getDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let range = calendar.range(of: .day, in: .month, for: currentDate) ?? 1..<32
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days of the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            Calendar.current.isDate(event.date, inSameDayAs: date)
        }
    }
    
    private func navigateMonth(_ direction: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = Calendar.current.date(byAdding: .month, value: direction, to: currentDate) ?? currentDate
        }
    }
}
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(ClubManager())
                    .padding()
    }
}
