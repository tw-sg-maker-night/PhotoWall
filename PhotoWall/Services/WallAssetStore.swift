//
//  FileStore.swift
//  PhotoWall
//
//  Created by Colin Harris on 9/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

class WallAssetStore {
    
    let fileManager: FileManager
    let documentsUrl: URL
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        self.documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func setupInitial() {
        guard let existing = try? fileManager.contentsOfDirectory(atPath: self.documentsUrl.path), existing.count == 0 else {
            return
        }
        
        do {
            try copyFilesFor(name: "Cory")
            try copyFilesFor(name: "Angie")
        } catch {
            print("Failed to initialize the AR content. \(error.localizedDescription)")
        }
    }
    
    func loadAssets() -> [WallAsset] {
        print("loadAssets")
        let folders = try! fileManager.contentsOfDirectory(atPath: self.documentsUrl.path)
        print("folders = \(folders.count)")
        return folders.map { folder in
            loadWallAsset(from: self.documentsUrl.appendingPathComponent(folder))
        }.compactMap { $0 }
    }
    
    private func copyFilesFor(name: String) throws {
        let baseDir = documentsUrl.appendingPathComponent(name)
        try fileManager.createDirectory(at: baseDir, withIntermediateDirectories: false, attributes: nil)
        
        let imageUrl = Bundle.main.url(forResource: name, withExtension: "png")!
        let newImageUrl = baseDir.appendingPathComponent("\(name).png")
        try fileManager.copyItem(at: imageUrl, to: newImageUrl)
        
        let videoUrl = Bundle.main.url(forResource: name, withExtension: "m4v")!
        let newVideoUrl = baseDir.appendingPathComponent("\(name).m4v")
        try fileManager.copyItem(at: videoUrl, to: newVideoUrl)
        
        let manifest = WallAssetManifest(imageFileName: imageUrl.lastPathComponent, videoFileName: videoUrl.lastPathComponent, imageWidth: 0.17)
        let manifestData = try? JSONEncoder().encode(manifest)
        let newManifestUrl = baseDir.appendingPathComponent("manifest.json")
        try manifestData?.write(to: newManifestUrl)
    }
    
    private func loadWallAsset(from url: URL) -> WallAsset? {
        print("loadWallAsset(from: \(url.absoluteString))")
        let manifestUrl = url.appendingPathComponent("manifest.json")
        guard fileManager.fileExists(atPath: manifestUrl.path),
            let manifest = loadManifest(from: manifestUrl) else {
                print("Manifest not found at: \(manifestUrl.absoluteString)")
                return nil
        }
        
        return WallAsset(
            identifier: url.lastPathComponent,
            imageUrl: url.appendingPathComponent(manifest.imageFileName),
            videoUrl: url.appendingPathComponent(manifest.videoFileName),
            width: manifest.imageWidth
        )
    }
    
    private func loadManifest(from url: URL) -> WallAssetManifest? {
        return try? JSONDecoder().decode(WallAssetManifest.self, from: Data(contentsOf: url))
    }
}
