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
import SwiftyJSON

class HATAccountServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetTableValues() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body: [Dictionary<String, Any>] =
            [
                [
                "lastUpdated" : "2017-02-09T16:48:17.499Z",
                "id" : 31707,
                "data" : [
                        "notablesv1" : [
                                        "authorv1" : [
                                                    "phata" : "mariostsekis.hubofallthings.net"
                                        ],
                                        "public_until" : "",
                                        "shared_on" : "",
                                        "message" : "web",
                                        "kind" : "note",
                                        "created_time" : "2017-02-09T16:17:07+00:00",
                                        "shared" : "false",
                                        "updated_time" : "2017-02-09T16:48:19+00:00"
                    ]
                ],
                "name" : "2017-02-09T16:48:19.506Z"
                ]
        ]
        let userDomain = "mariostsekis.hubofallthings.net"
        let tableID: NSNumber = 13
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        let parameters: Dictionary<String, String> = ["limit" : "1",
                                                      "starttime" : "0"]
        let urlToConnect = "https://mariostsekis.hubofallthings.net/data/table/13/values?pretty=true&limit=1&starttime=0"
        let expectationTest = expectation(description: "Getting table values...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion(json: [JSON]) {
            
            XCTAssertNotNil(json)
            expectationTest.fulfill()
        }
        
        func failed(error: HATTableError) {
            
        }
        
        HATAccountService.getHatTableValues(token: token, userDomain: userDomain, tableID: tableID, parameters: parameters, successCallback: completion, errorCallback: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCheckHATTableExists() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body: Dictionary<String, Any> =
            [
                "subTables" : [
                    [
                        "name" : "locationv1",
                        "id" : 16,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "latitude",
                                "id" : 24,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "longitude",
                                "id" : 25,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "accuracy",
                                "id" : 26,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "altitude",
                                "id" : 27,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "heading",
                                "id" : 28,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "altitude_accuracy",
                                "id" : 30,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "speed",
                                "id" : 34,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "shared",
                                "id" : 35,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "photov1",
                        "id" : 15,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "link",
                                "id" : 29,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "source",
                                "id" : 31,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "caption",
                                "id" : 32,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "shared",
                                "id" : 33,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "authorv1",
                        "id" : 14,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "id",
                                "id" : 36,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "nick",
                                "id" : 37,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "name",
                                "id" : 38,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "phata",
                                "id" : 39,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "photo_url",
                                "id" : 40,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ]
                ],
                "fields" : [
                    [
                        "name" : "message",
                        "id" : 17,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "kind",
                        "id" : 18,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "created_time",
                        "id" : 19,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "updated_time",
                        "id" : 20,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "shared_on",
                        "id" : 21,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "shared",
                        "id" : 22,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "public_until",
                        "id" : 23,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ]
                ],
                "name" : "notablesv1",
                "source" : "rumpel",
                "lastUpdated" : "2016-11-04T11:53:19+0000",
                "id" : 13,
                "dateCreated" : "2016-11-04T11:53:19+0000"
        ]
        let userDomain = "mariostsekis.hubofallthings.net"
        let tableName: String = "notablesv1"
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        let sourceName: String = "rumpel"
        let urlToConnect = "https://mariostsekis.hubofallthings.net/data/table?name=notablesv1&source=rumpel"
        let expectationTest = expectation(description: "Getting table values...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion(tableID: NSNumber) {
            
            XCTAssertNotNil(json)
            expectationTest.fulfill()
        }
        
        func failed(error: HATTableError) {
            
        }
        
        HATAccountService.checkHatTableExists(userDomain: userDomain, tableName: tableName, sourceName: sourceName, authToken: token, successCallback: completion, errorCallback: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCreateTable() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body: Dictionary<String, Any> =
            [
                "subTables" : [
                    [
                        "name" : "locationv1",
                        "id" : 16,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "latitude",
                                "id" : 24,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "longitude",
                                "id" : 25,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "accuracy",
                                "id" : 26,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "altitude",
                                "id" : 27,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "heading",
                                "id" : 28,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "altitude_accuracy",
                                "id" : 30,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "speed",
                                "id" : 34,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "shared",
                                "id" : 35,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "photov1",
                        "id" : 15,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "link",
                                "id" : 29,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "source",
                                "id" : 31,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "caption",
                                "id" : 32,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "shared",
                                "id" : 33,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "authorv1",
                        "id" : 14,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "id",
                                "id" : 36,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "nick",
                                "id" : 37,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "name",
                                "id" : 38,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "phata",
                                "id" : 39,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "photo_url",
                                "id" : 40,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ]
                ],
                "fields" : [
                    [
                        "name" : "message",
                        "id" : 17,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "kind",
                        "id" : 18,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "created_time",
                        "id" : 19,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "updated_time",
                        "id" : 20,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "shared_on",
                        "id" : 21,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "shared",
                        "id" : 22,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "public_until",
                        "id" : 23,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ]
                ],
                "name" : "notablesv1",
                "source" : "rumpel",
                "lastUpdated" : "2016-11-04T11:53:19+0000",
                "id" : 13,
                "dateCreated" : "2016-11-04T11:53:19+0000"
        ]
        let userDomain = "mariostsekis.hubofallthings.net"
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        let urlToConnect = "https://mariostsekis.hubofallthings.net/data/table"
        let expectationTest = expectation(description: "Creating table...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func failed(error: HATTableError) {
           
            print("hello")
        }
        
        func test() -> Void {
                
            HATAccountService.createHatTable(userDomain: userDomain, token: token, notablesTableStructure: Structures.createNotablesTableJSON(), failed: failed)()
        }
        
        expectationTest.fulfill()
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testDeleteTableValues() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body: [Dictionary<String, Any>] =
            [
                [
                    "lastUpdated" : "2017-02-09T16:48:17.499Z",
                    "id" : 31707,
                    "data" : [
                        "notablesv1" : [
                            "authorv1" : [
                                "phata" : "mariostsekis.hubofallthings.net"
                            ],
                            "public_until" : "",
                            "shared_on" : "",
                            "message" : "web",
                            "kind" : "note",
                            "created_time" : "2017-02-09T16:17:07+00:00",
                            "shared" : "false",
                            "updated_time" : "2017-02-09T16:48:19+00:00"
                        ]
                    ],
                    "name" : "2017-02-09T16:48:19.506Z"
                ]
        ]
        let userDomain = "mariostsekis.hubofallthings.net"
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        let urlToConnect = "https://mariostsekis.hubofallthings.net/data/record/123"
        let expectationTest = expectation(description: "Deleting table values...")
        
        MockingjayProtocol.addStub(matcher: everything, builder: json(body))
        
        func completion(token: String) {
            
            XCTAssertNotNil(token)
            expectationTest.fulfill()
        }
        
        func failed(error: HATTableError) {
            
            print("hey")
        }
        
        HATAccountService.deleteHatRecord(userDomain: userDomain, token: token, recordId: 123, success: completion, failed: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testTickle() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body: [Dictionary<String, Any>] =
            [
                [
                    "lastUpdated" : "2017-02-09T16:48:17.499Z",
                    "id" : 31707,
                    "data" : [
                        "notablesv1" : [
                            "authorv1" : [
                                "phata" : "mariostsekis.hubofallthings.net"
                            ],
                            "public_until" : "",
                            "shared_on" : "",
                            "message" : "web",
                            "kind" : "note",
                            "created_time" : "2017-02-09T16:17:07+00:00",
                            "shared" : "false",
                            "updated_time" : "2017-02-09T16:48:19+00:00"
                        ]
                    ],
                    "name" : "2017-02-09T16:48:19.506Z"
                ]
        ]
        let userDomain = "mariostsekis.hubofallthings.net"
        let urlToConnect = "https://notables.hubofallthings.com/api/bulletin/tickle?"
        let expectationTest = expectation(description: "Tickling hat...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion() {
            
            XCTAssertTrue(true)
            expectationTest.fulfill()
        }
        
        func failed(error: HATTableError) {
            
        }
        
        HATAccountService.triggerHatUpdate(userDomain: userDomain, completion: completion)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCheckHATTableExistsForUpload() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let body: Dictionary<String, Any> =
            [
                "subTables" : [
                    [
                        "name" : "locationv1",
                        "id" : 16,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "latitude",
                                "id" : 24,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "longitude",
                                "id" : 25,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "accuracy",
                                "id" : 26,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "altitude",
                                "id" : 27,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "heading",
                                "id" : 28,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "altitude_accuracy",
                                "id" : 30,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "speed",
                                "id" : 34,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "shared",
                                "id" : 35,
                                "tableId" : 16,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "photov1",
                        "id" : 15,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "link",
                                "id" : 29,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "source",
                                "id" : 31,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "caption",
                                "id" : 32,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "shared",
                                "id" : 33,
                                "tableId" : 15,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "authorv1",
                        "id" : 14,
                        "source" : "rumpel",
                        "fields" : [
                            [
                                "name" : "id",
                                "id" : 36,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "nick",
                                "id" : 37,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "name",
                                "id" : 38,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "phata",
                                "id" : 39,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ],
                            [
                                "name" : "photo_url",
                                "id" : 40,
                                "tableId" : 14,
                                "lastUpdated" : "2016-11-04T11:53:19+0000",
                                "dateCreated" : "2016-11-04T11:53:19+0000"
                            ]
                        ],
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ]
                ],
                "fields" : [
                    [
                        "name" : "message",
                        "id" : 17,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "kind",
                        "id" : 18,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "created_time",
                        "id" : 19,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "updated_time",
                        "id" : 20,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "shared_on",
                        "id" : 21,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "shared",
                        "id" : 22,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ],
                    [
                        "name" : "public_until",
                        "id" : 23,
                        "tableId" : 13,
                        "lastUpdated" : "2016-11-04T11:53:19+0000",
                        "dateCreated" : "2016-11-04T11:53:19+0000"
                    ]
                ],
                "name" : "notablesv1",
                "source" : "rumpel",
                "lastUpdated" : "2016-11-04T11:53:19+0000",
                "id" : 13,
                "dateCreated" : "2016-11-04T11:53:19+0000"
        ]
        let userDomain = "mariostsekis.hubofallthings.net"
        let tableName: String = "notablesv1"
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJleUp3Y205MmFXUmxja2xFSWpvaWJXRnlhVzl6ZEhObGEybHpMbWgxWW05bVlXeHNkR2hwYm1kekxtNWxkQ0lzSW5CeWIzWnBaR1Z5UzJWNUlqb2liV0Z5YVc5emRITmxhMmx6SW4wPSIsInJlc291cmNlIjoibWFyaW9zdHNla2lzLmh1Ym9mYWxsdGhpbmdzLm5ldCIsImFjY2Vzc1Njb3BlIjoib3duZXIiLCJpc3MiOiJtYXJpb3N0c2VraXMuaHVib2ZhbGx0aGluZ3MubmV0IiwiZXhwIjoxNDg3MzIyNzk0LCJpYXQiOjE0ODcwNjM1OTQsImp0aSI6ImUxYWY1ODY3ZWRhNjFmM2MxMmE3YzE1OGEwNDhmMjM0YmFiMzI3ZDVhNzQ5NDIzYWIwNGU1OTkxZTUxZDE1MTM0MzE3MDQwZDFhMjBiNTI1ZDMxODFmNWJiNTI3ZmVkMWJhMWYzZWEwZTlmZTM0MjZmM2E5ZDMwNmFjMGY3NGFjMTM1MWQ1OTFhYmMxZTI4NmJmMGYyMjgzNzRkZWU2MDdhYWQ2MjU3OGJkNzJhZTI2OWI4NDY4NWJiYjY2OGMzMmQzODRkZjQwZjIxNDU4Y2IwMjFlMDc5ODc5MzFmNmVlNTMyNWMxNGViNGNiOGFmYTNlMWI0ZjgwNzQ5M2M3ZDYifQ.lz3Snzglz9WtGTIlp4qmJsCnpljrwafYRSg7QKa9CNQAfq_yB5XIOcfH8As8f_fneQW08-ats4Qk1F_yfeQKPIa2GnissQj0W2rl4pnRMiFcKE2vddMRsM_fwGEsr43foGNIjJM3KIBPaECxC_QZdGdqu_wnpSS2rRqbJPrcdPs5FOhAWaLdL6ej0vkhdVX97-VwGyW70AcwZ-yFP8mKLZygwixqPn1-ubCc2ahkS94cM40s4-fon0HNNC4SNOB-q4g_87caAjXRN6cchrJitltHZ3_4xe4p9wMCK-LGjF99xUYT4aUbsiJ4tOPKOcqQsZgbfBZGqUM4_4aHQQ3Pxg"
        let sourceName: String = "rumpel"
        let urlToConnect = "https://" + userDomain + "/data/table?name=" + tableName + "&source=" + sourceName
        let expectationTest = expectation(description: "Getting table values...")
        
        MockingjayProtocol.addStub(matcher: http(.get, uri: urlToConnect), builder: json(body))
        
        func completion(dictionary: Dictionary<String, Any>) {
            
            //XCTAssertNotNil(json)
            expectationTest.fulfill()
        }
        
        func failed(error: HATTableError) {
            
        }
        
        HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: tableName, sourceName: sourceName, authToken: token, successCallback: completion, errorCallback: failed)
        
        waitForExpectations(timeout: 10) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testDomainURL() {
        
        let userDomain = "mariostsekis.hubofallthings.net"
        let expectedURL = "https://" + userDomain + "/publickey"
        let returnedURL = HATAccountService.TheUserHATDomainPublicKeyURL(userDomain)
        
        XCTAssertEqual(returnedURL, expectedURL)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
