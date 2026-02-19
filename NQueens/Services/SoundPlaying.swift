//
//  SoundPlaying.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 20. 2. 2026..
//


import AVFoundation
import UIKit

@MainActor
protocol SoundPlaying: AnyObject {
    func playMove()
    func playVictory()
}

@MainActor
final class SoundPlayer: SoundPlaying {
    private var movePlayer: AVAudioPlayer?
    private var victoryPlayer: AVAudioPlayer?

    init() {
        preload()
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
