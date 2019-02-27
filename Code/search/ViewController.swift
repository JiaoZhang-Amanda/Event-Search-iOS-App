//
//  ViewController.swift
//  search
//
//  Created by mac on 2018/11/19.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import EasyToast
import SwiftSpinner

struct GeoJson: Decodable {
    var lat: Float
    var lon: Float
}


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var search_view: UIView!
    @IBOutlet weak var fav_view: UIView!
    //input keyword
    @IBOutlet weak var keyword: UITextField!
    var keyword_list:[String] = Array()
    @IBOutlet weak var keyword_tableview: UITableView!
    var _keyword: String = ""
    
    //choose category
    @IBOutlet weak var category: UITextField!
    var category_picker = UIPickerView()
    var _category: String = "ALL"
    
    //choose distance
    @IBOutlet weak var distance: UITextField!
    var _distance: String = "10"
    
    //choose unit
    @IBOutlet weak var unit: UIPickerView!
    var _unit: String = "miles"
    
    //from part--current location box
    @IBOutlet weak var uncheckbox1: UIButton!
    @IBOutlet weak var uncheckBox2: UIButton!
    var _isInputLoc: Bool = false
    @IBOutlet weak var inputLoc: UITextField!
    var _Loc: String=""
    var _lat: Float = 0.0
    var _lng: Float = 0.0
    
    //fav related
    @IBOutlet weak var fav_table: UITableView!
    var one_fav = Favorite()
    var fav_list: [Favorite] = []
    var seletedIndex: Int = 0
    
    @IBOutlet weak var noResult: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noResult.isHidden = true
        if let fav = UserDefaults.standard.value(forKey:"myfavorite") as? Data {
            let one_fav = try? PropertyListDecoder().decode(Array<Favorite>.self, from: fav)
            fav_list = one_fav!
            //print("FAvorite: ", one_fav)
        }else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(fav_list), forKey:"myfavorite")
        }
        
        
        self.fav_view.isHidden = true
        //get geoLocation
        getGeoLoc()

        //keyword
        keyword_tableview?.dataSource = self
        keyword_tableview?.delegate = self
        keyword_tableview.isHidden = true
        keyword.delegate = self
        keyword.addTarget(self, action: #selector(search_keyword(_:)), for: .editingChanged)
        
        //category input
        category.delegate = self
        category.text = "ALL"
        categortPicker()
        
        //distance input
        distance.delegate = self
        
        //button view
        let mycolor = UIColor.lightGray
        uncheckbox1.layer.borderColor = mycolor.cgColor
        uncheckBox2.layer.borderColor = mycolor.cgColor
        
        //input location
        self.inputLoc.delegate = self
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let fav = UserDefaults.standard.value(forKey:"myfavorite") as? Data {
            let one_fav = try? PropertyListDecoder().decode(Array<Favorite>.self, from: fav)
            fav_list = one_fav!
            //print("FAvorite: ", one_fav)
            self.fav_table.reloadData()
        }
    }
    func getGeoLoc() {
        print("....")
        let url = URL(string: "http://ip-api.com/json")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Autocomplete ERROR")
            }else {
                guard let data = data else { return }
                do {
                    let geoloc = try JSONDecoder().decode(GeoJson.self, from: data)
                    //current location
                    self._lat = geoloc.lat
                    self._lng = geoloc.lon
                    //print(self._lat)
                }catch let error as NSError{
                    print("Error serailization json:", error)
                }
            }
        }.resume()
    }
    
    //keyword autocomplete
    @IBAction func search_keyword(_ sender: Any) {
        keyword_tableview.isHidden = false
        self.keyword_list.removeAll()
        //search for the keyword
        let urlString = self.keyword.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let auto_url = "http://jiaozhanghw8.us-east-2.elasticbeanstalk.com/api/auto?keyword=" + urlString!
        let url = URL(string: auto_url)
        self._keyword = self.keyword.text!
        let list = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.view.showToast("Search result error", position: .bottom, popTime: 2, dismissOnTap: true)
                }
                print("Autocomplete ERROR")
            }else {
                if let content = data {
                    do {
                        //array
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //let att = myJson["_embedded"]
                        let attractions = myJson["_embedded"] as AnyObject
                        let att_list = attractions["attractions"] as? NSArray
                        if att_list != nil {
                            let length = att_list!.count
                            //print(length)
                            for i in 0 ..< length {
                                if let att = att_list![i] as? NSDictionary {
                                    if let att_name = att["name"] as? String
                                    {
                                        self.keyword_list.append(att_name)
                                        
                                        //print(att_name)
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.keyword_tableview.reloadData()
                        }
                    }catch let error as NSError{
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
        //print(keyword_list)
        //keyword_list.append("test")
        
        
        
    }
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 1 {
            return fav_list.count
        }else {
            return keyword_list.count
        }
        
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "fav", for: indexPath) as! FavoriteTableViewCell
            cell.f_img.image = UIImage(named: fav_list[indexPath.row].f_icon)
            cell.f_name.text = fav_list[indexPath.row].f_name
            cell.f_venue.text = fav_list[indexPath.row].f_venue
            cell.f_date.text = fav_list[indexPath.row].f_time
            return(cell)
        }else {
            //print(self.keyword_list)
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "KeywordCell")
            cell.textLabel?.text = keyword_list[indexPath.row]
            return(cell)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            self.seletedIndex = indexPath.row
            performSegue(withIdentifier: "favDetail", sender: self)
        } else {
            keyword.text = self.keyword_list[indexPath.row]
            self._keyword = keyword.text!
            keyword_tableview.isHidden = true
        }

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 1 {
            return true
        }else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                self.view.showToast(fav_list[indexPath.row].f_name + " was been removed from favorites", position: .bottom, popTime: 3, dismissOnTap: true)
                fav_list.remove(at: indexPath.row)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(fav_list), forKey:"myfavorite")
                if fav_list.count == 0 {
                    self.noResult.isHidden = false
                    self.fav_view.isHidden = true
                } else {
                    self.fav_table.reloadData()
                }
                
            }
        }
    }
    

    //category picker
    var categories = ["ALL", "Music", "Sports", "Arts & Theatre", "Film", "Miscellaneous"]
    //unit picker
    var units = ["miles", "kms"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        if pickerView == unit {
            let unitCustomeView = UIView(frame: CGRect(x: 0, y:0, width:97 , height:30 ))
            let unitCustomeLabel = UILabel(frame: CGRect(x: 0, y:0, width:97 , height:30 ))
            unitCustomeLabel.text = units[row]
            unitCustomeLabel.textAlignment = .center
            unitCustomeLabel.font = UIFont.systemFont(ofSize: 14)
            unitCustomeView.addSubview(unitCustomeLabel)
            return unitCustomeView
        }else if pickerView == category_picker {
            let unitCustomeView = UIView(frame: CGRect(x:0, y:0, width: pickerView.frame.width, height: pickerView.frame.height))
            let unitCustomeLabel = UILabel(frame: CGRect(x:0, y:0, width: pickerView.frame.width, height: pickerView.frame.height))
            unitCustomeLabel.text = categories[row]
            unitCustomeLabel.textAlignment = .center
            unitCustomeView.addSubview(unitCustomeLabel)
            return unitCustomeView
        }
        return UIView()
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countsRow = categories.count
        if pickerView == unit {
            countsRow = units.count
        }
        return countsRow
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == unit {
            _unit = units[row]
        }else if pickerView == category_picker {
            _category = categories[row]

            category.text = categories[row]
        }
    }
    func categortPicker(){
        
        category_picker.delegate = self
        category_picker.dataSource = self
        
        //assign category picker to category textfield
        category.inputView = category_picker

        //create a toolbar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        //add a cancel button on this toolbar
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(self.doneClick))
        
        //add a flexible space
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //add a done button on this toolbar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(self.doneClick))
        toolBar.setItems([cancelButton, flexible, doneButton], animated: true)
        
        //assign toolbar to textfield
        category.inputAccessoryView = toolBar
    }
    @objc func doneClick(){
        self.keyword_tableview.isHidden = true
        self.view.endEditing(false)
    }
    @objc func clearClick(){
        self.keyword_tableview.isHidden = true
        self.view.endEditing(false)
    }
    
    //distance
    @IBAction func distance_input(_ sender: Any) {
        if(distance.text != ""){
            self._distance = distance.text!
        }
    }
    
    @IBAction func clickCurrent(_ sender: Any) {
        if(_isInputLoc) {
            inputLoc.isUserInteractionEnabled = false
            inputLoc.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5)
            _isInputLoc = false;
            uncheckbox1.backgroundColor = UIColor.lightGray
            uncheckBox2.backgroundColor = UIColor.white

        }else{
            inputLoc.isUserInteractionEnabled = true
            inputLoc.backgroundColor = UIColor.white
            _isInputLoc = true;
            uncheckbox1.backgroundColor = UIColor.white
            uncheckBox2.backgroundColor = UIColor.lightGray
        }
        
    }
    
    @IBAction func Loc_input(_ sender: Any) {
        self._Loc = inputLoc.text!
    }
    
    //hide keyboard when click outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self._keyword = self.keyword.text!
        keyword_tableview.isHidden = true
        self.view.endEditing(true)
    }
    //press return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.keyword_tableview.isHidden = true
        return (true)
    }
    
    //search
    @IBAction func search(_ sender: UIButton) {
        //keyword is all spaces
        let trimmedString = _keyword.trimmingCharacters(in: .whitespaces)
        //print(_keyword)
        if trimmedString == "" {
            self.view.showToast("Keyword and location are mandatory fields", position: .bottom, popTime: 5, dismissOnTap: true)
        }
        //empty spaces
        else if(_keyword == "") {
            self.view.showToast("Keyword and location are mandatory fields", position: .bottom, popTime: 2, dismissOnTap: true)
        }
        //empty user loc
        else if(_isInputLoc && _Loc == "") {
            self.view.showToast("Keyword and location are mandatory fields", position: .bottom, popTime: 5, dismissOnTap: true)
        }else {
            performSegue(withIdentifier: "search", sender: self)
        }
//        print("keyword: ", _keyword)
//        print("category: ", _category)
//        print("distance: ", _distance)
//        print("unit: ", _unit)
//        print("isUserInput: ", _isInputLoc)
//        print("Loc: ", _Loc)
//        print("lat: ", _lat)
//        print("lng: ", _lng)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favDetail" {
            let detail = segue.destination as! DetailViewController
            detail.d_AT = fav_list[seletedIndex].d_AT!
            detail.d_Venue = fav_list[seletedIndex].f_venue
            let data_time = fav_list[seletedIndex].f_time.components(separatedBy: " ")
            let data = data_time[0]
            let time = data_time[1]
            detail.d_time = data
            detail.d_data = time
            
            detail.d_category = fav_list[seletedIndex].d_category
            detail.d_minPrice = fav_list[seletedIndex].d_minPrice
            detail.d_maxPrice = fav_list[seletedIndex].d_maxPrice
            detail.d_ticketStatus = fav_list[seletedIndex].d_ticketStatus
            detail.d_ticketLink = fav_list[seletedIndex].d_ticketLink
            
            detail.segment = fav_list[seletedIndex].f_icon
            detail.d_seat = fav_list[seletedIndex].d_seat
            detail.v_address = fav_list[seletedIndex].v_address
            detail.v_city = fav_list[seletedIndex].v_city
            detail.v_state = fav_list[seletedIndex].v_state
            detail.v_phone = fav_list[seletedIndex].v_phone
            detail.v_open = fav_list[seletedIndex].v_open
            detail.v_genre = fav_list[seletedIndex].v_general
            detail.v_child = fav_list[seletedIndex].v_child
            
            detail.f_name = fav_list[seletedIndex].f_name
            detail.f_icon = fav_list[seletedIndex].f_icon
            detail.f_data = fav_list[seletedIndex].f_time
            detail.isFav = true
        } else {
            let searchResult = segue.destination as! SearchViewController
            searchResult._keyword = _keyword
            searchResult._category = _category
            searchResult._distance = _distance
            searchResult._unit = _unit
            searchResult._isInputLoc = _isInputLoc
            searchResult._Loc = _Loc
            searchResult._lat = Double(_lat)
            searchResult._lng = Double(_lng)
        }

    }
    
    
    //clear
    @IBAction func clear(_ sender: Any) {
        self.keyword.text = nil
        _keyword = ""
        self.keyword_list.removeAll()
        keyword_tableview.isHidden = true
        self.category.text = "ALL"
        _category = "ALL"
        self.distance.text = nil
        _distance = "10"
        self.unit.reloadAllComponents()
        _unit = "miles"
        _isInputLoc = false
        self.inputLoc.text = ""
        inputLoc.isUserInteractionEnabled = false
        inputLoc.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5)
        _isInputLoc = false;
        uncheckbox1.backgroundColor = UIColor.lightGray
        uncheckBox2.backgroundColor = UIColor.white
        _Loc = ""
    }
    
    @IBAction func toggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.search_view.isHidden = false
            self.fav_view.isHidden = true
            self.noResult.isHidden = true
            self.keyword_tableview.isHidden = true
        }else {
            self.search_view.isHidden = true
            print("count:",fav_list.count)
            if fav_list.count == 0 {
                self.noResult.isHidden = false
                self.fav_view.isHidden = true
            }else {
                self.noResult.isHidden = true
                self.fav_view.isHidden = false
            }
            //self.fav_view.isHidden = false
        }
    }
}

