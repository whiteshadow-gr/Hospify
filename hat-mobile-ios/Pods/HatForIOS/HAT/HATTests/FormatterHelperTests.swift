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

class FormatterHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFormattingStringToDate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let stringDate = "2017-02-14T18:07:33.000Z"
        
        let result = FormatterHelper.formatStringToDate(string: stringDate)
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: result!)
        let month = calendar.component(.month, from: result!)
        let year = calendar.component(.year, from: result!)
        
        let hour = calendar.component(.hour, from: result!)
        let minutes = calendar.component(.minute, from: result!)
        let seconds = calendar.component(.second, from: result!)
        let mseconds = calendar.component(.nanosecond, from: result!)
        
        XCTAssertTrue(day == 14)
        XCTAssertTrue(month == 02)
        XCTAssertTrue(year == 2017)
        XCTAssertTrue(hour == 18)
        XCTAssertTrue(minutes == 07)
        XCTAssertTrue(seconds == 33)
        XCTAssertTrue(mseconds == 000)
    }
    
    func testFromBase64URLToBase64() {
        
        let base64URLString = "eyAibXNnX2VuIjogIkhlbGxvIiwKICAibXNnX2pwIjogIuOBk-OCk-OBq-OBoeOBryIsCiAgIm1zZ19jbiI6ICLkvaDlpb0iLAogICJtc2dfa3IiOiAi7JWI64WV7ZWY7IS47JqUIiwKICAibXNnX3J1IjogItCX0LTRgNCw0LLRgdGC0LLRg9C50YLQtSEiLAogICJtc2dfZGUiOiAiR3LDvMOfIEdvdHQiIH0"
        
        let base64String = FormatterHelper.fromBase64URLToBase64(s: base64URLString)
        
        XCTAssertTrue(base64String == "eyAibXNnX2VuIjogIkhlbGxvIiwKICAibXNnX2pwIjogIuOBk+OCk+OBq+OBoeOBryIsCiAgIm1zZ19jbiI6ICLkvaDlpb0iLAogICJtc2dfa3IiOiAi7JWI64WV7ZWY7IS47JqUIiwKICAibXNnX3J1IjogItCX0LTRgNCw0LLRgdGC0LLRg9C50YLQtSEiLAogICJtc2dfZGUiOiAiR3LDvMOfIEdvdHQiIH0=")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
