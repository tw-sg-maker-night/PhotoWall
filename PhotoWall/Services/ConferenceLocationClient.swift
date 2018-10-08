//
//  ConferenceLocationClient.swift
//  PhotoWall
//
//  Created by Colin Harris on 10/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import PromiseKit

class ConferenceLocationClient {
    
    let country: Country
    let location: Location
    
    init(country: String, office: String) {
        self.location = Location(country: country, office: office)
        self.country = Country(country: country, offices: [location])
    }
}

extension ConferenceLocationClient: LocationService {
    
    func fetchAllLocations() -> Promise<[Country]> {
        return Promise.value([country])
    }
    
    func getCurrentLocation() -> Promise<Location> {
        return Promise.value(location)
    }
    
    func getHomeLocation() -> Location? {
        return location
    }
    
    func setHomeLocation(_ location: Location) {
        // no nothing
    }
    
    func clearHomeLocation() {
        // do nothing
    }
    
    func getLocationFromIP() -> Promise<Location> {
        return Promise.value(location)
    }
    
    func getLocationFromGPS() -> Promise<Location> {
        return Promise.value(location)
    }    
}
