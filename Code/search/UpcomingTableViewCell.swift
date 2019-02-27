//
//  UpcomingTableViewCell.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/24.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import WebKit

class UpcomingTableViewCell: UITableViewCell, WKUIDelegate {

    @IBOutlet weak var dis_name: UILabel!
    @IBOutlet weak var dis_artist: UILabel!
    @IBOutlet weak var dis_date: UILabel!
    @IBOutlet weak var dis_type: UILabel!
    var uri : String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(myaction))
        dis_name.addGestureRecognizer(gesture)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func myaction()
    {
        //print("dddd")
        if let url = URL(string: self.uri) {
            UIApplication.shared.open(url, options: [:])
        }
        //TODO
    }

}
