//
//  CellDataTests.swift
//  NQueensTests
//

import XCTest
@testable import NQueens

@MainActor
final class CellDataTests: XCTestCase {

    func testIdFormat() {
        let cell = CellData(row: 2, col: 3, hasQueen: false, isConflict: false)
        XCTAssertEqual(cell.id, "2-3")
    }

    func testIsLightForEvenSum() {
        let cell = CellData(row: 0, col: 0, hasQueen: false, isConflict: false)
        XCTAssertTrue(cell.isLight)

        let cell2 = CellData(row: 1, col: 1, hasQueen: false, isConflict: false)
        XCTAssertTrue(cell2.isLight)
    }

    func testIsDarkForOddSum() {
        let cell = CellData(row: 0, col: 1, hasQueen: false, isConflict: false)
        XCTAssertFalse(cell.isLight)

        let cell2 = CellData(row: 1, col: 0, hasQueen: false, isConflict: false)
        XCTAssertFalse(cell2.isLight)
    }

    func testEquality() {
        let cell1 = CellData(row: 0, col: 0, hasQueen: true, isConflict: false)
        let cell2 = CellData(row: 0, col: 0, hasQueen: true, isConflict: false)
        XCTAssertEqual(cell1, cell2)
    }

    func testInequalityOnQueen() {
        let cell1 = CellData(row: 0, col: 0, hasQueen: true, isConflict: false)
        let cell2 = CellData(row: 0, col: 0, hasQueen: false, isConflict: false)
        XCTAssertNotEqual(cell1, cell2)
    }

    func testInequalityOnConflict() {
        let cell1 = CellData(row: 0, col: 0, hasQueen: false, isConflict: true)
        let cell2 = CellData(row: 0, col: 0, hasQueen: false, isConflict: false)
        XCTAssertNotEqual(cell1, cell2)
    }

    func testCheckerboardPatternForFullBoard() {
        for row in 0..<8 {
            for col in 0..<8 {
                let cell = CellData(row: row, col: col, hasQueen: false, isConflict: false)
                let expectedLight = (row + col) % 2 == 0
                XCTAssertEqual(cell.isLight, expectedLight, "Cell (\(row),\(col)) should be \(expectedLight ? "light" : "dark")")
            }
        }
    }
}
