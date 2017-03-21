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

@testable import HAT

class LoginServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoginRequest() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectationTest = expectation(description: "Verification...")
        let userDomain = "mariostsekis.hubofallthings.net"

        func success(usersDomain: String) {
            
            XCTAssertTrue(usersDomain == userDomain)
            expectationTest.fulfill()
        }
        
        func failed(result: String) {
            
            XCTAssertFalse(false, "Nothing returned")
            expectationTest.fulfill()
        }
        
        LoginService.logOnToHAT(userHATDomain: userDomain, successfulVerification: success, failedVerification: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testAuthorize() {
        
        let body = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt/JmV8Y7tyEsYdUQJtf9\noyWu+xx91rflRWg4+eCbgbJY8uFkoagbu5/5AdHBou1o21fElufsJdUgNDS0fa/z\nQzHey7q/9c8+JZChg5EYJvFmg8UB8wLBHpQC/5Oqj9vxvvot2tjfFeh35YhQszoz\nygmA7DeR5BLBWfR/PLiDvMEENQsjhdpYFmGWtcN5RWpF0UqWjluz/wQRXCJcxhiJ\njbCNaLcid9ijA7oowdwv50SlxSd019SXs1pRkkX7P4izXpX8i6hICx64waJKnxZa\nc8wiQAhAJuAHuiqUU6HOnMDw1g9KTIOUeefT+PO3wb7M46LsBYtf7zTJ2HypJSX8\nMwIDAQAB\n-----END PUBLIC KEY-----\n"
        
        let userDomain = "mariostsekis.hubofallthings.net"
        let expectationTest = expectation(description: "Authentication...")
        
        func string(_ body: String, status: Int = 200, headers:[String:String]? = nil) -> (_ request: URLRequest) -> Response {
            return { (request:URLRequest) in
                return stringData(body, status: status, headers: headers)(request)
            }
        }
        
        func stringData(_ data: String, status: Int = 200, headers: [String:String]? = nil) -> (_ request: URLRequest) -> Response {
            return { (request:URLRequest) in
                var headers = headers ?? [String:String]()
                if headers["Content-Type"] == nil {
                    headers["Content-Type"] = "text/plain; charset=utf-8"
                }
                let data2: Data = data.data(using: .utf8)!
                return http(status, headers: headers, download: .content(data2))(request)
            }
        }
        
        if let url = HATAccountService.TheUserHATDomainPublicKeyURL(userDomain) {
            
            MockingjayProtocol.addStub(matcher: http(.get, uri: url), builder: string(body) )
            
            func completion(result: Bool) {
                
                XCTAssert(result)
                expectationTest.fulfill()
            }
            
            func failed(error: AuthenicationError) {
                
                
            }
            
            let urlToConnect = "rumpellocationtrackerapp://rumpellocationtrackerapphost?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MjUzMTMxLCJpYXQiOjE0ODY5OTM5MzEsImp0aSI6ImRlNjM5YmVjZWYxY2RhYmY0Mjk2YTQzOTBjMThjZjQ3NTZmNGJhNzcwMDRjODg1YzBjOWE2YmZmMGZmZTY3NDVjYmFjYTUzZGQ2M2VlN2MzMzUxNWRjNzgyMDg4Yzc2MzdiMGE1YjVhMmVjN2ZjZGYwN2NkYTdjYjJjYTg5N2Q4MTFjNGY3YWIyYmRhNjVmMmI5ZTgzYTgyNzgzMzlmNTYwOTVhNTM4NzBiYzA0MWY0YmY5YzRmMTNhZDg2N2Y3ZTJkYjM4ZmE3NmZkNmU2ZTAyMWVjZjRiZjlmMThkNzUyYWVlMWZkMmI2M2RlODNhNTY0MmFlNWNkYzIwMzFhN2IifQ.Q3MdMggMpPWqPl1XMLm740WAaHw3oxLqMSiDT16tt4V4Q3WFrsH-geLva6m7fosjDg5r0L3MkpB-yqnOPeLc-YcWFLBYZOgnfyMEN0Q5o0vZ6_2m5JgOPGvLIJ3CEec8Dh3rf7p0Ua69oU0woCwBFjkuTosNfnTStbHisVg26JywGprK7jjve_W1zwAKr20GcCoMC5ulsP3nWCTZVLy2V6IRBUBPR8lXwmEz_PY27ayAqiGBXKz6lXJEkzxbwRrTYF3pO3s8E6oJYI1547rAteaIQDYbD7kisqAccHIvxyTz3AGjiAPPthlPf41pgHK4KuER91uKEBOul59A76vYAQ"
            
            LoginService.loginToHATAuthorization(userDomain: userDomain, url: NSURL(string: urlToConnect)!, success: completion, failed: failed)
            
            waitForExpectations(timeout: 10) { error in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func testVerifyDomain() {
        
        let domain = "hubofallthings.net"
        
        XCTAssert(LoginService.verifyDomain(domain))
    }
    
}
