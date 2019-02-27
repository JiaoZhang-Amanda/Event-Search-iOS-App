//
//  DetailViewController.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/22.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import Kingfisher
import EasyToast
import WebKit

class DetailViewController: UITabBarController {
    //get the detail data from the result table
    var d_AT: String = ""
    var d_Venue: String?   //venue name
    var d_time: String?
    var d_data: String?
    var d_category: String?
    var d_minPrice: Float?
    var d_maxPrice: Float?
    var d_ticketStatus: String?
    var d_ticketLink: String?
    var d_seat: String?
    var segment = String()
    
    //venue delated data
    var v_address: String?
    var v_city: String?
    var v_state: String?
    var v_phone: String?
    var v_open: String?
    var v_genre: String?
    var v_child: String?
    
    //isFav
    var f_name = String()  //event name
    var f_data = String()  //data and time
    var f_icon = String()
    var fav_button = UIBarButtonItem()
    var isFav: Bool = false
    
    override func viewDidLoad() {
        print("4: ", isFav)
        super.viewDidLoad()
        //isFav or not

        isFavFun()
        addNavImg()
        let firstVC = (storyboard?.instantiateViewController(withIdentifier: "info"))! as UIViewController
        let secontVC = (storyboard?.instantiateViewController(withIdentifier: "art"))! as UIViewController
        let thirdVC = (storyboard?.instantiateViewController(withIdentifier: "venue"))! as UIViewController
        let forthVC = (storyboard?.instantiateViewController(withIdentifier: "upcoming"))! as UIViewController
        
        firstVC.tabBarItem.title = "Info"
        secontVC.tabBarItem.title = "Artist"
        thirdVC.tabBarItem.title = "Venue"
        forthVC.tabBarItem.title = "Upcoming"
        
        firstVC.tabBarItem.image = UIImage(named: "info")
        secontVC.tabBarItem.image = UIImage(named: "contacts")
        thirdVC.tabBarItem.image = UIImage(named: "location")
        forthVC.tabBarItem.image = UIImage(named: "calendar")
        
        viewControllers = [firstVC, secontVC, thirdVC, forthVC]

        // Do any additional setup after loading the view.
    }
    
    func isFavFun() {
        var get_fav = [Favorite]()
        if let fav = UserDefaults.standard.value(forKey:"myfavorite") as? Data {
            let one_fav = try? PropertyListDecoder().decode(Array<Favorite>.self, from: fav)
            get_fav = one_fav!
            //print("FAvorite: ", one_fav)
        }
        for f in get_fav {
            let data_time = f.f_time.components(separatedBy: " ")
            let data = data_time[0]
            let time = data_time[1]
            if f.f_venue == d_Venue && f.f_name == f_name && data == d_data && time == d_time {
                self.isFav = true
            }
        }
    }
    
    func addNavImg() {
        
        if isFav {
            fav_button = UIBarButtonItem(image: UIImage(named: "favorite-filled"), style: .plain, target: self, action: #selector(self.clickFav))
        }else {
            fav_button = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(self.clickFav))
        }

        let twitter = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(self.shareTwitter))
        
        self.navigationItem.setRightBarButtonItems([fav_button, twitter], animated: true)

        
    }
    @objc func clickFav() {
        var get_fav = [Favorite]()
        if let fav = UserDefaults.standard.value(forKey:"myfavorite") as? Data {
            let one_fav = try? PropertyListDecoder().decode(Array<Favorite>.self, from: fav)
            get_fav = one_fav!
            //print("FAvorite: ", one_fav)
        }
        
        if self.isFav {
            
            //refresh the favorite list
            var tmp_rm = Favorite()
            tmp_rm.f_name = self.f_name
            tmp_rm.f_venue = self.d_Venue!
            tmp_rm.f_time = self.f_data
            tmp_rm.f_icon = self.f_icon
            let remove_fav = get_fav.filter { $0.f_name != tmp_rm.f_name }
            UserDefaults.standard.set(try? PropertyListEncoder().encode(remove_fav), forKey:"myfavorite")
            
            //change the favorite icon
            fav_button.image = UIImage(named: "favorite-empty")
            self.isFav = false
            self.view.showToast(d_AT+" was remove to favorite", position: .bottom, popTime: 3, dismissOnTap: true)

        }else {
            //refresh the favorite list
            var tmp = Favorite()
            tmp.f_name = self.f_name
            tmp.f_venue = self.d_Venue!
            tmp.f_time = self.f_data
            tmp.f_icon = self.f_icon
            tmp.d_AT = self.d_AT
            tmp.d_category = self.d_category
            tmp.d_minPrice = self.d_minPrice
            tmp.d_maxPrice = self.d_maxPrice
            tmp.d_ticketStatus = self.d_ticketStatus
            tmp.d_ticketLink = self.d_ticketLink
            tmp.d_seat = self.d_seat
            tmp.v_address = self.v_address
            tmp.v_city = self.v_city
            tmp.v_state = self.v_state
            tmp.v_phone = self.v_phone
            tmp.v_open = self.v_open
            tmp.v_general = self.v_genre
            tmp.v_child = self.v_child
            get_fav.append(tmp)
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(get_fav), forKey:"myfavorite")
            
            fav_button.image = UIImage(named: "favorite-filled")
            self.isFav = true
            self.view.showToast(d_AT+" was added to favorite", position: .bottom, popTime: 3, dismissOnTap: true)

        }
    }
    
    @objc func shareTwitter() {
        let str1 = "Check out " + self.d_AT
        let str2 = " located at " + self.d_Venue! + ". Website: "
        let str3 = self.d_ticketLink! + "#CSCI571EventSearch"
        let str = str1 + str2 + str3
        let urlKW = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        if let url = URL(string: "https://twitter.com/intent/tweet?text=" + urlKW!) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let back_data = segue.source as? SearchViewController
        back_data?.show_data[(back_data?.seleted_index)!].fav = self.isFav
    }
    




}
