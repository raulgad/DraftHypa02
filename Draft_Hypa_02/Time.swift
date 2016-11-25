//
//  Time.swift
//  Draft_Hypa_02
//
//  Created by mac on 23.11.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

struct Time {
    static let sharedInstance = Time()
    var view: UIView
    var pinRightTimer: NSLayoutConstraint!
    
    private init() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.green()
    }
    
    func resetViewToDefault() {
        view.backgroundColor = UIColor.green()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main().bounds.width, height: view.bounds.height)
    }
    
    mutating func createConstraints(destinationViewController: UIViewController) -> [NSLayoutConstraint] {
        let pinLeftTimer = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        pinRightTimer = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0)
        let heightTimer = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.height, multiplier: 0.0412, constant: 0)
        return [pinLeftTimer, pinRightTimer, heightTimer]
    }
}
