//
//  ThirdVenueViewController.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/22.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class ThirdVenueViewController: UIViewController {

    @IBOutlet weak var v_address: UILabel!
    @IBOutlet weak var v_city: UILabel!
    @IBOutlet weak var v_phone: UILabel!
    @IBOutlet weak var v_open: UILabel!
    @IBOutlet weak var v_genre: UILabel!
    @IBOutlet weak var v_chile: UILabel!
    
    var lat: Double = 0
    var lng: Double = 0
    
    @IBOutlet weak var map: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //info
        if let tabBarVC = self.tabBarController as? DetailViewController {
            self.v_address.text = tabBarVC.d_Venue
            //city
            if tabBarVC.v_city == "" || tabBarVC.v_city == nil || tabBarVC.v_state == "" || tabBarVC.v_state == nil {
                self.v_city.text = "N/A"
            }else if tabBarVC.v_city == "" || tabBarVC.v_city == nil {
                self.v_city.text = tabBarVC.v_state!
            }else if tabBarVC.v_state == "" || tabBarVC.v_state == nil {
                self.v_city.text = tabBarVC.v_city!
            }else {
                self.v_city.text = tabBarVC.v_city!+", "+tabBarVC.v_state!
            }
            //phone
            if tabBarVC.v_phone == "" || tabBarVC.v_phone == nil {
                self.v_phone.text = "N/A"
            }else {
               self.v_phone.text = tabBarVC.v_phone
            }
            //open hour
            if tabBarVC.v_open == "" || tabBarVC.v_open == nil {
                self.v_open.text = "N/A"
            } else {
                self.v_open.text = tabBarVC.v_open
            }
            //general
            if tabBarVC.v_genre == "" || tabBarVC.v_genre == nil {
                self.v_genre.text = "N/A"
            } else {
                self.v_genre.text = tabBarVC.v_genre
            }
            //child
            if tabBarVC.v_child == "" || tabBarVC.v_child == nil {
                self.v_chile.text = "N/A"
            } else {
                self.v_chile.text = tabBarVC.v_child
            }
            searchLatLng(add: tabBarVC.v_address!)
        }
        
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
                        
                        self.lat = res.results[0].geometry.location["lat"]!
                        self.lng =  res.results[0].geometry.location["lng"]!
                        print("lat: ",self.lat)
                        print("lng: ",self.lng)
                        DispatchQueue.main.async {
                            let camera = GMSCameraPosition.camera(withLatitude: self.lat, longitude: self.lng, zoom: 14.0)
                            self.map.camera = camera
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
                            marker.title = self.v_address.text
                            //marker.snippet = "Australia"
                            marker.map = self.map
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
}
