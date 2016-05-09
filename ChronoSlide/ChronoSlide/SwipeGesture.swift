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

/// Custom Swipe Gesture that keeps track of the velocity of the users movement.
class ChronoSwipeGesture: UIGestureRecognizer{
    /// The velocity vector of the gesture when it ends.
    var velocity: CGVector?
    /// The starting point of gesture decided by user input.
    var startPosition:CGPoint?
    /// The start time of the gesture decided by user input.
    var startTime: NSDate?
    /// The end point of the gesture decided by user input.
    var endPosition:CGPoint?
    /// The end time of the gesture decided by user input.
    var endTime: NSDate?
    /// The stored point before the end point.
    var storedPoint: CGPoint?
    
    
    /**
        Touch input start for the gesture.
        
        - Parameter touches: Set of input from the user.
        - Parameter event: Touch event from the user.
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event!)
        state = .Began
        let aTouch = touches
        startPosition  = aTouch.first?.locationInView(self.view)
        startTime = NSDate()
        print("start")
    }
    
    /**
     Touch input changed for the gesture.
     
     - Parameter touches: Set of input from the user.
     - Parameter event: Touch event from the user.
     */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event!)
        let aTouch = touches
        storedPoint = aTouch.first?.locationInView(self.view)
        state = .Changed

        
    }
    
    /**
     Touch input ended for the gesture.
     
     - Parameter touches: Set of input from the user.
     - Parameter event: Touch event from the user.
     */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("ended")
        super.touchesEnded(touches, withEvent: event!)
        let aTouch = touches
        endPosition = aTouch.first?.locationInView(self.view)

        if startPosition == endPosition {
           // print("same")
            state = .Cancelled
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
    
    /**
     Touch input cancelled for the gesture.
     
     - Parameter touches: Set of input from the user.
     - Parameter event: Touch event from the user.
     */
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches!, withEvent: event!)
        state = .Cancelled
    }
    
    /**
     Reset the state of the gesture.
     
     */
    override func reset() {
        super.reset()
        state = .Possible
    }
    
    /**
     Initializes a new gesture with parameters
     
     - Parameter target: Object to actach the gesture to.
     - Parameter action: Function to call when the gesture is used.
     */
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target!, action: action)
        delaysTouchesEnded = false
        
    }
    

}