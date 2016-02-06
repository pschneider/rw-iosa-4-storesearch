//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Patrick Schneider on 16/12/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    // MARK: Properties
    var search: Search!
    private var firstTime = true
    private var downloadTasks = [NSURLSessionDownloadTask]()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // convert layout to auto layout constraints by UIKit
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true

        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        pageControl.numberOfPages = 0

        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true

        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scrollView.frame = view.bounds

        pageControl.frame = CGRect(
            x: 0,
            y: view.frame.size.height - pageControl.frame.size.height,
            width: view.frame.size.width,
            height: pageControl.frame.size.height
        )

        if firstTime {
            firstTime = false
            switch search.state {
            case .NotSearchedYet: break
            case .NoResults: showNothingFoundLabel()
            case .Loading: showSpinner()
            case .Results(let list): tileButtons(list)
            }
        }
    }

    deinit {
        print("Deinit \(self)")
        for task in downloadTasks {
            task.cancel()
        }
    }

    // MARK: API
    func searchResultsRecieved() {
        hideSpinner()
        switch search.state {
        case .NotSearchedYet, .Loading: break
        case .NoResults: showNothingFoundLabel()
        case .Results(let list): tileButtons(list)
        }
    }

    // MARK: Helper
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.center = CGPoint(
            x: CGRectGetMidX(scrollView.bounds) + 0.5,
            y: CGRectGetMidY(scrollView.bounds) + 0.5)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }

    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Nothing Found", comment: "No search result")
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.clearColor()
        label.sizeToFit()

        var rect = label.frame
        rect.size.width = ceil(rect.size.width/2) * 2 // make even
        rect.size.height = ceil(rect.size.height/2) * 2 // make even
        label.frame = rect
        label.center = CGPoint(x: CGRectGetMidX(scrollView.bounds), y: CGRectGetMidY(scrollView.bounds))
        view.addSubview(label)


    }

    private func tileButtons(searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20

        let scrollViewWidth = scrollView.bounds.size.width
        switch scrollViewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }

        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2

        var row = 0
        var column = 0
        var x = marginX
        for (index, searchResult) in searchResults.enumerate() {
            let button = UIButton(type: .Custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), forState: .Normal)
            button.tag = 2000 + index
            button.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
            downloadImageForSearchResult(searchResult, andPlaceOnButton: button)
            button.frame = CGRect(
                x: x + paddingHorz,
                y: marginY + CGFloat(row)*itemHeight + paddingVert,
                width: buttonWidth,
                height: buttonHeight)
            scrollView.addSubview(button)

            row += 1
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }

        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * scrollViewWidth,
            height: scrollView.bounds.size.height)

        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0

        print("Number of Pages: \(numPages)")
    }

    private func downloadImageForSearchResult(searchResult: SearchResult, andPlaceOnButton button: UIButton) {
        guard let url = NSURL(string: searchResult.artworkURL60) else { return }

        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL(url) { [weak button] url, response, error in
            if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                dispatch_async(dispatch_get_main_queue()) {
                    if let button = button {
                        button.setImage(image.resizeImageWithBounds(CGSize(width: 60, height: 60)), forState: .Normal)
                    }
                }
            }
        }
        downloadTask.resume()
        downloadTasks.append(downloadTask)
    }

    // MARK: Actions
    @IBAction func pageChanged(sender: UIPageControl) {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
            self.scrollView.contentOffset = CGPoint(
                x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                y: 0)

            },
            completion: nil)
    }

    func buttonPressed(sender: UIButton) {
        performSegueWithIdentifier("ShowDetail", sender: sender)
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if case .Results(let list) = search.state {
                let controller = segue.destinationViewController as! DetailViewController
                controller.searchResult = list[sender!.tag - 2000]
                controller.isPopUp = true
            }
        }
    }

}

// MARK: UIScrollViewDelegate
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
        pageControl.currentPage = currentPage
    }
}
