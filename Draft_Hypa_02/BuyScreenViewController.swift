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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buyPasses(_ sender: AnyObject) {
        increasePasses()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func increasePasses() {
        delegate.passes += 1
    }
}
