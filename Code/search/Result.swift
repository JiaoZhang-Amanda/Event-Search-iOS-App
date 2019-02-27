//
//  Result.swift
//  search
//
//  Created by mac on 2018/11/20.
//  Copyright © 2018 Amanda. All rights reserved.
//

import Foundation

struct Result: Decodable{
    let _embedded: Embed?
}
struct Embed: Decodable {
    let events: [Event]
}
struct Event: Decodable {
    let _embedded: Em
    let dates: Dates
    let name: String //name of event
    let classifications: [Classfy]
    let priceRanges: [Price?]?
    let url: String //buy at
    let seatmap: Seat?
}
struct Seat: Decodable {
    let staticUrl: String //seat map url
}
struct Price: Decodable {
    let min: Float
    let max: Float
}
struct Em: Decodable {
    let attractions: [Att]  //
    let venues: [Venue]
    
}
struct Att: Decodable {
    let name: String
}
struct Classfy: Decodable {
    let segment: Genre
    let genre: Gen
}
struct Gen: Decodable {
    let name: String  //genre name
}
struct Genre: Decodable {
    let name: String  //segment name: category
}
struct Venue: Decodable {
    let address: [String: String]
    let city: City
    let state: [String: String]
    let boxOfficeInfo: [String: String]?
    let generalInfo: [String: String]?
    let name: String   //venue name
    
}
struct City: Decodable {
    let name: String
}
struct Address: Decodable {
    let line1: String
}
struct Dates: Decodable {
    let start: StartDate
    let status: Statu
}
struct Statu: Decodable {
    let code: String //ticket statue
}
struct StartDate: Decodable {
    let localDate: String  //local date
    let localTime: String //local time
}
