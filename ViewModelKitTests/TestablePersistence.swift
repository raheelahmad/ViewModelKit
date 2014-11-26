//
//  TestablePersistence.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/2/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData

class TestablePersistence: Persistence {
    override func addStoreToCoordinator(coordinator: NSPersistentStoreCoordinator) {
        var error: NSError?
        let store = coordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil,
            URL: nil,
            options: nil, error: &error)
        if store == nil { println("Could not open store: \(error)") }
    }
    
    override var modelURL: NSURL! {
        let bundle = NSBundle(forClass: Persistence.self)
        let url = bundle.URLForResource(modelName, withExtension: "momd")
        return url
    }
    
    init() {
        super.init(appName: "ViewModelKit")
    }
}
