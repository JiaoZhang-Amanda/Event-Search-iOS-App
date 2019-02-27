//
//  FavoriteTableViewCell.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/24.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var f_img: UIImageView!
    @IBOutlet weak var f_name: UILabel!
    @IBOutlet weak var f_venue: UILabel!
    @IBOutlet weak var f_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
