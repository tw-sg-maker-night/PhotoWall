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
    
    init(groupId: String = "Singapore", assetStore: WallAssetStore) {
        let credentials = AWSStaticCredentialsProvider(accessKey: "***REMOVED***", secretKey: "***REMOVED***")
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: credentials)
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
        self.s3 = AWSS3.default()
        self.transferManager = AWSS3TransferManager.default()
        self.assetStore = assetStore
        self.groupId = groupId
    }

    func downloadManifests() {
        getAssetNames { assetNames in
            let _: [AWSTask<AnyObject>] = assetNames.map { assetName in
                self.assetStore.createAssetDir(name: assetName)
                return self.downloadManifest(for: assetName)
            }
            // TODO: monitor downloads, then parse manifest file(s) and download resources specified in manifest.
        }
    }
    
    func getAssetNames(block: @escaping ([String]) -> Void) {
        if let request = AWSS3ListObjectsV2Request() {
            request.bucket = "photo-wall-assets"
            request.prefix = "\(groupId)/"
            request.delimiter = "/"
            s3.listObjectsV2(request) { output, error in
                guard let output = output, error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    block([])
                    return
                }
                let prefixes: [String] = output.commonPrefixes!.map { object in
                    if let prefix = object.prefix {
                        return prefix.replacingOccurrences(of: "\(self.groupId)/", with: "").replacingOccurrences(of: "/", with: "")
                    }
                    return nil
                }.compactMap { $0 }
                block(prefixes)
            }
        }
    }
    
    func downloadManifest(for name: String) -> AWSTask<AnyObject> {
        let request = AWSS3TransferManagerDownloadRequest()!
        request.bucket = "photo-wall-assets"
        request.key = "\(groupId)/\(name)/manifest.json"
        request.downloadingFileURL = assetStore.manifestUrl(for: name)
        let task = self.transferManager.download(request)
        task.continueWith(executor: AWSExecutor.mainThread()) { response in
            print("finished download")
            return nil
        }
        return task
    }
}
