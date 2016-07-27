//
//  ViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    var cards: [Cards] = []

    var offset = CGPoint.zero
    var xDistanceBetweenCards: CGFloat = 80
    var previousPassedTranslationX: CGFloat = CGFloat(0)
    
    var animator: UIDynamicAnimator!
    
    var cardPanGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator(referenceView: self.view)
//        animator.setValue(true, forKey: "debugEnabled")
        
        //Creating cards
        for _ in 0...5 {
            //Init card
            let card = Cards()
            self.view.addSubview(card.content)
            cards.append(card)
            
            //Set UIPanGestureRecognizer to card
            cardPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
            cardPanGestureRecognizer.delegate = self
            card.content.addGestureRecognizer(cardPanGestureRecognizer)
            card.content.isExclusiveTouch = true
        }
        
        createConstrants()
    }
    
    func createConstrants() {
        for card in cards {
            //Set constraints to card
            let pinLeftCard = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: card.item == 0 ? 0 : 12)
            let pinRightCard = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: card.item == 0 ? 0 : -12)
            let topMarginCards = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: card.item == 0 ? self.view : cards[card.item - 1].content, attribute: card.item == 0 ? NSLayoutAttribute.top : NSLayoutAttribute.bottom, multiplier: 1.0, constant: card.item == 0 ? 24 : 12)
            let heightCard = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: card.item == 0 ? 0.25 : 0.11, constant: 0)
            self.view.addConstraints([pinLeftCard, pinRightCard, topMarginCards, heightCard])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set default center position of the card
        for card in cards {
            card.defaultCenter = card.content.center
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self.view)
        guard let touchedView = pan.view else {
            print("Error with unwrap pan.view")
            return
        }
        var location = pan.location(in: self.view)
        
        switch pan.state {
            case .began:
                //Set previous touched cards to init default positions is user starts touching card due snaping
                //FIXME: Cycles in this function is not a good idea?
                for card in cards {
                    card.content.center = card.defaultCenter
                }

                //Set X offset of touched location and touched card's center
                let touchedViewCenter = touchedView.center
                offset.x = location.x - touchedViewCenter.x
                
                //Set first translation of linked cards to default value
                previousPassedTranslationX = CGFloat(0)
            
                animator.removeAllBehaviors()
            
            case .changed:
                //Moving touched card considering offset
                location.x -= offset.x
                location.y = cards[touchedView.tag].defaultCenter.y
                touchedView.center = location
                
                //FIXME: Ugly "if pyramid"
                //Linking cards for sliding
                if translation.x > xDistanceBetweenCards {
                    //Calcute number of times that card passed xDistanceBetweenCards
                    let passedPoints = Int(translation.x / xDistanceBetweenCards)
                    
                    for passedPoint in 1...passedPoints {
                        //FIXME: Ugly "if statements"
                        if touchedView.tag - passedPoint >= 0 {
                            //FIXME: Vague appeal "x: (cards[touchedView.tag - passedPoint].content.center.x + (translation.x - previousPassedTranslationX))"
                            cards[touchedView.tag - passedPoint].content.center = CGPoint(x: (cards[touchedView.tag - passedPoint].content.center.x + (translation.x - previousPassedTranslationX)), y: cards[touchedView.tag - passedPoint].defaultCenter.y)
                        }
                        if touchedView.tag + passedPoint < cards.count {
                            cards[touchedView.tag + passedPoint].content.center = CGPoint(x: (cards[touchedView.tag + passedPoint].content.center.x + (translation.x - previousPassedTranslationX)), y: cards[touchedView.tag + passedPoint].defaultCenter.y)
                        }
                    }
                }
                if translation.x < 0 {
                    for card in cards {
                        card.content.center = CGPoint(x: (card.content.center.x + (translation.x - previousPassedTranslationX)), y: card.defaultCenter.y)
                    }
                }
                
                //Saving current translation pass for translation movement
                previousPassedTranslationX = translation.x
            
            case .cancelled, .ended:
                animator.removeAllBehaviors()
                
                //Set UISnapBehavior to cards but previously turn off allowsRotation of the card
                //FIXME: Cycles in this function is not a good idea?
                for card in cards {
                    //Add UIDynamicItemBehavior to animator
                    let dynamicItemBehavior = UIDynamicItemBehavior(items: [card.content])
                    dynamicItemBehavior.allowsRotation = false
                    animator.addBehavior(dynamicItemBehavior)
                    
                    //FIXME: Creating snap behaviors with same variable name
                    //Set UISnapBehavior to views
                    let snapBehavior = UISnapBehavior(item: card.content, snapTo: card.defaultCenter)
                    snapBehavior.damping = 0.15
                    animator.addBehavior(snapBehavior)
                }
            
            default: ()
        }
    }
}

