//
//  Persistence.swift
//  Epoch
//
//  Created by Raheel Ahmad on 10/25/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import Foundation
//
//  PersistenceStack.swift

import CoreData

public class Persistence: NSObject {
	public let modelName: String
	public let mainContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		context.undoManager = nil
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return context
		}()
	public var isSetup: Bool { return mainContext.persistentStoreCoordinator != nil }
	
	public init(appName: String) {
		modelName = appName
		super.init()
	}
	
	public func deleteAndResetStack() {
		var error: NSError?
		
		let coordinator = mainContext.persistentStoreCoordinator
		if coordinator == nil { return }
		if let store = coordinator!.persistentStoreForURL(storeURL) {
			mainContext.reset()
			let removedStore = coordinator!.removePersistentStore(store, error: &error)
			if !removedStore {
				println("Unable to remove store: \(error)")
				return
			}
			
			let fm = NSFileManager.defaultManager()
			let deleted = fm.removeItemAtURL(storeURL, error: &error)
			if !deleted {
				println("Unable to remove Core Data DB at \(storeURL): \(error)")
			}
			addStoreToCoordinator(coordinator!)
		}
		
	}
	
	public func setupStack() {
		let model = NSManagedObjectModel(contentsOfURL: modelURL)
		if let model = model {
			let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
			addStoreToCoordinator(coordinator)
			
			mainContext.persistentStoreCoordinator = coordinator
		}
	}
	
	public func addStoreToCoordinator(coordinator: NSPersistentStoreCoordinator) {
		var error: NSError?
		let options = [ NSMigratePersistentStoresAutomaticallyOption: true,
			NSInferMappingModelAutomaticallyOption: true ]
		let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)
		if store == nil {
			println("Could not open store at \(storeURL): \(error)")
		}
	}
	
	public func printStoreInfo() {
		let model = mainContext.persistentStoreCoordinator!.managedObjectModel
		let entities = model.entities as [NSEntityDescription]
		for entity in entities {
			println(entity)
		}
	}
	
	public func save() {
		let moc = mainContext
		moc.performBlock {
			var error: NSError?
			if !moc.save(&error) {
				println("Error saving context: \(error)")
			}
		}
	}
}

extension Persistence { // MARK: URLs
	public var modelURL: NSURL! {
        let name = modelName
		return NSBundle.mainBundle().URLForResource(name, withExtension: "momd")
	}
	
	var storeURL: NSURL! {
		let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
		let documentURL = urls.last as NSURL
		let dbName = "\(modelName).sqlite"
		let storeURL = documentURL.URLByAppendingPathComponent(dbName)
		return storeURL
	}
}


//
//  ManagedObject.swift

import CoreData

@objc public protocol HasDefault {
	var isDefault: Bool { get }
    class var defaultName: String { get }
}

public class ManagedObject: NSManagedObject {
	public class var managedEntityName: String { return "" }
	public class var sortDescriptors: [NSSortDescriptor] { return [] }
	public class var sectionKeyPath: String? { return nil }
	
	public class func all(context: NSManagedObjectContext) -> [AnyObject]? {
		let request = NSFetchRequest(entityName: managedEntityName)
		var error: NSError?
		let result = context.executeFetchRequest(request, error: &error)
		if result == nil {
			println("Error fetching \(NSStringFromClass(self)): \(error)")
			return nil
		} else {
			return result
		}
	}
	
	public class func insert(context: NSManagedObjectContext) -> AnyObject? {
        let name = managedEntityName
		let object = NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: context) as? ManagedObject
		return object
	}
	
    public class func controller(#context: NSManagedObjectContext) -> NSFetchedResultsController {
		let request = NSFetchRequest(entityName: managedEntityName)
		request.sortDescriptors = sortDescriptors
		let controller = NSFetchedResultsController(fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: sectionKeyPath,
			cacheName: nil)
		
		return controller
	}
}
