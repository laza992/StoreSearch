//
//  Enums.swift
//  StoreSearch
//
//  Created by Lazar Stojkovic on 6/5/20.
//  Copyright © 2020 lazar. All rights reserved.
//

import Foundation

enum AnimationStyle {
    case slide
    case fade
}

enum Category: Int {
    case all = 0
    case music = 1
    case software = 2
    case ebooks = 3
    
    var type: String {
        switch self {
        case .all:
            return ""
        case .music:
            return "musicTrack"
        case .software:
            return "software"
        case .ebooks:
            return "ebook"
        }
    }
}

enum State {
    case notSearchedYet
    case loading
    case noResults
    case results([SearchResult])
}
