//
//  NSFetchedResultsController.swift
//  Epoch
//
//  Created by Raheel Ahmad on 10/28/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData

public extension NSFetchedResultsController {
    func fetch() {
        var error: NSError?
        if !performFetch(&error) {
            println("Error fetching: \(error)")
        }
    }
}
