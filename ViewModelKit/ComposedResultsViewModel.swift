//
//  ComposedResultsViewModel.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/2/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData

public class ComposedResultsViewModel: NSObject {
    public var segmentCount: Int { return countElements(viewModels) }
    public var currentSegmentIndex: Int
    
    private var currentViewModel: ResultsViewModel { return viewModels[currentSegmentIndex] }
    private let viewModels: [ResultsViewModel]
	private var onRowChangeBlocks: [ RowChangeType: RowChangeBlock ]
	private var onSectionChangeBlocks: [ SectionChangeType: SectionChangeBlock ]
	
	public init(info composedInfo: [SingleResultsInfo]) {
		assert(composedInfo.count > 0, "Should have more than 1 info")
		var viewModels: [ResultsViewModel] = []
		for anInfo in composedInfo {
			viewModels.append(SingleResultsViewModel(info: anInfo))
		}
		self.viewModels = viewModels
		currentSegmentIndex = 0
		onRowChangeBlocks = [:]
		onSectionChangeBlocks = [:]
		
		super.init()
	}
	
	public init(viewModels: [ResultsViewModel]) {
		self.viewModels = viewModels
		currentSegmentIndex = 0
		onRowChangeBlocks = [:]
		onSectionChangeBlocks = [:]
		
		super.init()
	}
}

public extension ComposedResultsViewModel {
	func deleteObjectAtIndexPath(indexPath: NSIndexPath) {
		currentViewModel.deleteObjectAtIndexPath(indexPath)
	}
}

extension ComposedResultsViewModel: ResultsViewModel {
    public var count: Int { return currentViewModel.count }
	public var sectionCount: Int { return currentViewModel.sectionCount }
	public func rowsForSection(section: Int) -> Int {
		return currentViewModel.rowsForSection(section)
	}
	
	public var allObjects: [ManagedObject] {
		return currentViewModel.allObjects
	}
	
    public func load() {
        for vm in viewModels { vm.load() }
    }
	
	public func reload() {
		for vm in viewModels { vm.reload() }
	}
	
	public func bind(type: RowChangeType, onChange: RowChangeBlock) {
        onRowChangeBlocks[type] = onChange
        for vm in viewModels {
			vm.bind(type) { [unowned self] info in
                if vm === self.currentViewModel {
                    if let block = self.onRowChangeBlocks[type] {
                        block(info)
                    }
                }
            }
        }
    }
	
	public func bind(type: SectionChangeType, onChange: SectionChangeBlock) {
        onSectionChangeBlocks[type] = onChange
        for vm in viewModels {
			vm.bind(type) { [unowned self] info in
                if vm === self.currentViewModel {
                    if let block = self.onSectionChangeBlocks[type] {
                        block(info)
                    }
                }
            }
        }
    }
	
	public func unbind(forRowChangeType: RowChangeType) {
        for vm in viewModels {
            vm.unbind(forRowChangeType)
        }
    }
	
	public func unbind(type: SectionChangeType) {
		for vm in viewModels {
			vm.unbind(type)
		}
	}
	
    public func unbindAll() {
		let rowChangeTypes: [RowChangeType] = [ .WillChange, .DidChange, .Added, .Deleted, .Updated, .Moved ]
        for type in rowChangeTypes {
            unbind(type)
        }
		
		let sectionChangeTypes: [SectionChangeType] = [ .Added, .Deleted ]
        for type in sectionChangeTypes {
            unbind(type)
        }
    }
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> ManagedObject? {
        return currentViewModel.objectAtIndexPath(indexPath)
    }
	
	public func titleForSection(sectionIndex: Int) -> String? {
		return currentViewModel.titleForSection(sectionIndex)
	}
}