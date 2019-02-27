//
//  ForthUpcomingViewController.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/22.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import SwiftSpinner
import WebKit

struct UpComingEvents {
    var name: String
    var artist: String
    var date: String
    var time: String
    var type: String
    var uri: String
    
    init(name: String = "",
         artist: String = "",
         date: String = "",
         time: String = "",
         type: String = "",
         uri: String = "") {
        self.name = name
        self.artist = artist
        self.date = date
        self.time = time
        self.type = type
        self.uri = uri
    }
}

class ForthUpcomingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKUIDelegate {

    var d_Venue: String = ""
    var id: String = ""
    var events: [UpComingEvents] = []
    var defaultEvent: [UpComingEvents] = []
    
    //sort related
    @IBOutlet weak var order: UISegmentedControl!
    var sortedBy = ""
    var orderBy: String = "Ascending"
    
    @IBOutlet weak var noResult: UIView!
    @IBOutlet weak var event_table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.webView.uiDelegate = self
        SwiftSpinner.show("Searching for events")
//        self.event_table.isHidden = true
        self.noResult.isHidden = true
        
        order.isEnabled = false
        
        event_table.delegate = self
        event_table.dataSource = self
        event_table.rowHeight = UITableView.automaticDimension
        
        if let tabBarVC = self.tabBarController as? DetailViewController {
            self.d_Venue = tabBarVC.d_Venue!
            getID()
            print("3",self.d_Venue)
            //SearchUpcoming()
        }
        //print(events)
        //view.backgroundColor = .green
        // Do any additional setup after loading the view.
    }
    
    func getID() {
        //d_Venue
        let urlString = self.d_Venue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let id_url = "http://jiaozhangHW8.us-east-2.elasticbeanstalk.com/api/getID?venue="+urlString!
        print(urlString)
        
        //search for music result
        print("1", id_url)
        guard let url = URL(string: id_url) else { return }
        let list = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.view.showToast("Search result error", position: .bottom, popTime: 2, dismissOnTap: true)
                }
                print("Search result error")
            }else {
                //print(data)
                if let content = data {
                    do {
                        let res = try JSONDecoder().decode(Id.self, from: content)
                        if res.resultsPage.results.venue[0].id == -1 {
                            SwiftSpinner.hide()
                            DispatchQueue.main.async {
                                self.view.showToast("search id error", position: .bottom, popTime: 2, dismissOnTap: true)
                            }
                        }else {
                            self.id = String(res.resultsPage.results.venue[0].id)
                            print("2,", self.id)
                            SwiftSpinner.hide()
                            DispatchQueue.main.async {
                                self.SearchUpcoming()
                            }
                            
                        }


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
    
    func SearchUpcoming() {
        print("4", self.id)
        let up_url = "http://jiaozhangHW8.us-east-2.elasticbeanstalk.com/api/upComing?ID="+self.id
        guard let url = URL(string: up_url) else { return }
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
                        let res = try JSONDecoder().decode(Upcoming.self, from: content)
                        
                        if res.resultsPage.results.event == nil {
                            DispatchQueue.main.async {
                                self.event_table.isHidden = true
                                self.noResult.isHidden = false
                            }
                            //self.noResult.isHidden = false
                        }else {
                            for e in res.resultsPage.results.event! {
                                var tmp_event = UpComingEvents()
                                tmp_event.name = e.displayName
                                tmp_event.uri = e.uri
                                if e.start.date != nil {
                                    tmp_event.date = e.start.date!
                                }
                                if e.start.time != nil {
                                    tmp_event.time = e.start.time!
                                }
                                
                                if e.type != "" {
                                    tmp_event.type = e.type
                                }
                                
                                if e.performance.count != 0 && e.performance[0].displayName != "" {
                                    tmp_event.artist = e.performance[0].displayName
                                }
                                
                                self.events.append(tmp_event)
                            }
                            
                            //self.events.removeAll()
                            if self.events.count == 0 {
                                //print("......")
                                DispatchQueue.main.async {
                                    self.event_table.isHidden = true
                                    self.noResult.isHidden = false
                                }
                            }else {
                                DispatchQueue.main.async {
                                    self.event_table.isHidden = false
                                    self.noResult.isHidden = true
                                    self.defaultEvent = self.events
                                    DispatchQueue.main.async {
                                        self.event_table.reloadData()
                                    }
                                }
                                
                            }
                            
                        }
                        

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
        if events.count > 5 {
            return 5
        }else {
            return events.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "upEvent", for: indexPath) as! UpcomingTableViewCell
        
        //add clickable
        cell.dis_name.text = events[indexPath.row].name
        cell.dis_name.isUserInteractionEnabled = true
        cell.uri = events[indexPath.row].uri

        cell.dis_artist.text = events[indexPath.row].artist
        
        var tmp_data = ""
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        
        if let date = dateFormatterGet.date(from: events[indexPath.row].date) {
            tmp_data = dateFormatterPrint.string(from: date)
            //print(dateFormatterPrint.string(from: date))
        }
        
        cell.dis_date.text = tmp_data + " " + events[indexPath.row].time
        cell.dis_type.text = "Type: " + events[indexPath.row].type
        return cell
    }
    
    @IBAction func byToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            events = defaultEvent
            self.event_table.reloadData()
            order.isEnabled = false
            order.selectedSegmentIndex = 0
            self.sortedBy = ""
        }else if sender.selectedSegmentIndex == 1 {
            print(self.orderBy)
            order.isEnabled = true
            if self.orderBy == "Ascending" {
                events = events.sorted(by: { $0.name < $1.name })
                self.event_table.reloadData()
            }else {
                events = events.sorted(by: { $0.name > $1.name })
                self.event_table.reloadData()
            }
            self.sortedBy = "name"
            
        }else if sender.selectedSegmentIndex == 2 {
            if self.orderBy == "Ascending" {
                events = events.sorted(by: { $0.date < $1.date })
                self.event_table.reloadData()
            }else {
                events = events.sorted(by: { $0.date > $1.date })
                self.event_table.reloadData()
            }
            self.sortedBy = "date"
            order.isEnabled = true
        }else if sender.selectedSegmentIndex == 3 {
            if self.orderBy == "Ascending" {
                events = events.sorted(by: { $0.artist < $1.artist })
                self.event_table.reloadData()
            }else {
                events = events.sorted(by: { $0.artist > $1.artist })
                self.event_table.reloadData()
            }
            self.sortedBy = "artist"
            order.isEnabled = true
        }else if sender.selectedSegmentIndex == 4 {
            if self.orderBy == "Ascending" {
                events = events.sorted(by: { $0.type < $1.type })
                self.event_table.reloadData()
            }else {
                events = events.sorted(by: { $0.type > $1.type })
                self.event_table.reloadData()
            }
            self.sortedBy = "type"
            order.isEnabled = true
        }
    }
    
    @IBAction func orderToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            self.orderBy = "Decending"
            if self.sortedBy == "name" {
                events = events.sorted(by: { $0.name > $1.name })
            }else if self.sortedBy == "date" {
                events = events.sorted(by: { $0.date > $1.date })
            }else if self.sortedBy == "artist" {
                events = events.sorted(by: { $0.artist > $1.artist })
            }else if self.sortedBy == "type" {
                events = events.sorted(by: { $0.type > $1.type })
            }else {  }
            self.event_table.reloadData()
        }else if sender.selectedSegmentIndex == 0 {
            self.orderBy = "Ascending"
            if self.sortedBy == "name" {
                events = events.sorted(by: { $0.name < $1.name })
            }else if self.sortedBy == "date" {
                events = events.sorted(by: { $0.date < $1.date })
            }else if self.sortedBy == "artist" {
                events = events.sorted(by: { $0.artist < $1.artist })
            }else if self.sortedBy == "type" {
                events = events.sorted(by: { $0.type < $1.type })
            }else { events = defaultEvent }
            self.event_table.reloadData()
        }
    }
    
}
