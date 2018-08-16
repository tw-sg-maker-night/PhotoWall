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

class LoadingController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        RemoteStore().downloadAssets()?.continueOnSuccessWith(executor: AWSExecutor.mainThread()) { task in
            self.performSegue(withIdentifier: "ShowAR", sender: self)
        }
    }
    
}
