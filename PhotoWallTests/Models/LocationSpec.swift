
//
//  LocationSpec.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Quick
import Nimble
@testable import PhotoWall

class LocationSpec: QuickSpec {
    override func spec() {
        
        describe("decoding") {
            it("can be decoded from valid json") {
                let jsonString = "{ \"country\": \"Australia\", \"office\": \"Melbourne\", \"officeImageUrl\": \"http://www.example.com/image.png\" }"
                
                let jsonData = jsonString.data(using: .utf8)!
                let decoder = BaseService.decoder()
                let location = try! decoder.decode(Location.self, from: jsonData)
                
                expect(location.country).to(equal("Australia"))
                expect(location.office).to(equal("Melbourne"))
                expect(location.officeImageUrl!.absoluteString).to(equal("http://www.example.com/image.png"))
            }
            
            it("can be decoded from json without an officeImageUrl") {
                let jsonString = "{ \"country\": \"Australia\", \"office\": \"Melbourne\", \"officeImageUrl\": null }"
                
                let jsonData = jsonString.data(using: .utf8)!
                let decoder = BaseService.decoder()
                let location = try! decoder.decode(Location.self, from: jsonData)
                
                expect(location.country).to(equal("Australia"))
                expect(location.office).to(equal("Melbourne"))
                expect(location.officeImageUrl).to(beNil())
            }
        }
        
    }
}
