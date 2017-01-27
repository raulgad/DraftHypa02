//
//  BuyScreenViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.11.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class BuyScreenViewController: UIViewController {
    
    var delegate: CardsViewControllerDelegate!
    var isBoughtPasses: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        isBoughtPasses = false
    }
    
    @IBAction func buyPasses(_ sender: AnyObject) {
        delegate.passes.value += 1
        isBoughtPasses = true
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        if isBoughtPasses {
            Time.sharedInstance.reset()
            delegate.passes.value -= 1
            self.dismiss(animated: true, completion: nil)
            delegate.showNewCards(from: .left)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
