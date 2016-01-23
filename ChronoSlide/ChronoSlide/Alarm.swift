//
//  Alarm.swift
//  ChronoSlide
//
//  Created by Tim Harris on 1/21/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

struct Alarm {
    var alarmHour: Int
    var alarmMinute: Int
    var alarmState: Bool
    var alarmName: String
    var alarmSound: MPMediaItem
    var alarmNotification: UILocalNotification
    
    mutating func setAlarmHour(newHour: Int){
        alarmHour = newHour
    }
    
    mutating func setAlarmMinute(newMinute: Int){
        alarmMinute = newMinute
    }
    mutating func setAlarmState(newState: Bool){
        alarmState = newState
    }
    
    mutating func setAlarmName(newName: String){
        alarmName = newName
    }
    
    mutating func setAlarmSound(newSound: MPMediaItem){
        alarmSound = newSound
    }
    
}

