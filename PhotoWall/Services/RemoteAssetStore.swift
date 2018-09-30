//
//  RemoteStore.swift
//  PhotoWall
//
//  Created by Colin Harris on 11/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import AWSS3

protocol RemoteAssetStore {
    var groupId: String { get }
    //TODO: Need to review all these public methdos consolidate
    func downloadAssets() -> AWSTask<AnyObject>?
    func getAssetNames() -> AWSTask<AnyObject>?
    func downloadManifest(for name: String) -> AWSTask<AnyObject>
    func downloadAsset(fileName: String, for name: String) -> AWSTask<AnyObject>
    func getAssetFileNames(for name: String) -> AWSTask<AnyObject>?
    func uploadAsset(asset: WallAsset) -> AWSTask<AnyObject>
    func deleteAsset(asset: WallAsset) -> AWSTask<AWSS3DeleteObjectsOutput>
    func assetExists(asset: WallAsset) -> AWSTask<AWSS3HeadObjectOutput>
    func createGroupFolder() -> AWSTask<AWSS3PutObjectOutput>?
}

class S3AssetStore: RemoteAssetStore {

    let transferManager: AWSS3TransferManager
    let s3: AWSS3
    let localAssetStore: LocalAssetStore
    let groupId: String
    let bucket: String

    init(groupId: String = "Singapore", localAssetStore: LocalAssetStore = WallAssetStore(), appConfig: AppConfig = AppConfigLoader().load()) {
        let credentials = AWSStaticCredentialsProvider(accessKey: appConfig.awsAccessKey, secretKey: appConfig.awsSecretKey)
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: credentials)
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
        self.s3 = AWSS3.default()
        self.transferManager = AWSS3TransferManager.default()
        self.localAssetStore = localAssetStore
        self.groupId = groupId
        self.bucket = appConfig.bucketName
    }

    func downloadAssets() -> AWSTask<AnyObject>? {
        return getAssetNames()!.continueOnSuccessWith { task in
            guard let assetNames = task.result as? [String] else {
                print("Unknown response type")
                return nil
            }

            let tasks: [AWSTask<AnyObject>] = assetNames.map { assetName in
                self.localAssetStore.createAssetDir(name: assetName)
                return self.downloadManifest(for: assetName).continueOnSuccessWith { task -> AWSTask<AnyObject>? in
                    print("Downloaded manifest file")
                    if let assetManifest = self.localAssetStore.loadManifest(for: assetName) {
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

    func createGroupFolder() -> AWSTask<AWSS3PutObjectOutput>? {
        if let request = AWSS3PutObjectRequest() {
            request.bucket = bucket
            request.key = groupId+"/"
            return s3.putObject(request)
        }
        return nil
    }
    
    func getAssetNames() -> AWSTask<AnyObject>? {
        if let request = AWSS3ListObjectsV2Request() {
            request.bucket = bucket
            request.prefix = groupId+"/"
            request.delimiter = "/"
            return s3.listObjectsV2(request).continueWith { task in
                guard let result = task.result, task.error == nil else {
                    print("Error: \(task.error!.localizedDescription)")
                    return nil
                }
                guard let commonPrefixes = result.commonPrefixes else {
                    return nil
                }
                let prefixes: [String] = commonPrefixes.map { object in
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
        request.bucket = bucket
        request.key = "\(groupId)/\(name)/manifest.json"
        request.downloadingFileURL = localAssetStore.manifestUrl(for: name)
        return self.transferManager.download(request)
    }

    func downloadAsset(fileName: String, for name: String) -> AWSTask<AnyObject> {
        guard !localAssetStore.fileExists(fileName, for: name) else {
            return AWSTask(result: nil)
        }
        let request = AWSS3TransferManagerDownloadRequest()!
        request.bucket = bucket
        request.key = "\(groupId)/\(name)/\(fileName)"
        request.downloadingFileURL = localAssetStore.fileUrl(fileName: fileName, for: name)
        return self.transferManager.download(request)
    }
    
    func getAssetFileNames(for name: String) -> AWSTask<AnyObject>? {
        let prefix = "\(groupId)/\(name)/"
        if let request = AWSS3ListObjectsV2Request() {
            request.bucket = bucket
            request.prefix = prefix
            request.delimiter = "/"
            return s3.listObjectsV2(request).continueWith { task in
                guard let result = task.result, task.error == nil else {
                    print("Error: \(task.error!.localizedDescription)")
                    return nil
                }
                var keys = [String]()
                if let contents = result.contents {
                    keys = contents.map { object in
                        if var key = object.key {
                            key = key.replacingOccurrences(of: prefix, with: "")
                            if key != "" || key != "manifest.json" {
                                return key
                            }
                        }
                        return nil
                    }.compactMap { $0 }
                    print("keys: \(keys)")
                }
                
                return AWSTask(result: NSArray(array: keys))
            }
        }
        return nil
    }
    
    func uploadAsset(asset: WallAsset) -> AWSTask<AnyObject> {
        return getAssetFileNames(for: asset.identifier)!.continueOnSuccessWith { task in
            if let fileNames = task.result as? [String] {
                var tasks = [AWSTask<AnyObject>]()
                let urls = [asset.imageUrl, asset.videoUrl, self.localAssetStore.manifestUrl(for: asset.identifier)]
                for url in urls {
                    if !fileNames.contains(url.lastPathComponent) {
                        if let task = self.uploadFile(for: asset.identifier, withUrl: url) {
                            tasks.append(task)
                        }
                    }
                }
                return AWSTask(forCompletionOfAllTasks: tasks) as AWSTask<AnyObject>
            }
            return AWSTask(error: RemoteStoreError.genericError) as AWSTask<AnyObject>
        }
    }
    
    private func uploadFile(for identifier: String, withUrl url: URL) -> AWSTask<AnyObject>? {
        return uploadFile(for: identifier, withUrl: url, fileName: url.lastPathComponent)
    }
        
    private func uploadFile(for identifier: String, withUrl url: URL, fileName: String) -> AWSTask<AnyObject>? {
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.bucket = self.bucket
            uploadRequest.key = "\(self.groupId)/\(identifier)/\(fileName)"
            uploadRequest.body = url
            return transferManager.upload(uploadRequest)
        }
        return nil
    }
    
    func deleteAsset(asset: WallAsset) -> AWSTask<AWSS3DeleteObjectsOutput> {
        let request = AWSS3DeleteObjectsRequest()!
        request.bucket = self.bucket
        let toRemove = AWSS3Remove()!
        toRemove.objects = [
            awsIdentifierFor(key: "\(self.groupId)/\(asset.identifier)/\(asset.imageFileName)"),
            awsIdentifierFor(key: "\(self.groupId)/\(asset.identifier)/\(asset.videoFileName)"),
            awsIdentifierFor(key: "\(self.groupId)/\(asset.identifier)/manifest.json")
        ]
        request.remove = toRemove
        return self.s3.deleteObjects(request)
    }
    
    private func awsIdentifierFor(key: String) -> AWSS3ObjectIdentifier {
        let identifier = AWSS3ObjectIdentifier()!
        identifier.key = key
        return identifier
    }
    
    func assetExists(asset: WallAsset) -> AWSTask<AWSS3HeadObjectOutput> {
        let request = AWSS3HeadObjectRequest()!
        request.bucket = self.bucket
        request.key = "\(self.groupId)/\(asset.identifier)/manifest.json"
        return self.s3.headObject(request)
    }
}

enum RemoteStoreError: Error {
    case genericError
}
