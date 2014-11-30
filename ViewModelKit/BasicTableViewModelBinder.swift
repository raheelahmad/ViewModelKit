//
//  BasicTableViewModelBinder.swift
//  ViewModelKit
//
//  Created by Raheel Ahmad on 11/29/14.
//  Copyright (c) 2014 Sakun Labs. All rights reserved.
//

import Foundation

public class BasicTableViewModelBinder: TableViewModelBinder {
	public init() {
		
	}
	
	public func bind(viewModel: ResultsViewModel, tableView: UITableView) {
		viewModel.bind(.WillChange) { [unowned self] info in
			tableView.beginUpdates()
		}
		viewModel.bind(.DidChange) { [unowned self] info in
			tableView.endUpdates()
		}
		viewModel.bind(RowChangeType.Added) { [unowned self] info in
			let paths = info.map({ $0.path })
			tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Automatic)
		}
		viewModel.bind(RowChangeType.Deleted) { [unowned self] info in
			let paths = info.map({ $0.path })
			tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Automatic)
		}
		viewModel.bind(RowChangeType.Updated) { [unowned self] info in
			let paths = info.map({ $0.path })
			tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .Automatic)
		}
		viewModel.bind(RowChangeType.Moved) { [unowned self] info in
			let oldPaths = info.map({ $0.path })
			let newPaths = info.map({ $0.secondPath! })
			tableView.deleteRowsAtIndexPaths(oldPaths, withRowAnimation: .Automatic)
			tableView.insertRowsAtIndexPaths(newPaths, withRowAnimation: .Automatic)
		}
		viewModel.bind(SectionChangeType.Added) { [unowned self] info in
			let indexSet = NSIndexSet(index: info.index)
			tableView.insertSections(indexSet, withRowAnimation: .Automatic)
		}
		viewModel.bind(SectionChangeType.Deleted) { [unowned self] info in
			let indexSet = NSIndexSet(index: info.index)
			tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
		}
	}
	
	public func unbindAll(viewModel: ResultsViewModel) {
		viewModel.unbindAll()
	}
}
