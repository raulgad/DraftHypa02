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
    func showNewCards(from: CardsViewController.Direction)
}

//FIXME: Check and set all variables to 'weak || owned' property if needed.
class CardsViewController: UIViewController, UIGestureRecognizerDelegate, CardsViewControllerDelegate {
    private var score = Score.sharedInstance
    internal var passes = Passes.sharedInstance
    
    var currentTask = Task()
    var nextTask = Task()
    
    
    var cards = [Card]()
    
    let time = Time.sharedInstance
    var backside = Backside.sharedInstance
    
    var animator: UIDynamicAnimator! 
    var cardPanGestureRecognizer: UIPanGestureRecognizer!
    var questionTapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: self.view)
//        animator.setValue(true, forKey: "debugEnabled")
        
        self.view.addSubview(backside.bottomItem.view)
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
            
            self.view.addSubview(card.view)
            card.setLayout(inView: self.view)
        }
        
        //Add timer view
        self.view.addSubview(time.view)
        time.setLayout(inView: self.view)
        time.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        switch pan.state {
            case .began:
                animator.removeAllBehaviors()
            
            case .changed:
                let touchedCardDefaultCenter = cards[touchedCard.tag].defaultCenter!
//                //Offset between current and previous center.x
//                //FIXME: xOffset incorrect when you move already moving cards
//                let offset = translation - (touchedCard.center - touchedCardDefaultCenter)
//                
                backside.updateItemsWhenCardMoving(to: translation)
                
                //Move to right
                if translation.x > 0 {
//                    //Move touchedCard
//                    touchedCard.center.x += offset.x
                    
//                    let distanceBetweenCards: CGFloat = 60//120
                    //Moving linked cards
//                    if translation.x > distanceBetweenCards {
//                        //Calcute number of times that card passed xDistanceBetweenCards
//                        let passedPoints = Int(translation.x / distanceBetweenCards)
//                        
//                        moveCardsWithLapse(touchedCard, passedPoints, offset)
//                    }
                    moveWithLapse(cards: cards, direction: .right, distance: 60, pan: pan)
                }
                
                //Move to left
                if translation.x < 0 {
                    //Move cards to the left simultaneously
                    for card in cards {
//                        card.view.center.x += offset.x
                        card.view.center.x = touchedCardDefaultCenter.x + translation.x
                    }
                }
            
            case .cancelled, .ended:
                animator.removeAllBehaviors()
                                
                //Add UIDynamicItemBehavior to animator and turn off allowsRotation of the card
                setDynamicItemBehavior(items: cards.map{$0.view})
                
                //Set UISnapBehavior to cards
                for card in cards {
                    //Set UISnapBehavior to views
                    setSnapBehavior(item: card.view, snapTo: card.defaultCenter)
                }
                
                let distanceWhichCardsStartsSlideAway: CGFloat = 200
                //Slide away cards to right and answer to question
                if translation.x > distanceWhichCardsStartsSlideAway {
                    //Check answer and edit score
                    checkAnswer(touchedCard: Card.Item(rawValue: touchedCard.tag)!)
                }
                //Slide away cards to left and pass question
                else if translation.x < -distanceWhichCardsStartsSlideAway {
                    //Pass task and decrease passes
                    passTask()
                }
            default: ()
        }
    }
    
    func moveWithLapse(cards: [Card], direction: Direction, distance: CGFloat, pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self.view)
        guard let touchedCard = pan.view else {
            print("Error with unwrap pan.view")
            return
        }
        
        let touchedCardDefaultCenter = cards[touchedCard.tag].defaultCenter!
        //Offset between current and previous center.x
        //FIXME: xOffset incorrect when you move already moving cards
        let offset = translation - (touchedCard.center - touchedCardDefaultCenter)
        
        //Move touchedCard
        touchedCard.center.x += offset.x
        
        if translation.x > distance {
            //Calcute number of times that card passed xDistanceBetweenCards
            let passedPoints = Int(translation.x / distance)
            
            //Сondition for don't do unnecessary cycles
            if passedPoints <= cards.count {
                //Change center of the cards that start moving after touchedCard pass the passedPoints
                for passedPoint in 1...passedPoints {
                    let indexCardAboveTouchedCard = touchedCard.tag - passedPoint
                    //Check if array of cards has card above of the touchedCard
                    if indexCardAboveTouchedCard >= 0 {
                        //Set new position to card above touchedCard
                        cards[indexCardAboveTouchedCard].view.center.x += offset.x
                    }
                    let indexCardUnderTouchedCard = touchedCard.tag + passedPoint
                    //Check if array of cards has card under of the touchedCard
                    if indexCardUnderTouchedCard < cards.count {
                        //Set new position to card under touchedCard
                        cards[indexCardUnderTouchedCard].view.center.x += offset.x
                    }
                }
            }
        }
    }

    
    
//    func moveCardsWithLapse(_ touchedCard: UIView, _ passedPoints: Int, _ offset: CGPoint) {
//        //Сondition for don't do unnecessary cycles
//        if passedPoints <= cards.count {
//            //Change center of the cards that start moving after touchedCard pass the passedPoints
//            for passedPoint in 1...passedPoints {
//                let indexCardAboveTouchedCard = touchedCard.tag - passedPoint
//                //Check if array of cards has card above of the touchedCard
//                if indexCardAboveTouchedCard >= 0 {
//                    //Set new position to card above touchedCard
//                    cards[indexCardAboveTouchedCard].view.center.x += offset.x
//                }
//                let indexCardUnderTouchedCard = touchedCard.tag + passedPoint
//                //Check if array of cards has card under of the touchedCard
//                if indexCardUnderTouchedCard < cards.count {
//                    //Set new position to card under touchedCard
//                    cards[indexCardUnderTouchedCard].view.center.x += offset.x
//                }
//            }
//        }
//    }

    func showNewCards(from: Direction) {
        slideAway(cards: cards.map{$0.view},
                  to: from == .left ? .right : .left)
        delay(delay: 0.25, closure:{_ in
            self.updateContentOf(cards: self.cards)
            self.snapBack(cards: self.cards, from: from)})
        print("\(Task.complexity) : Task.complexity -- complexity of the next task")
        print("\(score.value) : score.value in showNewCards")
    }
    
    func slideAway(cards: [UIDynamicItem], to direction: Direction) {
        animator.removeAllBehaviors()
        
        //Add UIGravityBehavior for pushing cards
        let gravity = UIGravityBehavior(items: cards)
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
    
    func updateContentOf(cards: [Card]) {
        currentTask = nextTask
        
        for card in cards {
            //Put next task to card
            card.label.text = currentTask.getLabel(to: card)
            
            //Update card's color
            card.updateColor()
        }
        
        //Update nexTask
        nextTask = Task()
    }
    
    func snapBack(cards: [Card], from direction: Direction) {
        animator.removeAllBehaviors()
        
        for card in cards {
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
    
    func checkAnswer(touchedCard: Card.Item) {
        if currentTask.checkAnswer(touchedCard: touchedCard) {
            print("Correct answer :)")
            score.value += 1
            time.reset()
            time.start()
            showNewCards(from: .left)
        } else {
            print("Wrong answer :(")
            gameOver()
        }
    }
    
    func passTask() {
        if passes.value < 1 {
            self.performSegue(withIdentifier: "buyScreenSegue", sender: nil)
        } else {
            time.reset()
            time.start()
            showNewCards(from: .right)
            passes.value -= 1
        }
    }
    
    func resetGame() {
        print("New Game!")
        Task.resetComplexity()
        nextTask = Task()
        score.value = 0
        time.reset()
        showNewCards(from: .left)
    }
    
    func gameOver() {
        time.stop()
        print("Game Over!")
        self.performSegue(withIdentifier: "endScreenSegue", sender: nil)
        
//            //If you want present endScreen directly from any viewcontroller.
//            stop()
//            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main())
//            let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "endScreenStoryboardID") as UIViewController
//            let appDelegate = UIApplication.shared().delegate as! AppDelegate
//            appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
 
    enum Direction {
        case left, right, up, down, unknown
    }
}

//extensions to CGPoint
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

//public func += (left: inout CGPoint, right: CGPoint) {
//    left = left + right
//}
//
//public func -= (left: inout CGPoint, right: CGPoint) {
//    left = left - right
//}
