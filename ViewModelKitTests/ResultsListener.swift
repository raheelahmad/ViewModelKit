//
//  ResultsListener.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/2/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import Foundation

class ResultsListener: NSObject {
	let viewModel: ResultsViewModel
    
    var willChangeContent: Bool = false
	var didChangeContent: Bool = false
	var added: [NSIndexPath: ManagedObject] = [:]
	var deleted: [NSIndexPath: ManagedObject] = [:]
	var updated: [NSIndexPath: ManagedObject] = [:]
	var moved: [ (NSIndexPath, NSIndexPath, ManagedObject) ] = []
	var addedSections: [Int] = []
	var deletedSections: [Int] = []
	
	init(viewModel: ResultsViewModel) {
		self.viewModel = viewModel
		super.init()
		
		viewModel.bind(.DidChange) { info in
            self.didChangeContent = true
        }
		
		viewModel.bind(.WillChange) { info in
            self.willChangeContent = true
            self.added.removeAll(keepCapacity: false)
            self.deleted.removeAll(keepCapacity: false)
            self.updated.removeAll(keepCapacity: false)
        }
        
        viewModel.bind(RowChangeType.Added) { info in
            for result in info {
                self.added[result.path] = result.object
            }
        }
		
		viewModel.bind(RowChangeType.Deleted ) { info in
            for result in info {
                self.deleted[result.path] = result.object
            }
        }
        
        viewModel.bind(RowChangeType.Updated) { info in
            for result in info {
                self.updated[result.path] = result.object
            }
        }
		
		viewModel.bind(RowChangeType.Moved) { info in
			for result in info {
				let objectMovedInfo = ( result.path, result.secondPath!, result.object!)
				self.moved.append(objectMovedInfo)
			}
		}
		
		viewModel.bind(SectionChangeType.Added) { info in
			self.addedSections.append(info.index)
		}
		viewModel.bind(SectionChangeType.Deleted) { info in
			self.deletedSections.append(info.index)
		}
	}
	
	func reset() {
		willChangeContent = false
		didChangeContent = false
		added = [:]
		deleted = [:]
		updated = [:]
		moved = []
		addedSections = []
		deletedSections = []
	}
    
    func unbind(rowChangeType: RowChangeType) {
        viewModel.unbind(rowChangeType)
    }
    
    func unbindAll() {
        for type in [ RowChangeType.DidChange, RowChangeType.WillChange, RowChangeType.Added,
            RowChangeType.Deleted, RowChangeType.Updated ] {
                viewModel.unbind(type)
        }
		for type in [ SectionChangeType.Deleted, SectionChangeType.Added ] {
			viewModel.unbind(type)
		}
    }
}
