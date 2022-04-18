//
//  BMAudioStore.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/04/15.
//

import Foundation

final class BMAudioStore {
  
  var audioPlayers: [BMAudioPlayer] = []
}

// MARK: - Getters & Setters

extension BMAudioStore {
  
  /// The count of all audioPlayers
  var countOfAudioPlayers: Int {
    audioPlayers.count
  }
  
  /// The count of audioPlayers for the specified AudioType
  /// - Parameter audioType: AudioType
  /// - Returns: Int
  func countOfPlayersFor(audioType: AudioType) -> Int  {
    playersOf(audioType: audioType).count
  }
  
  /// An audioplayer matched to the given identifier
  /// - Parameter identifier: String
  /// - Returns:  BMAudioPlayer?
  func playerFrom(identifier: String) -> BMAudioPlayer? {
    audioPlayers[identifier]
  }
  
  /// An array of all audioPlayers of the specific AudiotType
  /// - Parameter audioType: AudioType
  /// - Returns:  [BMAudioPlayer]
  func playersOf(audioType: AudioType) -> [BMAudioPlayer] {
    audioPlayers[audioType]
  }
  
  /// Appends a new audioPlayer to the BMAudioStore
  /// - Parameter audioPlayer: BMAudioPlayer
  func appendAudioPlayer(_ audioPlayer: BMAudioPlayer) {
    audioPlayers.append(audioPlayer)
  }
  
  /// Deletes a single audioPlayer with the specified identifier
  /// - Parameter identifier: String
  func destroyAudioPlayer(identifier: String) {
    guard
      let index = audioPlayers.firstIndex(where: { $0.identifier == identifier})
    else {
      return
    }
    let audioPlayer = audioPlayers[index]
    audioPlayer.stop()
    audioPlayer.destroy()
    audioPlayers.remove(at: index)
  }
  
  /// Removes all audioPlayers from the stack
  func destroyAllAudioPlayers() {
    audioPlayers.forEach { deleteAudioPlayer(identifier: $0.identifier) }
  }
  
  /// Removes all audioPlayers of the specified AudioType
  /// - Parameter audioType: AudioType
  func removeAllPlayersOfType(_ audioType: AudioType) {
    audioPlayers.removeAll { $0.audioType == audioType }
  }
  
  /// Pauses all the audioPlayers
  func pauseAllPlayers() {
    audioPlayers.forEach { $0.pause() }
  }
  
  /// Resumes playback of the audioPlayers
  func resumeAllPlayers() {
    audioPlayers.forEach { $0.play() }
  }
  
  /// Sets the volume of the specified audioPlayer
  /// - Parameters:
  ///   - identifier: String
  ///   - volume: Float
  func setPlayerVolume(identifier: String, volume: Float) {
    guard let player = audioPlayers[identifier] else { return }
    player.setVolume(volume)
  }
}

// MARK: - Subscripts

extension Array where Element == BMAudioPlayer {
  
  subscript(identifier: String) -> BMAudioPlayer? {
    first { $0.identifier == identifier }
  }
  
  subscript(audioType: AudioType) -> [BMAudioPlayer] {
    filter { $0.audioType == audioType }
  }
}
