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
    func resumeTiming()
}

//FIXME: Check and set all variables to 'weak || owned' property
class CardsViewController: UIViewController, UIGestureRecognizerDelegate, CardsViewControllerDelegate {
    private var score = Score.sharedInstance //Int = 0
    var passes = Passes.sharedInstance //Int = 1
    //FIXME: 'taskComplexity' should be implemented in Task?
    var taskComplexity: Int = 0
    
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
    
//    @IBOutlet weak var scoreStackView: UIStackView!
//    @IBOutlet weak var passesStackView: UIStackView!
//    var scoreLabel: UILabel!
//    var passesLabel: UILabel!
    
    //FIXME: 'time' should be implemented by singleton AND like a separate module
    let time = Time.sharedInstance
    var timer = Timer()
    let intervalCallingTimerFunction: CGFloat = 0.05
//    var isTimerRunning: Bool = false
    var isTimeElapsed: Bool = false
    var pausedTime: Date!

    //FIXME: Should don be access to it from there. Get access from backside
    var bottomItem = BottomItem.sharedInstance
    
    var backside = Backside.sharedInstance
    
    var animator: UIDynamicAnimator! 
    var cardPanGestureRecognizer: UIPanGestureRecognizer!
    var questionTapGestureRecognizer: UITapGestureRecognizer!
    
    var constraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(self.view.bounds) : self.view.bounds")
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
//        print("\(UIApplication.shared().delegate?.window) : UIApplication.shared().delegate?.window")
        
//        self.view.heightAnchor.constraint(equalToConstant: UIScreen.main().bounds.height).isActive = true
//        self.view.widthAnchor.constraint(equalToConstant: UIScreen.main().bounds.width).isActive = true
       
//        let margins = UIApplication.shared().windows[0].layoutMarginsGuide
//        self.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
//        self.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
//        self.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
//        self.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        
        animator = UIDynamicAnimator(referenceView: self.view)
////        animator.setValue(true, forKey: "debugEnabled")
        
//        FIXME: You should not have access to it from there. Get access from backside
        self.view.addSubview(bottomItem.view)
        self.view.addConstraints(bottomItem.createViewConstraints(destinationViewController: self))
//

        //Creating cards
        for _ in 1...Card.cardsCount {
            //Init card
            let card = Card()
            self.view.addSubview(card.view)
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
                card.view.addGestureRecognizer(cardPanGestureRecognizer)
                card.view.isExclusiveTouch = true
            } else {
                card.view.addGestureRecognizer(questionTapGestureRecognizer)
            }
            cardsViews.append(card.view)
            
            self.view.addConstraints(card.createViewConstraints(destinationViewController: self))
            
        }

        //Add timer view
        self.view.addSubview(time.view)
        self.view.addConstraints(time.createViewConstraints(destinationViewController: self))

        //Add score and passes labels
//        scoreStackView.isHidden = true
//        scoreLabel = scoreStackView.arrangedSubviews[0] as! UILabel
//        passesStackView.isHidden = true
//        passesLabel = passesStackView.arrangedSubviews[0] as! UILabel
     
        
        
        
        
//        
//        
//        questionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
//        questionTapGestureRecognizer.delegate = self
//        self.view.addGestureRecognizer(questionTapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(self.view.bounds) : self.view.bounds viewWillAppear")
    }
    
    override func viewWillLayoutSubviews() {
        print("\(self.view.bounds) : self.view.bounds viewWillLayoutSubviews")
        
        self.view.topAnchor.constraint(equalTo: (self.view.window?.topAnchor)!).isActive = true
        self.view.bottomAnchor.constraint(equalTo: (self.view.window?.bottomAnchor)!).isActive = true
        //        self.view.leftAnchor.constraint(equalTo: (self.view.window?.leftAnchor)!).isActive = true
        self.view.leadingAnchor.constraint(equalTo: (self.view.window?.leadingAnchor)!).isActive = true
        //        self.view.rightAnchor.constraint(equalTo: (self.view.window?.rightAnchor)!).isActive = true
        self.view.trailingAnchor.constraint(equalTo: (self.view.window?.trailingAnchor)!).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        print("\(self.topLayoutGuide.length) : self.topLayoutGuide.length")
        print("\(self.view.bounds) : self.view.bounds after translatesAutoresizingMaskIntoConstraints in viewDidLayoutSubviews")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("\(bottomItem.view.frame) : bottomItem.view.frame")
        print("\(self.view.frame) : self.view.frame viewDidAppear")

        
        
        
        
        
        
        
        
        
        //Set default center position of the card
        for card in cards {
            card.defaultCenter = card.view.center
        }
        
        //FIXME: Show EndScreen, when time is elapsed due you viewing another view (e.g. OperationScreen)
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
//        pauseTiming()
//        delay(delay: 1, closure: resumeTiming)

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
                //Set previous touched cards to init default positions if user starts touching card due snaping
                //FIXME: Cycles in this function is not a good idea?
                for card in cards { card.view.center = card.defaultCenter }

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
                
//                //Show score
//                if translation.x > 0 {
//                    scoreStackView.isHidden = false
//                    passesStackView.isHidden = true
//                    self.scoreLabel.text = String(self.score.value)
//                }
                
                //Moving linked cards
                //Move to right
                if translation.x > xDistanceFromCardsStartsMovesTogether {
                    //Calcute number of times that card passed xDistanceBetweenCards
                    let passedPoints = Int(translation.x / xDistanceFromCardsStartsMovesTogether)
                    
                    moveCardsWithLag(touchedCard, passedPoints, translationOffset)
                }
                //Move to left
                if translation.x < 0 {
//                    //Show passes
//                    passesStackView.isHidden = false
//                    scoreStackView.isHidden = true
//                    passesLabel.text = String(passes.value)
                    
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
                let dynamicItemBehavior = UIDynamicItemBehavior(items: cardsViews)
                dynamicItemBehavior.allowsRotation = false
                animator.addBehavior(dynamicItemBehavior)
                
                //Set UISnapBehavior to cards
                //FIXME: Cycles in this function is not a good idea?
                for card in cards {
                    //FIXME: Creating snap behaviors with same variable name
                    //Set UISnapBehavior to views
                    let snapBehavior = UISnapBehavior(item: card.view, snapTo: card.defaultCenter)
                    snapBehavior.damping = snapBehaviorDamping
                    animator.addBehavior(snapBehavior)
                }
                
                //FIXME: Ugly if-else pyramid. And hardcode values "left", "right", distanceForSlidingCard
                //Slide away cards to right
                if translation.x > abs(distanceForSlidingCard) {
//                    if !isTimerRunning { startTiming() }
                    
                    //Check answer and edit score
                    if currentTask.checkAnswer(touchedCard: touchedCard.item) {
                        self.score.value += 1
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
                    //FIXME: HArdcode "right"/"left"
                    slideAwayCards(to: .right)
                }
                //Slide away cards to left
                else if translation.x < distanceForSlidingCard {
                    
//                    passesLabel.text = String(passes)
                    
                    resetTiming()
                    startTiming()
                    
                    self.taskComplexity += 1
                    
                    //Decreese passes
                    if passes.value < 1 {
                        pauseTiming()
                        self.performSegue(withIdentifier: "buyScreenSegue", sender: nil)
                    } else {
                        passes.value -= 1
                    }
                    
                    slideAwayCards(to: .left)
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
            card.label.text = nextTask.getLabel(to: card)
            
            let viewWidth = self.view.bounds.width
            let cardWidth = card.view.bounds.width
            
            //Move cards to self.view's edge
            //Move cards behind left edge
            if card.view.center.x >= (viewWidth + (cardWidth/2)) {
                card.view.center.x = ((cardWidth/2) - viewWidth)
            }
            //Move cards behind right edge
            else if card.view.center.x <= (-cardWidth/2) {
                card.view.center.x = viewWidth + (cardWidth/2)
            }
            
            //Update card's data
            card.updateColor()
            
            //Turn off view's rotation
            let dynamicItemBehavior = UIDynamicItemBehavior (items: [card.view])
            dynamicItemBehavior.allowsRotation = false
            animator.addBehavior(dynamicItemBehavior)
            
            //Set UISnapBehavior to cards for snaping to card's default position
            let snapBehavior = UISnapBehavior(item: card.view, snapTo: card.defaultCenter)
            snapBehavior.damping = snapBehaviorDamping
            animator.addBehavior(snapBehavior)
        }
        
        //Update nexTask
        nextTask = Task(complexity: self.taskComplexity + 1)
        print("\(score.value) : score.value in showNewCards")
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
        self.score.value = 0
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
        
        //Changing view's color from green to red.
        let color = time.view.backgroundColor?.cgColor.components, red = 0, green = 1, blue = 2, alpha = 3
        time.view.backgroundColor = UIColor(red: (color![red] + stepToChangeColor), green: (color![green] - stepToChangeColor), blue: color![blue], alpha: color![alpha])
        
        //Changing view's width
        time.view.frame = CGRect(x: 0, y: 0, width: (time.view.bounds.width - stepToChangeWidth), height: time.view.bounds.height)
        
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
    
    //FIXME: Need to delete. We can just restart timing.
    func resumeTiming() {
        print("resumeTiming()")
        timer = Timer.init(timeInterval: Double(intervalCallingTimerFunction), target: self, selector: #selector(CardsViewController.updateTimingView), userInfo: pausedTime, repeats: true)
        
        RunLoop.current().add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        
//        isTimerRunning = true
    }
    
    enum Direction {
        case left, right, up, down, unknown
    }
}
