//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Patrick Schneider on 11/12/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    // MARK: Life-Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    // MARK: Actions
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(
        presented: UIViewController,
        presentingViewController presenting: UIViewController,
        sourceViewController source: UIViewController) -> UIPresentationController? {

        return DimmingPresentationController(
            presentedViewController: presented,
            presentingViewController: presenting
        )
    }
}
