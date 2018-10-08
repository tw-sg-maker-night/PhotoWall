//
//  AppSettings.swift
//  PhotoWall
//
//  Created by Colin Harris on 10/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

protocol AppSettingsProtocol {
    func conferenceModeEnabled() -> Bool
    func setVersionAndBuildNumber()
}

class AppSettings: AppSettingsProtocol {
    
    private struct Keys {
        static let ConferenceModeKey = "conference_mode"
        static let AppVersionKey = "app_version"
        static let BuildNumberKey = "build_number"
    }
    
    func conferenceModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.ConferenceModeKey)
    }
    
    func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: Keys.AppVersionKey)
        
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: Keys.BuildNumberKey)
    }
}
