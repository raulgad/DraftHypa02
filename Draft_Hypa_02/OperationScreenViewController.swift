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

    @IBOutlet weak var additionButton: UIButton!
    @IBOutlet weak var subtractionButton: UIButton!
    @IBOutlet weak var multiplicationButton: UIButton!
    @IBOutlet weak var divisionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionButton.layer.cornerRadius = 8
        subtractionButton.layer.cornerRadius = 8
        multiplicationButton.layer.cornerRadius = 8
        divisionButton.layer.cornerRadius = 8
    }
    
    func resetGameAndCloseView() {
        delegate.resetGame()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addition(_ sender: AnyObject) {
        Task.taskOperation = Operation.Addition
        resetGameAndCloseView()
    }
    
    @IBAction func subtraction(_ sender: AnyObject) {
        Task.taskOperation = Operation.Subtraction
        resetGameAndCloseView()
    }
    
    @IBAction func multiplication(_ sender: AnyObject) {
        Task.taskOperation = Operation.Multiplication
        resetGameAndCloseView()
    }
    
    @IBAction func division(_ sender: AnyObject) {
        Task.taskOperation = Operation.Division
        resetGameAndCloseView()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
