//
//  Cards.swift
//  Draft_Hypa_02
//
//  Created by mac on 27.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

//FIXME: Why using class and not struct? Struct is better for perfomance (it using stack and value type). Because cannot assign new value to struct's property. See 'Protocol and Value Oriented Programming in UIKit Apps' WWDC video.
class Card {
    //Use var 'item' for set number of the card in an 'UIView.tag' parameter
    private static var item: Int = 0
        
    var content: UIView
    var label: UILabel
    //FIXME: Parameter "defaultCenter" not in the right place, it should be realized like a parameter of an UIView?
    var defaultCenter: CGPoint
    let item: Item
    
    init() {
        content = UIView()
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.shadowColor = UIColor.white()
        label.textAlignment = .center
        content.backgroundColor = UIColor.randomColor()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.tag = Card.item
        
        switch Card.item {
        case 0:
            item = Item.Question
        case 1:
            item = Item.AnswerOne
        case 2:
            item = Item.AnswerTwo
        default:
            item = Item.Unknown
            print("\(item) : 'item' property has incorrect value")
        }
        
        label.text = String(self.item)
        content.addSubview(label)
        if item == .Question {
            content.layer.cornerRadius = 0
        } else {
            content.layer.cornerRadius = 4
        }
        
        Card.item += 1
        self.defaultCenter = content.center
    }
    
    //FIXME: What you will do if number of answers will be changed dynamically?
    enum Item {
        case Question, AnswerOne, AnswerTwo, Unknown
    }
    
    func updateColor() {
        self.content.backgroundColor = UIColor.randomColor()
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
