//
//  SingleResultsViewModel_Relation_Sections_Tests.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/9/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import XCTest

class SingleResultsViewModel_Relation_Sections_Tests: XCTestCase {
    var persistence: TestablePersistence!
	var context: NSManagedObjectContext { return persistence.mainContext }
	
	func setupListener(showEmptySection: Bool = false) -> ResultsListener {
        let context = persistence.mainContext
        let projectClass = Project.self
		let sectionKeyPath: String = "client"
		let sortDescriptors = [ NSSortDescriptor(key: "client.name", ascending: true)]
		let info = SingleResultsInfo(context: context,
			managedClass: projectClass,
			sectionNameKeyPath: sectionKeyPath,
			sectionDisplayNameKeyPath: "client.name",
			sortDescriptors: sortDescriptors,
			predicate: nil,
			showEmptySection: showEmptySection)
        let viewModel = SingleResultsViewModel(info: info)
		let listener = ResultsListener(viewModel: viewModel)
		
        viewModel.load()
        return listener
    }
	
	// --- Object at path
	
	func testObjectAtIndexPath() {
		let listener = setupListener(showEmptySection: false)
		
		insertProjectsWithTwoClients()
		
		XCTAssertEqual(listener.viewModel.sectionCount, 2, "Should have correct section count")
		let projectForClientAIndexPath = NSIndexPath(forItem: 1, inSection: 0)
		let projectForClientA = listener.viewModel.objectAtIndexPath(projectForClientAIndexPath) as Project
		XCTAssertEqual(projectForClientA.client!.name, "A", "Should have correct object in the section")
		let projectForClientBIndexPath = NSIndexPath(forItem: 1, inSection: 1)
		let projectForClientB = listener.viewModel.objectAtIndexPath(projectForClientBIndexPath) as Project
		XCTAssertEqual(projectForClientB.client!.name, "B", "Should have correct object in the section")
	}
	
	func testObjectAtIndexPath_WithEmptyIncluded() {
		let listener = setupListener(showEmptySection: true)
		
		insertProjectsWithTwoClientsAndEmpties()
		
		XCTAssertEqual(listener.viewModel.sectionCount, 3, "Should have correct section count")
		let projectForClientAIndexPath = NSIndexPath(forItem: 1, inSection: 0)
		let projectForClientA = listener.viewModel.objectAtIndexPath(projectForClientAIndexPath) as Project
		XCTAssertEqual(projectForClientA.client!.name, "A", "Should have correct object in the section")
		let projectForClientBIndexPath = NSIndexPath(forItem: 1, inSection: 1)
		let projectForClientB = listener.viewModel.objectAtIndexPath(projectForClientBIndexPath) as Project
		XCTAssertEqual(projectForClientB.client!.name, "B", "Should have correct object in the section")
	}
	
	// --- Section count
	
	func testSectionCountWithRelation_WithEmptyIncluded() {
		let listener = setupListener(showEmptySection: true)
		
		insertProjectsHalfWithClients()
		
		XCTAssertEqual(listener.viewModel.sectionCount, 2, "Should have correct section count with section on relation")
	}
	
	func testSectionCountWithRelation() {
		let listener = setupListener(showEmptySection: false)
		
		insertProjectsHalfWithClients()
		
		XCTAssertEqual(listener.viewModel.sectionCount, 1, "Should have correct section count with section on relation")
	}
	
	// --- Title
	
	func testSectionTitle() {
		let listener = setupListener(showEmptySection: false)
		
		insertProjectsWithTwoClients()
		
		let titleA = listener.viewModel.titleForSection(0)
		let titleB = listener.viewModel.titleForSection(1)
		
		XCTAssertEqual(titleA!, "A", "Should have correct section title")
		XCTAssertEqual(titleB!, "B", "Should have correct section title")
	}
	
	// --- Count
	
	func testCountWithRelation_WithEmptyIncluded() {
		let listener = setupListener(showEmptySection: true)
		
		insertProjectsHalfWithClients()
		
		XCTAssertEqual(listener.viewModel.count, 10, "Should have correct count with section on relation")
	}
	
	func testCountWithRelation() {
		let listener = setupListener(showEmptySection: false)
		
		insertProjectsWithClients()
		
		XCTAssertEqual(listener.viewModel.count, 10, "Should have correct count with section on relation")
	}
	
	// --- Binding notification
	
	func testNotifiesAboutSectionInsertions() {
		let listener = setupListener(showEmptySection: false)
		
		insertProjectsWithTwoClients()
		
		XCTAssertEqual(listener.addedSections.count, 2, "Should have added 2 sections")
	}
	
	// --- Helpers
	
	func insertProjectsWithTwoClientsAndEmpties() {
		let clientA = Client.insert(context) as Client
		clientA.name = "A"
		let clientB = Client.insert(context) as Client
		clientB.name = "B"
		for i in 0..<10 {
			let p = Project.insert(context) as Project
			p.client = i % 2 == 0 ? clientA : clientB
		}
		
		for _ in 0..<4 { Project.insert(context) }
		
		context.save(nil)
	}
	
	func insertProjectsWithTwoClients() {
		let clientA = Client.insert(context) as Client
		clientA.name = "A"
		let clientB = Client.insert(context) as Client
		clientB.name = "B"
		for i in 0..<10 {
			let p = Project.insert(context) as Project
			p.client = i % 2 == 0 ? clientA : clientB
		}
		
		context.save(nil)
	}
	
	func insertProjectsHalfWithClients() {
		let client = Client.insert(context) as Client
		for i in 0..<10 {
			let p = Project.insert(context) as Project
			if i % 2 == 0 {
				p.client = client
			}
		}
		
		context.save(nil)
	}
	
	func insertProjectsWithClients() {
		let client = Client.insert(context) as Client
		for _ in 0..<10 {
			let p = Project.insert(context) as Project
			p.client = client
		}

		context.save(nil)
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
/**
	func testItemsCountWithEmptyIncluded() {
		let listener = setupListener(showEmptySection: true)
		
		insertForItemsCountTests()
		
		XCTAssertEqual(listener.viewModel.count, 20, "Total count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.rowsForSection(0), 2, "Section row count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.rowsForSection(1), 7, "Section row count should be correct when there is an empty section")
//		XCTAssertEqual(listener.viewModel.rowsForSection(2), 11, "Section row count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.sectionCount, 3, "Section count should be correct when there is an empty section")
	}
	
	let someClientName = "Some Client"
	let someOtherClientName = "Some Other Client"
	
	func insertForItemsCountTests() {
		let someClient = Client.insert(context) as Client
		someClient.name = someClientName
		let someOtherClient = Client.insert(context) as Client
		someOtherClient.name = someOtherClientName
		for i in 0..<20 {
			let p1 = Project.insert(context) as Project
			if i % 3 == 0 {
				p1.client = someClient
			} else if i % 7 == 0 {
				p1.client = someOtherClient
			}
		}
		context.save(nil)
	}
	
	func testObjectInSections() {
		let listener = setupListener(showEmptySection: false)
		
		insertForItemsCountTests()
		
		let aSomeOtherClientProjectPath = NSIndexPath(forItem: 1, inSection: 0)
		let aSomeOtherClientProject = listener.viewModel.objectAtIndexPath(aSomeOtherClientProjectPath) as Project
		XCTAssertEqual(aSomeOtherClientProject.client!.name, someOtherClientName, "Object at index path should be correct in a section")
		
		let aSomeClientProjectPath = NSIndexPath(forItem: 1, inSection: 1)
		let aSomeClientProject = listener.viewModel.objectAtIndexPath(aSomeClientProjectPath) as Project
		XCTAssertEqual(aSomeClientProject.client!.name, someClientName, "Object at index path should be correct in a section")
	}
	
*/
}
