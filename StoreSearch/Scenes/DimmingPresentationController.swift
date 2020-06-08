//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Lazar Stojkovic on 6/5/20.
//  Copyright © 2020 lazar. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    // MARK: - Properties
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    // MARK: - Public Methods
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        // Animate background gradient view
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin()  {
        if let coordinator = presentedViewController.transitionCoordinator {coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
        }
    }
}
