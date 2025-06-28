import UserNotifications
import Foundation
import SwiftUI
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Match Notifications
    func scheduleMatchReminder(for match: Match) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Match"
        content.body = "Match against \(match.opponent) starts in 1 hour!"
        content.sound = .default
        content.badge = 1
        
        // Schedule notification 1 hour before match
        let matchDate = match.date
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: matchDate) ?? matchDate
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "match-\(match.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling match notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelMatchReminder(for matchId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["match-\(matchId.uuidString)"])
    }
    
    // MARK: - Training Notifications
    func scheduleTrainingReminder(for training: Training) {
        let content = UNMutableNotificationContent()
        content.title = "Training Session"
        content.body = "\(training.type.rawValue) training starts in 30 minutes at \(training.location)"
        content.sound = .default
        content.badge = 1
        
        // Schedule notification 30 minutes before training
        let trainingDate = training.date
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -30, to: trainingDate) ?? trainingDate
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "training-\(training.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling training notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelTrainingReminder(for trainingId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["training-\(trainingId.uuidString)"])
    }
    
    // MARK: - News Notifications
    func scheduleNewsNotification(for news: ClubNews) {
        guard news.isBreaking else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Breaking News"
        content.body = news.title
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "news-\(news.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling news notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Player Notifications
    func schedulePlayerBirthdayReminder(for player: Player) {
        let content = UNMutableNotificationContent()
        content.title = "Player Birthday"
        content.body = "It's \(player.name)'s birthday today! 🎉"
        content.sound = .default
        content.badge = 1
        
        // Calculate next birthday
        let calendar = Calendar.current
        let today = Date()
        let birthDate = calendar.date(byAdding: .year, value: -(player.age), to: today) ?? today
        
        var nextBirthday = calendar.nextDate(after: today, matching: calendar.dateComponents([.month, .day], from: birthDate), matchingPolicy: .nextTime) ?? today
        
        // If birthday is today, schedule for next year
        if calendar.isDate(nextBirthday, inSameDayAs: today) {
            nextBirthday = calendar.date(byAdding: .year, value: 1, to: nextBirthday) ?? today
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: nextBirthday)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "birthday-\(player.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling birthday notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Contract Expiry Notifications
    func scheduleContractExpiryReminder(for player: Player) {
        let content = UNMutableNotificationContent()
        content.title = "Contract Expiring"
        content.body = "\(player.name)'s contract expires in 30 days"
        content.sound = .default
        content.badge = 1
        
        // Schedule notification 30 days before contract expiry
        let reminderDate = Calendar.current.date(byAdding: .day, value: -30, to: player.contractExpiry) ?? player.contractExpiry
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "contract-\(player.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling contract notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Utility Methods
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    func clearBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

// MARK: - Notification Categories and Actions
extension NotificationManager {
    func setupNotificationCategories() {
        // Match notification actions
        let viewMatchAction = UNNotificationAction(
            identifier: "VIEW_MATCH",
            title: "View Match",
            options: [.foreground]
        )
        
        let matchCategory = UNNotificationCategory(
            identifier: "MATCH_REMINDER",
            actions: [viewMatchAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Training notification actions
        let viewTrainingAction = UNNotificationAction(
            identifier: "VIEW_TRAINING",
            title: "View Training",
            options: [.foreground]
        )
        
        let markAttendedAction = UNNotificationAction(
            identifier: "MARK_ATTENDED",
            title: "Mark as Attended",
            options: []
        )
        
        let trainingCategory = UNNotificationCategory(
            identifier: "TRAINING_REMINDER",
            actions: [viewTrainingAction, markAttendedAction],
            intentIdentifiers: [],
            options: []
        )
        
        // News notification actions
        let readNewsAction = UNNotificationAction(
            identifier: "READ_NEWS",
            title: "Read Article",
            options: [.foreground]
        )
        
        let newsCategory = UNNotificationCategory(
            identifier: "BREAKING_NEWS",
            actions: [readNewsAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            matchCategory,
            trainingCategory,
            newsCategory
        ])
    }
}
