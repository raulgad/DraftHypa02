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
    
    
    
    //Use 'number' for set number of the card in an 'UIView.tag' parameter
    private static var number: Int = 0
    private static var previousCard: Card!
    static let cardsCount: Int = 8
    
    var label: UILabel
    
    
    
    var view: UIView
//    FIXME: CGAffineTransform.identity instead defaultCenter
    var defaultCenter: CGPoint!
    let type: Item
    
    init() {
        type = Item(rawValue: Card.number) ?? Item.Unknown
        
        view = UIView()
        view.backgroundColor = UIColor.randomColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.tag = Card.number
        
        view.layer.cornerRadius = (type == .Question) ? 0 : 4
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.shadowColor = UIColor.white()
        label.textAlignment = .center
        label.text = String(self.type)
        view.addSubview(label)
        
        Card.number += 1
    }
    
    func setLayout(inView: UIView) {
        
        //Create constant for decreasing view's height considering top-margins between views
        let heightMarginsDecrease = -(12 + (12/CGFloat(Card.cardsCount))*2)
        
        let heightMultiplierForQuestionCard = Card.cardsCount > 1 ? CGFloat(0.35) : 1
        let heightMultiplierForAnswerCards = Card.cardsCount > 1 ? ((1 - heightMultiplierForQuestionCard) / CGFloat(Card.cardsCount-1)) : 1
        let isQuestionCard = self.type == .Question
        
        self.view.leadingAnchor.constraint(equalTo: inView.leadingAnchor,
                                           constant: isQuestionCard ? 0 : 12).isActive = true
        self.view.trailingAnchor.constraint(equalTo: inView.trailingAnchor,
                                            constant: isQuestionCard ? 0 : -12).isActive = true
        self.view.heightAnchor.constraint(equalTo: inView.heightAnchor,
                                          multiplier: isQuestionCard ? heightMultiplierForQuestionCard : heightMultiplierForAnswerCards,
                                          constant: heightMarginsDecrease).isActive = true
        self.view.topAnchor.constraint(equalTo: isQuestionCard ? inView.topAnchor : Card.previousCard.view.bottomAnchor,
                                       constant: isQuestionCard ? 20 : 13).isActive = true
        
        //FIXME: Ugly code below is needed to set default position of the card. Setting default center in the viewDidAppear of CardsViewController doesn't work properly when UISnapBehavior.damping is 1 or bigger.
        let questionViewHeight = heightMultiplierForQuestionCard * inView.frame.height + heightMarginsDecrease
        let answerViewHeight = heightMultiplierForAnswerCards * inView.frame.height + heightMarginsDecrease
        
        switch self.view.tag {
        case 0:
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: ((questionViewHeight / 2) + 20))
        case 1:
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: (Card.previousCard.defaultCenter.y + (questionViewHeight / 2) + (answerViewHeight / 2) + 13))
        default :
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: (Card.previousCard.defaultCenter.y + answerViewHeight + 13))
        }
        
        Card.previousCard = self
    }
    
    func updateColor() {
        self.view.backgroundColor = UIColor.randomColor()
    }
    
    //FIXME: Set number of answers by number Cards.count
    enum Item: Int {
        case Question, AnswerOne, AnswerTwo, Unknown
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
