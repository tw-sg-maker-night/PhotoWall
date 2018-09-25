//
//  Country.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

public struct Country: Codable {
    public let country: String
    public let offices: [Location]
}
