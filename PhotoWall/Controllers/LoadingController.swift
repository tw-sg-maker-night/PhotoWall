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
    func didFinishLoading(assetStore: AssetStore)
}

class LoadingController: UIViewController {
    
    var assetStore: AssetStore!
    weak var delegate: LoadingDelegate?
    
    @IBOutlet var loadingLabel: UILabel!
    
    class func new(assetStore: AssetStore, delegate: LoadingDelegate) -> LoadingController {
        let controller = LoadingController(nibName: "Loading", bundle: nil)
        controller.delegate = delegate
        controller.assetStore = assetStore
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingLabel.text = "Loading \(assetStore.groupId) photos..."
        loadingLabel.setNeedsLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        assetStore.createGroupFolder()?.continueWith { task in
            self.assetStore.downloadAssets()?.continueOnSuccessWith(executor: AWSExecutor.mainThread()) { task in
                self.delegate?.didFinishLoading(assetStore: self.assetStore)
            }
        }
    }
    
}
