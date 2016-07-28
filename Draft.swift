//
//  ViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    var myView: UIView!
    
    var animator: UIDynamicAnimator!
    var attachmentBehavior: UIAttachmentBehavior!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        createConstrants()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        myView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        guard let panView = pan.view else {
            print("Error with unwrap pan.view")
            return
        }
        let location = pan.location(in: self.view)
        
        switch pan.state {
            case .began:
                if #available(iOS 9.0, *) {
                    let dynamicItemBehavior = UIDynamicItemBehavior(items: [myView])
                    dynamicItemBehavior.allowsRotation = false
                    animator.addBehavior(dynamicItemBehavior)

                    attachmentBehavior = UIAttachmentBehavior(item: panView, attachedToAnchor: location)
                    attachmentBehavior.frictionTorque = 1.0
                    animator.addBehavior(attachmentBehavior)
                    print(attachmentBehavior.frictionTorque)
                } else {
                    // Fallback on earlier versions
                }
            
            case .changed:
                attachmentBehavior.anchorPoint = location
                
            case .cancelled, .ended:
                animator.removeAllBehaviors()
                
            default: ()
        }
    }
    
    func initViews() {
        ...
    }
    
    func createConstrants() {
        ...
    }
}
