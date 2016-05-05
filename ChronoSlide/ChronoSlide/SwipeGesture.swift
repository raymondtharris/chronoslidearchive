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

class ChronoSwipeGesture: UIGestureRecognizer{
    var velocity: CGVector?
    var force:CGVector?
    var startPosition:CGPoint?
    var startTime: NSDate?
    var endPosition:CGPoint?
    var endTime: NSDate?
    var storedPoint: CGPoint?
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event!)
        state = .Began
        let aTouch = touches
        startPosition  = aTouch.first?.locationInView(self.view)
        startTime = NSDate()
        print("start")
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event!)
        let aTouch = touches
        storedPoint = aTouch.first?.locationInView(self.view)
        state = .Changed

        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event!)
        let aTouch = touches
        endPosition = aTouch.first?.locationInView(self.view)

        if startPosition == endPosition {
            state = .Failed
        }
        else {
            endTime = NSDate()
            let deltaTime = endTime?.timeIntervalSinceDate(startTime!)
            let deltaPositionX = endPosition!.x - startPosition!.x
            let deltaPositionY = endPosition!.y - startPosition!.y

            if endPosition?.x == storedPoint?.x {
                velocity = CGVectorMake(0.0, 0.0)
            } else {
            velocity = CGVectorMake(deltaPositionX/CGFloat(deltaTime!), deltaPositionY/CGFloat(deltaTime!))

            }
            state = .Ended
        }
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches!, withEvent: event!)
        state = .Cancelled
    }
    
    override func reset() {
        super.reset()
    }
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target!, action: action)
        delaysTouchesEnded = false
        
    }
    

}