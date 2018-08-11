//
//  CustomStringConvertable.swift
//  PhotoWall
//
//  Created by Colin Harris on 11/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

extension CustomStringConvertible {
    var description : String {
        var description = "***** \(type(of: self)) *****\n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }
        return description
    }
}
