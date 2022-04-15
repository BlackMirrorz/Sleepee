//
//  BMAudioStore.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/04/15.
//

import Foundation

final class BMAudioStore {
  
  var audioPlayers: [BMAudioPlayer] = []
  
  subscript(identifier: String) -> BMAudioPlayer? {
    audioPlayers.first { $0.identifier == identifier }
  }
  
  subscript(audioFileType: String) -> [BMAudioPlayer] {
    audioPlayers.filter { $0.audioFileType == audioFileType }
  }
}
