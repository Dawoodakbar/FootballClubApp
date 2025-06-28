//
//  Persistence.swift
//  FootballClub
//
//  Created by Dawood Akbar on 28/06/2025.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        let sampleClub = ClubEntity(context: viewContext)
        sampleClub.name = "FC Champions"
        sampleClub.founded = 1965
        sampleClub.stadium = "Champions Arena"
        sampleClub.capacity = 45000
        sampleClub.manager = "Alex Rodriguez"
        sampleClub.clubDescription = "A legendary football club with a rich history of success."
        sampleClub.primaryColor = "#22C55E"
        sampleClub.secondaryColor = "#3B82F6"
        sampleClub.motto = "Excellence Through Unity"
        sampleClub.nickname = "The Champions"
        sampleClub.achievements = ["League Champions (5x)", "Cup Winners (3x)", "International Trophy (2x)"]
        
        // Add sample player
        let samplePlayer = PlayerEntity(context: viewContext)
        samplePlayer.id = UUID()
        samplePlayer.name = "Marco Silva"
        samplePlayer.position = "Forward"
        samplePlayer.age = 25
        samplePlayer.jerseyNumber = 10
        samplePlayer.goals = 18
        samplePlayer.assists = 12
        samplePlayer.appearances = 28
        samplePlayer.height = 180
        samplePlayer.weight = 75
        samplePlayer.nationality = "Brazil"
        samplePlayer.marketValue = 2500000
        samplePlayer.fitnessLevel = 0.92
        samplePlayer.injuryStatus = "Fit"
        samplePlayer.preferredFoot = "Right"
        samplePlayer.joinDate = Date()
        samplePlayer.contractExpiry = Calendar.current.date(byAdding: .year, value: 2, to: Date())
        samplePlayer.club = sampleClub
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FootballClub")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// MARK: - Core Data Operations
extension PersistenceController {
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
        save()
    }
    
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }
}

// MARK: - Entity Creation Helpers
extension PersistenceController {
    
    func createPlayer(from player: Player, for club: ClubEntity) -> PlayerEntity {
        let playerEntity = PlayerEntity(context: container.viewContext)
        playerEntity.id = player.id
        playerEntity.name = player.name
        playerEntity.position = player.position.rawValue
        playerEntity.age = Int32(player.age)
        playerEntity.jerseyNumber = Int32(player.jerseyNumber)
        playerEntity.goals = Int32(player.goals)
        playerEntity.assists = Int32(player.assists)
        playerEntity.appearances = Int32(player.appearances)
        playerEntity.height = Int32(player.height)
        playerEntity.weight = Int32(player.weight)
        playerEntity.nationality = player.nationality
        playerEntity.marketValue = Int32(player.marketValue)
        playerEntity.fitnessLevel = player.fitnessLevel
        playerEntity.injuryStatus = player.injuryStatus.rawValue
        playerEntity.preferredFoot = player.preferredFoot.rawValue
        playerEntity.joinDate = player.joinDate
        playerEntity.contractExpiry = player.contractExpiry
        playerEntity.photo = player.photo
        playerEntity.club = club
        
        return playerEntity
    }
    
    func createMatch(from match: Match, for club: ClubEntity) -> MatchEntity {
        let matchEntity = MatchEntity(context: container.viewContext)
        matchEntity.id = match.id
        matchEntity.opponent = match.opponent
        matchEntity.date = match.date
        matchEntity.venue = match.venue.rawValue
        matchEntity.competition = match.competition
        matchEntity.status = match.status.rawValue
        matchEntity.homeScore = match.homeScore != nil ? Int32(match.homeScore!) : 0
        matchEntity.awayScore = match.awayScore != nil ? Int32(match.awayScore!) : 0
        matchEntity.homeTeam = match.homeTeam
        matchEntity.awayTeam = match.awayTeam
        matchEntity.weather = match.weather?.rawValue
        matchEntity.attendance = match.attendance != nil ? Int32(match.attendance!) : 0
        matchEntity.formation = match.formation?.rawValue
        matchEntity.club = club
        
        return matchEntity
    }
    
    func createTraining(from training: Training, for club: ClubEntity) -> TrainingEntity {
        let trainingEntity = TrainingEntity(context: container.viewContext)
        trainingEntity.id = training.id
        trainingEntity.date = training.date
        trainingEntity.type = training.type.rawValue
        trainingEntity.duration = Int32(training.duration)
        trainingEntity.location = training.location
        trainingEntity.trainingDescription = training.description
        trainingEntity.status = training.status.rawValue
        trainingEntity.intensity = training.intensity.rawValue
        trainingEntity.focus = training.focus.map { $0.rawValue }
        trainingEntity.weatherConditions = training.weatherConditions?.rawValue
        trainingEntity.club = club
        
        return trainingEntity
    }
}
