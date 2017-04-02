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
//    var leadingAnchor = NSLayoutConstraint()
//    var centerXAnchor = NSLayoutConstraint()
    var leadingAnchor = NSLayoutConstraint()
    var trailingAnchor = NSLayoutConstraint()
    var viewPosition: CGFloat!
    var valueLabel = UILabel()
    var nameLabel = UILabel()
    
    private init() {
        valueLabel.textColor = UIColor.lightGray()
        valueLabel.font = UIFont.systemFont(ofSize: 120, weight: UIFontWeightThin)
        valueLabel.numberOfLines = 2
        valueLabel.minimumScaleFactor = 0.25
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.textAlignment = .center
        valueLabel.text = String(Score.sharedInstance.value)
        
        nameLabel.textColor = UIColor.lightGray()
        nameLabel.font = UIFont.systemFont(ofSize: 46, weight: UIFontWeightThin)
        nameLabel.textAlignment = .center
        nameLabel.text = Score.sharedInstance.name
        
        //FIXME: There must be two different stackviews for score and passes accordingly
        view = UIStackView(arrangedSubviews: [valueLabel, nameLabel])
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = -40
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.isHidden = true
    }
    
    func setLayout(inView: UIView) {
        leadingAnchor = self.view.leadingAnchor.constraint(equalTo: inView.leadingAnchor, constant: 12)
        leadingAnchor.isActive = true
        
        trailingAnchor = self.view.trailingAnchor.constraint(equalTo: inView.trailingAnchor, constant: -12)
        
        self.view.bottomAnchor.constraint(equalTo: inView.bottomAnchor, constant: -12).isActive = true
        self.view.widthAnchor.constraint(lessThanOrEqualTo: inView.widthAnchor, multiplier: 0.5).isActive = true
        self.view.heightAnchor.constraint(equalTo: inView.heightAnchor,
                                          multiplier: 0.4).isActive = true
    }
    
    func updateViewWhenCardMoving(direction: CardsViewController.Direction) {
        
        switch direction {
        case .left:
            if trailingAnchor.isActive {
                trailingAnchor.isActive = false
                leadingAnchor.isActive = true
                valueLabel.text = String(Score.sharedInstance.value)
                nameLabel.text = Score.sharedInstance.name
            }
            
        case .right:
            if leadingAnchor.isActive {
                leadingAnchor.isActive = false
                trailingAnchor.isActive = true
                valueLabel.text = String(Passes.sharedInstance.value)
                nameLabel.text = Passes.sharedInstance.name
            }
        default:
            print("'updateViewWhenCardMoving' not defined for this direction")
        }
    }
    
}
