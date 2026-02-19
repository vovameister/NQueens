//
//  ChessCellView.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//


import SwiftUI

struct ChessCellView: View {
    let cellData: CellData
    let cellSize: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellColor)
            
            if cellData.hasQueen {
                Image(systemName: "crown.fill")
                    .font(.system(size: cellSize * 0.5))
                    .foregroundStyle(cellData.isConflict ? .red : .yellow)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onTap()
            }
        }
    }
    
    private var cellColor: Color {
        if cellData.isConflict && cellData.hasQueen {
            return cellData.isLight ? Color.red.opacity(0.3) : Color.red.opacity(0.5)
        }
        return cellData.isLight ? Color.white : Color.gray.opacity(0.3)
    }
}
