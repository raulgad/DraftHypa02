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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buyPasses(_ sender: AnyObject) {
        increasePasses()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        if isBoughtPasses {
            delegate.resumeTiming()
            self.dismiss(animated: true, completion: nil)
        } else {
            delegate.resetGame()
            self.dismiss(animated: true, completion: nil)
        }
        
//        delegate.resetGame()
//        self.dismiss(animated: true, completion: nil)
    }
    
    private func increasePasses() {
        delegate.passes.value += 1
        isBoughtPasses = true
    }
}
