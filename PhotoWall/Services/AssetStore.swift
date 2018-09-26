//
//  AssetStore.swift
//  PhotoWall
//
//  Created by Colin Harris on 26/9/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3

class AssetStore {
    
    let groupId: String
    let localAssetStore: LocalAssetStore
    let remoteAssetStore: RemoteAssetStore
    
    init(groupId: String) {
        self.groupId = groupId
        self.localAssetStore = WallAssetStore(groupId: groupId)
        self.remoteAssetStore = S3AssetStore(groupId: groupId, localAssetStore: localAssetStore)
    }
}

extension AssetStore: LocalAssetStore {
    func loadAssets() -> [WallAsset] {
        return localAssetStore.loadAssets()
    }
    
    func createAssetDir(name: String) {
        localAssetStore.createAssetDir(name: name)
    }
    
    func storeImage(_ image: UIImage, for name: String) {
        localAssetStore.storeImage(image, for: name)
    }
    
    func storeVideo(_ url: URL, for name: String) {
        localAssetStore.storeVideo(url, for: name)
    }
    
    func delete(asset: WallAsset) {
        localAssetStore.delete(asset: asset)
    }
    
    func loadOrCreateManifest(for name: String) -> WallAssetManifest? {
        return localAssetStore.loadOrCreateManifest(for: name)
    }
    
    func loadManifest(for name: String) -> WallAssetManifest? {
        return localAssetStore.loadManifest(for: name)
    }
    
    func manifestUrl(for name: String) -> URL {
        return localAssetStore.manifestUrl(for: name)
    }
    
    func fileUrl(fileName: String, for name: String) -> URL {
        return localAssetStore.fileUrl(fileName: fileName, for: name)
    }
    
    func assetFolder(for name: String) -> URL {
        return localAssetStore.assetFolder(for: name)
    }
    
    func fileExists(_ fileName: String, for name: String) -> Bool {
        return localAssetStore.fileExists(fileName, for: name)
    }
}
    
extension AssetStore: RemoteAssetStore {
    func downloadAssets() -> AWSTask<AnyObject>? {
        return remoteAssetStore.downloadAssets()
    }
    
    func getAssetNames() -> AWSTask<AnyObject>? {
        return remoteAssetStore.getAssetNames()
    }
    
    func downloadManifest(for name: String) -> AWSTask<AnyObject> {
        return remoteAssetStore.downloadManifest(for: name)
    }
    
    func downloadAsset(fileName: String, for name: String) -> AWSTask<AnyObject> {
        return remoteAssetStore.downloadAsset(fileName: fileName, for: name)
    }
    
    func getAssetFileNames(for name: String) -> AWSTask<AnyObject>? {
        return remoteAssetStore.getAssetFileNames(for: name)
    }
    
    func uploadAsset(asset: WallAsset) -> AWSTask<AnyObject> {
        return remoteAssetStore.uploadAsset(asset: asset)
    }
    
    func deleteAsset(asset: WallAsset) -> AWSTask<AWSS3DeleteObjectsOutput> {
        return remoteAssetStore.deleteAsset(asset: asset)
    }
    
    func assetExists(asset: WallAsset) -> AWSTask<AWSS3HeadObjectOutput> {
        return remoteAssetStore.assetExists(asset: asset)
    }
}
