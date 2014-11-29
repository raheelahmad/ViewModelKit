//
//  DataSource.swift
//  ViewModelKit
//
//  Created by Raheel Ahmad on 11/29/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import Foundation

@objc public protocol DataSource {
	func load()
	func reload()
}

