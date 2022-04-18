//
//  FilesManager.swift
//  SleepTightDB
//
//  Created by Josh Robbins on 2022/04/12.
//

import Foundation
import CloudKit

enum FilesManager {
 
  enum FileType {
    case audio, image
    
    var suffix: String {
      switch self {
      case .audio:
        return ".wav"
      case .image:
        return ".png"
      }
    }
  }
  
  private static let fileManager = FileManager.default
  
  private static let userDirectoryName = "SleepTightStorage"
  private static let audioDirectoryName = "Audio"
  private static let imageDirectoryName = "Images"
  
  private static var documentsDirectory: URL {
    fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
  
  private static var userDirectory: URL {
    documentsDirectory.appendingPathComponent(userDirectoryName)
  }
  
  private static var audioDirectory: URL {
    userDirectory.appendingPathComponent(audioDirectoryName)
  }
  
  private static var imageDirectory: URL {
    userDirectory.appendingPathComponent(imageDirectoryName)
  }
}

// MARK: - Getters

extension FilesManager {
  
  static func urlFor(audioFile: String, isBundledResource: Bool) -> URL {
    if isBundledResource {
      return Bundle.main.url(forResource: audioFile, withExtension: ".wav")!
    } else {
      return audioDirectory.appendingPathComponent(audioFile + ".wav")
    }
  }
  
  static func urlFor(imageFile: String) -> URL {
    imageDirectory.appendingPathComponent(imageFile + ".png")
  }
}

// MARK: - Directory Creation & Listing

extension FilesManager {
  
  static func createAppDirectories() {
    createDirectory(at: documentsDirectory.appendingPathComponent(userDirectoryName).path) { }
    createDirectory(at: audioDirectory.path) { }
    createDirectory(at: imageDirectory.path) { }
  }
  
  private static func createDirectory(at path: String, _ didComplete: @escaping ( ()->() )) {
 
    do {
      if !fileManager.fileExists(atPath: path) {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        didComplete()
      }
    } catch {
      didComplete()
    }
  }
}

enum FileWriteError: Error {
  case unableToWriteFile, fileExists, invalidAssetURL
}

// MARK: - Asset Writing

extension FilesManager {
  
  static func write(asset: CKAsset, entitled title: String, of type: FileType) async throws {
    
    var baseLocation: URL
    
    switch type {
    case .audio:
      baseLocation = audioDirectory
    case .image:
      baseLocation = imageDirectory
    }
  
    guard let assetURL = asset.fileURL else {
      throw FileWriteError.invalidAssetURL
    }
    
    let writableLocation =  baseLocation.appendingPathComponent(title + type.suffix)
    
    guard !fileManager.fileExists(atPath: writableLocation.path) else {
      throw FileWriteError.fileExists
    }
  
    do {
      let writeableFile = try Data(contentsOf:  assetURL)
      try? writeableFile.write(to: baseLocation.appendingPathComponent(title + type.suffix), options: .atomic)
    } catch {
      throw FileWriteError.unableToWriteFile
    }
  }
}

// MARK: - Debugging

extension FilesManager {
  
  static func listAllData(of type: FileType) {
    
    var baseLocation: URL
    
    switch type {
    case .audio:
      baseLocation = audioDirectory
    case .image:
      baseLocation = imageDirectory
    }
    
    do {
      if let files = try? fileManager.contentsOfDirectory(atPath: baseLocation.path) {
        for file in files {
          print("Saved File", file)
        }
      }
    }
  }
}
