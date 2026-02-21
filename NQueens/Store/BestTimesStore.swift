//
//  BestTimesStore.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import CoreData

struct RecordDTO: Sendable {
    let id: UUID?
    let boardSize: Int32
    let time: Double
    let date: Date?
}

protocol BestTimesStoreProtocol: Sendable {
    func saveRecord(size: Int, time: Double) async
    func fetchRecords(for size: Int, limit: Int) async -> [RecordDTO]
    func deleteOldRecords(for size: Int, keepingTop limit: Int) async
}

final class BestTimesStore: BestTimesStoreProtocol, Sendable {
    private let container: NSPersistentContainer

    init(containerName: String = "RecordStore") {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data error: \(error)")
            }
        }
    }

    func saveRecord(size: Int, time: Double) async {
        await container.performBackgroundTask { context in
            let record = Record(context: context)
            record.id = UUID()
            record.boardSize = Int32(size)
            record.time = time
            record.date = Date()

            self.saveContext(context)
        }
    }

    func fetchRecords(for size: Int, limit: Int) async -> [RecordDTO] {
        await container.performBackgroundTask { context in
            let request: NSFetchRequest<Record> = Record.fetchRequest()
            request.predicate = NSPredicate(format: "boardSize == %d", size)
            request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
            request.fetchLimit = limit

            do {
                let records = try context.fetch(request)
                return records.map {
                    RecordDTO(id: $0.id, boardSize: $0.boardSize, time: $0.time, date: $0.date)
                }
            } catch {
                print("Fetch error: \(error)")
                return []
            }
        }
    }

    func deleteOldRecords(for size: Int, keepingTop limit: Int) async {
        await container.performBackgroundTask { context in
            let request: NSFetchRequest<Record> = Record.fetchRequest()
            request.predicate = NSPredicate(format: "boardSize == %d", size)
            request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]

            do {
                let all = try context.fetch(request)
                if all.count > limit {
                    for i in limit..<all.count {
                        context.delete(all[i])
                    }
                    self.saveContext(context)
                }
            } catch {
                print("Delete error: \(error)")
            }
        }
    }

    private func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
}
