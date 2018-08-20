//
//  RemoteStore.swift
//  PhotoWall
//
//  Created by Colin Harris on 11/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import AWSS3

class RemoteStore {

    let transferManager: AWSS3TransferManager
    let s3: AWSS3
    let assetStore: WallAssetStore
    let groupId: String

    init(groupId: String = "Singapore", assetStore: WallAssetStore = WallAssetStore(), appConfig: AppConfig = AppConfigLoader().load()) {
        let credentials = AWSStaticCredentialsProvider(accessKey: appConfig.awsAccessKey, secretKey: appConfig.awsSecretKey)
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: credentials)
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
        self.s3 = AWSS3.default()
        self.transferManager = AWSS3TransferManager.default()
        self.assetStore = assetStore
        self.groupId = groupId
    }

    func downloadAssets() -> AWSTask<AnyObject>? {
        return getAssetNames()!.continueOnSuccessWith { task in
            guard let assetNames = task.result as? [String] else {
                print("Unknown response type")
                return nil
            }

            let tasks: [AWSTask<AnyObject>] = assetNames.map { assetName in
                self.assetStore.createAssetDir(name: assetName)
                return self.downloadManifest(for: assetName).continueOnSuccessWith { task -> AWSTask<AnyObject>? in
                    print("Downloaded manifest file")
                    if let assetManifest = self.assetStore.loadManifest(for: assetName) {
                        let imageTask = self.downloadAsset(fileName: assetManifest.imageFileName, for: assetName)
                        let videoTask = self.downloadAsset(fileName: assetManifest.videoFileName, for: assetName)
                        return AWSTask(forCompletionOfAllTasks: [imageTask, videoTask])
                    }
                    return nil
                }
            }
            return AWSTask(forCompletionOfAllTasks: tasks).continueOnSuccessWith { (task: AWSTask<AnyObject>) -> AWSTask<AnyObject>? in
                print("All done!")
                return nil
            }
        }
    }

    func getAssetNames() -> AWSTask<AnyObject>? {
        if let request = AWSS3ListObjectsV2Request() {
            request.bucket = "photo-wall-assets"
            request.prefix = "\(groupId)/"
            request.delimiter = "/"
            return s3.listObjectsV2(request).continueWith { task in
                guard let result = task.result, task.error == nil else {
                    print("Error: \(task.error!.localizedDescription)")
                    return nil
                }
                let prefixes: [String] = result.commonPrefixes!.map { object in
                    if let prefix = object.prefix {
                        return prefix.replacingOccurrences(of: "\(self.groupId)/", with: "").replacingOccurrences(of: "/", with: "")
                    }
                    return nil
                }.compactMap { $0 }
                return AWSTask(result: NSArray(array: prefixes))
            }
        }
        return nil
    }

    func downloadManifest(for name: String) -> AWSTask<AnyObject> {
        let request = AWSS3TransferManagerDownloadRequest()!
        request.bucket = "photo-wall-assets"
        request.key = "\(groupId)/\(name)/manifest.json"
        request.downloadingFileURL = assetStore.manifestUrl(for: name)
        return self.transferManager.download(request)
    }

    func downloadAsset(fileName: String, for name: String) -> AWSTask<AnyObject> {
        guard !assetStore.fileExists(fileName, for: name) else {
            return AWSTask(result: nil)
        }
        let request = AWSS3TransferManagerDownloadRequest()!
        request.bucket = "photo-wall-assets"
        request.key = "\(groupId)/\(name)/\(fileName)"
        request.downloadingFileURL = assetStore.fileUrl(fileName: fileName, for: name)
        return self.transferManager.download(request)
    }
}
