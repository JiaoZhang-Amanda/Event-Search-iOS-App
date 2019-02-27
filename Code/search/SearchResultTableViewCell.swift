//
//  SearchResultTableViewCell.swift
//  search
//
//  Created by mac on 2018/11/22.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import EasyToast

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var event_name: UILabel!
    @IBOutlet weak var venue_name: UILabel!
    @IBOutlet weak var data_time: UILabel!
    @IBOutlet weak var category_img: UIImageView!
    @IBOutlet weak var fav_img: UIImageView!
    var isFav: Bool = false
    var icon: String = ""
    var d_AT: String = ""
    var d_category: String = ""
    var d_min: Float?
    var d_max: Float?
    var d_ticketStatus = String()
    var d_ticketLink = String()
    var d_seat: String?
    var v_address: String?
    var v_city: String = ""
    var v_state: String = ""
    var v_phone: String?
    var v_open: String?
    var v_general: String?
    var v_child: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedMe))
        fav_img.addGestureRecognizer(tap)
        fav_img.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func tappedMe()
    {
        var get_fav = [Favorite]()
        if let fav = UserDefaults.standard.value(forKey:"myfavorite") as? Data {
            let one_fav = try? PropertyListDecoder().decode(Array<Favorite>.self, from: fav)
            get_fav = one_fav!
            //print("FAvorite: ", one_fav)
        }
        
        //var fav = UserDefaults.standard.array(forKey: "myfavorite") as? [Favorite] ?? [Favorite]()
        
        if self.isFav {
            
            //refresh the favorite list
            var tmp_rm = Favorite()
            tmp_rm.f_name = event_name.text!
            tmp_rm.f_venue = venue_name.text!
            tmp_rm.f_time = data_time.text!
            tmp_rm.f_icon = icon
            let remove_fav = get_fav.filter { $0.f_name != tmp_rm.f_name }
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(remove_fav), forKey:"myfavorite")
            
            //change the favorite icon
            self.fav_img.image = UIImage(named: "favorite-empty")
            self.isFav = false
            
//            makeToast("This is a piece of toast", duration: 3.0, position: .bottom){
//                didTap in {
//                    if didTap {
//                        print("completion from tap")
//                    } else {
//                        print("completion without tap")
//                    }
//                }
//            }popTime: 5,
            showToast(event_name.text!+" was remove to favorite", position: .bottom, popTime: 3, dismissOnTap: true)
        }else {
            //refresh the favorite list
            var tmp = Favorite()
            tmp.f_name = event_name.text!
            tmp.f_venue = venue_name.text!
            tmp.f_time = data_time.text!
            tmp.f_icon = icon
            tmp.d_AT = d_AT
            tmp.d_category = d_category
            tmp.d_minPrice = d_min
            tmp.d_maxPrice = d_max
            tmp.d_ticketStatus = d_ticketStatus
            tmp.d_ticketLink = d_ticketLink
            
            tmp.d_seat = d_seat
            tmp.v_address = v_address
            tmp.v_city = v_city
            tmp.v_state = v_state
            tmp.v_phone = v_phone
            tmp.v_open = v_open
            tmp.v_general = v_general
            tmp.v_child = v_child
            
            get_fav.append(tmp)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(get_fav), forKey:"myfavorite")
            
            //change the favorite icon
            self.fav_img.image = UIImage(named: "favorite-filled")
            self.isFav = true
            showToast(event_name.text!+" was added to favorite", position: .bottom, popTime: 3, dismissOnTap: true)

        }

        //print("1: is_Fav:", isFav)
    }
    
    

    
    
    
    

}
