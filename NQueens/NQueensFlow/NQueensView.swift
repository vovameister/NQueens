//
//  NQueensView.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import SwiftUI

struct NQueensView: View {
    @State private var viewModel: NQueensViewModel
    @State private var showBestTimes = false
    
    @MainActor
    init(
        bestTimesService: BestTimesServiceProtocol? = nil,
        soundPlayer: SoundPlaying? = nil
    ) {
        self.viewModel = .init(
            bestTimesService: bestTimesService ?? BestTimesService(),
            soundPlayer: soundPlayer ?? SoundPlayer()
        )
    }
    
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
                    isInteractionEnabled: viewModel.state.allowsInteraction,
                    onCellTap: { row, col in
                        viewModel.toggleQueen(at: row, col: col)
                    }
                )
                .padding()
                
                TimerView(
                    elapsedTime: viewModel.elapsedTime,
                    isRunning: viewModel.state.runsTimer
                )
                
                Spacer()
                
                controlButtons
            }
            .padding(.top)
            
            if viewModel.state.showsBoardSizeDialog {
                settingsView
            }
        }
        .alert("Victory! 🎉", isPresented: winAlertBinding) {
            Button("New Game") {
                viewModel.resetGame()
            }
            Button("View Records") {
                showBestTimes = true
                viewModel.dismissWinAlert()
            }
            Button("Continue") {
                viewModel.dismissWinAlert()
            }
        } message: {
            if viewModel.state.hasNewRecord {
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
            isPresented: boardSizeDialogBinding,
            inputSize: $viewModel.inputSize,
            isInputValid: viewModel.isInputValid,
            onStart: {
                viewModel.startGame(size: viewModel.inputSize)
            },
            onCancel: {
                if viewModel.boardSize == 0 {
                    viewModel.inputSize = "8"
                    viewModel.startGame(size: "8")
                } else {
                    viewModel.closeSettings()
                }
            }
        )
    }

    private var boardSizeDialogBinding: Binding<Bool> {
        Binding {
            viewModel.state.showsBoardSizeDialog
        } set: { isPresented in
            if !isPresented {
                viewModel.closeSettings()
            }
        }
    }

    private var winAlertBinding: Binding<Bool> {
        Binding {
            viewModel.state.showsWinAlert
        } set: { isPresented in
            if !isPresented {
                viewModel.dismissWinAlert()
            }
        }
    }

}

#Preview {
    NQueensView()
}
