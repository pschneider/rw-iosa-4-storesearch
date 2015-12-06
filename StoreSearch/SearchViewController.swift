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
        static let loadingCell = "LoadingCell"
    }

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Properties
    var searchResults = [SearchResult]()
    var hasSearched = false // could also be done with optionals
    var isLoading = false

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

        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)

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

        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
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

    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()

        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String

        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }

    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()

        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String

        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }

    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()

        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String

        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }

    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()

        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String

        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genres: AnyObject  = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        return searchResult
    }

    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [AnyObject] else {
            print("Expected 'results' array")
            return []
        }

        var searchResults = [SearchResult]()

        for resultDict in array {
            if let resultDict = resultDict as? [String: AnyObject] {
                var searchResult: SearchResult?
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = parseTrack(resultDict)
                    case "audiobook":
                        searchResult = parseAudioBook(resultDict)
                    case "software":
                        searchResult = parseSoftware(resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String where kind == "ebook" {
                    searchResult = parseEBook(resultDict)
                }
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }

    func kindForDisplay(kind: String) -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audiobook"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }
}

// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()

            isLoading = true
            tableView.reloadData()

            hasSearched = true
            searchResults = [SearchResult]()

            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

            dispatch_async(queue) {
                let url = self.urlWithSearchText(searchBar.text!)
                print("URL: \(url)")

                if let jsonString = self.performStoreRequestWithURL(url),
                    let dictionary = self.parseJSON(jsonString) {
                        self.searchResults = self.parseDictionary(dictionary)

                        // searchResults.sortInPlace({ (result1, result2) -> Bool in
                        //    return result1.name.localizedStandardCompare(result2.name) == .OrderedAscending
                        // })
                        // searchResults.sortInPlace {
                        //     $0.name.localizedStandardCompare($1.name) == .OrderedAscending
                        // }
                        self.searchResults.sortInPlace(<)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNetworkError()
                }
            }
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

        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell

            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name

            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unkown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
            }

            return cell
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        }
        return searchResults.count == 0 ? 1 : searchResults.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}

