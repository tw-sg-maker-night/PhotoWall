//
//  LocationListController.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import PKHUD

protocol LocationListDelegate: class {
    func locationSelected(location: Location)
}

class LocationListController: UIViewController {
    
    weak var delegate: LocationListDelegate?
    var locationService: LocationService!
    var dataSource: LocationDataSource!
    
    var tableView: UITableView!
    
    class func new(locationService: LocationService, delegate: LocationListDelegate) -> LocationListController {
        let controller = LocationListController()
        controller.delegate = delegate
        controller.locationService = locationService
        controller.dataSource = LocationDataSource(locationService: locationService)
        return controller
    }
    
    override func loadView() {
        print("LocationListcontroller.loadView")
        super.loadView()
        self.tableView = UITableView()
        self.tableView.delegate = self
        self.tableView.dataSource = dataSource
        self.view.addSubview(self.tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0),
        ])
    }
    
    override func viewDidLoad() {
        print("LocationListcontroller.viewDidLoad")
        super.viewDidLoad()
        navigationItem.title = "Locations"
        navigationController?.isNavigationBarHidden = false
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.prompt = "Select your default location"
        loadData()
    }
    
    func loadData() {
        HUD.show(.labeledProgress(title: nil, subtitle: "Loading locations"))
        firstly {
            dataSource.load()
        }.done {
            HUD.hide()
            self.tableView.reloadData()
        }.catch { error in
            print("Failed to load locations", error)
            HUD.flash(.labeledError(title: "Error", subtitle: "Failed to load locations"), delay: 1.5)
        }
    }    
}

extension LocationListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let location = dataSource.location(for: indexPath)
        
        locationService.setHomeLocation(location)
        
        delegate?.locationSelected(location: location)
    }
}
