//
//  Photo.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/23.
//  Copyright © 2018 Amanda. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    let link: String
}
