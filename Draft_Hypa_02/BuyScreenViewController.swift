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
    @IBOutlet weak var passesValue: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        //Add timing view to the screen.
        self.view.addSubview(Time.sharedInstance.view)
        Time.sharedInstance.setLayout(inView: self.view)
        
        isBoughtPasses = false
    }
    
    @IBAction func buyPasses(_ sender: AnyObject) {
        delegate.passes.value += 1
        passesValue.text = String(delegate.passes.value)
        isBoughtPasses = true
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        if isBoughtPasses {
            delegate.passes.value -= 1
            Time.sharedInstance.reset()
            Time.sharedInstance.start()
            self.dismiss(animated: true, completion: nil)
            delegate.showNewCards(from: .left)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
