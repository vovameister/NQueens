//
//  GameRecordTests.swift
//  NQueensTests
//

import XCTest
@testable import NQueens

@MainActor
final class GameRecordTests: XCTestCase {

    func testFormattedTime() {
        let record = GameRecord(id: UUID(), size: 8, time: 65.42, date: Date())
        XCTAssertEqual(record.formattedTime, "1:05.42")
    }

    func testFormattedTimeZero() {
        let record = GameRecord(id: UUID(), size: 10, time: 0, date: Date())
        XCTAssertEqual(record.formattedTime, "0:00.00")
    }

    func testFormattedTimeSubMinute() {
        let record = GameRecord(id: UUID(), size: 6, time: 12.5, date: Date())
        XCTAssertEqual(record.formattedTime, "0:12.50")
    }
}
