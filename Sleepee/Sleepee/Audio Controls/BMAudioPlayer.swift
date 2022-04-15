//
//  BMAudioPlayer.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/04/15.
//

import Foundation
import AVFoundation

final class BMAudioPlayer: Equatable, Hashable {
 
  enum PlayerState: String {
    case notYetLoaded, loading, loaded, failed
  }
  
  private var playerLooper: AVPlayerLooper!

  private var fadeTimer: Timer?
  
  var player: AVQueuePlayer?

  private let fadeInterval: TimeInterval = 0.1
  
  private(set) var audioFile: AudioFile!
  
  var fadeDuration: TimeInterval?
 
  var identifier: String {
    audioFile.uuidIdentifier
  }
  
  var audioFileType: String {
    audioFile.audioType
  }
  
  private var durationKey = "duration"
  
  // MARK: - Initialization
  
  init(audioFile: AudioFile) {
    self.audioFile = audioFile
    configurePlayer()
  }
  
  deinit {
    print("Destroyed BMAudioPlayer \(identifier)")
    fadeTimer?.invalidate()
    fadeTimer = nil
  }
  
  // MARK: - PlayerSetup
  
  private func configurePlayer() {
    let asset = AVAsset(url: audioFile.audioFileURL)
    let playerItem = AVPlayerItem(asset: asset)
    
    player = AVQueuePlayer()
    
    guard let player = player else {
      return
    }

    Task {
      let _ = try await asset.load(.duration)
      
      if case .loaded = asset.status(of: .duration) {
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        await player.play()
      }
    }
  }
}

// MARK: - Callbacks

extension BMAudioPlayer {
  
  func play() {
    player?.play()
  }
  
  func pause() {
    player?.pause()
  }
  
  func stop() {
    player?.seek(to: .zero)
    player?.pause()
  }
  
  func resetPlayBackTime() {
    self.stop()
    player?.play()
  }
}

// MARK: - Equatable && Hashable

extension BMAudioPlayer {
  
  static func == (lhs: BMAudioPlayer, rhs: BMAudioPlayer) -> Bool {
    lhs.identifier == rhs.identifier
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}
