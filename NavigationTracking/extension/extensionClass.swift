//
//  extensionClass.swift
//  NavigationTracking
//
//  Created by manish on 17/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit

extension UIView {
    func viewBorder(){
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4.0
    }
    
    
    func viewStartCornerRadius(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15.0
    }
    
}

extension UIViewController{
    func showAlert(){
        let alertController = UIAlertController(title: "Internet Connect", message: "Internet connection seems to be offline. Please check your internet connect and try again.", preferredStyle:UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in

        })
        self.present(alertController, animated: true, completion: nil)
    }
}

