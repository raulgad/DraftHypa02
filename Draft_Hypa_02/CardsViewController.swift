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
    //MARK: 'nextTask' isn't necessary variable. It using just for prepare task before setting it in a card.
    var nextTask = Task()
    
    var cards = [Card]()
    //FIXME: Excessive variable 'previousCardTranslation'
    var previousCardTranslation = CGPoint.zero
    
    let time = Time.sharedInstance
    var backside = Backside.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(backside.bottomItem.view)
        backside.bottomItem.setLayout(inView: self.view)
        
        //Creating cards
        for _ in 1...Card.count {
            //Init card
            let card = Card()
            //Get init task's text for cards
            card.label.text = currentTask.getLabel(to: card)
            //Set UIPanGestureRecognizer to answer cards
            let cardPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
            cardPanGestureRecognizer.delegate = self
            //Set UITapGestureRecognizer to question card (top card)
            let questionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
            questionTapGestureRecognizer.delegate = self
            card.view.addGestureRecognizer(card.item == .question ? questionTapGestureRecognizer : cardPanGestureRecognizer)
            card.view.isExclusiveTouch = true
            
            cards.append(card)
            
            self.view.addSubview(card.view)
            card.setLayout(inView: self.view)
        }
        
        time.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Add timer view
        //FIXME: The right way: we must create all views (timing, score/passes, etc) in Interface Builder in the appropriate storyboard screens. 'Time' class must be 'TimeController'. The 'timeView' (= outlet in the 'OperationScreenViewController') we should set to the 'Time.sharedInstance.views' dictionary that we loop through to 'update' and 'reset' views.
        self.view.addSubview(time.view)
        time.setLayout(inView: self.view)
    }
    
    func tap(tap: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "operationScreenSegue", sender: nil)
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self.view)
        guard let touchedCardView = pan.view else {
            print("Error with unwrap pan.view")
            return
        }

        
        switch pan.state {
            case .began:
                removeAllAnimations(cards)
                
                //Reset previousCardTranslation to 0 when start touching card again. Neccessery for correct move in already moving cards.
                previousCardTranslation = CGPoint.zero
            
            case .changed:
                backside.updateItemsWhenCardMoving(to: translation)
                
                //Move to right
                if translation.x > 0 {
                    moveWithLapse(cards: cards, direction: .right, distance: 60, pan: pan)
                }
                
                //Move to left
                if translation.x < 0 {
                    //Move cards to the left simultaneously
                    for card in cards {
                        card.center.x.constant = translation.x
                    }
                }
            
            case .cancelled, .ended:
                let distanceWhichCardsStartsSlideAway: CGFloat = 200
                //Slide away cards to right and check answer
                if translation.x > distanceWhichCardsStartsSlideAway {
                    //Check answer and edit score
                    checkAnswer(touchedCard: .answer(touchedCardView.tag))
                }
                //Slide away cards to left and pass question
                else if translation.x < -distanceWhichCardsStartsSlideAway {
                    //Pass task and decrease passes
                    passTask()
                }
                else {
                    snapToDefaultCenterAnimation(items: cards)
                }
            
            default: ()
            
        }
    }
    
    func removeAllAnimations(_ cards: [Card]) {
        for card in cards { card.view.layer.removeAllAnimations() }
    }
    
    func moveWithLapse(cards: [Card], direction: Direction, distance: CGFloat, pan: UIPanGestureRecognizer) {
        var translation = pan.translation(in: self.view)
        guard let touchedCardView = pan.view else {
            print("Error with unwrap pan.view")
            return
        }
        
        //Set to 0 card's coordinat that shouldn't change
        switch direction {
        case .left, .right:
            translation.y = 0
        case .up, .down:
            translation.x = 0
        case .any:
            break
        default:
            print("'moveWithLapse()' not defined for this direction")
        }
        
        //Calcute number of times that card passed xDistanceBetweenCards
        let passedPoints = abs(Int(translation.length() / distance))

        //Offset between current and previous card's center
        let offset = translation - previousCardTranslation
        
        //Move touchedCard
        cards[touchedCardView.tag].center += offset
        
        if passedPoints > 0 && passedPoints <= cards.count {
            //Change center of the cards that start moving after touchedCard pass the passedPoints
            for passedPoint in 1...passedPoints {
                let indexCardAboveTouchedCard = touchedCardView.tag - passedPoint
                //Check if array of cards has card above of the touchedCard
                if indexCardAboveTouchedCard >= 0 {
                    //Set new position to card above touchedCard
                    cards[indexCardAboveTouchedCard].center += offset
                }
                let indexCardUnderTouchedCard = touchedCardView.tag + passedPoint
                //Check if array of cards has card under of the touchedCard
                if indexCardUnderTouchedCard < cards.count {
                    //Set new position to card under touchedCard
                    cards[indexCardUnderTouchedCard].center += offset
                }
            }
        }
        //Save current translation to previousCardTranslation for calculate offset between current and previous card's center.
        previousCardTranslation = translation
    }

    func showNewCards(from: Direction) {
        slideAway(cards: cards,
                  to: from == .left ? .right : .left)
        
        delay(delay: 0.25, closure:{_ in
            self.currentTask = self.nextTask
            self.updateContentOf(cards: self.cards)
            self.nextTask = Task()
            self.setBehind(edge: from, cards: self.cards)
            self.snapToDefaultCenterAnimation(items: self.cards)})
        print("\(Task.currentStep) : Task.currentStep - complexity is currentStep/numberOfStepsToChangeRange")
        print("\(score.value) : score.value in showNewCards")
    }
    
    func slideAway(cards: [Card], to direction: Direction) {
        removeAllAnimations(cards)
        
        UIView.animate(withDuration: 0.20,
                       delay: 0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
                        
                        self.setBehind(edge: direction, cards: cards)
            },
                       completion: nil)
    }
    
    func setBehind(edge: Direction, cards: [Card]) {
        //Set card's center behind the window’s edge
        for card in cards {
            switch edge {
            case .left:
                card.center.x.constant = -(self.view.frame.width)
            case .right:
                card.center.x.constant = self.view.frame.width
            case .up:
                card.center.y.constant = -(self.view.frame.height)
            case .down:
                card.center.y.constant = self.view.frame.height
            default:
                print("'setBehind()' not defined for this direction")
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func delay (delay: Double, closure: () ->()) {
        DispatchQueue.main.after(when: .now() + delay, execute: closure)
    }
    
    func updateContentOf(cards: [Card]) {
        for card in cards {
            //Put next task to card
            card.label.text = nextTask.getLabel(to: card)
            
            //Update card's color
            card.updateColor()
        }
    }
    
    func snapToDefaultCenterAnimation(items: [Card]) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: [.allowUserInteraction, .curveEaseOut],
                       animations: {
                        
                        //Set snap animation to default card's position
                        for card in self.cards {
                            //FIXME: Need to refactor card.defaultCenter to the constraint's constant
                            card.center.x.constant = 0
                            card.center.y.constant = card.defaultCenter.y - self.view.center.y
                        }
                        self.view.layoutIfNeeded()
            },
                       completion: nil)
    }

    //Setting delegate to screen's view controllers for access to resetGame()
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!  {
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
        score.reset()
        time.reset()
        showNewCards(from: .left)
    }
    
    func gameOver() {
        time.stop()
        print("Game Over!")
        
        //FIXME: Workaround for show endScreen from any viewcontroller. Or we can dismiss all current modal viewcontrollers (by 'self.view.window?.rootViewController?.dismiss') and then present endScreen
        let endScreen = UIStoryboard(name: "Main", bundle: Bundle.main()).instantiateViewController(withIdentifier: "endScreenStoryboardID") as! EndScreenViewController
        //FIXME: There is assume that CardsViewController is always rootViewController of the window, but it would be right if we use appDelegate.window?.rootViewController?
        let visibleViewController = self.presentedViewController ?? self
        visibleViewController.present(endScreen, animated: true, completion: {
            endScreen.delegate = self
        })
    }
 
    enum Direction {
        case left, right, up, down, any, unknown
    }
}

//extensions to CGPoint
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

public func += (left: inout (x: NSLayoutConstraint, y: NSLayoutConstraint), right: CGPoint) {
    left.x.constant = left.x.constant + right.x
    left.y.constant = left.y.constant + right.y
}

public extension CGPoint {
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
}
