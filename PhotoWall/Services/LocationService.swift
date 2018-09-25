//
//  LocationService.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import PromiseKit

public enum LocationError: String, Error {
    case gpsLocationFailed
    case ipLocationFailed
    case defaultLocationNotSet
    case officeImageNotFound
}

public protocol LocationService {
    func fetchAllLocations() -> Promise<[Country]>
    func getCurrentLocation() -> Promise<Location>
    
    func getHomeLocation() -> Location?
    func setHomeLocation(_ location: Location)
    func clearHomeLocation()
    
    func getLocationFromIP() -> Promise<Location>
    func getLocationFromGPS() -> Promise<Location>
}
