//
//  CardsViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

protocol CardsViewControllerDelegate {
    var passes: Int { get set }
    func resetGame()
    func resumeTiming()
}

//FIXME: Check and set all variables to 'weak || owned' property
class CardsViewController: UIViewController, UIGestureRecognizerDelegate, CardsViewControllerDelegate {
    //FIXME: 'score' should be implemented by singleton?
    private var score: Int = 0
    var taskComplexity: Int = 0
    var passes: Int = 1
    
    var currentTask = Task(complexity: 0)
    var nextTask = Task(complexity: 1)
    
    let distanceForSlidingCard: CGFloat = -200
    var cards = [Card]()
    //FIXME: Is 'cardsViews' neccessary when we can use 'cards'?
    var cardsViews = [UIView]()

    var offsetBetweenTouchAndCardCenter = CGPoint.zero
    var xDistanceFromCardsStartsMovesTogether: CGFloat = 120
    var previousPassedTranslationX: CGFloat = CGFloat(0)
    var snapBehaviorDamping: CGFloat = 0.250
    
    @IBOutlet weak var scoreStackView: UIStackView!
    @IBOutlet weak var passesStackView: UIStackView!
    var scoreLabel: UILabel!
    var passesLabel: UILabel!
    
    //FIXME: 'timer' should be implemented by singleton AND like a separate module
    var time = Time.sharedInstance
    var timer = Timer()
    let intervalCallingTimerFunction: CGFloat = 0.05
//    var isTimerRunning: Bool = false
    var isTimeElapsed: Bool = false
    var pausedTime: Date!
    
    var animator: UIDynamicAnimator! 
    var cardPanGestureRecognizer: UIPanGestureRecognizer!
    var questionTapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: self.view)
        // animator.setValue(true, forKey: "debugEnabled")
        
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
            
            self.view.addConstraints(card.createConstraints(destinationViewController: self))
        }
        
        //Add timer view
        self.view.addSubview(time.view)
        self.view.addConstraints(time.createConstraints(destinationViewController: self))
        
        //Add score and passes labels
        scoreStackView.isHidden = true
        scoreLabel = scoreStackView.arrangedSubviews[0] as! UILabel
        passesStackView.isHidden = true
        passesLabel = passesStackView.arrangedSubviews[0] as! UILabel
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set default center position of the card
        for card in cards {
            card.defaultCenter = card.content.center
        }
        
        //Show EndScreen, when time is elapsed due you viewing another view (e.g. OperationScreen)
        if isTimeElapsed {
            print("\(isTimeElapsed) : isTimeElapsed")
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
        pauseTiming()
        delay(delay: 1, closure: resumeTiming)
        
        //self.performSegue(withIdentifier: "operationScreenSegue", sender: nil)
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
                //Set previous touched cards to init default positions if user starts touching card due snaping
                //FIXME: Cycles in this function is not a good idea?
                for card in cards { card.content.center = card.defaultCenter }

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
                
                //Show score
                if translation.x > 0 {
                    scoreStackView.isHidden = false
                    passesStackView.isHidden = true
                    self.scoreLabel.text = String(self.score)
//                    DispatchQueue.main.async(execute: {
//                        self.scoreLabel.text = String(self.score)
//                    })
                }
                
                //Moving linked cards
                //Move to right
                if translation.x > xDistanceFromCardsStartsMovesTogether {
                    //Calcute number of times that card passed xDistanceBetweenCards
                    let passedPoints = Int(translation.x / xDistanceFromCardsStartsMovesTogether)
                    
                    moveCardsWithLag(touchedCard, passedPoints, translationOffset)
                }
                //Move to left
                if translation.x < 0 {
                    //Show passes
                    passesStackView.isHidden = false
                    scoreStackView.isHidden = true
                    passesLabel.text = String(passes)
                    
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
//                    if !isTimerRunning { startTiming() }
                    
                    //Check answer and edit score
                    if currentTask.checkAnswer(touchedCard: touchedCard.item) {
                        self.score += 1
                        self.taskComplexity += 1
                        
//                        self.scoreLabel.text = String(self.score)
                        
                        resetTiming()
                        startTiming()
                        print("Correct answer :)")
                    } else {
                        print("Wrong result :(")
                        stopTiming() //MARK: It's not necessary because timer could still be running and then will be stopped.
                        self.performSegue(withIdentifier: "endScreenSegue", sender: nil)
                    }
                    
                    slideAwayCards(to: "right")
                }
                //Slide away cards to left
                else if translation.x < distanceForSlidingCard {
                    
//                    passesLabel.text = String(passes)
                    
                    resetTiming()
                    startTiming()
                    
                    self.taskComplexity += 1
                    
                    //Decreese passes
                    if passes < 1 {
                        pauseTiming()
                        self.performSegue(withIdentifier: "buyScreenSegue", sender: nil)
                    } else {
                        passes -= 1
                    }
                    
                    slideAwayCards(to: "left")
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
    
    func slideAwayCards(to direction: String) {
        animator.removeAllBehaviors()
        //Add UIGravityBehavior for pushing cards
        let gravity = UIGravityBehavior(items: cardsViews)
        if direction == "left" {
            gravity.gravityDirection = CGVector(dx: -20, dy: 0)
        } else {
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
            card.label.text = nextTask.getLabel(to: card)
            
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
        
        //Update nexTask
        nextTask = Task(complexity: self.taskComplexity + 1)
        print("\(score) : score in showNewCards")
        print("\(taskComplexity) : taskComplexity in showNewCards")
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
    
    func resetGame() {
        print("Reset Game!")
        self.nextTask = Task(complexity: 1)
        self.taskComplexity = 0
        self.score = 0
        resetTiming()
        showNewCards()
    }
    
    func startTiming() {
        timer = Timer.scheduledTimer(timeInterval: Double(intervalCallingTimerFunction), target: self, selector: #selector(CardsViewController.updateTimingView), userInfo: Date(), repeats: true)
//        isTimerRunning = true
    }
    
    func stopTiming() {
        timer.invalidate()
//        isTimerRunning = false
    }
    
    func updateTimingView() {
        let timeLength: CGFloat = 15
        let elapsedTime = CGFloat(-(timer.userInfo as! Date).timeIntervalSinceNow)
        let stepToChangeColor = (1 / (timeLength * (4/5))) * intervalCallingTimerFunction // 1 is final color value in view's color animation. And (4/5) is multiplicator for increasing speed of color changes.
        let stepToChangeWidth = (self.view.bounds.width / timeLength) * intervalCallingTimerFunction
        
        //Changing view's color
        let color = time.view.backgroundColor?.cgColor.components, red = 0, green = 1, blue = 2, alpha = 3
        time.view.backgroundColor = UIColor(red: (color![red] + stepToChangeColor), green: (color![green] - stepToChangeColor), blue: color![blue], alpha: color![alpha])
        
        //Changing view's width
        
        //We can not edit time.view.frame and UILabel.text (eg, score or passes labels) without problems with UI. When we updating UILabel.text it effects to Autolayout and cause to reset time.view.frame to default constraints. That why we editing time.pinRightTimer.constant and NOT time.view.frame
        //time.view.frame = CGRect(x: 0, y: 0, width: (time.view.bounds.width - stepToChangeWidth), height: time.view.bounds.height)
        
        time.pinRightTimer.constant = -(elapsedTime)
        time.view.setNeedsLayout()
        
        if elapsedTime > timeLength {
            print("\(elapsedTime) : Time is elapsed")
            isTimeElapsed = true
            stopTiming() //We can not use resetTiming() because it will immediately set 'isTimeElapsed' to false.
            self.performSegue(withIdentifier: "endScreenSegue", sender: nil)
        }
    }
    
    func resetTiming() {
        stopTiming()
        isTimeElapsed = false
        
        time.resetViewToDefault()
    }
    
    func pauseTiming() {
        pausedTime = timer.userInfo as! Date
        timer.invalidate()
    }
    
    func resumeTiming() {
        print("resumeTiming()")
        timer = Timer.init(timeInterval: Double(intervalCallingTimerFunction), target: self, selector: #selector(CardsViewController.updateTimingView), userInfo: pausedTime, repeats: true)
        
        RunLoop.current().add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        
//        isTimerRunning = true
    }
}
