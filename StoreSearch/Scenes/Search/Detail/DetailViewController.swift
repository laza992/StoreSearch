//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Lazar Stojkovic on 6/5/20.
//  Copyright © 2020 lazar. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    // MARK: - Properties
    
    var downloadTask: URLSessionDownloadTask?
    var dismissStyle = AnimationStyle.fade
    var isPopUp = false
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    deinit {
        downloadTask?.cancel()
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMenu" {
            let controller = segue.destination as! MenuViewController
            controller.delegate = self
        }
    }
    
    // MARK: - Private methods
    
    private func setup() {
        popupView.layer.cornerRadius = 10
        if isPopUp {
          let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            
          gestureRecognizer.cancelsTouchesInView = false
          gestureRecognizer.delegate = self
          view.addGestureRecognizer(gestureRecognizer)
          view.backgroundColor = UIColor.clear
        } else {
          view.backgroundColor = UIColor(patternImage:UIImage(named: "LandscapeBackground")!)
          popupView.isHidden = true
          if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            title = displayName
          }
        }
        if searchResult != nil {
            updateUI()
        }
    }
    
    private func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        // Show price
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        // Get image
        
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        popupView.isHidden = false
        priceButton.setTitle(priceText, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func close(_ sender: Any) {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DetailViewController: UIGestureRecognizerDelegate {
    private func gestureRecognizer(shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
}

// MARK: - MenuViewControllerDelegate

extension DetailViewController: MenuViewControllerDelegate {
    func menuViewControllerSendEmail(_: MenuViewController) {
        dismiss(animated: true) {
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject"))
                controller.setToRecipients(["your@email-address-here.com"])
                controller.mailComposeDelegate = self
                controller.modalPresentationStyle = .formSheet
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension DetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
