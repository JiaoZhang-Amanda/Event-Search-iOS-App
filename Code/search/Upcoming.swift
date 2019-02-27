//
//  Upcoming.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/24.
//  Copyright © 2018 Amanda. All rights reserved.
//

import Foundation

struct Upcoming: Decodable {
    let resultsPage: Resp
}

struct Resp: Decodable {
    let results: Res
}

struct Res: Decodable {
    let event: [UpComingEvent]?
}

struct UpComingEvent: Decodable {
    let displayName: String //Name
    let uri: String //uri
    let performance: [Per]
    let start: Start //date & time
    let type: String //type
}

struct Start: Decodable {
    let date: String?
    let time: String?
}
struct Per: Decodable {
    let displayName: String //artist
    
}

