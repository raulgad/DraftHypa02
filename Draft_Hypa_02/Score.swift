//
//  Score.swift
//  Draft_Hypa_02
//
//  Created by mac on 03.12.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation

class Score {
    static let sharedInstance: Score = Score()
    let name: String = "Score"
    var value: Int = 0 {
        didSet {
            //FIXME: Not a godd idea to get direct access (not through 'backside')?
            delay(delay: 1.5, closure: BottomItem.sharedInstance.updateScoreOrPassesInView)
        }
    }
    
    private init() { }
    
    func delay (delay: Double, closure: () ->()) {
        DispatchQueue.main.after(when: .now() + delay, execute: closure)
    }
}
