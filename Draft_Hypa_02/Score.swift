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
    //FIXME: Bad idea to give everybody access for changing the value. Maybe you should give access by delegate.
    var value: Int = 0 {
        didSet {
            Backside.sharedInstance.bottomItem.valueLabel.text = String(value)
        }
    }
    
    private init() { }
}
