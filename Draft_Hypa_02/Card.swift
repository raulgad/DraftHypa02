//
//  Cards.swift
//  Draft_Hypa_02
//
//  Created by mac on 27.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

class Card {
    //Save previous created card for using in setLayout() and init()
    private static var previousCard: Card!
    //Number of cards in the app
    static var count: Int = 3
    var defaultCenter = CGPoint()
    var center = (x: NSLayoutConstraint(), y: NSLayoutConstraint())
    
    var view = UIView()
    var label = UILabel()
    //Type of the card (question or answer)
    let item: Item
    
    init() {
        let currentCardNumber = Card.previousCard == nil ? 0 : (Card.previousCard.view.tag + 1)
        
        item = currentCardNumber == 0 ? .question : .answer(currentCardNumber)
        
        view.tag = currentCardNumber
        
        setViewUI()        
        setLabelUI()
    }
    
    func setLayout(inView: UIView) {
        //Create constant for decreasing view's height considering top-margin (12px) between answers
        let heightMarginsDecrease = -(12 + (12/CGFloat(Card.count))*2)
        
        let heightMultiplierForQuestion = Card.count > 1 ? CGFloat(0.35) : 1
        let heightMultiplierForAnswer = Card.count > 1 ? ((1 - heightMultiplierForQuestion) / CGFloat(Card.count-1)) : 1
        let isQuestionCard = (self.item == .question)
        
        //Set default position of the card.
        let questionYCenter = (heightMultiplierForQuestion * inView.frame.height + heightMarginsDecrease) / 2
        let answerYCenter = (heightMultiplierForAnswer * inView.frame.height + heightMarginsDecrease) / 2
        
        switch self.view.tag {
        case 0:
            //Set 'defaultCenter' for question card
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: questionYCenter + 20)
        case 1:
            //Set 'defaultCenter' for first answer card
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: (Card.previousCard.defaultCenter.y + questionYCenter + answerYCenter + 13))
        default :
            //Set 'defaultCenter' for answer cards below first answer card
            defaultCenter = CGPoint(x: inView.center.x,
                                    y: (Card.previousCard.defaultCenter.y + (answerYCenter * 2) + 13))
        }
        
        //Set constraints to the card
        center.x = self.view.centerXAnchor.constraint(equalTo: inView.centerXAnchor)
        center.x.isActive = true
        center.y = self.view.centerYAnchor.constraint(equalTo: inView.centerYAnchor,
                                           constant: (defaultCenter.y - inView.center.y))
        center.y.isActive = true
        self.view.widthAnchor.constraint(equalTo: inView.widthAnchor,
                                         multiplier: isQuestionCard ? 1 : 0.925).isActive = true
        self.view.heightAnchor.constraint(equalTo: inView.heightAnchor,
                                          multiplier: isQuestionCard ? heightMultiplierForQuestion : heightMultiplierForAnswer,
                                          constant: heightMarginsDecrease).isActive = true

        Card.previousCard = self
    }
    
    func setViewUI() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Task.operation.color
        view.layer.cornerRadius = item == .question ? 0 : 4
        view.clipsToBounds = true
    }
    
    func setLabelUI() {
        label.textColor = UIColor.white()
        label.font = UIFont.systemFont(ofSize: 64, weight: UIFontWeightThin)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.25
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = String(self.item)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    static func resetLayoutSettings() {
        previousCard = nil
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
