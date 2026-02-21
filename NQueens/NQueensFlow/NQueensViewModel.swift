//
//  NQueensViewModel.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import SwiftUI

@MainActor
@Observable
final class NQueensViewModel {
    private let bestTimesService: BestTimesServiceProtocol
    private let soundPlayer: SoundPlaying
    private var queens: Set<Position> = []
    private var conflicts: Set<Position> = []
    private var startTime: Date?
    private var timer: Timer?

    private(set) var boardSize: Int = 0
    private(set) var cellsData: [CellData] = []
    private(set) var queensCount: Int = 0
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var isTimerRunning: Bool = false
    private(set) var allowPlaying: Bool = true
    private(set) var isNewRecord: Bool = false
    private(set) var bestTime: TimeInterval?
    private(set) var records: [GameRecord] = []

    var showingSizeAlert: Bool = true
    var showingWinAlert: Bool = false
    var inputSize: String = "8"

    var formattedTime: String {
        elapsedTime.formatted(decimalPlaces: 0, padMinutes: true)
    }

    var isInputValid: Bool {
        guard let size = Int(inputSize) else { return false }
        return size >= 4 && size <= 12
    }

    init(bestTimesService: BestTimesServiceProtocol, soundPlayer: SoundPlaying) {
        self.bestTimesService = bestTimesService
        self.soundPlayer = soundPlayer
    }

    func startGame(size: String) {
        guard let sizeInt = Int(size) else { return }
        boardSize = sizeInt
        showingSizeAlert = false
        resetGame()
    }

    func toggleQueen(at row: Int, col: Int) {
        let position = Position(row: row, col: col)

        if queens.contains(position) {
            queens.remove(position)
        } else {
            queens.insert(position)
            Task { await soundPlayer.playMove() }
        }

        updateConflicts()
        rebuildCells()
        checkWinCondition()
    }

    func resetGame() {
        queens.removeAll()
        conflicts.removeAll()
        rebuildCells()
        showingWinAlert = false
        resetTimer()
        startTimer()
        allowPlaying = true
        loadCurrentBest()
    }

    func openSettings() {
        showingSizeAlert = true
    }

    func loadCurrentBest() {
        Task {
            bestTime = await bestTimesService.getBestTime(for: boardSize)
        }
    }

    func loadRecords() {
        Task {
            records = await bestTimesService.getResults(for: boardSize)
        }
    }

    private func rebuildCells() {
        var cells: [CellData] = []
        cells.reserveCapacity(boardSize * boardSize)
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let position = Position(row: row, col: col)
                cells.append(CellData(
                    row: row,
                    col: col,
                    hasQueen: queens.contains(position),
                    isConflict: conflicts.contains(position)
                ))
            }
        }
        cellsData = cells
        queensCount = queens.count
    }

    private func updateConflicts() {
        conflicts.removeAll()

        let queensArray = Array(queens)

        for i in 0..<queensArray.count {
            for j in (i + 1)..<queensArray.count {
                if areInConflict(queensArray[i], queensArray[j]) {
                    conflicts.insert(queensArray[i])
                    conflicts.insert(queensArray[j])
                }
            }
        }
    }

    private func areInConflict(_ q1: Position, _ q2: Position) -> Bool {
        if q1.row == q2.row { return true }
        if q1.col == q2.col { return true }
        return abs(q1.row - q2.row) == abs(q1.col - q2.col)
    }

    private func checkWinCondition() {
        if queens.count == boardSize && conflicts.isEmpty {
            stopTimer()
            allowPlaying = false
            showingWinAlert = true
            Task { await soundPlayer.playVictory() }
            let finalTime = elapsedTime
            let finalSize = boardSize
            Task {
                isNewRecord = await bestTimesService.isNewRecord(finalTime, for: finalSize)
                await bestTimesService.addResult(boardSize: finalSize, time: finalTime)
                loadCurrentBest()
            }
        }
    }

    private func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        startTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let startTime = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    private func resetTimer() {
        stopTimer()
        elapsedTime = 0
        startTime = nil
    }
}
