//
//  Project.swift
//  Epoch
//
//  Created by Raheel Ahmad on 10/27/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import ViewModelKit

class Project: ManagedObject, Printable {
    override class var managedEntityName: String { return "Project" }
    override class var sortDescriptors: [NSSortDescriptor] {
        return [ NSSortDescriptor(key: "name", ascending: true) ]
    }
	
    @NSManaged var name: String
    @NSManaged var type: String?
    @NSManaged var client: Client?
	
	override var description: String {
		return "Project: \(name). Client \(client?.name)"
	}
}
