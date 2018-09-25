//
//  LoadingController.swift
//  PhotoWall
//
//  Created by Colin Harris on 15/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import AWSCore

protocol LoadingDelegate: class {
    func didFinishLoadingLocation(_ location: Location)
}

class LoadingController: UIViewController {
    
    var location: Location?
    weak var delegate: LoadingDelegate?
    @IBOutlet var loadingLabel: UILabel!
    
    class func new(location: Location, delegate: LoadingDelegate) -> LoadingController {
        let controller = LoadingController(nibName: "Loading", bundle: nil)
        controller.delegate = delegate
        controller.location = location
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingLabel.text = "Loading \(location!.office) photos..."
        loadingLabel.setNeedsLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let location = location {
            RemoteStore(groupId: location.office).downloadAssets()?.continueOnSuccessWith(executor: AWSExecutor.mainThread()) { task in
                self.delegate?.didFinishLoadingLocation(location)
            }
        }
    }
    
}
