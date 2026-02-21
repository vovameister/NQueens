//
//  NQueensViewModelTests.swift
//  NQueensTests
//

import XCTest
@testable import NQueens

@MainActor
final class NQueensViewModelTests: XCTestCase {

    private var mockService: MockBestTimesService!
    private var sut: NQueensViewModel!

    override func setUp() {
        mockService = MockBestTimesService()
        sut = NQueensViewModel(bestTimesService: mockService, soundPlayer: MockSoundPlayer())
    }

    // MARK: - startGame

    func testStartGameSetsBoardSizeAndHidesAlert() {
        sut.startGame(size: "6")

        XCTAssertEqual(sut.boardSize, 6)
        XCTAssertFalse(sut.showingSizeAlert)
    }

    func testStartGameWithInvalidSizeDoesNothing() {
        sut.startGame(size: "abc")

        XCTAssertEqual(sut.boardSize, 0)
    }

    func testStartGameCreatesCells() {
        sut.startGame(size: "8")

        XCTAssertEqual(sut.cellsData.count, 64)
    }

    func testStartGameResetsState() {
        sut.startGame(size: "4")
        sut.toggleQueen(at: 0, col: 0)

        sut.startGame(size: "5")

        XCTAssertEqual(sut.boardSize, 5)
        XCTAssertEqual(sut.queensCount, 0)
        XCTAssertEqual(sut.cellsData.count, 25)
    }

    // MARK: - isInputValid

    func testInputValidForValidSizes() {
        for size in 4...12 {
            sut.inputSize = "\(size)"
            XCTAssertTrue(sut.isInputValid, "Size \(size) should be valid")
        }
    }

    func testInputInvalidForTooSmall() {
        sut.inputSize = "3"
        XCTAssertFalse(sut.isInputValid)
    }

    func testInputInvalidForTooLarge() {
        sut.inputSize = "13"
        XCTAssertFalse(sut.isInputValid)
    }

    func testInputInvalidForNonNumeric() {
        sut.inputSize = "abc"
        XCTAssertFalse(sut.isInputValid)
    }

    func testInputInvalidForEmpty() {
        sut.inputSize = ""
        XCTAssertFalse(sut.isInputValid)
    }

    // MARK: - toggleQueen

    func testToggleQueenPlacesQueen() {
        sut.startGame(size: "6")

        sut.toggleQueen(at: 3, col: 5)

        XCTAssertEqual(sut.queensCount, 1)
        let cell = sut.cellsData.first { $0.row == 3 && $0.col == 5 }
        XCTAssertTrue(cell?.hasQueen == true)
    }

    func testToggleQueenRemovesExistingQueen() {
        sut.startGame(size: "7")
        sut.toggleQueen(at: 4, col: 6)

        sut.toggleQueen(at: 4, col: 6)

        XCTAssertEqual(sut.queensCount, 0)
        let cell = sut.cellsData.first { $0.row == 4 && $0.col == 6 }
        XCTAssertTrue(cell?.hasQueen == false)
    }

    // MARK: - Conflict Detection

    func testRowConflictDetected() {
        sut.startGame(size: "8")
        sut.toggleQueen(at: 3, col: 1)
        sut.toggleQueen(at: 3, col: 7)

        let cell1 = sut.cellsData.first { $0.row == 3 && $0.col == 1 }
        let cell2 = sut.cellsData.first { $0.row == 3 && $0.col == 7 }
        XCTAssertTrue(cell1?.isConflict == true)
        XCTAssertTrue(cell2?.isConflict == true)
    }

    func testColumnConflictDetected() {
        sut.startGame(size: "8")
        sut.toggleQueen(at: 1, col: 5)
        sut.toggleQueen(at: 6, col: 5)

        let cell1 = sut.cellsData.first { $0.row == 1 && $0.col == 5 }
        let cell2 = sut.cellsData.first { $0.row == 6 && $0.col == 5 }
        XCTAssertTrue(cell1?.isConflict == true)
        XCTAssertTrue(cell2?.isConflict == true)
    }

    func testDiagonalConflictDetected() {
        sut.startGame(size: "6")
        sut.toggleQueen(at: 1, col: 2)
        sut.toggleQueen(at: 4, col: 5)

        let cell1 = sut.cellsData.first { $0.row == 1 && $0.col == 2 }
        let cell2 = sut.cellsData.first { $0.row == 4 && $0.col == 5 }
        XCTAssertTrue(cell1?.isConflict == true)
        XCTAssertTrue(cell2?.isConflict == true)
    }

    func testAntiDiagonalConflictDetected() {
        sut.startGame(size: "7")
        sut.toggleQueen(at: 1, col: 5)
        sut.toggleQueen(at: 5, col: 1)

        let cell1 = sut.cellsData.first { $0.row == 1 && $0.col == 5 }
        let cell2 = sut.cellsData.first { $0.row == 5 && $0.col == 1 }
        XCTAssertTrue(cell1?.isConflict == true)
        XCTAssertTrue(cell2?.isConflict == true)
    }

    func testNoConflictForSafeQueens() {
        sut.startGame(size: "8")
        // Place three non-conflicting queens
        sut.toggleQueen(at: 0, col: 3)
        sut.toggleQueen(at: 1, col: 6)
        sut.toggleQueen(at: 2, col: 4)

        let conflictCells = sut.cellsData.filter { $0.isConflict }
        XCTAssertTrue(conflictCells.isEmpty)
    }

    func testConflictClearsWhenQueenRemoved() {
        sut.startGame(size: "6")
        sut.toggleQueen(at: 2, col: 1)
        sut.toggleQueen(at: 2, col: 4)

        // Both should be in conflict
        XCTAssertEqual(sut.cellsData.filter { $0.isConflict }.count, 2)

        // Remove one
        sut.toggleQueen(at: 2, col: 4)

        let conflictCells = sut.cellsData.filter { $0.isConflict }
        XCTAssertTrue(conflictCells.isEmpty)
    }

    // MARK: - Win Condition

    func testWinConditionWith4Queens() async throws {
        await mockService.state.setIsNewRecord(true)
        sut.startGame(size: "4")

        // Known 4-queens solution: (0,1), (1,3), (2,0), (3,2)
        sut.toggleQueen(at: 0, col: 1)
        sut.toggleQueen(at: 1, col: 3)
        sut.toggleQueen(at: 2, col: 0)
        sut.toggleQueen(at: 3, col: 2)

        XCTAssertTrue(sut.showingWinAlert)
        XCTAssertFalse(sut.allowPlaying)

        // Wait for async Task in checkWinCondition
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertTrue(sut.isNewRecord)

        let addedResults = await mockService.state.addedResults
        XCTAssertEqual(addedResults.count, 1)
        XCTAssertEqual(addedResults.first?.boardSize, 4)
    }

    func testWinConditionWith8Queens() async throws {
        await mockService.state.setIsNewRecord(true)
        sut.startGame(size: "8")

        // Known 8-queens solution: (0,0), (1,4), (2,7), (3,5), (4,2), (5,6), (6,1), (7,3)
        sut.toggleQueen(at: 0, col: 0)
        sut.toggleQueen(at: 1, col: 4)
        sut.toggleQueen(at: 2, col: 7)
        sut.toggleQueen(at: 3, col: 5)
        sut.toggleQueen(at: 4, col: 2)
        sut.toggleQueen(at: 5, col: 6)
        sut.toggleQueen(at: 6, col: 1)
        sut.toggleQueen(at: 7, col: 3)

        XCTAssertTrue(sut.showingWinAlert)
        XCTAssertFalse(sut.allowPlaying)

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertTrue(sut.isNewRecord)

        let addedResults = await mockService.state.addedResults
        XCTAssertEqual(addedResults.count, 1)
        XCTAssertEqual(addedResults.first?.boardSize, 8)
    }

    func testNoWinWhenNotAllQueensPlaced() {
        sut.startGame(size: "8")
        // Place 7 of 8 non-conflicting queens (missing last one)
        sut.toggleQueen(at: 0, col: 0)
        sut.toggleQueen(at: 1, col: 4)
        sut.toggleQueen(at: 2, col: 7)
        sut.toggleQueen(at: 3, col: 5)
        sut.toggleQueen(at: 4, col: 2)
        sut.toggleQueen(at: 5, col: 6)
        sut.toggleQueen(at: 6, col: 1)

        XCTAssertFalse(sut.showingWinAlert)
        XCTAssertTrue(sut.allowPlaying)
    }

    func testNoWinWhenConflictsExist() {
        sut.startGame(size: "8")
        // Place 8 queens on main diagonal — all in conflict
        for i in 0..<8 {
            sut.toggleQueen(at: i, col: i)
        }

        XCTAssertFalse(sut.showingWinAlert)
        XCTAssertTrue(sut.allowPlaying)
    }

    func testWinNotNewRecord() async throws {
        await mockService.state.setIsNewRecord(false)
        sut.startGame(size: "4")

        sut.toggleQueen(at: 0, col: 1)
        sut.toggleQueen(at: 1, col: 3)
        sut.toggleQueen(at: 2, col: 0)
        sut.toggleQueen(at: 3, col: 2)

        XCTAssertTrue(sut.showingWinAlert)

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertFalse(sut.isNewRecord)
    }

    // MARK: - resetGame

    func testResetGameClearsBoard() {
        sut.startGame(size: "8")
        sut.toggleQueen(at: 0, col: 3)
        sut.toggleQueen(at: 1, col: 6)
        sut.toggleQueen(at: 2, col: 4)

        sut.resetGame()

        XCTAssertEqual(sut.queensCount, 0)
        XCTAssertTrue(sut.allowPlaying)
        XCTAssertFalse(sut.showingWinAlert)
        XCTAssertTrue(sut.cellsData.allSatisfy { !$0.hasQueen && !$0.isConflict })
    }

    // MARK: - openSettings

    func testOpenSettingsShowsAlert() {
        sut.showingSizeAlert = false

        sut.openSettings()

        XCTAssertTrue(sut.showingSizeAlert)
    }

    // MARK: - Service delegation

    func testLoadBestTimeDelegatesToService() async throws {
        await mockService.state.setBestTime(42.5)
        sut.startGame(size: "8")

        sut.loadCurrentBest()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(sut.bestTime, 42.5)
    }

    func testBestTimeIsNilWhenNoRecords() async throws {
        await mockService.state.setBestTime(nil)
        sut.startGame(size: "8")

        sut.loadCurrentBest()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertNil(sut.bestTime)
    }

    func testLoadRecordsDelegatesToService() async throws {
        let record = GameRecord(id: UUID(), size: 10, time: 10.0, date: Date())
        await mockService.state.setResults([record])
        sut.startGame(size: "10")

        sut.loadRecords()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(sut.records.count, 1)
        XCTAssertEqual(sut.records.first?.time, 10.0)
    }
}
