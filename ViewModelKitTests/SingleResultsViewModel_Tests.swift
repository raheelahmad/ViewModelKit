//
//  SingleResultsViewModel_Tests.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/2/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import XCTest

class SingleResultsViewModel_Tests: XCTestCase {
    var persistence: TestablePersistence!
    
	func setupListener() -> ResultsListener {
        let context = persistence.mainContext
        let projectClass = Project.self
		let sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
		let info = SingleResultsInfo(context: context,
			managedClass: projectClass,
			sectionNameKeyPath: nil,
			sectionDisplayNameKeyPath: nil,
			sortDescriptors: sortDescriptors,
			predicate: nil,
			showEmptySection: false)
        let viewModel = SingleResultsViewModel(info: info)
		let listener = ResultsListener(viewModel: viewModel)
		
        viewModel.load()
        return listener
    }
    
    func testResultsViewModelNotifiesChangingContent() {
        let context = persistence.mainContext
		let listener = setupListener()
		
		let p = Project.insert(context) as Project
		p.name = "Scribd"
		context.save(nil)
		
		XCTAssertTrue(listener.willChangeContent, "Should have changed content")
	}
	
	func testResultsViewModelNotifiesAddition() {
		let context = persistence.mainContext
		let listener = setupListener()
		
		let p = Project.insert(context) as Project
		p.name = "Scribd"
		context.save(nil)
		
		XCTAssertEqual(listener.added.count, 1, "Should have added 1 object")
    }
	
    func testUnbinding() {
        // Bind and test
        let context = persistence.mainContext
		
		let listener = setupListener()
		
		let p1 = Project.insert(context) as Project
		context.save(nil)
		
		XCTAssertEqual(listener.added.count, 1, "Should notify after binding")
		
		// Now unbind and test
		listener.unbind(.Deleted)
		
		let p2 = Project.insert(context) as Project
		context.deleteObject(p1)
		context.save(nil)
		
		XCTAssertEqual(listener.deleted.count, 0, "Should not notify after unbinding")
		XCTAssertEqual(listener.added.count, 1, "Should notify after unbinding")
    }
	
	func testCount() {
		let context = persistence.mainContext
		let listener = setupListener()
		
		for _ in 0...4 { Project.insert(context) }
		context.save(nil)
		
		XCTAssertEqual(listener.viewModel.count, 5, "Count should be correct")
	}
	
	func testObjectAtIndexPath() {
		let context = persistence.mainContext
		let listener = setupListener()
		
		for i in 0...4 {
			let p = Project.insert(context) as Project
			p.name = "\(i) Project"
		}
		context.save(nil)
		
		XCTAssertEqual(listener.viewModel.count, 5, "Count should be correct")
		
		let path = NSIndexPath(forRow: 1, inSection: 0)
		let object1 = listener.viewModel.objectAtIndexPath(path) as Project
		XCTAssertTrue(object1.name == "1 Project", "Should give the correct object at IndexPath")
	}
	
    func testResultsViewModelNotifiesAboutMultipleChanges() {
        let context = persistence.mainContext
        let p1 = Project.insert(context) as Project
        let p3 = Project.insert(context) as Project
		
		context.save(nil)
        
        let listener = setupListener()
		
        // Insert, update and delete 1 each
        let p2 = Project.insert(context) as Project
        context.deleteObject(p1)
        
        context.save(nil)
		
        XCTAssertEqual(listener.added.count, 1, "Should have added 1 object")
        XCTAssertEqual(listener.deleted.count, 1, "Should have deleted 1 object")
		
        p3.name = "Scribd"
		
		context.save(nil)
		
        XCTAssertEqual(listener.updated.count, 1, "Should have updated 1 object")
    }

    override func setUp() {
        super.setUp()
        persistence = TestablePersistence()
        persistence.setupStack()
    }
    
    override func tearDown() {
		persistence.deleteAndResetStack()
        super.tearDown()
    }
}
