//
//  Search.swift
//  StoreSearch
//
//  Created by Patrick Schneider on 17/01/16.
//  Copyright © 2016 Patrick Schneider. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    enum State {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([SearchResult])
    }

    enum Category: Int {
        case All = 0
        case Music
        case Software
        case EBooks

        var entityName: String {
            switch self {
            case .All: return ""
            case .Music: return "musicTrack"
            case .Software: return "software"
            case .EBooks: return "ebook"
            }
        }
    }

    private var dataTask: NSURLSessionDataTask? = nil
    private(set) var state: State = .NotSearchedYet

    func performSearchForText(text: String, category: Category, completion: SearchComplete) {
        print("Searching...")
        if !text.isEmpty {
            dataTask?.cancel()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true

            state = .Loading

            let url = urlWithSearchText(text, category: category)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url) { (data, response, error) in
                self.state = .NotSearchedYet
                var success = false
                if let error = error where error.code == -999 {
                    return // search cancelled
                }
                if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200,
                    let data = data, dictionary = self.parseJSON(data) {
                        var searchResults = self.parseDictionary(dictionary)
                        if searchResults.isEmpty {
                            self.state = .NoResults
                        } else {
                            searchResults.sortInPlace(<)
                            self.state = .Results(searchResults)
                        }
                        success = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(success)
                }
            }
            dataTask?.resume()
        }
    }

    private func urlWithSearchText(searchText: String, category: Category) -> NSURL {
        let locale = NSLocale.autoupdatingCurrentLocale()
        let language = locale.localeIdentifier
        let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String

        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        let urlString = String(
            format: "https://itunes.apple.com/search?term=%@&entity=%@&limit=200&lang=%@&country=%@",
            escapedSearchText, category.entityName, language, countryCode)
        return NSURL(string: urlString)!
    }

    private func parseJSON(data: NSData) -> [String: AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }

    private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
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

    private func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
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

    private func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
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

    private func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
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

    private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
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
}