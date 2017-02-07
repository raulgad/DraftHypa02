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
    
    //Corner radius of the buttons is setted in Interface Builder (in section 'User Defined Runtime Attributes' of the button)
    
    override func viewDidAppear(_ animated: Bool) {
        //Add timing view to the operationScreen.
        //FIXME: The right way: we must create all views (timing, score/passes, etc) in Interface Builder in the appropriate storyboard screens. 'Time' class must be 'TimeController'. The 'timeView' (= outlet in the 'OperationScreenViewController') we should set to the 'Time.sharedInstance.views' dictionary that we loop through to 'update' and 'reset' views.
        self.view.addSubview(Time.sharedInstance.view)
        Time.sharedInstance.setLayout(inView: self.view)
    }
    
    func resetGameAndCloseView() {
        delegate.resetGame()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addition(_ sender: AnyObject) {
        Task.operation = .addition
        resetGameAndCloseView()
    }
    
    @IBAction func subtraction(_ sender: AnyObject) {
        Task.operation = .subtraction
        resetGameAndCloseView()
    }
    
    @IBAction func multiplication(_ sender: AnyObject) {
        Task.operation = .multiplication
        resetGameAndCloseView()
    }
    
    @IBAction func division(_ sender: AnyObject) {
        Task.operation = .division
        resetGameAndCloseView()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
