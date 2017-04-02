//
//  Passes.swift
//  Draft_Hypa_02
//
//  Created by mac on 03.12.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation

class Passes {
    //Create Singleton for passes
    static let sharedInstance: Passes = Passes()
    let name: String = "passes"
    var value: Int = 3 {
        didSet {
            //Update passes view
            Backside.sharedInstance.bottomItem.valueLabel.text = String(value)
            
            //Hold task's capacity
            Task.holdCapacity()
        }
    }
    
    private init() { }
}
