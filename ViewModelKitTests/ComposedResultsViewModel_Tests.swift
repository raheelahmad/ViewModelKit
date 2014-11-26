//
//  ComposedResultsViewModel_Tests.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/2/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import XCTest

class ComposedResultsViewModel_Tests: XCTestCase {
    var persistence: TestablePersistence!
    
    func setupListener() -> (ResultsListener, ComposedResultsViewModel) {
        let context = persistence.mainContext
        let projectClass = Project.self
        let clientClass = Client.self
		let sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
		let projectInfo = SingleResultsInfo(context: context,
			managedClass: projectClass,
			sectionNameKeyPath: nil,
			sectionDisplayNameKeyPath: nil,
			sortDescriptors: sortDescriptors,
			predicate: nil,
			showEmptySection: false)
		let clientInfo = SingleResultsInfo(context: context,
			managedClass: clientClass,
			sectionNameKeyPath: nil,
			sectionDisplayNameKeyPath: nil,
			sortDescriptors: sortDescriptors,
			predicate: nil,
			showEmptySection: false)
        let viewModel = ComposedResultsViewModel(info: [ projectInfo, clientInfo ])
		let listener = ResultsListener(viewModel: viewModel)
		
        viewModel.load()
        return (listener, viewModel)
    }
    
    
    func testNotifiesForDefaultSelection() {
        let context = persistence.mainContext
        
        let p0 = Project.insert(context) as Project // To tests for update later
		p0.name = "Scri"
		let p1 = Project.insert(context) as Project
		
		context.save(nil)
		
        let (listener, viewModel) = setupListener()
        
		let p2 = Project.insert(context) as Project
        let c1 = Client.insert(context) as Client // should not be included
		context.deleteObject(p1)
		
        context.save(nil)
        
        XCTAssertEqual(listener.added.count, 1, "Should notify for the correct index")
        XCTAssertEqual(listener.deleted.count, 1, "Should notify for the correct index")
        for (path, object) in listener.added {
            XCTAssertTrue(object is Project,  "Should notify for the correct index")
        }
		
        p0.name = "Scribd"
		context.save(nil)
		XCTAssertEqual(listener.updated.count, 1, "Should notify for the correct index")
		
        for (path, object) in listener.updated {
            XCTAssertTrue(object is Project,  "Should notify for the correct index")
        }
    }

    func testNotifiesForCurrentSelection() {
        let context = persistence.mainContext
        let (listener, viewModel) = setupListener()
        
        // For the default selection (Project)
        let p1 = Project.insert(context) as Project
        let p2 = Project.insert(context) as Project
        let c1 = Client.insert(context) as Client
        context.save(nil)
        
        XCTAssertEqual(listener.added.count, 2, "Should notify for the correct index")
        for (path, object) in listener.added {
            XCTAssertTrue(object is Project,  "Should notify for the correct index")
        }
        
        // Switch selection
        viewModel.currentSegmentIndex = 1
        let c2 = Client.insert(context) as Client
        let c3 = Client.insert(context) as Client
        p2.name = "Estwhile"
        XCTAssertEqual(listener.added.count, 2, "Should notify for the correct index")
        XCTAssertEqual(listener.updated.count, 0, "Should notify for the correct index")
    }
    
    func testUnbinding() {
        let context = persistence.mainContext
        let (listener, viewModel) = setupListener()
        
        let p1 = Project.insert(context) as Project
        let c1 = Client.insert(context) as Client
        
        listener.unbindAll()
        
        context.save(nil)
        
        XCTAssertEqual(listener.added.count, 0, "Should unbind")
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
