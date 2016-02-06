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

    private let displayNamesForKind = [
        "album": NSLocalizedString("Album", comment: "Localized kind: Album"),
        "audiobook": NSLocalizedString("Audiobook", comment: "Localized kind: Audiobook"),
        "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
        "ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
        "feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Movie"),
        "music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
        "podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
        "software": NSLocalizedString("App", comment: "Localized kind: App"),
        "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
        "tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
    ]

    func kindForDisplay() -> String {
        return displayNamesForKind[kind] ?? kind
    }
}