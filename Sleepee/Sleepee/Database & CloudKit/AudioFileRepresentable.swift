//
//  AudioFileRepresentable.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/04/18.
//

import Foundation

/// An immutable representation of an Audio used for local data
struct AudioFileRespresentable {
  var uuidIdentifier: String
  var displayName: String
  var displayDescription: String?
  var composer: String?
  var assetName: String
  var audioFileSize: NSNumber?
  var audioType: String
  var streamingAudioURL: String?
  var audioDownloadURL: String?
  var categories: [String]?
  var isFree: NSNumber
  var isBundledResource: Bool
  var sortOrder: NSNumber
}
