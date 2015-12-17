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

    override func viewDidLoad() {
        super.viewDidLoad()

        // convert layout to auto layout constraints by UIKit
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true

        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true

        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true

        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.contentSize = CGSize(width: 1000, height: 1000)

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
