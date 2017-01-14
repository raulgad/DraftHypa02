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
    
    let distanceWhichStartsSlideCardsAway: CGFloat = -200
    var cards = [Card]()
    //FIXME: Is 'cardsViews' neccessary when we can use 'cards'?
    var cardsViews = [UIView]()

    var offsetBetweenTouchAndCardCenter = CGPoint.zero
    var xDistanceFromCardsStartsMovesTogether: CGFloat = 120
    var previousPassedTranslationX: CGFloat = CGFloat(0)
    
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
//        self.view.addConstraints(backside.bottomItem.setLayout(inView: self.view))
        backside.bottomItem.setLayout(inView: self.view)
        
        //Creating cards
        for _ in 1...Card.cardsCount {
            //Init card
            let card = Card()
            //Get init task's text for cards
            card.label.text = currentTask.getLabel(to: card)
            //Set UIPanGestureRecognizer to answer cards
            cardPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
            cardPanGestureRecognizer.delegate = self
            //Set UITapGestureRecognizer to question card (top card)
            questionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
            questionTapGestureRecognizer.delegate = self
            card.view.addGestureRecognizer(card.type == Card.Item.Question ? questionTapGestureRecognizer : cardPanGestureRecognizer)
            card.view.isExclusiveTouch = true
            
            cards.append(card)
            cardsViews.append(card.view)
            
            self.view.addSubview(card.view)
//            self.view.addConstraints(card.createViewConstraints(destinationView: self.view))
            card.setLayout(inView: self.view)
        }
        
        //Add timer view
        self.view.addSubview(time.view)
//        self.view.addConstraints(time.setLayout(inView: self.view))
        time.setLayout(inView: self.view)
        time.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        //Set default center position of the card
//        for card in cards {
//            card.defaultCenter = card.view.center
//            print("\(card.view.center.y) : card.view.center.y")
//        }
        
        if time.value <= 0 {
            self.performSegue(withIdentifier: "endScreenSegue", sender: nil)
        }
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
                    
                    moveCardsWithLapse(touchedCard, passedPoints, translationOffset)
                }
                //Move to left
                if translation.x < 0 {
                    
                    //Move cards to the left simultaneously
                    for card in cards {
                        card.view.center = CGPoint(x: (card.view.center.x + translationOffset), y: card.defaultCenter.y)
                    }
                }
                
                //Saving current translation pass for translation movement
                previousPassedTranslationX = translation.x
            
            case .cancelled, .ended:
                
                animator.removeAllBehaviors()
                
                //Add UIDynamicItemBehavior to animator and turn off allowsRotation of the card
                setDynamicItemBehavior(items: cardsViews)
                
                //Set UISnapBehavior to cards
                for card in cards {
                    //Set UISnapBehavior to views
                    setSnapBehavior(item: card.view, snapTo: card.defaultCenter)
                }
                
                //FIXME: Ugly if-else pyramid.
                //Slide away cards to right
                if translation.x > abs(distanceWhichStartsSlideCardsAway) {
                    
                    //Check answer and edit score
                    if currentTask.checkAnswer(touchedCard: Card.Item(rawValue: touchedCard.tag)!) {
                        print("Correct answer :)")
                        score.value += 1
                        time.reset()
                        time.start()
                        
                        slideAwayCards(to: .right)
                        //Show new cards with delay
                        delay(delay: 0.25, closure:{_ in self.showNewCards(from: .left)})
                    } else {
                        print("Wrong answer :(")
                        gameOver()
                    }
                }
                    
                //Slide away cards to left
                else if translation.x < distanceWhichStartsSlideCardsAway {
                    //Decreese passes
                    if passes.value < 1 {
                        self.performSegue(withIdentifier: "buyScreenSegue", sender: nil)
                    } else {
                        time.reset()
                        time.start()
                        passes.value -= 1
                        
                        slideAwayCards(to: .left)
                        //Show new cards with delay
                        delay(delay: 0.25, closure:{_ in self.showNewCards(from: .right)})
                    }
                }
            default: ()
        }
    }
    
    func moveCardsWithLapse(_ touchedCard: UIView, _ passedPoints: Int, _ translationOffset: CGFloat) {
        //Moving linked cards
        for passedPoint in 1...passedPoints {
            if touchedCard.tag - passedPoint >= 0 {
                //FIXME: Hardcode "cards[touchedView.tag - passedPoint]"
                unowned let cardAbove = cards[touchedCard.tag - passedPoint]
                cardAbove.view.center = CGPoint(x: (cardAbove.view.center.x + translationOffset), y: cardAbove.defaultCenter.y)
            }
            if touchedCard.tag + passedPoint < cards.count {
                unowned let cardUnder = cards[touchedCard.tag + passedPoint]
                cardUnder.view.center = CGPoint(x: (cardUnder.view.center.x + translationOffset), y: cardUnder.defaultCenter.y)
            }
        }
    }
    
    func slideAwayCards(to direction: Direction) {
        animator.removeAllBehaviors()
        //Add UIGravityBehavior for pushing cards
        let gravity = UIGravityBehavior(items: cardsViews)
        let magnitude = 20
        
        switch direction {
        case .left:
            gravity.gravityDirection = CGVector(dx: -magnitude, dy: 0)
        case .right:
            gravity.gravityDirection = CGVector(dx: magnitude, dy: 0)
        case .up:
            gravity.gravityDirection = CGVector(dx: 0, dy: -magnitude)
        case .down:
            gravity.gravityDirection = CGVector(dx: 0, dy: magnitude)
        default:
            print("'slideAwayCards' not defined for this direction")
        }
        
        animator.addBehavior(gravity)
    }
    
    func delay (delay: Double, closure: () ->()) {
        DispatchQueue.main.after(when: .now() + delay, execute: closure)
    }
    
    func showNewCards(from direction: Direction) {
        currentTask = nextTask
        
        animator.removeAllBehaviors()
        
        for card in cards {
            //Put next task to card
            card.label.text = currentTask.getLabel(to: card)
            
            //Update card's color
            card.updateColor()
            
            switch direction {
            //CGAfFineTransform doesn't change the card.view.center (see documentation) thus UISnapBehavior snaps new cards from the wrong direction
            case .left:
               card.view.center.x = -self.view.center.x
            case .right:
                card.view.center.x = (self.view.bounds.width + self.view.center.x)
            case .up:
                card.view.center.y = -self.view.center.y
            case .down:
                card.view.center.y = (self.view.bounds.height + self.view.center.y)
            default:
                print("'showNewCards' not defined for this direction")
            }
            
            //Turn off view's rotation
            setDynamicItemBehavior(items: [card.view])
            //Set UISnapBehavior to cards for snaping to card's default position
            setSnapBehavior(item: card.view, snapTo: card.defaultCenter)
        }
        
        print("\(Task.complexity) : Task.complexity -- complexity of the next task")
        print("\(score.value) : score.value in showNewCards")
        //Update nexTask
        nextTask = Task()
    }
    
    func setDynamicItemBehavior(items: [UIDynamicItem]) {
        let dynamicItemBehavior = UIDynamicItemBehavior (items: items)
        dynamicItemBehavior.allowsRotation = false
        animator.addBehavior(dynamicItemBehavior)
    }
    
    func setSnapBehavior(item: UIDynamicItem, snapTo point: CGPoint) {
        let snapBehavior = UISnapBehavior(item: item, snapTo: point)
        snapBehavior.damping = 5//0.250
        animator.addBehavior(snapBehavior)
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
        showNewCards(from: .left)
    }
 
    enum Direction {
        case left, right, up, down, unknown
    }
}
