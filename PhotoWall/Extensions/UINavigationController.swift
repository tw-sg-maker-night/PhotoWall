//
//  UINavigationController.swift
//
//  Created by Colin Harris on 7/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    func controllerOfType<T: UIViewController>() -> T? {
        return viewControllers.first { controller in
            return (controller as? T) != nil
        } as? T
    }
}
