//
//  GameRecord.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 20. 2. 2026..
//
import Foundation

struct GameRecord: Identifiable {
    let id: UUID
    let size: Int
    let time: TimeInterval
    let date: Date
    
    var formattedTime: String {
        time.formatted(decimalPlaces: 2, padMinutes: false)
    }
    
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var formattedDate: String {
        GameRecord.formatter.string(from: date)
    }
}
