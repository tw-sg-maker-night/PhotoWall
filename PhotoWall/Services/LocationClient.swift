//
//  LocationClient.swift
//
//  Created by Colin Harris on 11/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

public class LocationClient: BaseService {
        
}

extension LocationClient: LocationService {
    
    public func fetchAllLocations() -> Promise<[Country]> {
        return get(path: "/api/locations")
    }
    
    public func getCurrentLocation() -> Promise<Location> {
        print("Lookup location via IP")
        return firstly {
            self.getLocationFromIP()
        }.recover { (error: Error) -> Promise<Location> in
            print("Lookup location via GPS")
            return self.getLocationFromGPS()
        }.recover { (error: Error) -> Promise<Location> in
            print("Lookup default home location")
            if let defaultLocation = self.getHomeLocation() {
                return Promise.value(defaultLocation)
            }
            throw LocationError.defaultLocationNotSet
        }
    }
    
    var sharedUserDefaults: UserDefaults {
        return UserDefaults(suiteName: "group.com.thoughtworks.ARPhotoWall")!
    }
    
    public func getHomeLocation() -> Location? {
        if let data = sharedUserDefaults.data(forKey: Constants.UserDefaults.HomeLocationKey) {
            return try? BaseService.decoder().decode(Location.self, from: data)
        }
        return nil
    }
    
    public func setHomeLocation(_ location: Location) {
        if let data = try? BaseService.encoder().encode(location) {
            sharedUserDefaults.set(data, forKey: Constants.UserDefaults.HomeLocationKey)
        } else {
            print("Failed to encode location")
        }
    }
    
    public func clearHomeLocation() {
        sharedUserDefaults.set(nil, forKey: Constants.UserDefaults.HomeLocationKey)
    }
    
    public func getLocationFromIP() -> Promise<Location> {
        return post(path: "/api/location_from_ip_address")
    }
    
    public func getLocationFromGPS() -> Promise<Location> {
        return firstly {
            getCoreLocation()
        }.then { (coreLocation: CLLocation) in
            self.getLocationFromCoordinate(coordinate: coreLocation.coordinate)
        }.map { location -> Location in
            if location == nil {
                throw LocationError.gpsLocationFailed
            }
            return location!
        }
    }
    
    func getCoreLocation() -> Promise<CLLocation> {
        return firstly {
            return CLLocationManager.requestLocation(authorizationType: .whenInUse)
        }.firstValue
    }
    
    func getLocationFromCoordinate(coordinate: CLLocationCoordinate2D) -> Promise<Location?> {
        return post(
            path: "/api/location_from_coordinates",
            params: [
                "lat": coordinate.latitude,
                "long": coordinate.longitude
            ]
        )
    }
}
