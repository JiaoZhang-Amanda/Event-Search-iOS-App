//
//  SecondArtViewController.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/22.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftSpinner
import WebKit

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger{
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

struct music_data {
    var m_name: String
    var m_pop: Int
    var m_foll: Int
    var m_url: String
    //var photo: [String]
    
    init(my_name: String = "",
         my_pop: Int = 0,
         my_foll: Int = 0,
         my_url: String = "") {
        self.m_name = my_name
        self.m_pop = my_pop
        self.m_url = my_url
        self.m_foll = my_foll
        //self.photo = []
    }
}

class SecondArtViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {


    @IBOutlet weak var collection_view: UICollectionView!
    
    var AT_name = String()
    var category = String()
    var ATNameArr: [String] = []
    
    var music: [music_data] = []
    var photo: [[String]] = []
    
    var searchCount: Int = 0
    //photos
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Searching for events")
        
        collection_view.delegate = self
        collection_view.dataSource = self
//        let width = view.frame.size.width
//        let height = view.frame.size.height / 2
//        let layout = collection_view.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: width, height: height)
        
        if let tabBarVC = self.tabBarController as? DetailViewController {
            //venue_name = "USC"
            AT_name = tabBarVC.d_AT
            category = tabBarVC.segment
            ATNameArr = self.AT_name.components(separatedBy: " | ")
            for name in ATNameArr {
                if category == "music" {
                    SeachMusic(Keyword: name)
                    //SearchPhoto(Keyword: name)
                }else {
                    //self.musicView.isHidden = true
                    SearchPhoto(Keyword: name)
                }
            }
            //let firstName: String = ATNameArr[0]
            //let secongName: String = ATNameArr[1]
            //print("name",firstName)
            //print("name",secongName)
            //var fullNameAT = split(AT_name) {$0 == " | "}
            
            //print(venue_name)
        }
        //collection.photos

    }
    func SearchPhoto(Keyword: String) {
        searchCount = searchCount + 1
        let urlString = Keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = "http://jiaozhangHW8.us-east-2.elasticbeanstalk.com/api/photo?searchKey="+urlString!
        //search for music result
        print("~1",url)
        guard let photo_url = URL(string: url) else { return }
        let list = URLSession.shared.dataTask(with: photo_url) { (data, response, error) in
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
                        let res = try JSONDecoder().decode(Photo.self, from: content)
                        var photos: [String] = []
                        for p in res.items {
                            photos.append(p.link)
                        }
                        self.photo.append(photos)
                        //self.collection1.photos = self.photos
                        DispatchQueue.main.async {
                           // if Keyword == self.ATNameArr[1] {
                            
                           // }
                            //if self.searchCount == 2 {
                                self.collection_view.reloadData()
                               SwiftSpinner.hide()
                            //}
                            
                            //self.collection1.photo = self.photos
                            //self.collection1.reloadData()
                            //print("~4",url)
                        }
                        //print("....", self.collection1.photos)
                        //print("~2",url)
                    }catch let error as NSError {
                        SwiftSpinner.hide()
                        DispatchQueue.main.async {
                            self.view.showToast("serailization error", position: .bottom, popTime: 2, dismissOnTap: true)
                        }
                        print("Error serailization json:", error)
                    }
                }
                //SwiftSpinner.hide()
            }
        }
        list.resume()
    }
    
    func SeachMusic(Keyword: String) {
        //url
        let urlString = Keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = "http://localhost:3000/api/music?attName="+urlString!
        //let url = "http://jiaozhanghw8amanda.us-east-2.elasticbeanstalk.com/api/music?attName=pink"
        //search for music result
        print(url)
        guard let music_url = URL(string: url) else { return }
        let list = URLSession.shared.dataTask(with: music_url) { (data, response, error) in
            if error != nil {
                SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.view.showToast("Search result error", position: .bottom, popTime: 2, dismissOnTap: true)
                }
                print("Search result error")
            }else {
                if let content = data {
                    do {
//                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//                        print(myJson)
                        let res = try JSONDecoder().decode(Music.self, from: content)
                        var tmp_music = music_data()
                        for m in res.artists.items {
                            tmp_music.m_name = m.name
                            tmp_music.m_pop = m.popularity
                            tmp_music.m_foll = m.followers.total
                            tmp_music.m_url = m.external_urls.spotify
                            self.music.append(tmp_music)
                        }
                        DispatchQueue.main.async {
                            self.SearchPhoto(Keyword: Keyword)
                            //print("~4",url)
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
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photo.count > 2 {
            return 2
        }else {
            return photo.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AT_cell", for: indexPath) as! ATCollectionViewCell
    
        cell.title.text = ATNameArr[indexPath.row]
        if category == "music" {

            //myView.removeFromSuperview
            cell.m_name.text = ATNameArr[indexPath.row]
            let myInt = music[indexPath.row].m_foll
            let myIntString = myInt.formattedWithSeparator
            cell.m_follower.text = myIntString
            cell.m_popular.text = String(music[indexPath.row].m_pop)
            cell.uri = music[indexPath.row].m_url
            cell.m_check.isUserInteractionEnabled = true
            
            //let gesture = UITapGestureRecognizer.init(target: self, action: #selector(myaction(sender:)))
            cell.m_check.text = "Spotify"
            //cell.m_check.addGestureRecognizer(gesture)
            cell.addGesture()
        }else {
            print("change music view")
            //cell.musicView.frame = CGRect(x: 0, y: -100, width: 0, height: 0)
            //            CGRect() temp = self.view.frame
            //            temp.size.height = 0
            //            self.view.frame = temp
            //            cell.musicView.frame.set
            //            cell.musicView.frame.width = 0
            cell.musicView.isHidden = true
            cell.photoView.frame = CGRect(x: 0, y: cell.musicView.frame.origin.y - 10, width: cell.photoView.frame.width, height: cell.photoView.frame.height)
        }
        
        var tmp_photo = [String]()
        tmp_photo = self.photo[indexPath.row]
        print(photo[0])
        if tmp_photo.count > 8 {
            var url = URL(string: tmp_photo[0])
            cell.img1.kf.setImage(with: url)
            url = URL(string: tmp_photo[1])
            cell.img2.kf.setImage(with: url)
            url = URL(string: tmp_photo[2])
            cell.img3.kf.setImage(with: url)
            url = URL(string: tmp_photo[3])
            cell.img4.kf.setImage(with: url)
            url = URL(string: tmp_photo[4])
            cell.img5.kf.setImage(with: url)
            url = URL(string: tmp_photo[5])
            cell.img6.kf.setImage(with: url)
            url = URL(string: tmp_photo[6])
            cell.img7.kf.setImage(with: url)
            url = URL(string: tmp_photo[7])
            cell.img8.kf.setImage(with: url)

        } else {

            for index in 0...tmp_photo.count {
                if index == 0 {
                    print("picture 1")
                    let url0 = URL(string: tmp_photo[0])
                    cell.img1.kf.setImage(with: url0)
                }
                else if index == 1 {
                    //print("picture 2")
                    let url1 = URL(string: photo[indexPath.row][1])
                    cell.img2.kf.setImage(with: url1)
                }
                else if index == 2 {
                    //print("picture 3")
                    let url2 = URL(string: photo[indexPath.row][2])
                    cell.img3.kf.setImage(with: url2)
                }
                else if index == 3 {
                    let url3 = URL(string: photo[indexPath.row][3])
                    cell.img4.kf.setImage(with: url3)
                }
                else if index == 4 {
                    let url4 = URL(string: photo[indexPath.row][4])
                    cell.img5.kf.setImage(with: url4)
                }
                else if index == 5 {
                    let url5 = URL(string: photo[indexPath.row][5])
                    cell.img6.kf.setImage(with: url5)
                }
                else if index == 6 {
                    let url6 = URL(string: photo[indexPath.row][6])
                    cell.img7.kf.setImage(with: url6)
                }
                else if index == 7 {
                    let url7 = URL(string: photo[indexPath.row][7])
                    cell.img8.kf.setImage(with: url7)
                }
            }
            
        }
        return cell

    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let detail = segue.destination as! collection1View
//        detail.photos = photos
//    }
    

}
