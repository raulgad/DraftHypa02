//
//  ViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    var preludeView = UIView()
    var answerTopView: UIView!
    var answerBottomView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        createConstrants()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        //panGestureRecognizer.delegate = self
        preludeView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTap(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: preludeView)
        
        if recognizer.state == UIGestureRecognizerState.began {
            
        }
        else if recognizer.state == UIGestureRecognizerState.changed {
            if let view = recognizer.view {
                view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y)
            }
            recognizer.setTranslation(CGPoint.zero, in: preludeView)
        }
        else if recognizer.state == UIGestureRecognizerState.ended {
            //Figure out the length of the velocity vector (i.e. the magnitude)
            let velocity = recognizer.velocity(in: preludeView)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            
            //If the length is < 200, then decrease the base speed, otherwise increase it.
            let slideFactor = 0.1 * slideMultiplier
            
            //Calculate a final point based on the velocity and the slideFactor.
            var finalPoint = CGPoint(x: (recognizer.view?.center.x)! + (velocity.x * slideFactor), y: (recognizer.view?.center.y)!)
            
            //Make sure the final point x is within the view’s bounds
            finalPoint.x = min(max(finalPoint.x, 0), preludeView.bounds.size.width)
            
            //Animate the view to the final resting place.
            UIView.animate(withDuration: Double(slideFactor*2),
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: {
                            recognizer.view?.center = finalPoint
                },
                           completion: nil)
        }
    }

    func initViews() {
        //Init
        preludeView = UIView()
        answerTopView = UIView()
        answerBottomView = UIView()
        
        //Prepare Auto Layout
        preludeView.translatesAutoresizingMaskIntoConstraints = false
        answerTopView.translatesAutoresizingMaskIntoConstraints = false
        answerBottomView.translatesAutoresizingMaskIntoConstraints = false
        
        //Set background color
        preludeView.backgroundColor = UIColor.blue()
        answerTopView.backgroundColor = UIColor.darkGray()
        answerBottomView.backgroundColor = UIColor.lightGray()
        
        //Add to super view
        self.view.addSubview(preludeView)
        self.view.addSubview(answerTopView)
        self.view.addSubview(answerBottomView)
    }
    
    func createConstrants() {
        //Create constrants preludeView
        let pinLeftPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        let pinTopPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 24)
        let pinRightPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0)
        let heightPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.35, constant: 0)
        
        //Create constraints answerTopView
        let pinLeftAnswerTopView = NSLayoutConstraint(item: answerTopView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 12)
        let pinRightAnswerTopView = NSLayoutConstraint(item:answerTopView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -12)
        let topMarginAnswerTopViewToPreludeView = NSLayoutConstraint(item: answerTopView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: preludeView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 12)
        let heightAnswerTopView = NSLayoutConstraint(item: answerTopView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.25, constant: 0)
        
        //Create constrants answerBottomView
        let pinLeftAnswerBottomView = NSLayoutConstraint(item: answerBottomView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 12)
        let pinRightAnswerBottomView = NSLayoutConstraint(item: answerBottomView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -12)
        let topMarginAnswerBottomViewToAnswerTopView = NSLayoutConstraint(item: answerBottomView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: answerTopView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 12)
        let heightAnswerBottomView = NSLayoutConstraint(item: answerBottomView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.25, constant: 0)
        
        //Adding to super view
        self.view.addConstraints([pinLeftPreludeView, pinTopPreludeView, pinRightPreludeView, heightPreludeView, pinLeftAnswerTopView, pinRightAnswerTopView, heightAnswerTopView, topMarginAnswerTopViewToPreludeView, pinLeftAnswerBottomView, pinRightAnswerBottomView, topMarginAnswerBottomViewToAnswerTopView, heightAnswerBottomView])
    }
    
}

