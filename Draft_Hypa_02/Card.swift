//
//  Cards.swift
//  Draft_Hypa_02
//
//  Created by mac on 27.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

//FIXME: Why using class and not struct? Struct is better for perfomance (it using stack and value type). Because we cannot assign new value to struct's property. See 'Protocol and Value Oriented Programming in UIKit Apps' WWDC video.
class Card {
    //Use 'cardNumber' for set number of the card in an 'UIView.tag' parameter
    private static var cardNumber: Int = 0
    private static var previousCardsContentForConstraint = UIView()
    static let cardsCount: Int = 3
    
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
        content.tag = Card.cardNumber
        item = Item(rawValue: Card.cardNumber) ?? Item.Unknown
        content.layer.cornerRadius = (item == .Question) ? 0 : 4
        label.text = String(self.item)
        content.addSubview(label)
        defaultCenter = content.center
        
        Card.cardNumber += 1
    }
    
    func createConstraints(destinationViewController: UIViewController) -> [NSLayoutConstraint] {
        let pinLeftCard = NSLayoutConstraint(item: self.content, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: self.item == .Question ? 0 : 12)
        let pinRightCard = NSLayoutConstraint(item: self.content, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: self.item == .Question ? 0 : -12)
        let topMarginCards = NSLayoutConstraint(item: self.content, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.item == .Question ? destinationViewController.view : Card.previousCardsContentForConstraint, attribute: self.item == .Question ? NSLayoutAttribute.top : NSLayoutAttribute.bottom, multiplier: 1.0, constant: self.item == .Question ? 20 : 13)
        
        //Create constant for decreasing view's height considering top-margins between views
        let heightMarginsDecrease = -(12 + (12/CGFloat(Card.cardsCount))*2)
        
        let heightMultiplierForQuestionCard = Card.cardsCount > 1 ? CGFloat(0.35) : 1
        let heightMultiplierForAnswerCards = Card.cardsCount > 1 ? ((1 - heightMultiplierForQuestionCard) / CGFloat(Card.cardsCount-1)) : 1
        
        let heightCard = NSLayoutConstraint(item: self.content, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: destinationViewController.view, attribute: NSLayoutAttribute.height, multiplier: self.item == .Question ? heightMultiplierForQuestionCard : heightMultiplierForAnswerCards, constant: heightMarginsDecrease)
        
        //Storing card's view for get access to an upper card in topMarginCards constraint
        Card.previousCardsContentForConstraint = self.content
        
        return [pinLeftCard, pinRightCard, topMarginCards, heightCard]
    }
    
    func updateColor() {
        self.content.backgroundColor = UIColor.randomColor()
    }
    
    //FIXME: What you will do if number of answers will be changed dynamically?
    enum Item: Int {
        case Question, AnswerOne, AnswerTwo, Unknown
    }
}

//Extension for get card's item in an UIView
extension UIView {
    var item: Card.Item {
        get {
            return Card.Item(rawValue: self.tag) ?? Card.Item.Unknown
        }
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
