//
//  AudioManager.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/04/18.
//

import Foundation
import Combine
import AVFoundation
import MediaPlayer

final class AudioManager {
  
  static let shared = AudioManager()
  
  let audioStore = BMAudioStore()
  
  private var playBackTimer: AudioPlayBackTimer?
  
  @Published
  var playBackData: AudioPlayBackData?
  
  @Published
  var shouldShowMiniPlayer: Bool?
  
  @Published
  var playbackState: AudioManagerPlayBackState?
  
  var infinitePlayBackDuration: TimeInterval {
    24 * 3600
  }
  
  private (set) var playBackDuration: TimeInterval = 3600 {
    didSet {
      guard let playBackTimer = playBackTimer else { return }
      playBackTimer.modifyPlayBackDuration(playBackDuration)
    }
  }
  
  var isInfiniteTimer: Bool {
    playBackDuration == infinitePlayBackDuration
  }
  
  private var cancelBag: Set<AnyCancellable> = []
  
  // MARK: - Initialization
  
  private init () {
    setupBackgroundAudio()
    configureRemoteControlSettings()
    playbackState = .stopped
  }
  
  private func setupBackgroundAudio() {
    try? AVAudioSession.sharedInstance().setCategory(
      .playback,
      mode: .default,
      options:[.allowBluetooth, .allowAirPlay, .defaultToSpeaker]
    )
    try? AVAudioSession.sharedInstance().setActive(true)
  }
}

// MARK: - CallBacks

extension AudioManager {
  
  /// Sets The Individua Volume Of The Specified BMAudioPlayer
  /// - Parameters:
  ///   - identifier: The Identifier Of The AudioPlayer
  ///   - volume: The Volume Of The AudioPlayer
  func setPlayerVolume(identifier: String, volume: Float) {
    audioStore.setPlayerVolume(identifier: identifier, volume: volume)
  }
  
  /// Sets The PlayBackDuration Of The Timer
  /// - Parameter timerAction: TimerState
  func setTimer(timerAction: TimerState) {
    
    switch timerAction {
    case .noTimer:
      playBackDuration = infinitePlayBackDuration
    case .custom(let value):
      playBackDuration = Int(value) == 0 ? infinitePlayBackDuration : TimeInterval(value)
    }
    
    if playbackState == .paused {
      self.playBackData = nil
    } else {

    }
  }

  /// Pause The Current Audio Players
  func pause() {
    playbackState = .paused
    playBackTimer?.pause()
    audioStore.pauseAllPlayers()
  }
  
  /// Resumes The Current Audio Players
  func resume() {
    playBackTimer?.resume()
    playbackState = .playing
    audioStore.resumeAllPlayers()
  }

  /// Removes All Audio Players
  func removeAllPlayers() {
    audioStore.destroyAllAudioPlayers()
    destroyTimer()
  }
}

// MARK: - Timer

private extension AudioManager {
  
  func addPlayBackTimer() {
    playBackTimer = AudioPlayBackTimer()
  }
  
  /// Runs The PlayBackTimer
  @objc func runPlayBackTimer() {
   
    playBackTimer?.start(playBackDuration: playBackDuration)
    shouldShowMiniPlayer = true
    playbackState = .playing
    
    playBackTimer?.$state.sink(receiveValue: { [weak self] state in
      guard let self = self, let state = state else { return }
      
      switch state {
        
      case .playing(let playBackData):
        self.playBackData = playBackData
      case .paused(let playBackData):
        self.playBackData = playBackData
      case .finished(let playBackData):
        self.playBackData = playBackData
        self.destroyTimer()
        self.audioStore.resumeAllPlayers()
      }
    }).store(in: &cancelBag)
  }
  
  /// Destroys The PlayBackTimer
  func destroyTimer() {
    self.playBackData = nil
    shouldShowMiniPlayer = false
    playbackState = .stopped
  }
}

// MARK: - LockScreen Display

private extension AudioManager {
 
  func configureRemoteControlSettings() {
    
    let commandCenter = MPRemoteCommandCenter.shared()
    
    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget { [weak self] event in
      guard let self = self else { return .commandFailed }
      self.audioStore.resumeAllPlayers()
      self.playBackTimer?.pause()
      return .success
    }
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { [weak self] event in
      guard let self = self else { return .commandFailed }
      self.audioStore.pauseAllPlayers()
      self.playBackTimer?.resume()
      return .success
    }
    commandCenter.nextTrackCommand.isEnabled = false
    commandCenter.nextTrackCommand.addTarget {event in
      return .success
    }
    commandCenter.previousTrackCommand.isEnabled = false
    commandCenter.previousTrackCommand.addTarget {event in
      return .success
    }
  }
}
