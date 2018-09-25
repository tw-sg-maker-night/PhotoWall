//
//  Location.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

public struct Location: Codable {
    public let country: String
    public let office: String
    public let officeImageUrl: URL?
    
    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.country = try map.decode(String.self, forKey: .country)
        self.office = try map.decode(String.self, forKey: .office)
        self.officeImageUrl = try? map.decode(URL.self, forKey: .officeImageUrl)
    }
    
    public init(country: String, office: String, imageUrl: URL? = nil) {
        self.country = country
        self.office = office
        self.officeImageUrl = imageUrl
    }
}
