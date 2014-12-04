//
//  ManagedObjectContext.swift
//  ViewModelKit
//
//  Created by Raheel Ahmad on 12/3/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    public func performRequest(request: NSFetchRequest) -> [ManagedObject] {
        var error: NSError?
        var result = executeFetchRequest(request, error: &error)
        if result == nil {
            println("Error fetching: \(result)")
            result = []
        }
        return result as [ManagedObject]
    }
}
