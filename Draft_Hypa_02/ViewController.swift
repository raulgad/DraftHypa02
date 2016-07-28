//
//  ViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    let cardsCount: Int = 3
    var cards = [Cards]()
    var cardsViews = [UIView]()

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
        for _ in 1...cardsCount {
            //Init card
            let card = Cards()
            self.view.addSubview(card.content)
            cards.append(card)
            
            //Set UIPanGestureRecognizer to card
            cardPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
            cardPanGestureRecognizer.delegate = self
            card.content.addGestureRecognizer(cardPanGestureRecognizer)
            card.content.isExclusiveTouch = true
            
            cardsViews.append(card.content)
        }
        
        createConstrants()
    }
    
    func createConstrants() {
        for card in cards {
            //Set constraints to card
            let pinLeftCard = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: card.item == 0 ? 0 : 12)
            let pinRightCard = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: card.item == 0 ? 0 : -12)
            let topMarginCards = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: card.item == 0 ? self.view : cards[card.item - 1].content, attribute: card.item == 0 ? NSLayoutAttribute.top : NSLayoutAttribute.bottom, multiplier: 1.0, constant: card.item == 0 ? 24 : 12)
            
            //Create constant for decreasing view's height considering top-margins between views
            let heightMarginsDecrease = -(12 + (12/CGFloat(cardsCount))*2)
            
            let heightMultiplierForTaskCard = cardsCount > 1 ? CGFloat(0.35) : 1
            let heightMultiplierForAnswerCards = cardsCount > 1 ? ((1 - heightMultiplierForTaskCard) / CGFloat(cardsCount-1)) : 1
            let heightCard = NSLayoutConstraint(item: card.content, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: card.item == 0 ? heightMultiplierForTaskCard : heightMultiplierForAnswerCards, constant: heightMarginsDecrease)

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
                for card in cards { card.content.center = card.defaultCenter }

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
                
                let translationOffset = translation.x - previousPassedTranslationX
                
                //Moving linked cards
                if translation.x > xDistanceBetweenCards {
                    //Calcute number of times that card passed xDistanceBetweenCards
                    let passedPoints = Int(translation.x / xDistanceBetweenCards)
                    
                    moveCardsWithLag(touchedView, passedPoints, translationOffset)
                }
                if translation.x < 0 {
                    //Move cards to the left simultaneously
                    for card in cards {
                        card.content.center = CGPoint(x: (card.content.center.x + translationOffset), y: card.defaultCenter.y)
                    }
                }
                
                //Saving current translation pass for translation movement
                previousPassedTranslationX = translation.x
            
            case .cancelled, .ended:
                animator.removeAllBehaviors()
                
                //Add UIDynamicItemBehavior to animator and turn off allowsRotation of the card
                let dynamicItemBehavior = UIDynamicItemBehavior(items: cardsViews)
                dynamicItemBehavior.allowsRotation = false
                animator.addBehavior(dynamicItemBehavior)
                
                //Set UISnapBehavior to cards
                //FIXME: Cycles in this function is not a good idea?
                for card in cards {
                    //FIXME: Creating snap behaviors with same variable name
                    //Set UISnapBehavior to views
                    let snapBehavior = UISnapBehavior(item: card.content, snapTo: card.defaultCenter)
                    snapBehavior.damping = 0.20
                    animator.addBehavior(snapBehavior)
                }
                
                //Slide away cards
                //FIXME: Hardcode values "200, -200"
                if translation.x > 200 {
                    slideAwayCards(direction: 20)
                }
                else if translation.x < -200 {
                    slideAwayCards(direction: -20)
                }
            
            default: ()
        }
    }
    
    func moveCardsWithLag(_ touchedView: UIView, _ passedPoints: Int, _ translationOffset: CGFloat) {
        //Moving linked cards
        for passedPoint in 1...passedPoints {
            if touchedView.tag - passedPoint >= 0 {
                unowned let cardAbove = cards[touchedView.tag - passedPoint]
                cardAbove.content.center = CGPoint(x: (cardAbove.content.center.x + translationOffset), y: cardAbove.defaultCenter.y)
            }
            if touchedView.tag + passedPoint < cards.count {
                unowned let cardUnder = cards[touchedView.tag + passedPoint]
                cardUnder.content.center = CGPoint(x: (cardUnder.content.center.x + translationOffset), y: cardUnder.defaultCenter.y)
            }
        }
    }
    
    func slideAwayCards(direction: Int) {
        animator.removeAllBehaviors()
        let gravity = UIGravityBehavior(items: cardsViews)
        gravity.gravityDirection = CGVector(dx: direction, dy: 0)
        animator.addBehavior(gravity)
        
        //Show new cards with delay
        delay(delay: 0.25, closure: showNewCards)
    }
    
    func delay (delay: Double, closure: () ->()) {
        DispatchQueue.main.after(when: .now() + delay, execute: closure)
    }
    
    func showNewCards() {
        animator.removeAllBehaviors()
        
        for card in cards {
            let viewWidth = self.view.bounds.width
            let cardWidth = card.content.bounds.width
            
            //Move cards to self.view's edge
            if card.content.center.x >= (viewWidth + (cardWidth/2)) {
                card.content.center.x = ((cardWidth/2) - viewWidth)
            }
            else if card.content.center.x <= (-cardWidth/2) {
                card.content.center.x = viewWidth + (cardWidth/2)
            }
            
            //Update card's data
            card.content.backgroundColor = UIColor.randomColor()
            
            //Turn off view's rotation
            let dynamicItemBehavior = UIDynamicItemBehavior (items: [card.content])
            dynamicItemBehavior.allowsRotation = false
            animator.addBehavior(dynamicItemBehavior)
            
            //Set UISnapBehavior to cards
            let snapBehavior = UISnapBehavior(item: card.content, snapTo: card.defaultCenter)
            snapBehavior.damping = 0.20
            animator.addBehavior(snapBehavior)
        }
    }
    
}

