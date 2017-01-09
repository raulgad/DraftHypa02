//
//  CardsViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

protocol CardsViewControllerDelegate {
    var passes: Passes { get set }
    func resetGame()
    func gameOver()
    func slideAwayCards(to :CardsViewController.Direction)
}

//FIXME: Check and set all variables to 'weak || owned' property if needed.
class CardsViewController: UIViewController, UIGestureRecognizerDelegate, CardsViewControllerDelegate {
    private var score = Score.sharedInstance
    internal var passes = Passes.sharedInstance
    
    var currentTask = Task()
    var nextTask = Task()
    
    let distanceForSlidingCard: CGFloat = -200
    var cards = [Card]()
    //FIXME: Is 'cardsViews' neccessary when we can use 'cards'?
    var cardsViews = [UIView]()

    var offsetBetweenTouchAndCardCenter = CGPoint.zero
    var xDistanceFromCardsStartsMovesTogether: CGFloat = 120
    var previousPassedTranslationX: CGFloat = CGFloat(0)
    var snapBehaviorDamping: CGFloat = 0.250
    
    let time = Time.sharedInstance
    
    var backside = Backside.sharedInstance
    
    var animator: UIDynamicAnimator! 
    var cardPanGestureRecognizer: UIPanGestureRecognizer!
    var questionTapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: self.view)
        // animator.setValue(true, forKey: "debugEnabled")
        
        self.view.addSubview(backside.bottomItem.view)
        self.view.addConstraints(backside.bottomItem.createViewConstraints(destinationViewController: self))
        
        //Creating cards
        for _ in 1...Card.cardsCount {
            //Init card
            let card = Card()
            self.view.addSubview(card.content)
            cards.append(card)
            
            //Get init task's text for cards
            card.label.text = currentTask.getLabel(to: card)
            
            //Set UIPanGestureRecognizer to answer cards
            cardPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
            cardPanGestureRecognizer.delegate = self
            //Set UITapGestureRecognizer to question card (top card)
            questionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
            questionTapGestureRecognizer.delegate = self
            if card.item != Card.Item.Question {
                card.content.addGestureRecognizer(cardPanGestureRecognizer)
                card.content.isExclusiveTouch = true
            } else {
                card.content.addGestureRecognizer(questionTapGestureRecognizer)
            }
            
            cardsViews.append(card.content)
            
            self.view.addConstraints(card.createViewConstraints(destinationViewController: self))
        }
        
        //Add timer view
        self.view.addSubview(time.view)
        self.view.addConstraints(time.createViewConstraints(destinationViewController: self))
        time.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set default center position of the card
        for card in cards {
            card.defaultCenter = card.content.center
        }
        
        if time.value <= 0 {
            self.performSegue(withIdentifier: "endScreenSegue", sender: nil)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func tap(tap: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "operationScreenSegue", sender: nil)
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self.view)
        guard let touchedCard = pan.view else {
            print("Error with unwrap pan.view")
            return
        }
        var location = pan.location(in: self.view)
        
        switch pan.state {
            case .began:
                //Set X offset of touched location and touched card's center
                offsetBetweenTouchAndCardCenter.x = location.x - touchedCard.center.x
                
                //Set first translation of linked cards to default value
                previousPassedTranslationX = CGFloat(0)
            
                animator.removeAllBehaviors()
            
            case .changed:
                //Moving touched card considering offset
                location.x -= offsetBetweenTouchAndCardCenter.x
                location.y = cards[touchedCard.tag].defaultCenter.y
                touchedCard.center = location
                let translationOffset = translation.x - previousPassedTranslationX
                
                backside.updateItemsWhenCardMoving(to: translation)
                
                //Moving linked cards
                //Move to right
                if translation.x > xDistanceFromCardsStartsMovesTogether {
                    //Calcute number of times that card passed xDistanceBetweenCards
                    let passedPoints = Int(translation.x / xDistanceFromCardsStartsMovesTogether)
                    
                    moveCardsWithLag(touchedCard, passedPoints, translationOffset)
                }
                //Move to left
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
                    snapBehavior.damping = snapBehaviorDamping
                    animator.addBehavior(snapBehavior)
                }
                
                //FIXME: Ugly if-else pyramid. And hardcode values "left", "right", distanceForSlidingCard
                //Slide away cards to right
                if translation.x > abs(distanceForSlidingCard) {
                    
                    //Check answer and edit score
                    if currentTask.checkAnswer(touchedCard: touchedCard.item) {
                        print("Correct answer :)")
                        score.value += 1
                        time.reset()
                        time.start()
                        
                        slideAwayCards(to: .right)
                    } else {
                        print("Wrong answer :(")
                        gameOver()
                    }
                }
                    
                //Slide away cards to left
                else if translation.x < distanceForSlidingCard {
                    //Decreese passes
                    if passes.value < 1 {
                        self.performSegue(withIdentifier: "buyScreenSegue", sender: nil)
                    } else {
                        time.reset()
                        time.start()
                        passes.value -= 1
                        
                        slideAwayCards(to: .left)
                    }
                }
            default: ()
        }
    }
    
    func moveCardsWithLag(_ touchedCard: UIView, _ passedPoints: Int, _ translationOffset: CGFloat) {
        //Moving linked cards
        for passedPoint in 1...passedPoints {
            if touchedCard.tag - passedPoint >= 0 {
                //FIXME: Hardcode "cards[touchedView.tag - passedPoint]"
                unowned let cardAbove = cards[touchedCard.tag - passedPoint]
                cardAbove.content.center = CGPoint(x: (cardAbove.content.center.x + translationOffset), y: cardAbove.defaultCenter.y)
            }
            if touchedCard.tag + passedPoint < cards.count {
                unowned let cardUnder = cards[touchedCard.tag + passedPoint]
                cardUnder.content.center = CGPoint(x: (cardUnder.content.center.x + translationOffset), y: cardUnder.defaultCenter.y)
            }
        }
    }
    
    func slideAwayCards(to direction: Direction) {
        animator.removeAllBehaviors()
        //Add UIGravityBehavior for pushing cards
        let gravity = UIGravityBehavior(items: cardsViews)
        if direction == .left {
            gravity.gravityDirection = CGVector(dx: -20, dy: 0)
        } else if direction == .right {
            gravity.gravityDirection = CGVector(dx: 20, dy: 0)
        }
        
        animator.addBehavior(gravity)
        
        //Show new cards with delay
        delay(delay: 0.25, closure: showNewCards)
    }
    
    func delay (delay: Double, closure: () ->()) {
        DispatchQueue.main.after(when: .now() + delay, execute: closure)
    }
    
    func showNewCards() {
        currentTask = nextTask
        
        animator.removeAllBehaviors()
        
        for card in cards {
            //Put next task to card
            card.label.text = currentTask.getLabel(to: card)
            
            let viewWidth = self.view.bounds.width
            let cardWidth = card.content.bounds.width
            
            //Move cards to self.view's edge
            //Move cards behind left edge
            if card.content.center.x >= (viewWidth + (cardWidth/2)) {
                card.content.center.x = ((cardWidth/2) - viewWidth)
            }
            //Move cards behind right edge
            else if card.content.center.x <= (-cardWidth/2) {
                card.content.center.x = viewWidth + (cardWidth/2)
            }
            
            //Update card's data
            card.updateColor()
            
            //Turn off view's rotation
            let dynamicItemBehavior = UIDynamicItemBehavior (items: [card.content])
            dynamicItemBehavior.allowsRotation = false
            animator.addBehavior(dynamicItemBehavior)
            
            //Set UISnapBehavior to cards for snaping to card's default position
            let snapBehavior = UISnapBehavior(item: card.content, snapTo: card.defaultCenter)
            snapBehavior.damping = snapBehaviorDamping
            animator.addBehavior(snapBehavior)
        }
        
        print("\(Task.complexity) : Task.complexity -- complexity of the next task")
        print("\(score.value) : score.value in showNewCards")
        //Update nexTask
        nextTask = Task()
    }
    
    //Setting delegate to screen's view controllers for access to resetGame()
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!  {
            case "endScreenSegue":
                let destinationViewController = segue.destinationViewController as! EndScreenViewController
                destinationViewController.delegate = self
            case "operationScreenSegue":
                let destinationViewController = segue.destinationViewController as! OperationScreenViewController
                destinationViewController.delegate = self
            case "buyScreenSegue":
                let destinationViewController = segue.destinationViewController as! BuyScreenViewController
                destinationViewController.delegate = self
            default: ()
        }
    }
    
    func gameOver() {
        time.stop()
        print("Game Over!")
        self.performSegue(withIdentifier: "endScreenSegue", sender: nil)
    }
    
    func resetGame() {
        print("New Game!")
        Task.resetComplexity()
        nextTask = Task()
        score.value = 0
        time.reset()
        showNewCards()
    }
 
    enum Direction {
        case left, right, up, down, unknown
    }
}
