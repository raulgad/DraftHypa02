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
    static let sharedInstance = Time(duration: 15)
    private var timer = Timer()
    private(set) var value: CGFloat
    let duration: CGFloat
    var delegate: CardsViewControllerDelegate!
    var view: UIView
    
    private init(duration: CGFloat) {
        self.duration = duration
        
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.green()
        
        value = duration
    }
    
    func setLayout(inView: UIView) {
        self.view.widthAnchor.constraint(equalTo: inView.widthAnchor,
                                         multiplier: 1.0).isActive = true
        self.view.heightAnchor.constraint(equalTo: inView.heightAnchor,
                                          multiplier: 0.0412).isActive = true
    }
    
    func start() {
        let timeInterval: CGFloat = 0.05
        timer = Timer.scheduledTimer(timeInterval: Double(timeInterval),
                                     target: self,
                                     selector: #selector(updateView),
                                     userInfo: timeInterval,
                                     repeats: true)
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func reset() {
        stop()
        view.backgroundColor = UIColor.green()
        view.transform = CGAffineTransform.identity
        value = duration
    }
    
    func pauseOrResume() {
        timer.isValid ? stop() : start()
    }
    
    @objc func updateView() {
        let timeInterval = timer.userInfo as! CGFloat
        
        //Decrease time value in each function call
        value -= timeInterval
        
        //1 is final color value in view's color animation. And (4/5) is multiplicator for increasing speed of color changes.
        let stepToChangeColor = (1 / (duration * (4/5))) * timeInterval
        
        //Changing view's color from green to red.
        let color = view.backgroundColor?.cgColor.components
        view.backgroundColor = UIColor(red: color![0] + stepToChangeColor,
                                       green: color![1] - stepToChangeColor,
                                       blue: color![2],
                                       alpha: color![3])
        
        //Changing view's width
        view.transform = CGAffineTransform(scaleX: (value/duration), y: 1)
        
        if value <= 0 {
            print( "\(value) : Time is elapsed!")
            delegate.gameOver()
        }
    }
}
