//
//  TimerView.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026.
//

import SwiftUI

struct TimerView: View {
    let elapsedTime: TimeInterval
    let isRunning: Bool
    
    var body: some View {
        Text(formattedTime)
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(isRunning ? .primary : .secondary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            )
            .padding(.horizontal)
    }
    
    private var formattedTime: String {
        elapsedTime.formatted(decimalPlaces: 1, padMinutes: true)
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerView(elapsedTime: 125.6, isRunning: true)
        TimerView(elapsedTime: 0, isRunning: false)
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
