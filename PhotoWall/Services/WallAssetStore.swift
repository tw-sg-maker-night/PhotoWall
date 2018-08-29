//
//  FileStore.swift
//  PhotoWall
//
//  Created by Colin Harris on 9/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit

class WallAssetStore {
    
    let fileManager: FileManager
    let baseUrl: URL
    
    init(groupId: String = "Singapore", fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.baseUrl = documentsUrl.appendingPathComponent(groupId)
        if !fileManager.fileExists(atPath: baseUrl.path) {
            try? fileManager.createDirectory(at: baseUrl, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    func loadAssets() -> [WallAsset] {
        print("loadAssets")
        let folders = try! fileManager.contentsOfDirectory(atPath: baseUrl.path)
        print("folders = \(folders.count)")
        return folders.map { folder in
            loadWallAsset(from: baseUrl.appendingPathComponent(folder))
        }.compactMap { $0 }
    }
    
    func createAssetDir(name: String) {
        let assetDir = baseUrl.appendingPathComponent(name)
        try? fileManager.createDirectory(at: assetDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    func storeImage(_ image: UIImage, for name: String) {
        let newImageUrl = fileUrl(fileName: "\(UUID().uuidString).png", for: name)
        try? image.pngData()?.write(to: newImageUrl)
        if var manifest = loadOrCreateManifest(for: name) {
            manifest.setImageFileName(fileName: newImageUrl.lastPathComponent)
            saveManifest(manifest, for: name)
        }
    }
    
    func storeVideo(_ url: URL, for name: String) {
        let newVideoUrl = fileUrl(fileName: "\(UUID().uuidString).\(url.pathExtension)", for: name)
        try! fileManager.copyItem(at: url, to: newVideoUrl)
        if var manifest = loadOrCreateManifest(for: name) {
            manifest.setVideoFileName(fileName: newVideoUrl.lastPathComponent)
            saveManifest(manifest, for: name)
        }
    }
    
    func delete(asset: WallAsset) {
        try? fileManager.removeItem(at: asset.imageUrl)
        try? fileManager.removeItem(at: asset.videoUrl)
        try? fileManager.removeItem(at: self.manifestUrl(for: asset.identifier))
        try? fileManager.removeItem(at: self.assetFolder(for: asset.identifier))
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
    
    func loadOrCreateManifest(for name: String) -> WallAssetManifest? {
        var manifest = loadManifest(for: name)
        if manifest == nil {
            manifest = WallAssetManifest()
            saveManifest(WallAssetManifest(), for: name)
        }
        return manifest
    }
    
    func loadManifest(for name: String) -> WallAssetManifest? {
        let manifestUrl = baseUrl.appendingPathComponent("\(name)/manifest.json")
        return loadManifest(from: manifestUrl)
    }
    
    private func loadManifest(from url: URL) -> WallAssetManifest? {
        return try? JSONDecoder().decode(WallAssetManifest.self, from: Data(contentsOf: url))
    }
    
    private func saveManifest(_ manifest: WallAssetManifest, for name: String) {
        let manifestData = try? JSONEncoder().encode(manifest)
        print("Save manifest to: \(manifestUrl(for: name).absoluteString)")
        try? manifestData?.write(to: manifestUrl(for: name))
    }
    
    func manifestUrl(for name: String) -> URL {
        return baseUrl.appendingPathComponent("\(name)/manifest.json")
    }
    
    func fileUrl(fileName: String, for name: String) -> URL {
        return baseUrl.appendingPathComponent("\(name)/\(fileName)")
    }
    
    func assetFolder(for name: String) -> URL {
        return baseUrl.appendingPathComponent(name)
    }
    
    func fileExists(_ fileName: String, for name: String) -> Bool {
        let url = fileUrl(fileName: fileName, for: name)
        return fileManager.fileExists(atPath: url.path)
    }
}
