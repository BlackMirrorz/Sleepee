//
//  AudioFile.swift
//  Sleepee
//
//  Created by Josh Robbins on 2022/04/15.
//

import Foundation
import CoreData

public class AudioFile: NSManagedObject {
  
  @NSManaged public var uuidIdentifier: String
  @NSManaged public var displayName: String
  @NSManaged public var displayDescription: String?
  @NSManaged public var composer: String?
  @NSManaged public var assetName: String
  @NSManaged public var audioFileSize: NSNumber?
  @NSManaged public var audioType: String
  @NSManaged public var streamingAudioURL: String?
  @NSManaged public var audioDownloadURL: String?
  @NSManaged public var categories: [String]?
  @NSManaged public var isFree: NSNumber
  @NSManaged public var isBundledResource: Bool
  @NSManaged public var sortOrder: NSNumber
  
  //MARK: - Internal
  
  @NSManaged public var ckRecordID: String?
  
  static var entityName: String {
    return "AudioFile"
  }
}

// MARK: - Asset Getters

extension AudioFile {
 
  var audioFileURL: URL {
    FilesManager.urlFor(audioFile: assetName, isBundledResource: isBundledResource)
  }
  
  var imageFileURL: URL {
    return FilesManager.urlFor(imageFile:assetName)
  }
}

// MARK: - AudioFileKeys

enum AudioFileKeys: String, CaseIterable {
  case uuidIdentifier
  case displayName
  case displayDescription
  case assetName
  case audioFileSize
  case audioType
  case streamingAudioURL
  case audioDownloadURL
  case categories
  case isFree
  case isBundledResource
  case imageAsset
  case sortOrder
}

// MARK: - AudioFile Error

enum AudioFileError: Error {
  case invalidRecord
  case invalidImageAsset
  case invalidAudioAsset
  case unableToSaveImageAsset
  case unableToSaveAudioAsset
}
