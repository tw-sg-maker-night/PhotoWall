//
//  LocationDataSource.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class LocationDataSource: NSObject {
    
    let locationService: LocationService
    var countries: [Country] = []
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func load() -> Promise<Void> {
        return firstly {
            locationService.fetchAllLocations()
        }.done { countries in
            self.countries = countries
        }
    }
    
    func location(for indexPath: IndexPath) -> Location {
        return countries[indexPath.section].offices[indexPath.row]
    }
}

extension LocationDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries[section].offices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        let location = self.location(for: indexPath)
        cell.textLabel?.text = location.office
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countries[section].country
    }
}
