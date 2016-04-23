//
//  SwipeGesture.swift
//  ChronoSlide
//
//  Created by Tim Harris on 1/31/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class ChronoSwipeGesture: UISwipeGestureRecognizer{
    var velocity: CGVector?
    var force:CGVector?
    var startPosition:CGPoint?
    var startTime: NSDate?
    var endPosition:CGPoint?
    var endTime: NSDate?
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event!)
        let aTouch = touches
        startPosition  = aTouch.first?.locationInView(self.view)
        startTime = NSDate()
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event!)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event!)
        let aTouch = touches
        endPosition = aTouch.first?.locationInView(self.view)
        
        endTime = NSDate()
        let deltaTime = endTime?.timeIntervalSinceDate(startTime!)
        let deltaPositionX = endPosition!.x - startPosition!.x
        let deltaPositionY = endPosition!.y - startPosition!.y
        //let timeNumber = NSFloat
        velocity = CGVectorMake(deltaPositionX/CGFloat(deltaTime!), deltaPositionY/CGFloat(deltaTime!))
        print(velocity!)
        
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches!, withEvent: event!)
    }
    
    override func reset() {
        super.reset()
    }
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target!, action: action)
    }
    gesture
}