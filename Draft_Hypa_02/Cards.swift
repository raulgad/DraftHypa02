//
//  Cards.swift
//  Draft_Hypa_02
//
//  Created by mac on 27.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

//FIXME: Why using class and not struct? Struct is better for perfomance (it using stack and value type)
class Cards {
    private static var item: Int = 0
    
    var content: UIView
    var defaultCenter: CGPoint
    let item: Int = Cards.item
    
    init() {
        self.content = UIView()
        content.backgroundColor = UIColor.randomColor()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.layer.cornerRadius = 4
        content.tag = Cards.item
        Cards.item += 1
        self.defaultCenter = content.center
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        // If you wanted a random alpha, just create another random number for that too.
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
