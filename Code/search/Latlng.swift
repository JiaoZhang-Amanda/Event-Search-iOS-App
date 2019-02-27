//
//  Latlng.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/27.
//  Copyright © 2018 Amanda. All rights reserved.
//

import Foundation

struct Latlng: Decodable {
    let results: [L_Res]
}

struct L_Res: Decodable {
    let geometry: L_geo
}

struct L_geo: Decodable {
    let location: [String: Double]
}
