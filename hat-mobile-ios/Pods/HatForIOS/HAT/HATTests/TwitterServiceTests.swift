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

class TwitterServiceTests: XCTestCase {
    
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
        let urlToConnect = Twitter.statusURL
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        
        let expectationTest = expectation(description: "Checking twitter dataplug status...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion(result: Bool) {
            
            XCTAssertTrue(result)
            expectationTest.fulfill()
        }
        
        func failed(error: TwitterError) {
            
        }
        
        TwitterService.isTwitterDataPlugActive(token: token, successful: completion, failed: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRemoveDuplicatesFromObjects() {
        
        let obj1 = TwitterSocialFeedObject()
        let obj2 = TwitterSocialFeedObject()
        
        var array = [obj1, obj2]
        
        array = TwitterService.removeDuplicatesFrom(array: array)
        
        XCTAssertTrue(array.count == 1)
    }
    
    func testRemoveDuplicatesFromJSON() {
        
        let obj1: JSON = [
            "name" : "823256327329816577",
            "data" : [
                "tweets" : [
                    "source" : "https://hubofallthings.com/rel=nofollow",
                    "truncated" : "false",
                    "retweet_count" : "0",
                    "retweeted" : "false",
                    "favorite_count" : "0",
                    "id" : "823256327329816577",
                    "text" : "Twitter test",
                    "created_at" : "Sun Jan 22 19:49:38 +0000 2017",
                    "favorited" : "false",
                    "lang" : "en",
                    "user" : [
                        "friends_count" : "521",
                        "id" : "343997370",
                        "lang" : "en",
                        "listed_count" : "9",
                        "favourites_count" : "805",
                        "statuses_count" : "2192",
                        "screen_name" : "marios4th",
                        "name" : "Tsekis Marios",
                        "followers_count" : "196"
                    ]
                ]
            ],
            "id" : 11534,
            "lastUpdated" : "2017-01-22T19:49:38.000Z"
        ]
        let obj2: JSON = [
            "name" : "823256327329816577",
            "data" : [
                "tweets" : [
                    "source" : "https://hubofallthings.com/rel=nofollow",
                    "truncated" : "false",
                    "retweet_count" : "0",
                    "retweeted" : "false",
                    "favorite_count" : "0",
                    "id" : "823256327329816577",
                    "text" : "Twitter test",
                    "created_at" : "Sun Jan 22 19:49:38 +0000 2017",
                    "favorited" : "false",
                    "lang" : "en",
                    "user" : [
                        "friends_count" : "521",
                        "id" : "343997370",
                        "lang" : "en",
                        "listed_count" : "9",
                        "favourites_count" : "805",
                        "statuses_count" : "2192",
                        "screen_name" : "marios4th",
                        "name" : "Tsekis Marios",
                        "followers_count" : "196"
                    ]
                ]
            ],
            "id" : 11534,
            "lastUpdated" : "2017-01-22T19:49:38.000Z"
        ]
        
        let array = [obj1, obj2]
        
        let result = TwitterService.removeDuplicatesFrom(array: array)
        
        XCTAssertTrue(result.count == 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
