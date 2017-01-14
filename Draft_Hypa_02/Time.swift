//
//  Time.swift
//  Draft_Hypa_02
//
//  Created by mac on 23.11.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

class Time {
    static let sharedInstance = Time()
    private var timer = Timer()
    private let timeInterval: CGFloat = 0.05
    private(set) var value: CGFloat
    let duration: CGFloat = 15
    var delegate: CardsViewControllerDelegate!
    var view: UIView
//    var pinRightView: NSLayoutConstraint!
    
    private init() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.green()
        
        value = duration
    }
    
    func setLayout(inView: UIView) { //-> [NSLayoutConstraint]
//        let pinLeftView = NSLayoutConstraint(item: self.view,
//                                             attribute: NSLayoutAttribute.left,
//                                             relatedBy: NSLayoutRelation.equal,
//                                             toItem: destinationView,
//                                             attribute: NSLayoutAttribute.left,
//                                             multiplier: 1.0,
//                                             constant: 0)
//        pinRightView = NSLayoutConstraint(item: self.view,
//                                          attribute: NSLayoutAttribute.right,
//                                          relatedBy: NSLayoutRelation.equal,
//                                          toItem: destinationView,
//                                          attribute: NSLayoutAttribute.right,
//                                          multiplier: 1.0,
//                                          constant: 0)
//        let heightView = NSLayoutConstraint(item: self.view,
//                                            attribute: NSLayoutAttribute.height,
//                                            relatedBy: NSLayoutRelation.equal,
//                                            toItem: destinationView,
//                                            attribute: NSLayoutAttribute.height,
//                                            multiplier: 0.0412,
//                                            constant: 0)
//        return [pinLeftView, pinRightView, heightView]
        
        
        self.view.widthAnchor.constraint(equalTo: inView.widthAnchor, multiplier: 1.0).isActive = true
        self.view.heightAnchor.constraint(equalTo: inView.heightAnchor, multiplier: 0.0412).isActive = true
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: Double(timeInterval), target: self, selector: #selector(updateView), userInfo: Date(), repeats: true)
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func reset() {
        stop()
        view.backgroundColor = UIColor.green()
//        pinRightView.constant = 0
        view.transform = CGAffineTransform.identity
        value = duration
    }
    
    func pauseOrResume() {
        timer.isValid ? stop() : start()
    }
    
    @objc func updateView() {
        value -= timeInterval
        
        //1 is final color value in view's color animation. And (4/5) is multiplicator for increasing speed of color changes.
        let stepToChangeColor = (1 / (duration * (4/5))) * timeInterval
        //Changing view's color from green to red.
        let color = view.backgroundColor?.cgColor.components, red = 0, green = 1, blue = 2, alpha = 3
        view.backgroundColor = UIColor(red: (color![red] + stepToChangeColor), green: (color![green] - stepToChangeColor), blue: color![blue], alpha: color![alpha])
        
        //Changing view's width
//        pinRightView.constant -= stepToChangeWidth
        view.transform = CGAffineTransform(scaleX: (value/duration), y: 1)
        
        if value <= 0 {
            print( "\(value) : Time is elapsed!")
            delegate.gameOver()
        }
    }
}
