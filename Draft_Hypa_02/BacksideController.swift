//
//  BacksideController.swift
//  Draft_Hypa_02
//
//  Created by mac on 02.12.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

class Backside {
    static let sharedInstance: Backside = Backside()
    
    let topItem: TopItem
    let bottomItem: BottomItem
    
    private init() {
        topItem = TopItem.sharedInstance
        bottomItem = BottomItem.sharedInstance
    }
    
    func updateItemsWhenCardMoving(to translation: CGPoint) {
        bottomItem.updateViewWhenCardMoving(direction: translation.x > 0 ? .left : .right)
    }
    
    func updateItemsWhenGotAnswer(isCorrect isCorrectAnswer: Bool) {
        topItem.updateViewForAnswer(isCorrect: isCorrectAnswer)
    }
    
    func updateItemsForTiming() {
        
    }
}
