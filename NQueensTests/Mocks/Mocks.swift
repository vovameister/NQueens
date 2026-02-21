//
//  Mocks.swift
//  NQueensTests
//

@testable import NQueens
import Foundation

// MARK: - MockBestTimesService

actor MockBestTimesServiceState {
    var addedResults: [(boardSize: Int, time: TimeInterval)] = []
    var resultsToReturn: [GameRecord] = []
    var bestTimeToReturn: TimeInterval?
    var isNewRecordToReturn: Bool = false

    func addResult(_ result: (boardSize: Int, time: TimeInterval)) {
        addedResults.append(result)
    }

    func setResults(_ results: [GameRecord]) { resultsToReturn = results }
    func setBestTime(_ time: TimeInterval?) { bestTimeToReturn = time }
    func setIsNewRecord(_ value: Bool) { isNewRecordToReturn = value }
}

final class MockBestTimesService: BestTimesServiceProtocol, Sendable {
    let state = MockBestTimesServiceState()

    func addResult(boardSize: Int, time: TimeInterval) async {
        await state.addResult((boardSize, time))
    }

    func getResults(for size: Int) async -> [GameRecord] {
        await state.resultsToReturn.filter { $0.size == size }
    }

    func getBestTime(for size: Int) async -> TimeInterval? {
        await state.bestTimeToReturn
    }

    func isNewRecord(_ time: TimeInterval, for size: Int) async -> Bool {
        await state.isNewRecordToReturn
    }
}

// MARK: - MockBestTimesStore

actor MockBestTimesStoreState {
    var savedRecords: [(size: Int, time: Double)] = []
    var deletedForSizes: [(size: Int, keepingTop: Int)] = []
    var recordsToReturn: [RecordDTO] = []

    func saveRecord(_ record: (size: Int, time: Double)) {
        savedRecords.append(record)
    }

    func deleteOldRecords(_ info: (size: Int, keepingTop: Int)) {
        deletedForSizes.append(info)
    }

    func setRecords(_ records: [RecordDTO]) {
        recordsToReturn = records
    }
}

final class MockBestTimesStore: BestTimesStoreProtocol, Sendable {
    let state = MockBestTimesStoreState()

    func saveRecord(size: Int, time: Double) async {
        await state.saveRecord((size, time))
    }

    func fetchRecords(for size: Int, limit: Int) async -> [RecordDTO] {
        await state.recordsToReturn
    }

    func deleteOldRecords(for size: Int, keepingTop limit: Int) async {
        await state.deleteOldRecords((size, limit))
    }
}

// MARK: - MockSoundPlayer

actor MockSoundPlayer: SoundPlaying {
    func playMove() {}
    func playVictory() {}
}
