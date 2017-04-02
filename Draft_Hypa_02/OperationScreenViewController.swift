//
//  OperationScreenViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 04.11.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class OperationScreenViewController: UIViewController {
    
    var delegate: CardsViewControllerDelegate!
    
    override func viewDidAppear(_ animated: Bool) {
        //Add timing view to the screen.
        self.view.addSubview(Time.sharedInstance.view)
        Time.sharedInstance.setLayout(inView: self.view)
    }
    
    func resetGameAndDismissView() {
        delegate.resetGame()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addition(_ sender: AnyObject) {
        Task.operation = .addition
        resetGameAndDismissView()
    }
    
    @IBAction func subtraction(_ sender: AnyObject) {
        Task.operation = .subtraction
        resetGameAndDismissView()
    }
    
    @IBAction func multiplication(_ sender: AnyObject) {
        Task.operation = .multiplication
        resetGameAndDismissView()
    }
    
    @IBAction func division(_ sender: AnyObject) {
        Task.operation = .division
        resetGameAndDismissView()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
