//
//  BottomItem.swift
//  Draft_Hypa_02
//
//  Created by mac on 02.12.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

class BottomItem {
    static let sharedInstance = BottomItem()
    
    var view: UIStackView
    var pinLeftView: NSLayoutConstraint!
    var valueLabel = UILabel()
    var nameLabel = UILabel()
    
    private init() {
        valueLabel.font = UIFont(name: valueLabel.font.fontName, size: 100)
        valueLabel.backgroundColor = #colorLiteral(red: 0.1991284192, green: 0.6028449535, blue: 0.9592232704, alpha: 1)
        valueLabel.text = String(Score.sharedInstance.value)
        
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 24)
        nameLabel.backgroundColor = #colorLiteral(red: 0.7540004253, green: 0, blue: 0.2649998069, alpha: 1)
        nameLabel.text = Score.sharedInstance.name
        
        view = UIStackView(arrangedSubviews: [valueLabel, nameLabel])
        view.axis = .vertical
        view.contentMode = .scaleAspectFit
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createViewConstraints(destinationViewController: UIViewController) -> [NSLayoutConstraint] {
        pinLeftView = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 12)
        let pinRightView = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0)
        let topMarginView = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: (0.65 * destinationViewController.view.bounds.height))
        
        let heightView = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.height, multiplier: 0.3, constant: 0)
        return [pinLeftView, pinRightView, topMarginView, heightView]
    }
    
    func updateViewWhenCardMoving(direction: CardsViewController.Direction) {
        switch direction {
        case .left:
            if pinLeftView.constant == LeftSideViewMargin.right.rawValue {
                valueLabel.text = String(Score.sharedInstance.value)
                nameLabel.text = Score.sharedInstance.name
                pinLeftView.constant = LeftSideViewMargin.left.rawValue
            }
        case .right:
            if pinLeftView.constant == LeftSideViewMargin.left.rawValue {
                valueLabel.text = String(Passes.sharedInstance.value)
                nameLabel.text = Passes.sharedInstance.name
                pinLeftView.constant = LeftSideViewMargin.right.rawValue
            }
        default:
            print("'updateViewWhenCardMoving' not defined for this direction")
        }
    }
    
    //We need to update score and passes label if they values has updated in card moving to same direction as before.
    func updateScoreOrPassesInView() {
        let name = view.arrangedSubviews[1] as! UILabel
        if name.text == Score.sharedInstance.name {
            valueLabel.text = String(Score.sharedInstance.value)
        } else if name.text == Passes.sharedInstance.name {
            valueLabel.text = String(Passes.sharedInstance.value)
        }
    }
    
    enum LeftSideViewMargin: CGFloat {
        case left = 12
        case right = 242
    }
}
