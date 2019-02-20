//
//  AppSettings.swift
//  PhotoWall
//
//  Created by Colin Harris on 10/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

protocol AppSettingsProtocol {
    func eventModeEnabled() -> Bool
    func setVersionAndBuildNumber()
}

class AppSettings: AppSettingsProtocol {
    
    private struct Keys {
        static let AppVersionKey = "app_version"
        static let BuildNumberKey = "build_number"
        
        static let EventModeKey = "event_mode"
        static let EventCountryKey = "event_country"
        static let EventNameKey = "event_name"
    }
    
    func eventModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.EventModeKey)
    }
    
    func eventCountry() -> String? {
        return UserDefaults.standard.string(forKey: Keys.EventCountryKey)
    }
    
    func eventName() -> String? {
        return UserDefaults.standard.string(forKey: Keys.EventNameKey)
    }
    
    func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: Keys.AppVersionKey)
        
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: Keys.BuildNumberKey)
    }
}
