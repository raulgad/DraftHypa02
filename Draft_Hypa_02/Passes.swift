//
//  Passes.swift
//  Draft_Hypa_02
//
//  Created by mac on 03.12.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation

class Passes {
    static let sharedInstance: Passes = Passes()
    let name: String = "Passes"
    //FIXME: Bad idea to give everybody access for changing the value. Maybe you should give access by delegate.
    var value: Int = 3 {
        didSet {
            Backside.sharedInstance.bottomItem.updateScoreOrPassesInView()
            Task.holdComplexity()
        }
    }
    
    private init() { }
}
