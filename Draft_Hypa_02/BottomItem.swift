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
    var leadingAnchor = NSLayoutConstraint()
    var valueLabel = UILabel()
    var nameLabel = UILabel()
    
    private init() {
        valueLabel.font = UIFont(name: valueLabel.font.fontName, size: 100)
        valueLabel.backgroundColor = #colorLiteral(red: 0.1991284192, green: 0.6028449535, blue: 0.9592232704, alpha: 1)
        valueLabel.text = String(Score.sharedInstance.value)
        
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 24)
        nameLabel.backgroundColor = #colorLiteral(red: 0.7540004253, green: 0, blue: 0.2649998069, alpha: 1)
        nameLabel.text = Score.sharedInstance.name
        
        //FIXME: There must be two different stackviews for score and passes accordingly
        view = UIStackView(arrangedSubviews: [valueLabel, nameLabel])
        view.axis = .vertical
        view.contentMode = .scaleAspectFit
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setLayout(inView: UIView) {
        leadingAnchor = self.view.leadingAnchor.constraint(equalTo: inView.leadingAnchor,
                                                           constant: 12)
        leadingAnchor.isActive = true
        self.view.topAnchor.constraint(equalTo: inView.topAnchor,
                                       constant: (0.65 * inView.bounds.height)).isActive = true
        self.view.heightAnchor.constraint(equalTo: inView.heightAnchor,
                                          multiplier: 0.3).isActive = true
    }
    
    func updateViewWhenCardMoving(direction: CardsViewController.Direction) {
        switch direction {
        case .left:
            if leadingAnchor.constant == ViewPosition.right.rawValue {
                valueLabel.text = String(Score.sharedInstance.value)
                nameLabel.text = Score.sharedInstance.name
                leadingAnchor.constant = ViewPosition.left.rawValue
            }
        case .right:
            if leadingAnchor.constant == ViewPosition.left.rawValue {
                valueLabel.text = String(Passes.sharedInstance.value)
                nameLabel.text = Passes.sharedInstance.name
                leadingAnchor.constant = ViewPosition.right.rawValue
            }
        default:
            print("'updateViewWhenCardMoving' not defined for this direction")
        }
    }
    
    enum ViewPosition: CGFloat {
        case left = 12
        case right = 242
    }
}
