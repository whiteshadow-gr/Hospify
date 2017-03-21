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

class HATServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetAppToken() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body = ["accessToken" : "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoiaHR0cHM6XC9cL3NvY2lhbC1wbHVnLmh1Ym9mYWxsdGhpbmdzLmNvbSIsImFjY2Vzc1Njb3BlIjoidmFsaWRhdGUiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyODM2LCJpYXQiOjE0ODcwNjM2MzYsImp0aSI6ImRkZDk4NWRiNjE0MzQxNjUxMGY5ZjU3NTY5MjQ4YTRiNGJhODg1NzE3N2Q4YTJlZjMxMzQyYWM2ZDAwMWFjZTJkZjI5MDIwMWM1MWNmODlhNDE2Y2FhOWYzNGY5NDQ2ZGEyMjJlMTZiM2UzOGVmZWM5NzYxNzBlZWVmYTNmNDRkNjM2ZTIyMTMyYTFlODg4ZmQ1YzU3MzE3MDU5NjQ5NWVkMjM0OTUyMGEyOTgwZWQxMjRmOGNkYmZlMTU0MDYyN2NkZDMwZWMzOTlhMGJiNTU3YTYyZmI4Y2VhMmYyODZiZWM4MzMxZjEwNjZkMjE3OThkMmU0NDUzNTg5ZTgxZjcifQ.r8MUnCojsUDxQmGPeCljwizVxCG9mULEFFl4qXHHCtavUvPTZM-blR4U8ItJUSo7lGDwwbZmMyRgeEDtkpQVN7NV0Vpu1dibmRob5AgRrtqamXjZUZBlYKGlkvk26xvB94c1Lt-5_bYNy83ZF1D9PqiDC_h504fX15OX6XTrAXUnWyErZ_ukbn9MEdv-uxrhqCzTV0OW9U9kAcIJ42FUHoBkTCayqE76LP04Yf9N7eWuhAz63QqBzg4R3sFF-SmOb7Gu1JCTf7l5cILEVd1sdlJR4ipgBuq5g8IvkqwF38Ea2K1PKY4lKaOqb9pAXQYOqhBKkeyKANeeEPGhJ7OJHg",
                    "userId": "f5e089cb-a63f-4879-b3df-6ba99a928dac"]
        let userDomain = "mariostsekis.hubofallthings.net"
        let serviceName = "facebook"
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        let resource = "https://social-plug.hubofallthings.com"
        let urlToConnect = "https://mariostsekis.hubofallthings.net/users/application_token?&name=facebook&resource=https%3A//social-plug.hubofallthings.com"
        let expectationTest = expectation(description: "Getting app token...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion(appToken: String) {
            
            XCTAssertEqual(appToken, body["accessToken"])
            expectationTest.fulfill()
        }
        
        func failed(error: JSONParsingError) {
            
            
        }
        
        HATService.getApplicationTokenFor(serviceName: serviceName, userDomain: userDomain, token: token, resource: resource, succesfulCallBack: completion, failCallBack: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
