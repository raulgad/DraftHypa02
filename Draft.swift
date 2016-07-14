//
//  ViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    var preludeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        createConstrants()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector(("handleTap:")))
        preludeView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func handleTap(recognizer: UIPanGestureRecognizer) {
        print("WORKING!!!!")
    }
   
    func initViews() {
        //Init
        preludeView = UIView()
        
        //Prepare Auto Layout
        preludeView.translatesAutoresizingMaskIntoConstraints = false
        
        //Set background color
        preludeView.backgroundColor = UIColor.blue()
        
        //Add to super view
        self.view.addSubview(preludeView)
    }

    func createConstrants() {
        //Create constrants preludeView
        let pinLeftPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        let pinTopPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 24)
        let pinRightPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0)
        let heightPreludeView = NSLayoutConstraint(item: preludeView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.35, constant: 0)
        
        //Adding to super view
        self.view.addConstraints([pinLeftPreludeView, pinTopPreludeView, pinRightPreludeView, heightPreludeView])
    }
}

