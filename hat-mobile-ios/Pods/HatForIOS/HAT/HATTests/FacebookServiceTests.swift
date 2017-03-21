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
import Alamofire
import Mockingjay
import SwiftyJSON

class FacebookServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsFacebookDataPlugActive() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body: Dictionary<String, Any> = ["canPost" : "true"]
        let userDomain = "mariostsekis.hubofallthings.net"
        let urlToConnect = Facebook.statusURL
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        
        let expectationTest = expectation(description: "Checking facebook hat hat...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion(result: Bool) {
            
            XCTAssertTrue(result)
            expectationTest.fulfill()
        }
        
        func failed(error: FacebookError) {
            
        }
        
        FacebookService.isFacebookDataPlugActive(token: token, successful: completion, failed: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRemoveDuplicatesFromObjects() {
        
        let obj1 = FacebookSocialFeedObject()
        let obj2 = FacebookSocialFeedObject()
        
        var array = [obj1, obj2]
        
        array = FacebookService.removeDuplicatesFrom(array: array)
        
        XCTAssertTrue(array.count == 1)
    }
    
    func testRemoveDuplicatesFromJSON() {
        
        let obj1: JSON = [
            "name" : "default_Sun Jan 08 2017 21:21:26 GMT+0000 (UTC)",
            "data" : [
                "posts" : [
                    "id" : "10208854387451137_10209321243402244",
                    "created_time" : "2017-01-08T20:31:59+0000",
                    "full_picture" : "https://scontent.xx.fbcdn.net/v/t1.0-9/s720x720/15894983_10209321242442220_342243781888644727_n.jpg?oh=b90d598e80b1386cd92eb29b63990384&oe=58DA38A3",
                    "link" : "https://www.facebook.com/photo.php?fbid=10209321242442220&set=a.1908663150443.2108294.1057751927&type=3",
                    "from" : [
                        "id" : "10208854387451137",
                        "name" : "Marios Tsekis"
                    ],
                    "picture" : "https://scontent.xx.fbcdn.net/v/t1.0-0/s130x130/15894983_10209321242442220_342243781888644727_n.jpg?oh=80d63b5741590e1c22cb74fc9f07db47&oe=58E779B6",
                    "type" : "photo",
                    "updated_time" : "2017-01-08T20:31:59+0000",
                    "status_type" : "added_photos",
                    "story" : "Marios Tsekis added 2 new photos — with Lia Tseki and 6 others at Little Archies Reichenbach.",
                    "object_id" : "10209321242442220",
                    "privacy" : [
                        "friends" : "",
                        "value" : "ALL_FRIENDS",
                        "deny" : "",
                        "description" : "Your friends",
                        "allow" : ""
                    ],
                    "name" : "Photos from Marios Tsekis's post"
                ]
            ],
            "id" : 7771,
            "lastUpdated" : "2017-01-08T21:21:26.184Z"
        ]
        let obj2: JSON = [
            "name" : "default_Sun Jan 08 2017 21:21:26 GMT+0000 (UTC)",
            "data" : [
                "posts" : [
                    "id" : "10208854387451137_10209321243402244",
                    "created_time" : "2017-01-08T20:31:59+0000",
                    "full_picture" : "https://scontent.xx.fbcdn.net/v/t1.0-9/s720x720/15894983_10209321242442220_342243781888644727_n.jpg?oh=b90d598e80b1386cd92eb29b63990384&oe=58DA38A3",
                    "link" : "https://www.facebook.com/photo.php?fbid=10209321242442220&set=a.1908663150443.2108294.1057751927&type=3",
                    "from" : [
                        "id" : "10208854387451137",
                        "name" : "Marios Tsekis"
                    ],
                    "picture" : "https://scontent.xx.fbcdn.net/v/t1.0-0/s130x130/15894983_10209321242442220_342243781888644727_n.jpg?oh=80d63b5741590e1c22cb74fc9f07db47&oe=58E779B6",
                    "type" : "photo",
                    "updated_time" : "2017-01-08T20:31:59+0000",
                    "status_type" : "added_photos",
                    "story" : "Marios Tsekis added 2 new photos — with Lia Tseki and 6 others at Little Archies Reichenbach.",
                    "object_id" : "10209321242442220",
                    "privacy" : [
                        "friends" : "",
                        "value" : "ALL_FRIENDS",
                        "deny" : "",
                        "description" : "Your friends",
                        "allow" : ""
                    ],
                    "name" : "Photos from Marios Tsekis's post"
                ]
            ],
            "id" : 7771,
            "lastUpdated" : "2017-01-08T21:21:26.184Z"
        ]
        
        let array = [obj1, obj2]
        
        let result = FacebookService.removeDuplicatesFrom(array: array)
        
        XCTAssertTrue(result.count == 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
