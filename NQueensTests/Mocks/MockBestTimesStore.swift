//
//  Mocks.swift
//  NQueensTests
//

@testable import NQueens
import Foundation

// MARK: - MockBestTimesStore

final class MockBestTimesStoreState: @unchecked Sendable {
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
        state.saveRecord((size, time))
    }

    func fetchRecords(for size: Int, limit: Int) async -> [RecordDTO] {
        state.recordsToReturn
    }

    func deleteOldRecords(for size: Int, keepingTop limit: Int) async {
        state.deleteOldRecords((size, limit))
    }
}
