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
    //FIXME: Card's design should be setted with UIStackview and UIScrollview by Interface Builder (IBDesignable?)
    //Save previousCard for use in setLayout() and init()
    private static var previousCard: Card!
    //Number of cards in app
    static let count: Int = 8
    //FIXME: Use CGAffineTransform.identity instead defaultCenter
    var defaultCenter = CGPoint()
    
    var view: UIView
    var label = UILabel()
    let item: Item
    
    init() {
        let currentCardNumber = Card.previousCard == nil ? 0 : (Card.previousCard.view.tag + 1)
        
        item = currentCardNumber == 0 ? .question : .answer(currentCardNumber)
        
        view = UIView()
        view.backgroundColor = UIColor.randomColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.tag = currentCardNumber
        
        view.layer.cornerRadius = item == .question ? 0 : 4
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.shadowColor = UIColor.white()
        label.textAlignment = .center
        label.text = String(self.item)
        view.addSubview(label)
    }
    
    func setLayout(inView: UIView) {
        
        //Create constant for decreasing view's height considering top-margin between answers (12px)
        let heightMarginsDecrease = -(12 + (12/CGFloat(Card.count))*2)
        
        let heightMultiplierForQuestion = Card.count > 1 ? CGFloat(0.35) : 1
        let heightMultiplierForAnswer = Card.count > 1 ? ((1 - heightMultiplierForQuestion) / CGFloat(Card.count-1)) : 1
        let isQuestionCard = self.item == .question
        
        //FIXME: Workaround below is needed to set default position of the card. Setting default center in the viewDidAppear of CardsViewController doesn't work properly when UISnapBehavior.damping is 1 or bigger.
        let questionCenter = (heightMultiplierForQuestion * inView.frame.height + heightMarginsDecrease) / 2
        let answerCenter = (heightMultiplierForAnswer * inView.frame.height + heightMarginsDecrease) / 2
        
        switch self.view.tag {
        case 0:
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: questionCenter + 20)
        case 1:
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: (Card.previousCard.defaultCenter.y + questionCenter + answerCenter + 13))
        default :
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: (Card.previousCard.defaultCenter.y + answerCenter*2 + 13))
        }
        
        //Set constraints to card
        self.view.widthAnchor.constraint(equalTo: inView.widthAnchor,
                                         multiplier: isQuestionCard ? 1 : 0.925).isActive = true
        self.view.centerXAnchor.constraint(equalTo: inView.centerXAnchor).isActive = true
        self.view.centerYAnchor.constraint(equalTo: inView.centerYAnchor,
                                           constant: (defaultCenter.y - inView.center.y)).isActive = true
        self.view.heightAnchor.constraint(equalTo: inView.heightAnchor,
                                          multiplier: isQuestionCard ? heightMultiplierForQuestion : heightMultiplierForAnswer,
                                          constant: heightMarginsDecrease).isActive = true

        Card.previousCard = self
    }
    
    func updateColor() {
        self.view.backgroundColor = UIColor.randomColor()
    }
    
    enum Item {
        case question, answer(Int), unknown
    }
}

func == (left: Card.Item, right: Card.Item) -> Bool {
    switch (left, right) {
    case (.answer(let a), .answer(let b))   where a == b: return true
    case (.question, .question): return true
    case (.unknown, .unknown): return true
    default: return false
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
