//
//  WallAssetManifest.swift
//  PhotoWall
//
//  Created by Colin Harris on 10/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

struct WallAssetManifest: Codable, CustomStringConvertible {
    var imageFileName: String
    var videoFileName: String
    var imageWidth: Float
    
    init() {
        self.imageFileName = ""
        self.videoFileName = ""
        self.imageWidth = 0.15
    }
    
    init(imageFileName: String, videoFileName: String, imageWidth: Float) {
        self.imageFileName = imageFileName
        self.videoFileName = videoFileName
        self.imageWidth = 0.15
    }
    
    mutating func setImageFileName(fileName: String) {
        self.imageFileName = fileName
    }
    
    mutating func setVideoFileName(fileName: String) {
        self.videoFileName = fileName
    }
}
