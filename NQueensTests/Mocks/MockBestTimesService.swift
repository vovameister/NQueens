//
//  MockBestTimesService.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 21. 2. 2026..
//
@testable import NQueens
import Foundation

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
