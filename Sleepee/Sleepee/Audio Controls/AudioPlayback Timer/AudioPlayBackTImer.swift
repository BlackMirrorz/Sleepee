//
//  AudioPlayBackTImer.swift
//  SleepTight
//
//  Created by Josh Robbins on 2022/03/25.
//

import Foundation
import Combine
import MediaPlayer

final class AudioPlayBackTimer: NSObject {
  
  @Published
  var state: AudioPlayBackTimerState?
  
  private let timeInterval: TimeInterval = 0.1
  private var audioTrackingTimer: Timer?
  private var isPaused: Bool = false
  private var timeWhenPaused: TimeInterval?
  private var elapsedTime: TimeInterval = 0
  private var playBackDuration: TimeInterval = 30
  private var playBackData: AudioPlayBackData?
 
  // MARK: - Initialization
  
  override init() { }
}

// MARK: - CallBacks

extension AudioPlayBackTimer {
  
  /// Starts The PlayBackTimer With The Desired Total Playback Duration
  /// - Parameter playBackDuration: TimeInterval
  func start(playBackDuration: TimeInterval) {
    
    registerNowPlayingInfo()
    
    self.playBackDuration = playBackDuration
    
    audioTrackingTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] timer in
      guard let self = self else { return }
      
      self.elapsedTime += self.timeInterval
      
      self.playBackData = AudioPlayBackData(currentTime: self.elapsedTime, playBackDuration: self.playBackDuration)
      
      self.state = .playing(self.playBackData)
     
      guard let playBackData = self.playBackData else {
        return
      }
      
      if playBackData.remainingTime.seconds <= 0 {
        self.invalidate()
      } else {
        self.updateMediaCenter()
      }
    })
    
    RunLoop.main.add(audioTrackingTimer!, forMode: .common)
  }
  
  /// Pauses The AudioPlayback Timer
  func pause() {
    guard !isPaused else { return }
    timeWhenPaused = audioTrackingTimer?.fireDate.timeIntervalSinceNow
    audioTrackingTimer?.fireDate = Date(timeIntervalSinceNow: 3600*10000)
    isPaused = true
    state = .paused(playBackData)
  }
  
  /// Resumes The AudioPlayback Timer
  func resume() {
    guard isPaused else { return }
    audioTrackingTimer?.fireDate = Date().addingTimeInterval(timeWhenPaused!)
    isPaused = false
    state = .playing(playBackData)
  }
  
  /// Destroys The AudioPlayback Timer
  func invalidate() {
    audioTrackingTimer?.invalidate()
    audioTrackingTimer = nil
    state = .finished(playBackData)
    nullifyNowPlayingInfo()
  }
  
  /// Changes The Total PlayBack Duration
  /// - Parameter playBackDuration: TimeInterval
  func modifyPlayBackDuration(_ playBackDuration: TimeInterval) {
    elapsedTime = 0
    self.playBackDuration = playBackDuration
    
    playBackData = AudioPlayBackData(currentTime: elapsedTime, playBackDuration: playBackDuration)
    
    print("User Has Set PlayBack Duration", playBackData!.playBackDuration.shortDurationText)
    
    switch isPaused {
    case true:
      state = .paused(playBackData)
    case false:
      state = .playing(playBackData)
    }
    
    updateMediaCenter()
  }
}

// MARK: - MediaCenter

private extension AudioPlayBackTimer {
  
  private func updateMediaCenter() {
    
    guard let playBackData = playBackData else {
      return
    }
    
    DispatchQueue.main.async {
      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
        MPMediaItemPropertyTitle: "TEST",
        MPMediaItemPropertyArtist: "Josh",
        MPNowPlayingInfoPropertyElapsedPlaybackTime: playBackData.currentTime.seconds,
        MPMediaItemPropertyPlaybackDuration : playBackData.playBackDuration.seconds,
        MPNowPlayingInfoPropertyPlaybackRate: self.isPaused ? 0.0 : 1.0
      ]
    }
  }
  
  func registerNowPlayingInfo() {
    UIApplication.shared.beginReceivingRemoteControlEvents()
  }
  
  func nullifyNowPlayingInfo() {
    UIApplication.shared.endReceivingRemoteControlEvents()
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
  }
}
