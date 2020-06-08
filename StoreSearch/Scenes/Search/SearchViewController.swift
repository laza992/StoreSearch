//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Lazar Stojkovic on 6/4/20.
//  Copyright © 2020 lazar. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    
    var landscapeVC: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?
    
    private let search = Search()
    
    let searchResultCell = "SearchResultCell"
    let nothingFoundCell = "NothingFoundCell"
    let loadingCell = "LoadingCell"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Search", comment: "split view master button")
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: searchResultCell, bundle: nil), forCellReuseIdentifier: searchResultCell)
        tableView.register(UINib(nibName: nothingFoundCell, bundle: nil), forCellReuseIdentifier: nothingFoundCell)
        tableView.register(UINib(nibName: loadingCell, bundle: nil), forCellReuseIdentifier: loadingCell)
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        setupSegmentUI()
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        let rect = UIScreen.main.bounds
        if (rect.width == 812 && rect.height == 375) ||   // portrait
            (rect.width == 375 && rect.height == 812) {    // landscape
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
            switch newCollection.verticalSizeClass {
            case .compact:
                showLandscape(with: coordinator)
            case .regular, .unspecified:
                hideLandscape(with: coordinator)
            default: break
            }
        }
    }
    
    // MARK:- Private Methods
    
    private func setupSegmentUI() {
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ColorHelper.themeColor], for: .normal)
        segmentedControl.selectedSegmentTintColor = ColorHelper.themeColor
        segmentedControl.backgroundColor = .white
    }
    
    private func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChild(controller)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParent: self)
            })
        }
    }
    
    private func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
        }
    }
    
    private func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .primaryHidden
        }, completion: { _ in
            self.splitViewController!.preferredDisplayMode = .automatic
        })
    }
    
    // MARK: - Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if let category = Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(for: searchBar.text!, category: category, completion:{success in
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
            })
            tableView.reloadData()
            self.landscapeVC?.searchResultsReceived()
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
            
        case .loading:
            let cell = tableView.dequeueReusableCell( withIdentifier: loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .noResults:
            return tableView.dequeueReusableCell( withIdentifier: nothingFoundCell, for: indexPath)
            
        case .results(let list):
            let cell = tableView.dequeueReusableCell( withIdentifier: searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { tableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
            
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            if splitViewController!.displayMode != .allVisible {
                hideMasterPane()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
}
