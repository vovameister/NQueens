//
//  ChessBoardView.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import SwiftUI

struct ChessBoardView: View {
    let boardSize: Int
    let cellsData: [CellData]
    let isInteractionEnabled: Bool
    let onCellTap: (Int, Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cellSize = size / CGFloat(boardSize)
            let columns = Array(repeating: GridItem(.fixed(cellSize), spacing: 0), count: boardSize)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(cellsData) { cellData in
                    ChessCellView(
                        cellData: cellData,
                        cellSize: cellSize,
                        onTap: {
                            onCellTap(cellData.row, cellData.col)
                        }
                    )
                }
            }
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(isInteractionEnabled)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
