//
//  SwipeGesture.swift
//  ChronoSlide
//
//  Created by Tim Harris on 1/31/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import Foundation
import UIKit

class ChronoSwipeGesture: UIControl{
    var velocity: CGVector?
    var force:CGVector?
    var startPosition:CGPoint?
    var startTime: NSDate?
    var endPosition:CGPoint?
    var endTime: NSDate?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let aTouch = touches
        startPosition  = aTouch.first?.locationInView(self)
        startTime = NSDate()
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let aTouch = touches
        endPosition = aTouch.first?.locationInView(self)
        
        
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
}