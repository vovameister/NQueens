//
//  SoundPlaying.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 20. 2. 2026..
//


import AVFoundation
import UIKit

protocol SoundPlaying: Sendable, Actor {
    func playMove()
    func playVictory()
}

actor SoundPlayer: SoundPlaying {
    private var movePlayer: AVAudioPlayer?
    private var victoryPlayer: AVAudioPlayer?

    init() {
        Task {
            await preload()
        }
    }

    private func preload() {
        movePlayer = makePlayer(assetName: "move-sound")
        victoryPlayer = makePlayer(assetName: "the-sound-of-victory")

        movePlayer?.prepareToPlay()
        victoryPlayer?.prepareToPlay()
    }

    private func makePlayer(assetName: String) -> AVAudioPlayer? {
        guard let asset = NSDataAsset(name: assetName) else { return nil }
        return try? AVAudioPlayer(data: asset.data)
    }

    func playMove() {
        movePlayer?.currentTime = 0
        movePlayer?.play()
    }

    func playVictory() {
        victoryPlayer?.currentTime = 0
        victoryPlayer?.play()
    }
}
