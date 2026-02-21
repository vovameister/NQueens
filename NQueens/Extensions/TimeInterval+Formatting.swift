//
//  TimeInterval+Formatting.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 20. 2. 2026.
//

import Foundation

extension TimeInterval {
    func formatted(decimalPlaces: Int = 2, padMinutes: Bool = false) -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        let minutesFormat = padMinutes ? "%02d" : "%d"
        
        if decimalPlaces == 0 {
            return String(format: "\(minutesFormat):%02d", minutes, seconds)
        }
        
        let multiplier = decimalPlaces == 1 ? 10 : 100
        let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * Double(multiplier))
        let msFormat = decimalPlaces == 1 ? "%01d" : "%02d"
        
        return String(format: "\(minutesFormat):%02d.\(msFormat)", minutes, seconds, milliseconds)
    }
}
