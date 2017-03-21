/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import XCTest
import Mockingjay
import Alamofire

class LocationServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWriteToCloud() {
        
        let body = ["message" : ""]
        let urlToConnect = "https://marketsquare.hubofallthings.com/api/dataplugs/c532e122-db4a-44b8-9eaf-18989f214262/connect?hat=mariostsekis.hubofallthings.net"
        let userDomain = "mariostsekis.hubofallthings.net"
        let expectationTest = expectation(description: "Authorized...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion(result: Bool) {
            
            XCTAssert(result)
            expectationTest.fulfill()
        }
        
        func failed(error: JSONParsingError) {
            

        }
        
        LocationService.enableLocationDataPlug(userDomain, userDomain, success: completion, failed: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testFormatOfURLDuringRegistration() {
        
        let url = "https://marketsquare.hubofallthings.com/api/dataplugs/c532e122-db4a-44b8-9eaf-18989f214262/connect?hat=mariostsekis.hubofallthings.net"
        let userDomain = "mariostsekis.hubofallthings.net"
        
        let formattedURL = LocationService.locationDataPlugURL(userDomain, dataPlugID: HATDataPlugCredentials.Market_DataPlugID)
        
        XCTAssert(url == formattedURL)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
