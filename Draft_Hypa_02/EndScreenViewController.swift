//
//  EndScreenViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 04.11.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class EndScreenViewController: UIViewController {
    
    var delegate: CardsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    @IBAction func cancel(_ sender: AnyObject) {
        delegate.resetGame()
        self.dismiss(animated: true, completion: nil)
    }

}
