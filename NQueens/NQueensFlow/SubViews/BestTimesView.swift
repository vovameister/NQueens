//
//  BestTimesView.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import SwiftUI

struct BestTimesView: View {
    let boardSize: Int
    let results: [GameRecord]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            listContent
                .navigationTitle("Best Times - \(boardSize)×\(boardSize)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private var listContent: some View {
        List {
            if results.isEmpty {
                emptyStateView
            } else {
                resultsListView
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Results Yet",
            systemImage: "timer",
            description: Text("Complete a game to see your best times here")
        )
    }
    
    private var resultsListView: some View {
        ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
            resultRow(index: index, result: result)
        }
    }
    
    private func resultRow(index: Int, result: GameRecord) -> some View {
        HStack {
            Text("#\(index + 1)")
                .font(.headline)
                .foregroundStyle(rankColor(for: index))
                .frame(width: 40, alignment: .leading)
            
            if index < 3 {
                Image(systemName: "medal.fill")
                    .foregroundStyle(rankColor(for: index))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.formattedTime)
                    .font(.title3)
                    .bold()
                
                Text(result.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .primary
        }
    }
}

#Preview {
    BestTimesView(
        boardSize: 8,
        results: []
    )
}
