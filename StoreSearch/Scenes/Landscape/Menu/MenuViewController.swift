//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Lazar Stojkovic on 6/8/20.
//  Copyright © 2020 lazar. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class {
    func menuViewControllerSendEmail(_ controller: MenuViewController)
}

class MenuViewController: UITableViewController {

    // MARK: - Properties
    
    weak var delegate: MenuViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendEmail(self)
        }
    }

}
