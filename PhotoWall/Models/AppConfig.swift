//
//  AppConfig.swift
//  PhotoWall
//
//  Created by Colin Harris on 16/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

struct AppConfig {
    let awsAccessKey: String
    let awsSecretKey: String
    let bucketName: String
    
    let googleClientId: String
    let googleScopes: [String]
    let googleWebClientId: String
    let googleWebClientSecret: String
    
    let baseUrl: URL
    
    let hockeyAppIdentifier: String
}
