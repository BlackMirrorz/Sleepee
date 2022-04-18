//
//  AudioPlayBackData.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/03/25.
//

import Foundation
import CoreMedia

struct AudioPlayBackData {
  let timeScale: CMTimeScale = 600
  var playBackDuration: CMTime
  var currentTime: CMTime
  var remainingTime: CMTime
 
  var currentTimeDisplayable: String {
    currentTime.shortDurationText
  }
  var remainingTimeDisplayable: String {
    remainingTime.shortDurationText
  }
  
  /// Initializes The AudioPlayBackData
  /// - Parameters:
  ///   - currentTime: The Current PlayBackTime Of The Audio Session
  ///   - playBackDuration: The PlayBack Duration Set By The User
  init(currentTime: TimeInterval, playBackDuration: TimeInterval) {
    self.currentTime = CMTime(seconds: currentTime, preferredTimescale: timeScale)
    self.playBackDuration = CMTime(seconds: playBackDuration, preferredTimescale: timeScale)
    self.remainingTime = CMTime(seconds: self.playBackDuration.seconds - self.currentTime.seconds, preferredTimescale: timeScale)
  }
}
