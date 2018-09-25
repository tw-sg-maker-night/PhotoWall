//
//  CountrySpec.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Quick
import Nimble
@testable import PhotoWall

class CountrySpec: QuickSpec {
    override func spec() {
        
        describe("decoding") {
            it("can be decoded from valid json") {
                let jsonString = """
                    {
                        \"country\": \"Australia\",
                        \"offices\": [
                            {
                                \"country\": \"Australia\",
                                \"office\": \"Melbourne\",
                                \"officeImageUrl\": \"http://www.example.com/image.png\"
                            }
                        ]
                    }
                """

                let jsonData = jsonString.data(using: .utf8)!
                let decoder = BaseService.decoder()
                let country = try! decoder.decode(Country.self, from: jsonData)
                
                expect(country.country).to(equal("Australia"))
                expect(country.offices.count).to(equal(1))
                let office = country.offices.first
                expect(office?.country).to(equal("Australia"))
                expect(office?.office).to(equal("Melbourne"))
                expect(office?.officeImageUrl?.absoluteString).to(equal("http://www.example.com/image.png"))
            }
        }
        
    }
}
