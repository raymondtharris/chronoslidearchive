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
    var alarmSound: MPMediaItem? = nil
    var alarmNotification: UILocalNotification? = nil
    var alarmRepeat: [repeatType] = [.None]
    var alarmRepeats: Bool = false
    
    init(){
        self.alarmMinute = 30
        self.alarmHour = 8
        self.alarmState = false
        self.alarmName = ""
    }
    
    init(newMinute: Int, newHour: Int, newName: String){
        alarmMinute = newMinute
        alarmHour = newHour
        alarmName = newName
        alarmState = false
    }
    
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
    
    mutating func setAlarmNotification(newNotification: UILocalNotification) {
        alarmNotification = newNotification
    }
    
}


enum repeatType: CustomStringConvertible, Equatable {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
    case Everyday
    //case Weekly
    //case Monthly
    case None
    
    var description: String {
        switch self {
        case .Monday: return "Monday";
        case .Tuesday: return "Tuesday";
        case .Wednesday: return "Wednesday";
        case .Thursday: return "Thursday";
        case .Friday: return "Friday";
        case .Saturday: return "Saturday";
        case .Sunday: return "Sunday";
        case .Everyday: return "Everyday";
       // case .Weekly: return "Weekly";
       // case .Monthly: return "Monthly";
        case .None: return "None";
        }
        
    }

}