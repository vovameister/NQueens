//
//  BestTimesServiceTests.swift
//  NQueensTests
//

import XCTest
@testable import NQueens

@MainActor
final class BestTimesServiceTests: XCTestCase {

    private var mockStore: MockBestTimesStore!
    private var sut: BestTimesService!

    override func setUp() {
        mockStore = MockBestTimesStore()
        sut = BestTimesService(store: mockStore)
    }

    func testAddResultSavesAndCleansUp() async {
        await sut.addResult(boardSize: 8, time: 15.5)

        let savedRecords = await mockStore.state.savedRecords
        let deletedForSizes = await mockStore.state.deletedForSizes

        XCTAssertEqual(savedRecords.count, 1)
        XCTAssertEqual(savedRecords.first?.size, 8)
        XCTAssertEqual(savedRecords.first?.time, 15.5)
        XCTAssertEqual(deletedForSizes.count, 1)
        XCTAssertEqual(deletedForSizes.first?.size, 8)
        XCTAssertEqual(deletedForSizes.first?.keepingTop, 10)
    }

    func testGetBestTimeReturnsFirstRecord() async {
        await mockStore.state.setRecords([RecordDTO(id: UUID(), boardSize: 8, time: 12.3, date: Date())])

        let result = await sut.getBestTime(for: 8)

        XCTAssertEqual(result, 12.3)
    }

    func testGetBestTimeReturnsNilWhenEmpty() async {
        await mockStore.state.setRecords([])

        let result = await sut.getBestTime(for: 8)

        XCTAssertNil(result)
    }

    func testIsNewRecordReturnsTrueWhenNoRecords() async {
        await mockStore.state.setRecords([])

        let result = await sut.isNewRecord(100.0, for: 8)
        XCTAssertTrue(result)
    }

    func testIsNewRecordReturnsTrueWhenBetter() async {
        await mockStore.state.setRecords([RecordDTO(id: UUID(), boardSize: 8, time: 20.0, date: Date())])

        let result = await sut.isNewRecord(15.0, for: 8)
        XCTAssertTrue(result)
    }

    func testIsNewRecordReturnsFalseWhenWorse() async {
        await mockStore.state.setRecords([RecordDTO(id: UUID(), boardSize: 8, time: 10.0, date: Date())])

        let result = await sut.isNewRecord(15.0, for: 8)
        XCTAssertFalse(result)
    }

    func testIsNewRecordReturnsFalseWhenEqual() async {
        await mockStore.state.setRecords([RecordDTO(id: UUID(), boardSize: 8, time: 10.0, date: Date())])

        let result = await sut.isNewRecord(10.0, for: 8)
        XCTAssertFalse(result)
    }

    func testGetResultsMapsRecordsToGameRecords() async {
        let id = UUID()
        let date = Date()
        await mockStore.state.setRecords([RecordDTO(id: id, boardSize: 6, time: 25.5, date: date)])

        let results = await sut.getResults(for: 6)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, id)
        XCTAssertEqual(results.first?.size, 6)
        XCTAssertEqual(results.first?.time, 25.5)
        XCTAssertEqual(results.first?.date, date)
    }

    func testGetResultsHandlesNilIdAndDate() async {
        await mockStore.state.setRecords([RecordDTO(id: nil, boardSize: 10, time: 5.0, date: nil)])

        let results = await sut.getResults(for: 10)

        XCTAssertEqual(results.count, 1)
        XCTAssertNotNil(results.first?.id)
        XCTAssertNotNil(results.first?.date)
    }
}
