//
//  SingleResultsViewModel.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/2/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData

public struct SingleResultsInfo {
	public let context: NSManagedObjectContext
	public let managedClass: ManagedObject.Type
	public let sectionNameKeyPath: String?
	public let sectionDisplayNameKeyPath : String? /// keypath on for section title display
	public let sortDescriptors: [NSSortDescriptor]
	public let predicate: NSPredicate?
	public let showEmptySection: Bool
    public init(context: NSManagedObjectContext, managedClass: ManagedObject.Type,
        sectionNameKeyPath: String?, sectionDisplayNameKeyPath: String?, sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate?, showEmptySection: Bool) {
            self.context = context
            self.managedClass = managedClass
            self.sectionNameKeyPath = sectionNameKeyPath
            self.sectionDisplayNameKeyPath = sectionDisplayNameKeyPath
            self.sortDescriptors = sortDescriptors
            self.predicate = predicate
            self.showEmptySection = showEmptySection
    }
}

public class SingleResultsViewModel: NSObject, ResultsViewModel {
    private var onRowChangeBlocks: [ RowChangeType: RowChangeBlock]
    private var onSectionChangeBlocks: [ SectionChangeType: SectionChangeBlock]
    
    private let controller: NSFetchedResultsController
	private let controllerForEmptySection: NSFetchedResultsController?
    private let context: NSManagedObjectContext
	
	private let sectionDisplayKeyPath: String?
	
	private var allSections: [NSFetchedResultsSectionInfo] {
		var sections: [NSFetchedResultsSectionInfo] = []
		if let base = self.controller.sections as? [NSFetchedResultsSectionInfo] {
			sections.extend(base)
		}
		if let empty = self.controllerForEmptySection?.sections as? [NSFetchedResultsSectionInfo] {
			assert(empty.count == 1, "Should only have 1 section in empty")
			sections.extend(empty)
		}
		return sections
	}
	
	public init(info: SingleResultsInfo) {
		context = info.context

		let managedClass = info.managedClass
		let entity = NSEntityDescription.entityForName(managedClass.managedEntityName, inManagedObjectContext: context)
		
		var shouldSetNonEmptyPredicate = false
		let sectionKeyPath = info.sectionNameKeyPath
		if sectionKeyPath != nil && info.showEmptySection {
			let request = NSFetchRequest(entityName: managedClass.managedEntityName)
			request.sortDescriptors = info.sortDescriptors
			request.predicate = NSPredicate(format: "\(sectionKeyPath!) == nil")
			controllerForEmptySection = NSFetchedResultsController(fetchRequest: request,
				managedObjectContext: context,
				sectionNameKeyPath: nil,
				cacheName: nil)
		}
		
		onRowChangeBlocks = [:]
		onSectionChangeBlocks = [:]
		
		let request = NSFetchRequest(entityName: managedClass.managedEntityName)
		request.sortDescriptors = info.sortDescriptors
		let sectionNameKeyPath = info.sectionNameKeyPath
		var predicates: [NSPredicate] = []
		if controllerForEmptySection != nil {
			predicates.append(NSPredicate(format: "\(sectionNameKeyPath!) != nil")!)
		}
		if let predicate = info.predicate {
			predicates.append(predicate)
		}
		request.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        controller = NSFetchedResultsController(fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: sectionNameKeyPath,
			cacheName: nil)
		
		sectionDisplayKeyPath = info.sectionDisplayNameKeyPath
		
		super.init()
		
		controller.delegate = self
		controllerForEmptySection?.delegate = self
	}
	
    public func load() {
        controller.fetch()
		controllerForEmptySection?.fetch()
    }

	public func reload() {

	}
	
	public func bind(type: RowChangeType, onChange change: RowChangeBlock) {
        onRowChangeBlocks[type] = change
    }
	
	public func bind(type: SectionChangeType, onChange change: SectionChangeBlock) {
		onSectionChangeBlocks[type] = change
	}
	
	public func unbind(type: RowChangeType) {
        onRowChangeBlocks.removeValueForKey(type)
    }
	
	public func unbind(type: SectionChangeType) {
		onSectionChangeBlocks.removeValueForKey(type)
	}
    
    public var count: Int {
		return allSections.reduce(0) { $0 + $1.numberOfObjects }
    }
	
	public var sectionCount: Int {
		return allSections.count
	}
	
	public var allObjects: [ManagedObject] {
		return controller.fetchedObjects as [ManagedObject]
	}
	
	public func rowsForSection(sectionIndex: Int) -> Int {
		let section = allSections[sectionIndex]
		let count = section.numberOfObjects
        return count
	}
	
	public func titleForSection(sectionIndex: Int) -> String? {
		var name: String?
		if sectionDisplayKeyPath != nil {
            if rowsForSection(sectionIndex) > 0 {
                let anObjectPath = NSIndexPath(forItem: 0, inSection: sectionIndex)
                if let anObject = objectAtIndexPath(anObjectPath) {
                    name = anObject.valueForKeyPath(sectionDisplayKeyPath!) as? String
                }
            }
		} else {
			name = allSections[sectionIndex].name
		}
		return name
	}
	
    public func objectAtIndexPath(indexPath: NSIndexPath) -> ManagedObject? {
		var object: ManagedObject?
		if indexPath.section < controller.sections?.count {
			object = controller.objectAtIndexPath(indexPath) as? ManagedObject
		} else {
			let emptyIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
			object = controllerForEmptySection?.objectAtIndexPath(emptyIndexPath) as ManagedObject?
		}
		
        return object
    }
	
	func notifyObserver(info: [RowChangeInfo], key: RowChangeType) {
		if let observer = onRowChangeBlocks[key] {
			observer(info)
		}
	}
	
	func notifyObserver(info: SectionChangeInfo, key: SectionChangeType) {
		if let observer = onSectionChangeBlocks[key] {
			observer(info)
		}
	}
}

extension SingleResultsViewModel {
	public func deleteObjectAtIndexPath(indexPath: NSIndexPath) {
		var object = objectAtIndexPath(indexPath)
		if let context = object?.managedObjectContext {
			if let object = object {
				context.deleteObject(object)
			}
		}
	}
}

extension SingleResultsViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        notifyObserver([], key: .WillChange)
    }
	
	public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		var changeType: SectionChangeType?
		switch type {
		case NSFetchedResultsChangeType.Insert:
			changeType = .Added
		case NSFetchedResultsChangeType.Delete:
			changeType = .Deleted
		default:
			break
		}
		let info = SectionChangeInfo(index: sectionIndex)
		notifyObserver(info, key: changeType!)
	}
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: ManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                let added = RowChangeInfo(path: newIndexPath, secondPath: nil, object: anObject)
                notifyObserver([added], key: .Added)
            }
        case .Update:
            if let indexPath = indexPath {
                let updated = RowChangeInfo(path: indexPath, secondPath: nil, object: anObject)
                notifyObserver([updated], key: .Updated)
            }
        case .Delete:
            if let indexPath = indexPath {
                let deleted = RowChangeInfo(path: indexPath, secondPath: nil, object: anObject)
                notifyObserver([deleted], key: .Deleted)
            }
        case .Move:
			let moved = RowChangeInfo(path: indexPath!, secondPath: newIndexPath!, object: anObject)
			notifyObserver([moved], key: .Moved)
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        notifyObserver([], key: .DidChange)
    }
}
