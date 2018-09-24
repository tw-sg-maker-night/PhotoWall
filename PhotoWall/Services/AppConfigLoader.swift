//
//  AppConfigLoader.swift
//  PhotoWall
//
//  Created by Colin Harris on 16/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

class AppConfigLoader {
    
    private var configDictionary: [String: Any]?
    private var secretsDictionary: [String: Any]?
    
    init() {
        self.configDictionary = Bundle.main.infoDictionary?["AppConfig"] as? [String: Any]
        self.secretsDictionary = loadSecrets()
    }
    
    func load() -> AppConfig {
        return AppConfig(
            awsAccessKey: getKey("AWSAccessKey")!,
            awsSecretKey: getKey("AWSSecretKey")!,
            bucketName: getKey("BucketName")!
        )
    }
    
    private func getKey<T>(_ key: String) -> T? {
        if let value = configDictionary?[key] as? T {
            return value
        }
        if let value = secretsDictionary?[key] as? T {
            return value
        }
        return nil
    }
    
    private func loadSecrets() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? [String: Any]
        }
        return nil
    }
}
