//
//  ItemListViewController.swift
//  ToDo
//
//  Created by Antonio da Silva on 13/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import UIKit

class ItemListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var dataProvider: (UITableViewDataSource & UITableViewDelegate)!
    
    override func viewDidLoad() {
        tableView?.dataSource = dataProvider
        tableView?.delegate = dataProvider
    }

}
