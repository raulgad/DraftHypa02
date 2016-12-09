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
    var value: Int = 1 {
        didSet {
            //FIXME: Not a godd idea to get direct access (not through 'backside')?
            BottomItem.sharedInstance.updateScoreOrPassesInView()
        }
    }
    
    private init() { }
}
