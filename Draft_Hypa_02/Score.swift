//
//  Score.swift
//  Draft_Hypa_02
//
//  Created by mac on 03.12.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation

class Score {
    //Create Singleton for score
    static let sharedInstance: Score = Score()
    let name: String = "score"
    var value: Int = 0 {
        didSet {
            //Update score view
            Backside.sharedInstance.bottomItem.valueLabel.text = String(value)
        }
    }
    
    private init() { }
    
    func reset() {
        value = 0
        //Set score view to default position (to the left edge)
        Backside.sharedInstance.bottomItem.updateViewWhenCardMoving(direction: .left)
    }
}
