//
//  AudioPlayBackTimerState.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/04/18.
//

import Foundation

enum AudioPlayBackTimerState {
  case playing(AudioPlayBackData?), paused(AudioPlayBackData?), finished(AudioPlayBackData?)
}
