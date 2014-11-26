//
//  NSEntityDescription.swift
//  Epoch
//
//  Created by Raheel Ahmad on 11/9/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import CoreData

extension NSEntityDescription {
	
	func isValidRelationshipName(name: String) -> Bool {
		var matchingRelationship = false
		if let relationships = relationshipsByName as? [String: NSRelationshipDescription] {
			for (relationName, _) in relationships {
				if name == relationName {
					matchingRelationship = true
				}
			}
		}
		return matchingRelationship
	}
	
	func isValidAttributeName(name: String) -> Bool {
		var matchingAttribute = false
		if let attributes = attributesByName as? [String: NSAttributeDescription] {
			for (attributeName, _) in attributes {
				if name == attributeName {
					matchingAttribute = true
				}
			}
		}
		return matchingAttribute
	}
	
}
