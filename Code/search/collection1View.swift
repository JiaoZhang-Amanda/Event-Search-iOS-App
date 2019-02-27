//
//  collection1View.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/24.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit

class collection1View: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    var photo: [String] = ["https://www.dailybulletin.com/wp-content/uploads/2018/03/usc-logo.jpg?w=560", "https://s3.amazonaws.com/sidearm.sites/usctrojans.com/images/2017/12/20/USC_FOOTBALL_STANFORD_2017_090917_MCGILLEN_3798_71.jpg", "https://imagesvc.timeincapp.com/v3/fan/image?url=https://reignoftroy.com/wp-content/uploads/getty-images/2018/01/898609450-diamond-head-classic-new-mexico-state-v-usc.jpg.jpg&", "https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/USC_Trojans_logo.svg/1200px-USC_Trojans_logo.svg.png", "http://sait.usc.edu/recsports/spirit/wp-content/uploads/2014/08/32289733235_d73b218843_k.jpg", "https://volleyballmag.com/wp-content/uploads/2017/05/USC-celebrates.jpg", "https://s3.amazonaws.com/hkusa/20180426122656/USC-disassembly-APR-2018-Web1.jpg", "https://imagesvc.timeincapp.com/v3/fan/image?url=https://reignoftroy.com/wp-content/uploads/getty-images/2017/09/845091342-stanford-v-usc.jpg.jpg&c=sc&w=5100&h=3399"]
    
//    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
//        <#code#>
//    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photo.count > 8 {
            return 8
        }else {
            return photo.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("~", self.photo)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "img_cell", for: indexPath) as! ATImageCollectionViewCell
        //cell.title.text = "!!!"
        let url = URL(string: photo[indexPath.row])
        cell.at_image.kf.setImage(with: url)
        return cell
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
