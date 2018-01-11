//
//  TableViewController.swift
//  Pods-RichEditorViewSample
//
//  Created by Nikolay Derkach on 1/12/18.
//

import Foundation

class TableViewController: UITableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		performSegue(withIdentifier: "Swift", sender: self)
	}
}
