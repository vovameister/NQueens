//
//  BestTimesService.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import Foundation

protocol BestTimesServiceProtocol: Sendable {
    func addResult(boardSize: Int, time: TimeInterval) async
    func getResults(for size: Int) async -> [GameRecord]
    func getBestTime(for size: Int) async -> TimeInterval?
    func isNewRecord(_ time: TimeInterval, for size: Int) async -> Bool
}

final class BestTimesService: BestTimesServiceProtocol, Sendable {
    private let store: BestTimesStoreProtocol
    private let maxResults = 10

    init(store: BestTimesStoreProtocol = BestTimesStore()) {
        self.store = store
    }

    func addResult(boardSize: Int, time: TimeInterval) async {
        await store.saveRecord(size: boardSize, time: time)
        await store.deleteOldRecords(for: boardSize, keepingTop: maxResults)
    }

    func getResults(for size: Int) async -> [GameRecord] {
        let records = await store.fetchRecords(for: size, limit: maxResults)
        return records.map { record in
            GameRecord(
                id: record.id ?? UUID(),
                size: Int(record.boardSize),
                time: record.time,
                date: record.date ?? Date()
            )
        }
    }

    func getBestTime(for size: Int) async -> TimeInterval? {
        let records = await store.fetchRecords(for: size, limit: 1)
        return records.first?.time
    }

    func isNewRecord(_ time: TimeInterval, for size: Int) async -> Bool {
        guard let bestTime = await getBestTime(for: size) else { return true }
        return time < bestTime
    }
}
