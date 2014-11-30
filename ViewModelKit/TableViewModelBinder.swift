//
//  TableViewModelBinder.swift
//  ViewModelKit
//
//  Created by Raheel Ahmad on 11/29/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import Foundation

public protocol TableViewModelBinder {
	func bind(viewModel: ResultsViewModel, tableView: UITableView)
	func unbindAll(viewModel: ResultsViewModel)
}
