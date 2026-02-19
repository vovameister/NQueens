//
//  CellData.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

struct CellData: Identifiable, Equatable {
    let id: String
    let row: Int
    let col: Int
    let hasQueen: Bool
    let isConflict: Bool
    let isLight: Bool
    
    init(row: Int, col: Int, hasQueen: Bool, isConflict: Bool) {
        self.id = "\(row)-\(col)"
        self.row = row
        self.col = col
        self.hasQueen = hasQueen
        self.isConflict = isConflict
        self.isLight = (row + col) % 2 == 0
    }
}
