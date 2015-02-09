//
//  ResultsViewModel .swift
//  Epoch
//
//  Created by Raheel Ahmad on 10/30/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import Foundation
import ViewModelKit

public typealias RowChangeBlock = ([RowChangeInfo]) -> ()
public typealias SectionChangeBlock = (SectionChangeInfo) -> ()

public enum RowChangeType: String {
    case DidChange = "DidChange"
    case WillChange = "WillChange"
    case Added = "Added"
    case Deleted = "Deleted"
    case Moved = "Moved"
    case Updated = "Updated"
}

public enum SectionChangeType: String {
    case Added = "Added"
    case Deleted = "Deleted"
}

public struct RowChangeInfo {
	public let path: NSIndexPath
	public let secondPath: NSIndexPath?
	public let object: ManagedObject?
	public init(path: NSIndexPath, secondPath: NSIndexPath?, object: ManagedObject?) {
		self.path = path
		self.secondPath = secondPath
		self.object = object
	}
}

public struct SectionChangeInfo {
	public let index: Int
}

public protocol ViewModel: NSObjectProtocol {
	var count: Int { get }
	var sectionCount: Int { get }
	func rowsCountInSection(Int) -> Int
	func objectsInSection(Int) -> [ManagedObject]
    func objectAtIndexPath(NSIndexPath) -> ManagedObject?
}

public protocol Loadable: NSObjectProtocol {
    func load()
	func reload()
}

public protocol ResultsViewModel: ViewModel {
	var allObjects:  [ManagedObject] { get }
    func load()
	func reload()
	
    func bind(forRowChange: RowChangeType, onChange:RowChangeBlock)
    func bind(forSectionChange: SectionChangeType, onChange:SectionChangeBlock)
	func unbindAll()
    func unbind(forRowChangeType: RowChangeType)
    func unbind(forSectionChangeType: SectionChangeType)
	
	func titleForSection(sectionIndex: Int) -> String?
	
	func deleteObjectAtIndexPath(indexPath: NSIndexPath)
}
