//
//  ViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var preludeView: UIView!
    var answerTopView: UIView!
    var answerBottomView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        createConstrants()
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
        let pinTopPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 28)
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

