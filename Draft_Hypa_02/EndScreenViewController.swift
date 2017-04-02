//
//  EndScreenViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 04.11.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class EndScreenViewController: UIViewController{
    
    var delegate: CardsViewControllerDelegate!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var complexityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scoreLabel.text = "Score: \(Score.sharedInstance.value)"
        timeLabel.text = "Time: \(Int(Time.sharedInstance.duration))"
        if let complexityValue = Complexity(rawValue: Card.count) {
            complexityLabel.text = "Complexity: \(complexityValue.string)"
        }
    }
    
    @IBAction func fifteenTimePress(_ sender: AnyObject) {
        Time.sharedInstance.duration = 15
        timeLabel.text = "Time: 15"
    }

    @IBAction func twentyTimePress(_ sender: AnyObject) {
        Time.sharedInstance.duration = 20
        timeLabel.text = "Time: 20"
    }
    
    @IBAction func thirtyTimePress(_ sender: AnyObject) {
        Time.sharedInstance.duration = 30
        timeLabel.text = "Time: 30"
    }
    
    @IBAction func lowComplexityPress(_ sender: AnyObject) {
        Card.count = 3
        complexityLabel.text = "Complexity: low"
    }
    
    @IBAction func mediumComplexityPress(_ sender: AnyObject) {
        Card.count = 4
        complexityLabel.text = "Complexity: medium"
    }
    
    @IBAction func highComplexityPress(_ sender: AnyObject) {
        Card.count = 5
        complexityLabel.text = "Complexity: high"
    }
    
    @IBAction func replay(_ sender: AnyObject) {
        delegate.resetGame()
        //Dismiss all view controllers above the root view controller.
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    enum Complexity: Int {
        case low = 3, medium, high
        var string: String {
            return String(self)
        }
    }
}
