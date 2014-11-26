//
//  CoreDataTests.swift
//  Epoch
//
//  Created by Raheel Ahmad on 10/29/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import XCTest

class CoreDataTests: XCTestCase {
    var persistence: TestablePersistence!
    
    func testStackIsSetup() {
        XCTAssertNotNil(persistence.mainContext, "Context should not be nil")
    }

    override func setUp() {
        super.setUp()
        persistence = TestablePersistence()
        persistence.setupStack()
    }
    
    override func tearDown() {
        super.tearDown()
    }

}
