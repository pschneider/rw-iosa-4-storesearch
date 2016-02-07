//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Patrick Schneider on 11/12/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!

    // MARK: Properties
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded() { updateUI() }
        }
    }
    var downloadTask: NSURLSessionDownloadTask?

    enum AnimationStyle {
        case Slide
        case Fade
    }

    var isPopUp = false

    var dismissAnimationStyle = AnimationStyle.Fade

    // MARK: Life-Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10

        if isPopUp {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            view.backgroundColor = UIColor.clearColor()
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
            popupView.hidden = true

            if let displayName = NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String {
                title = displayName
            }
        }
        if let _ = searchResult {
            updateUI()
        }
    }

    deinit {
        print("Deinit: \(self)")
        downloadTask?.cancel()
    }

    func updateUI() {
        if let url = NSURL(string: searchResult.artworkURL100) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }

        nameLabel.text = searchResult.name

        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unkown", comment: "Unkown Artist Name")
        } else {
            artistNameLabel.text = searchResult.artistName
        }

        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre

        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency

        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.stringFromNumber(searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, forState: .Normal)

        popupView.hidden = false
        self.popupView.alpha = 0.0
        UIView.animateWithDuration(10, delay: 0.0, options: .CurveEaseIn, animations: {
            self.popupView.alpha = 1.0
        }, completion: nil)
    }

    // MARK: Actions
    @IBAction func close() {
        dismissAnimationStyle = .Slide
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func openInStore() {
        if let url = NSURL(string: searchResult.storeURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate
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

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissAnimationStyle {
        case .Slide:
            return SlideOutAnimationController()
        case .Fade:
            return FadeOutAnimationController()
        }
    }
}

// Dismiss by tapping outside of the popup view
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
