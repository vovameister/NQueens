//
//  NQueensView.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import SwiftUI

struct NQueensView: View {
    @State private var viewModel = NQueensViewModel(
        bestTimesService: BestTimesService(),
        soundPlayer: SoundPlayer()
    )
    @State private var showBestTimes = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                topView
                
                infoPanel
                
                ChessBoardView(
                    boardSize: viewModel.boardSize,
                    cellsData: viewModel.cellsData,
                    isInteractionEnabled: viewModel.allowPlaying && !viewModel.showingWinAlert,
                    onCellTap: { row, col in
                        viewModel.toggleQueen(at: row, col: col)
                    }
                )
                .padding()
                
                TimerView(
                    elapsedTime: viewModel.elapsedTime,
                    isRunning: viewModel.isTimerRunning
                )
                
                Spacer()
                
                controlButtons
            }
            .padding(.top)
            
            if viewModel.showingSizeAlert {
                settingsView
            }
        }
        .alert("Victory! 🎉", isPresented: $viewModel.showingWinAlert) {
            Button("New Game") {
                viewModel.resetGame()
            }
            Button("View Records") {
                showBestTimes = true
                viewModel.showingWinAlert = false
            }
            Button("Continue") {
                viewModel.showingWinAlert = false
            }
        } message: {
            if viewModel.isNewRecord {
                Text("Congratulations! You successfully placed all \(viewModel.boardSize) queens!\n\nTime: \(viewModel.formattedTime)\n\n🎉 New Personal Best!")
            } else {
                Text("Congratulations! You successfully placed all \(viewModel.boardSize) queens!\n\nTime: \(viewModel.formattedTime)")
            }
        }
        .sheet(isPresented: $showBestTimes) {
            BestTimesView(
                boardSize: viewModel.boardSize,
                results: viewModel.records
            )
        }
        .onChange(of: showBestTimes) {
            if showBestTimes {
                viewModel.loadRecords()
            }
        }
    }
    
    private var infoPanel: some View {
        HStack {
            VStack {
                Text("Size")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.boardSize)×\(viewModel.boardSize)")
                    .font(.title2)
                    .bold()
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("Queens")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.queensCount)/\(viewModel.boardSize)")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(viewModel.queensCount == viewModel.boardSize ? .green : .primary)
            }
            
            if let bestTime = viewModel.bestTime {
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("Best")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(bestTime.formatted(decimalPlaces: 2, padMinutes: true))
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
    
    private var topView: some View {
        ZStack {
            Text("N-Queens")
                .font(.largeTitle)
                .bold()
            
            HStack {
                Button {
                    showBestTimes = true
                } label: {
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundStyle(.yellow)
                }
                
                Spacer()
                
                Button {
                    viewModel.openSettings()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var controlButtons: some View {
        Button {
            viewModel.resetGame()
        } label: {
            Label("New Game", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity)
                .foregroundStyle(.black)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var settingsView: some View {
        BoardSizeDialog(
            isPresented: $viewModel.showingSizeAlert,
            inputSize: $viewModel.inputSize,
            isInputValid: viewModel.isInputValid,
            onStart: {
                viewModel.startGame(size: viewModel.inputSize)
            },
            onCancel: {
                if viewModel.boardSize == 0 {
                    viewModel.inputSize = "8"
                    viewModel.startGame(size: "8")
                }
            }
        )
    }

}

#Preview {
    NQueensView()
}
