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
    var startTime: Date?
    /// The end point of the gesture decided by user input.
    var endPosition:CGPoint?
    /// The end time of the gesture decided by user input.
    var endTime: Date?
    /// The stored point before the end point.
    var storedPoint: CGPoint?
    
    
    /**
        Touch input start for the gesture.
        
        - Parameter touches: Set of input from the user.
        - Parameter event: Touch event from the user.
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event!)
        state = .began
        let aTouch = touches
        startPosition  = aTouch.first?.location(in: self.view)
        startTime = Date()
        print("start")
    }
    
    /**
     Touch input changed for the gesture.
     
     - Parameter touches: Set of input from the user.
     - Parameter event: Touch event from the user.
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event!)
        let aTouch = touches
        storedPoint = aTouch.first?.location(in: self.view)
        state = .changed

        
    }
    
    /**
     Touch input ended for the gesture.
     
     - Parameter touches: Set of input from the user.
     - Parameter event: Touch event from the user.
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
        super.touchesEnded(touches, with: event!)
        let aTouch = touches
        endPosition = aTouch.first?.location(in: self.view)

        if startPosition == endPosition {
           // print("same")
            state = .cancelled
        }
        else {
            endTime = Date()
            let deltaTime = endTime?.timeIntervalSince(startTime!)
            let deltaPositionX = endPosition!.x - startPosition!.x
            let deltaPositionY = endPosition!.y - startPosition!.y

            if endPosition?.x == storedPoint?.x {
                velocity = CGVector(dx: 0.0, dy: 0.0)
            } else {
            velocity = CGVector(dx: deltaPositionX/CGFloat(deltaTime!), dy: deltaPositionY/CGFloat(deltaTime!))

            }
            state = .ended
        }
    }
    
    /**
     Touch input cancelled for the gesture.
     
     - Parameter touches: Set of input from the user.
     - Parameter event: Touch event from the user.
     */
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event!)
        state = .cancelled
    }
    
    /**
     Reset the state of the gesture.
     
     */
    override func reset() {
        super.reset()
        state = .possible
    }
    
    /**
     Initializes a new gesture with parameters
     
     - Parameter target: Object to actach the gesture to.
     - Parameter action: Function to call when the gesture is used.
     */
    override init(target: AnyObject?, action: Selector?) {
        super.init(target: target!, action: action)
        delaysTouchesEnded = false
        
    }
    

}
