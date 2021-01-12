//
//  SearchResponse.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    var resultCount: Int?
    var results: [Track]?
}

struct Track: Codable {
    var trackName: String?
    var collectionName: String?
    var artistName: String?
    var artworkUrl100: String?
    var previewUrl: String?
}
