//
//  BoardSizeDialog.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import SwiftUI

struct BoardSizeDialog: View {
    @Binding var isPresented: Bool
    @Binding var inputSize: String
    let isInputValid: Bool
    let onStart: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 8) {
                Text("Choose Board Size")
                    .font(.title2)
                    .bold()
                
                Text("Select board size from 4 to 12")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                    TextField("Enter size", text: $inputSize)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.black, lineWidth: 1)
                        )
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("Invalid input")
                            .font(.caption)
                    }
                    .foregroundStyle(.red)
                    .transition(.opacity)
                    .opacity(!isInputValid ? 1 : 0)
                }
                
                HStack(spacing: 12) {
                    Button {
                        onCancel()
                        isPresented = false
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        onStart()
                        isPresented = false
                    } label: {
                        Text("Start Game")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isInputValid)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.2), radius: 20)
            )
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var inputSize = "8"
    
    BoardSizeDialog(
        isPresented: $isPresented,
        inputSize: $inputSize,
        isInputValid: true,
        onStart: {},
        onCancel: {}
    )
}
