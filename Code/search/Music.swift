//
//  Music.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/24.
//  Copyright © 2018 Amanda. All rights reserved.
//

import Foundation

struct Music: Decodable {
    let artists: Artist
}

struct Artist: Decodable {
    let items: [Items]
}

struct Items: Decodable {
    let name: String   //m_name
    let followers: Follower
    let popularity: Int  //m_pop
    let external_urls: Url
}

struct Follower: Decodable {
    let total: Int  //m_foll
}

struct Url: Decodable {
    let spotify: String //m_check
}
