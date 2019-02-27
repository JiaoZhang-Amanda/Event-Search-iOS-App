//
//  ATCollectionViewCell.swift
//  search
//
//  Created by Amanda_Zhang on 2018/11/23.
//  Copyright © 2018 Amanda. All rights reserved.
//

import UIKit
import WebKit

//extension UIView {
//
//    // In order to create computed properties for extensions, we need a key to
//    // store and access the stored property
//    fileprivate struct AssociatedObjectKeys {
//        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
//    }
//
//    fileprivate typealias Action = (() -> Void)?
//
//    // Set our computed property type to a closure
//    fileprivate var tapGestureRecognizerAction: Action? {
//        set {
//            if let newValue = newValue {
//                // Computed properties get stored as associated objects
//                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//            }
//        }
//        get {
//            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
//            return tapGestureRecognizerActionInstance
//        }
//    }
//
//    // This is the meat of the sauce, here we create the tap gesture recognizer and
//    // store the closure the user passed to us in the associated object we declared above
//    public func addTapGestureRecognizer(action: (() -> Void)?) {
//        self.isUserInteractionEnabled = true
//        self.tapGestureRecognizerAction = action
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
//        self.addGestureRecognizer(tapGestureRecognizer)
//    }
//
//    // Every time the user taps on the UIImageView, this function gets called,
//    // which triggers the closure we stored
//    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
//        if let action = self.tapGestureRecognizerAction {
//            action?()
//        } else {
//            print("no action")
//        }
//    }
//
//}


class ATCollectionViewCell: UICollectionViewCell, WKUIDelegate {
    
    
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var m_name: UILabel!
    @IBOutlet weak var m_follower: UILabel!
    @IBOutlet weak var m_popular: UILabel!
    @IBOutlet weak var m_check: UILabel!
    var uri = String()
    
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img5: UIImageView!
    @IBOutlet weak var img6: UIImageView!
    @IBOutlet weak var img7: UIImageView!
    @IBOutlet weak var img8: UIImageView!
    func addGesture(){
        print("Check for add gesture")
        //print(uri)
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(myaction))
        m_check.addGestureRecognizer(gesture)
    }
    
    @objc func myaction()
    {
        print("dddd")
        if let url = URL(string: self.uri) {
            UIApplication.shared.open(url, options: [:])
        }
        //TODO
    }
    
    
}
