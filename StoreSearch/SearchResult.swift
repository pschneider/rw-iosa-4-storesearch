//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Patrick Schneider on 03/12/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import Foundation

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}

func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedDescending
}

class SearchResult {
    var name = ""
    var artistName = ""

    var artworkURL60 = ""
    var artworkURL100 = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
}