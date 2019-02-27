//
//  Id.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/24.
//  Copyright © 2018 Amanda. All rights reserved.
//

import Foundation

struct Id: Decodable {
    let resultsPage: Results
}

struct Results: Decodable {
    let results: Ress
}

struct Ress: Decodable {
    let venue: [Venues]
}

struct Venues: Decodable {
    let id: Int
    init(id: Int = -1) {
        self.id = id
    }
}
