//
//  ViewController.swift
//  search
//
//  Created by mac on 2018/11/19.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit

struct GeoJsons: Decodable {
    var lat: Float
    var lon: Float
    
}


class InitialViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
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
    
    //error message
    @IBOutlet weak var error: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search_view.isUserInteractionEnabled = true
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
        
        //input location
        self.inputLoc.delegate = self
        
        //error
        error.isHidden = true
        
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
                    let geoloc = try JSONDecoder().decode(GeoJsons.self, from: data)
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
        let url = URL(string: "http://jiaozhanghw8.us-east-2.elasticbeanstalk.com/api/auto?keyword=USC")
        let list = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Autocomplete ERROR")
            }else {
                if let content = data {
                    do {
                        //array
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //let att = myJson["_embedded"]
                        let attractions = myJson["_embedded"] as AnyObject
                        let att_list = attractions["attractions"] as? NSArray
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
                        DispatchQueue.main.async {
                            self.keyword_tableview.reloadData()
                        }
                    }catch let error as NSError{
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
        return keyword_list.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(self.keyword_list)
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "KeywordCell")
        cell.textLabel?.text = keyword_list[indexPath.row]
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        keyword.text = self.keyword_list[indexPath.row]
        self._keyword = keyword.text!
        keyword_tableview.isHidden = true
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
        self.view.endEditing(false)
    }
    @objc func clearClick(){
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
        keyword_tableview.isHidden = true
        self.view.endEditing(true)
    }
    //press return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
    
    //search
    @IBAction func search(_ sender: UIButton) {
        //keyword is all spaces
        let trimmedString = _keyword.trimmingCharacters(in: .whitespaces)
        //print(_keyword)
        if trimmedString == "" {
            error.isHidden = false
            
        }
            //empty spaces
        else if(_keyword == "") {
            error.isHidden = false
        }
            //empty user loc
        else if(_isInputLoc && _Loc == "") {
            error.isHidden = false
        }else {
            error.isHidden = true
            performSegue(withIdentifier: "search", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let searchResult = segue.destination as! SearchViewController
        searchResult._keyword = _keyword
        searchResult._category = _category
        searchResult._distance = _distance
        searchResult._unit = _unit
        searchResult._isInputLoc = _isInputLoc
        searchResult._Loc = _Loc
        searchResult._lat = _lat
        searchResult._lng = _lng
    }
    
    
    //clear
    
    @IBAction func clear(_ sender: UIButton)  {
        self.keyword.text = nil
        _keyword = ""
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
        error.isHidden = true
    }

    @IBAction func change(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.search_view.isHidden = false
            self.fav_view.isHidden = true
        }else {
            self.search_view.isHidden = true
            self.fav_view.isHidden = false
        }
    }
}

