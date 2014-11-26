//
//  Client.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/1/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData
import ViewModelKit

class Client: ManagedObject {
    override class var managedEntityName: String { return "Client" }
    
    @NSManaged var name: String
    @NSManaged var projects: [Project]
	
	override class var sortDescriptors: [NSSortDescriptor] { return [NSSortDescriptor(key: "name", ascending: true)] }
}
