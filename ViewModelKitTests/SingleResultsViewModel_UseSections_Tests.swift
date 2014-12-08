//
//  SingleResultsViewModel_UseSections_Tests.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/8/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import XCTest

class SingleResultsViewModel_UseSections_Tests: XCTestCase {
    var persistence: TestablePersistence!
	var context: NSManagedObjectContext { return persistence.mainContext }
    
	func setupListener(showEmptySection: Bool = false) -> ResultsListener {
        let context = persistence.mainContext
        let projectClass = Project.self
		let sectionKeyPath: String = "type"
		let sortDescriptors = [ NSSortDescriptor(key: sectionKeyPath, ascending: true)]
		let info = SingleResultsInfo(context: context,
			managedClass: projectClass,
			sectionNameKeyPath: sectionKeyPath,
			sectionDisplayNameKeyPath: sectionKeyPath,
			sortDescriptors: sortDescriptors,
			predicate: nil,
			showEmptySection: showEmptySection)
        let viewModel = SingleResultsViewModel(info: info)
		let listener = ResultsListener(viewModel: viewModel)
		
        viewModel.load()
        return listener
    }
	
	// --- Test Objects in sections
	
	func testObjectInSections() {
		let listener = setupListener(showEmptySection: false)
		
		insertForItemsCountTests()
		
		let complexProjectIndexPath = NSIndexPath(forItem: 1, inSection: 0)
		let complexProject = listener.viewModel.objectAtIndexPath(complexProjectIndexPath) as Project
		XCTAssertEqual(complexProject.type!, complexType, "Object at index path should be correct in a section")
		
		let easyProjectIndexPath = NSIndexPath(forItem: 1, inSection: 1)
		let easyProject = listener.viewModel.objectAtIndexPath(easyProjectIndexPath) as Project
		XCTAssertEqual(easyProject.type!, easyType, "Object at index path should be correct in a section")
	}
	
	func testObjectInSections_WithEmptySectionIncluded() {
		let listener = setupListener(showEmptySection: true)
		
		insertForItemsCountTests()
		
		let complexProjectIndexPath = NSIndexPath(forItem: 1, inSection: 0)
		let complexProject = listener.viewModel.objectAtIndexPath(complexProjectIndexPath) as Project
		XCTAssertEqual(complexProject.type!, complexType, "Object at index path should be correct in a section")
		
		let easyProjectIndexPath = NSIndexPath(forItem: 1, inSection: 1)
		let easyProject = listener.viewModel.objectAtIndexPath(easyProjectIndexPath) as Project
		XCTAssertEqual(easyProject.type!, easyType, "Object at index path should be correct in a section")
		
		let noTypeProjectIndexPath = NSIndexPath(forItem: 2, inSection: 2)
		let noTypeProject = listener.viewModel.objectAtIndexPath(noTypeProjectIndexPath) as Project
		XCTAssertNil(noTypeProject.type,  "Object at index path should be correct in a section")
	}
	
	// --- Test Section title
	
	func testSectionTitles() {
		let listener = setupListener(showEmptySection: false)
		
		insertForItemsCountTests()
		
		let title1 = listener.viewModel.titleForSection(0)
		let title2 = listener.viewModel.titleForSection(1)
		XCTAssertEqual(title1!, complexType, "Should have correct section title")
		XCTAssertEqual(title2!, easyType, "Should have correct section title")
	}
	
	// --- Section insert notification
	
	func testNotifiesAboutSectionInsertion() {
		let listener = setupListener(showEmptySection: false)
		
		insertForSectionCountTests()
		
		let project = Project.insert(context) as Project
		project.type = "Medium"
		
		context.save(nil)
		
		XCTAssertEqual(listener.addedSections.count, 3, "Should notify for section insertions")
		
		context.deleteObject(project)
		context.save(nil)
		
		XCTAssertEqual(listener.deletedSections.count, 1, "Should notify for section deletions")
	}
	
	// --- Test Items count in sections
	
	func testItemsCount() {
		let listener = setupListener(showEmptySection: false)
		
		insertForItemsCountTests()
		
		XCTAssertEqual(listener.viewModel.count, 9, "Total count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.rowsCountInSection(0), 2, "Section row count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.rowsCountInSection(1), 7, "Section row count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.sectionCount, 2, "Section count should be correct when there is an empty section")
	}
	
	func testItemsCount_WithEmptyIncluded() {
		let listener = setupListener(showEmptySection: true)
		
		insertForItemsCountTests()
		
		XCTAssertEqual(listener.viewModel.count, 20, "Total count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.rowsCountInSection(0), 2, "Section row count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.rowsCountInSection(1), 7, "Section row count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.rowsCountInSection(2), 11, "Section row count should be correct when there is an empty section")
		XCTAssertEqual(listener.viewModel.sectionCount, 3, "Section count should be correct when there is an empty section")
	}
	
	let easyType = "Easy"
	let complexType = "Complex"
	
	func insertForItemsCountTests() {
		for i in 0..<20 {
			let p1 = Project.insert(context) as Project
			if i % 3 == 0 {
				p1.type = easyType
			} else if i % 7 == 0 {
				p1.type = complexType
			}
		}
		context.save(nil)
	}
	
	// --- Test Sections Count

	func testSectionCountWithEmptyIncluded() {
		let listener = setupListener(showEmptySection: true)
		
		insertForSectionCountTests()
		
		context.save(nil)
		
		XCTAssertEqual(listener.viewModel.sectionCount, 3, "Should have 2 sections")
	}
	
	func testSectionCount() {
		let listener = setupListener()
		
		insertForSectionCountTests()
		
		context.save(nil)
		
		XCTAssertEqual(listener.viewModel.sectionCount, 2, "Should have 2 sections")
	}
	
	func insertForSectionCountTests() {
		let p1 = Project.insert(context) as Project
		let p0 = Project.insert(context) as Project
		
		p1.type = easyType
		p0.type = complexType
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
