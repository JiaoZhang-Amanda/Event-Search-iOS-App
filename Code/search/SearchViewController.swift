//
//  SearchViewController.swift
//  search
//
//  Created by mac on 2018/11/20.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftSpinner



struct result_data {
    var r_icon: String  //category image; d_segement
    var r_name: String  //name of the event
    var r_venue: String // name of the venue; d_Venue
    var r_time: String  // time of event; d_time
    var r_data: String  //data of event; d_data
    var fav: Bool
    var r_fav: String  //favorite image
    
    //detail related
    var d_AT: String
    var d_category: String?
    var d_minPrice: Float?
    var d_maxPrice: Float?
    var d_ticketStatus: String?
    var d_ticketLink: String?
    var d_seat: String?
    
    //venue data
    var v_address: String?
    var v_city: String?
    var v_state: String?
    var v_phone: String?
    var v_open: String?
    var v_genre: String?
    var v_child: String?
    
    init(my_icon: String = "", //
        my_name: String = "",
        my_venue: String = "",
        my_time: String = "",
        my_data: String = "",
        my_fav: Bool = false,
        my_fav_im: String = "", my_AT: String = "") {
        
        self.r_icon = my_icon
        self.r_name = my_name
        self.r_venue = my_venue
        self.r_time = my_time
        self.r_data = my_data
        self.fav = my_fav
        self.r_fav = my_fav_im
        self.d_AT = my_AT
        
    }
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //get data from the form
    var _keyword = String()
    var _category = String()
    var _distance = String()
    var _unit = String()
    var _isInputLoc = Bool()
    var _Loc = String()
    var _lat = Double()
    var _lng = Double()
    
    //useful json data
    var show_data = [result_data]()
    
    var seleted_index = 0

    @IBOutlet weak var noResult: UIView!
    @IBOutlet weak var result_table: UITableView!
    //!!!text
    var imagin = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noResult.isHidden = true
        SwiftSpinner.show("Searching for events")
        result_table.dataSource = self
        result_table.dataSource = self
        result_table.rowHeight = UITableView.automaticDimension
        result_table.estimatedRowHeight = 10
        if _isInputLoc {
            searchLatLng(add: _Loc)
        }else {
            search_json()
        }
        
        //navigationItem.backBarButtonItem
        //self.navigationItem.backBarButtonItem.action = #selector(backData());
        //!!!text
        //text.text = "keyword: " + _keyword
//        print("keyword: ", _keyword)
//        print("category: ", _category)
//        print("distance: ", _distance)
//        print("unit: ", _unit)
//        print("isUserInput: ", _isInputLoc)
//        print("Loc: ", _Loc)
//        print("lat: ", _lat)
//        print("lng: ", _lng)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        favHelp()

    }
    
    func favHelp() {
        show_data = show_data.sorted(by: { $0.r_data < $1.r_data })
        print("!!!To seach Favorite")
        var get_fav = [Favorite]()
        if let fav = UserDefaults.standard.value(forKey:"myfavorite") as? Data {
            let one_fav = try? PropertyListDecoder().decode(Array<Favorite>.self, from: fav)
            get_fav = one_fav!
            //print("Get the Favorite: ", get_fav)
            //f_name: "P!NK: BEAUTIFUL TRAUMA WORLD TOUR", f_icon: "music", f_venue: "The Forum", f_time: "2019-04-19 19:30:00"
        }
        if get_fav.count == 0 {
            for index in 0..<show_data.count {
                self.show_data[index].r_fav = "favorite-empty"
                self.show_data[index].fav = false
            }
        }else {
            for index in 0..<show_data.count {
                //print("Get the data: ", re)
                //r_icon: "music", r_name: "P!NK: BEAUTIFUL TRAUMA WORLD TOUR", r_venue: "The Forum", r_time: "19:30:00", r_data: "2019-04-19"
                for f in get_fav {
                    let data_time = f.f_time.components(separatedBy: " ")
                    let data = data_time[0]
                    let time = data_time[1]
                    print(data)
                    print(time)
                    if f.f_venue == self.show_data[index].r_venue && f.f_name == self.show_data[index].r_name && data ==  self.show_data[index].r_data && time == self.show_data[index].r_time{
                        self.show_data[index].r_fav = "favorite-filled"
                        self.show_data[index].fav = true
                        break
                    }else{
                        print("no Favorite")
                        self.show_data[index].r_fav = "favorite-empty"
                        self.show_data[index].fav = false
                    }
                }
            }
        }
        
        self.result_table.reloadData()
    }
    
    func searchLatLng(add: String) {
        let urlString = add.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let lt_url = "http://jiaozhangHW8.us-east-2.elasticbeanstalk.com/api/location?location="+urlString!
        guard let url = URL(string: lt_url) else { return }
        let list = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                //SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.view.showToast("Search Latitude and longitude error", position: .bottom, popTime: 2, dismissOnTap: true)
                }
                print("Search Latitude and longitude error")
            }else {
                if let content = data {
                    do {
                        //                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //                        print(myJson)
                        let res = try JSONDecoder().decode(Latlng.self, from: content)
                        
                        self._lat = res.results[0].geometry.location["lat"]!
                        self._lng =  res.results[0].geometry.location["lng"]!
                        print("lat: ",self._lat)
                        print("lng: ",self._lng)
                        DispatchQueue.main.async {
                            self.search_json()
                        }
                        
                    }catch let error as NSError {
                        DispatchQueue.main.async {
                            self.view.showToast("serailization error", position: .bottom, popTime: 2, dismissOnTap: true)
                        }
                        print("Error serailization json:", error)
                    }
                }
            }
        }
        list.resume()
    }
    
    func search_json() {
        //text
        if let url = URL(string: "http://csci571.com/hw/hw8/Images/Twitter.png") {
            do {
                let data = try Data(contentsOf: url)
                imagin.append(UIImage(data: data)!)
                imagin.append(UIImage(data: data)!)
            }catch {
                
            }
        }
        
        //get segmentId
        var _segmentId = String()
        if _category == "Music" {_segmentId = "KZFzniwnSyZfZ7v7nJ"}
        else if _category == "Sports" {_segmentId = "KZFzniwnSyZfZ7v7nE"}
        else if _category == "Arts & Theatre" {_segmentId = "KZFzniwnSyZfZ7v7na"}
        else if _category == "Film" {_segmentId = "KZFzniwnSyZfZ7v7nn"}
        else if _category == "Miscellaneous" {_segmentId = "KZFzniwnSyZfZ7v7n1"}
        
        //domain url
        let domain = "http://jiaozhangHW8.us-east-2.elasticbeanstalk.com/api/events?"
        
        //let kw = "keyword=pink"
        let urlKW = _keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let kw = "keyword="+urlKW!

        let seg = "&segmentId="+_segmentId
        let rad = "&radius="+_distance
        var ut = ""
        if _unit == "miles"{
            ut = "&unit="+_unit
        }else {
            ut = "&unit=km"
        }
        
        
        let latlng = "&lat="+_lat.description+"&lng="+_lng.description
        let url_string = domain + kw + seg + rad + ut + latlng
        print("!!!",url_string)

        //search for result
        guard let url = URL(string: url_string
            ) else { return }
        print("!!!",url)
        let list = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.view.showToast("Search result error", position: .bottom, popTime: 2, dismissOnTap: true)
                }
                print("Search result error")
            }else {
                if let content = data {
                    do {
                        //let myJson = try JSONSerialization.jsonObject(with: content, options: [])
                        let res = try JSONDecoder().decode(Result.self, from: content)
                        
                        if res._embedded == nil {
                            //no result
                            print("No result")
                           DispatchQueue.main.async { self.noResult.isHidden = false
                            self.result_table.isHidden = true}
                        }else {
                            for e in (res._embedded?.events)! {
                                var tmp_res = result_data()
                                tmp_res.r_data = e.dates.start.localDate
                                tmp_res.r_time = e.dates.start.localTime
                                tmp_res.r_name = e.name
                                for v in e._embedded.venues {
                                    tmp_res.r_venue = v.name
                                }
                                
                                for c in e.classifications {
                                    let gen = c.genre.name
                                    let cat = c.segment.name
                                    tmp_res.d_category = cat + " | " + gen
                                    if cat == "Music" {
                                        tmp_res.r_icon = "music"
                                    }else if cat == "Sports"{
                                        tmp_res.r_icon = "sports"
                                    }else if cat == "Arts & Theatre" {
                                        tmp_res.r_icon = "arts"
                                    }else if cat == "Film" {
                                        tmp_res.r_icon = "film"
                                    }else if cat == "Miscellaneous" {
                                        tmp_res.r_icon = "miscellaneous"
                                    }
                                }
                                
                                //tmp_res.r_fav = "favorite-empty"

                                
                                //tmp_res.d_AT = ""
                                //detail related
                                for att in e._embedded.attractions {
                                    tmp_res.d_AT = tmp_res.d_AT + " | " + att.name
                                }

                                
                                if e.priceRanges != nil && e.priceRanges!.count != 0 {
                                    for p in (e.priceRanges)! {
                                        if p != nil {
                                            tmp_res.d_minPrice = p?.min
                                            tmp_res.d_maxPrice = p?.max
                                            //print("3: ", tmp_res.d_minPrice)
                                        }
                                    }
                                }
                                
                                tmp_res.d_ticketStatus = e.dates.status.code
                                
                                tmp_res.d_ticketLink = e.url
                                if e.seatmap != nil {
                                    tmp_res.d_seat = e.seatmap?.staticUrl
                                }
                                
                                //venue related
                                let venue = e._embedded.venues[0]
                                tmp_res.v_address = venue.address["line1"]
                                tmp_res.v_city = venue.city.name
                                tmp_res.v_state = venue.state["name"]
                                tmp_res.v_phone = venue.boxOfficeInfo?["phoneNumberDetail"]
                                tmp_res.v_open = venue.boxOfficeInfo?["openHoursDetail"]
                                tmp_res.v_genre = venue.generalInfo?["generalRule"]
                                tmp_res.v_child = venue.generalInfo?["childRule"]
                                
                                //print("Original att: ", tmp_res.d_AT)
                                let start = tmp_res.d_AT.index(tmp_res.d_AT.startIndex, offsetBy: 3)
                                
                                let range = start..<tmp_res.d_AT.endIndex
                                
                                let s = tmp_res.d_AT[range]  // play
                               
                                tmp_res.d_AT = String(s)
                                //print("After att: ", tmp_res.d_AT)
                                
                                self.show_data.append(tmp_res)
                                
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.favHelp()
                        }
                        //print(res._embedded.events)
                        //print(self.show_data)
//                        DispatchQueue.main.async {
//                            self.result_table.reloadData()
//                        }
                        SwiftSpinner.hide()
                    }catch let error as NSError {
                        SwiftSpinner.hide()
                        DispatchQueue.main.async {
                            self.view.showToast("serailization error", position: .bottom, popTime: 2, dismissOnTap: true)
                        }
                        print("Error serailization json:", error)
                    }
                }
            }
        }
        list.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return show_data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! SearchResultTableViewCell
        cell.event_name.text = show_data[indexPath.row].r_name
        cell.venue_name.text = show_data[indexPath.row].r_venue
        cell.data_time.text = show_data[indexPath.row].r_data + " " + show_data[indexPath.row].r_time
        cell.category_img.image = UIImage(named: show_data[indexPath.row].r_icon)
        cell.icon = show_data[indexPath.row].r_icon
        cell.isFav = show_data[indexPath.row].fav
        
        
        cell.d_AT = show_data[indexPath.row].d_AT
        cell.d_category = show_data[indexPath.row].d_category!
        cell.d_min = show_data[indexPath.row].d_minPrice
        cell.d_max = show_data[indexPath.row].d_maxPrice
        cell.d_ticketStatus = show_data[indexPath.row].d_ticketStatus!
        cell.d_ticketLink = show_data[indexPath.row].d_ticketLink!
        
        cell.d_seat = show_data[indexPath.row].d_seat
        cell.v_address = show_data[indexPath.row].v_address
        cell.v_city = show_data[indexPath.row].v_city!
        cell.v_state = show_data[indexPath.row].v_state!
        cell.v_phone = show_data[indexPath.row].v_phone
        cell.v_open = show_data[indexPath.row].v_open
        cell.v_general = show_data[indexPath.row].v_genre
        cell.v_child = show_data[indexPath.row].v_child
//        if show_data[indexPath.row].fav {
//            show_data[indexPath.row].r_fav = "favorite-filled"
//        }else {
//            show_data[indexPath.row].r_fav = "favorite-empty"
//        }
        cell.fav_img.image = UIImage(named: show_data[indexPath.row].r_fav)
        //show_data[indexPath.row].fav = cell.isFav
        

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seleted_index = indexPath.row
        //let cell  = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! SearchResultTableViewCell
        //show_data[indexPath.row].fav = cell.isFav
        performSegue(withIdentifier: "detail", sender: self)
        //print("3: ", cell.isFav)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detail = segue.destination as! DetailViewController
//        let detail = detail_tab.viewControllers?.last as! FirstEventViewController

        detail.d_AT = show_data[seleted_index].d_AT
        print("AT Name", show_data[seleted_index].d_AT)
        detail.d_Venue = show_data[seleted_index].r_venue
        detail.d_time = show_data[seleted_index].r_time
        detail.d_data = show_data[seleted_index].r_data
        detail.d_category = show_data[seleted_index].d_category!
        detail.d_minPrice = show_data[seleted_index].d_minPrice
        detail.d_maxPrice = show_data[seleted_index].d_maxPrice
        detail.d_ticketStatus = show_data[seleted_index].d_ticketStatus!
        detail.d_ticketLink = show_data[seleted_index].d_ticketLink!
        detail.segment = show_data[seleted_index].r_icon
        detail.d_seat = show_data[seleted_index].d_seat
        
        detail.v_address = show_data[seleted_index].v_address
        detail.v_city = show_data[seleted_index].v_city
        detail.v_state = show_data[seleted_index].v_state
        detail.v_phone = show_data[seleted_index].v_phone
        detail.v_open = show_data[seleted_index].v_open
        detail.v_genre = show_data[seleted_index].v_genre
        detail.v_child = show_data[seleted_index].v_child
        
       //print("3.", detail.d_ticketStatus)
        
        
        //favorite statue to detail form
        detail.f_name = show_data[seleted_index].r_name
        detail.f_icon = show_data[seleted_index].r_icon
        detail.f_data = show_data[seleted_index].r_data + " " + show_data[seleted_index].r_time
        //let cell  = sender.view as? UITableViewCell
        //self.show_data[seleted_index].fav = cell.isFav
        
    }
    


}
