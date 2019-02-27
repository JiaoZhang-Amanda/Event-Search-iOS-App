//
//  Favorite.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/27.
//  Copyright © 2018 Amanda. All rights reserved.
//

import Foundation

struct Favorite: Codable {
    var f_name: String
    var f_icon: String
    var f_venue: String
    var f_time: String
    
    var d_AT: String?
    var d_category: String?
    var d_minPrice: Float?
    var d_maxPrice: Float?
    var d_ticketStatus: String?
    var d_ticketLink: String?
    var d_seat: String?
    var v_address: String?
    var v_city: String?
    var v_state: String?
    var v_phone: String?
    var v_open: String?
    var v_general: String?
    var v_child: String?
    //var f_data: String
    
    init(my_icon: String = "", //
        my_name: String = "",
        my_venue: String = "",
        my_time: String = "") {
        
        self.f_icon = my_icon
        self.f_name = my_name
        self.f_venue = my_venue
        self.f_time = my_time
        //self.f_data = my_data
        
    }
}
