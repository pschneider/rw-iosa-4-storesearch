//
//  ViewController.swift
//  StoreSearch
//
//  Created by Patrick Schneider on 03/12/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Properties
    var searchResults = [SearchResult]()
    var hasSearched = false // could also be done with optionals

    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.becomeFirstResponder()

        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80

        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)

        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Networking
    func performStoreRequestWithURL(url: NSURL) -> String? {
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }

    func showNetworkError() {
        let alert = UIAlertController(title: "Whooops...", message: "There was an error reading from the iTunes Store. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)

        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: Helper
    func urlWithSearchText(searchText: String) -> NSURL {
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        return NSURL(string: urlString)!
    }

    func parseJSON(jsonString: String) -> [String: AnyObject]? {
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }

        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }

    }
}

// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            hasSearched = true
//            searchResults = [SearchResult]()

            let url = urlWithSearchText(searchBar.text!)
            print("URL: \(url)")

            if let jsonString = performStoreRequestWithURL(url),
                let dictionary = parseJSON(jsonString) {
                    print("Dictionary: \(dictionary)")

                    tableView.reloadData()
                    return
            }
            showNetworkError()
        }
    }

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {

}

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell

            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName

            return cell
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }
        return searchResults.count == 0 ? 1 : searchResults.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

