//
//  FirstEventViewController.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/22.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import WebKit


class FirstEventViewController: UIViewController {

    //get the detail data from the result table
    var d_AT: String = "N/A"
    var d_Venue: String = "N/A"
    var d_time: String = "N/A"
    var d_data: String = "N/A"
    var d_category: String = "N/A"
    var d_minPrice: Float?
    var d_maxPrice: Float?
    var d_ticketStatus: String = "N/A"
    var d_ticketLink: String = "N/A"
    var d_seat: String = "N/A"
    
    @IBOutlet weak var AT: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var seat: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("3", d_ticketStatus)
        if let tabBarVC = self.tabBarController as? DetailViewController {
            self.d_AT = tabBarVC.d_AT
            print("Detail AT Name", self.d_AT)
            self.d_Venue = tabBarVC.d_Venue!
            self.d_time = tabBarVC.d_time!
            self.d_data = tabBarVC.d_data!
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd, yyyy"
            
            if let date = dateFormatterGet.date(from: self.d_data) {
                self.d_data = dateFormatterPrint.string(from: date)
                //print(dateFormatterPrint.string(from: date))
            }
            self.d_category = tabBarVC.d_category!
            self.d_ticketStatus = tabBarVC.d_ticketStatus!
            self.d_minPrice = tabBarVC.d_minPrice
            self.d_maxPrice = tabBarVC.d_maxPrice
            self.d_ticketLink = tabBarVC.d_ticketLink!
            self.d_seat = tabBarVC.d_seat ?? "N/A"
            
            //AT
            if d_AT != "N/A" && d_AT != "" {
                //print("!!!", d_AT)
                AT?.text = d_AT
            } else { AT?.text = "N/A" }
            
            //venue
            if d_Venue != "N/A" && d_Venue != "" {
                //print("!!!", d_AT)
                venue?.text = d_Venue
            } else { venue?.text = "N/A" }
            
            //time
            if d_time == "N/A" && d_time == "" && d_data == "N/A" && d_data == ""{
                category?.text = "N/A"
            } else if d_time == "N/A" && d_time == "" {
                time?.text = d_data
            } else if d_data == "N/A" && d_data == "" {
                time?.text = d_time
            } else {
                time?.text = d_data + " " + d_time
            }
            
            //category
            if d_category != "N/A" && d_category != "" {
                //print("!!!", d_AT)
                category?.text = d_category
            } else { category?.text = "N/A" }
            
            //price
            if d_minPrice != nil && d_maxPrice != nil {
                //print("!!!", d_AT)
                price?.text = (NSString(format: "%.1f", d_minPrice!) as String) + " ~ " + (NSString(format: "%.1f", d_maxPrice!) as String) + "(USD)"
            } else if d_minPrice != nil && d_maxPrice == nil {
                //print("!!!", d_AT)
                price?.text = (NSString(format: "%.2f", d_minPrice!) as String)
            }else if d_minPrice == nil && d_maxPrice != nil {
                //print("!!!", d_AT)
                price?.text = (NSString(format: "%.2f", d_maxPrice!) as String)
            }else { price?.text = "N/A" }
            
            //ticket status
            if d_ticketStatus != "N/A" && d_ticketStatus != "" {
                //print("!!!", d_AT)
                status?.text = d_ticketStatus
            } else { status?.text = "N/A" }
            
            //ticket link
            if d_ticketLink != "N/A" && d_ticketLink != "" {
                let gesture = UITapGestureRecognizer.init(target: self, action: #selector(ticketaction))
                link.addGestureRecognizer(gesture)
                //print("!!!", d_AT)
                link?.text = "Ticketmaster"
            } else {
                link?.text = "N/A"
                link.textColor = UIColor.black
            }
            
            //seat
            if d_seat != "N/A" && d_seat != "" {
                let gesture = UITapGestureRecognizer.init(target: self, action: #selector(seataction))
                seat.addGestureRecognizer(gesture)
                //print("!!!", d_AT)
                seat?.text = "View Here"
            } else {
                seat?.text = "N/A"
                seat.textColor = UIColor.black
            }
            
        }

        
//        venue.text = d_Venue
//        time.text = d_data! + " " + d_time!
//        category.text = d_category
//
//        price.text = (NSString(format: "%.2f", d_minPrice!) as String) + " - " + (NSString(format: "%.2f", d_maxPrice!) as String)
//        status.text = d_ticketStatus
//        link.text = d_ticketLink
//        seat.text = d_seat
        
        //view.backgroundColor = .red

        // Do any additional setup after loading the view.
    }
    
    @objc func ticketaction() {
        if let url = URL(string: self.d_ticketLink) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @objc func seataction() {

        if let url = URL(string: self.d_seat) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    

}
