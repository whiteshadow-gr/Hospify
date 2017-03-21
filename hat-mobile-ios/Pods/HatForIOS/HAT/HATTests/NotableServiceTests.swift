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

class NotableServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSorting() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let note1 = NotesData()
        var note2 = NotesData()
        
        note2.lastUpdated = note2.lastUpdated.addingTimeInterval(100)
        
        var array = [note1, note2]
        
        array = NotablesService.sortNotables(notes: array)
        
        XCTAssertTrue(array[0] == note2)
    }
    
    func testRemoveDuplicates() {
        
        let note1 = NotesData()
        let note2 = note1
        
        var array = [note1, note2]
        
        array = NotablesService.removeDuplicatesFrom(array: array)
        
        XCTAssertTrue(array.count == 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
