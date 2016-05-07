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

/// Sound based reminder of a particular time.
struct Alarm {
    /// Time value for the hour of an alarm.
    var alarmHour: Int
    /// Time value for the minute of an alarm.
    var alarmMinute: Int
    /// On and Off state for an alarm.
    var alarmState: Bool
    /// Name of an alarm.
    var alarmName: String
    /// Song or sound to be used for the alarm.
    var alarmSound: MPMediaItem? = nil
    /// Notification to be used for the alarm to fire.
    var alarmNotification: UILocalNotification? = nil
    /// Repeats for the alarm.
    var alarmRepeat: [repeatType] = [.None]
    /// Does the alarm have repeats.
    var alarmRepeats: Bool = false
    
    /**
        Initializes an alarm with the base information
     
        - Returns: An alarm value type with some basic variables.
    */
    init(){
        self.alarmMinute = 30
        self.alarmHour = 8
        self.alarmState = false
        self.alarmName = ""
    }
    
    /**
     Initializes an alarm with two parameters
     
     - Parameter newMinute: The minute value for the new alarm.
     - Parameter newHour: The hour value for the new alarm.
     - Returns: An alarm value type with an alarm time parameter.
     */
    init(newMinute: Int, newHour: Int, newName: String){
        alarmMinute = newMinute
        alarmHour = newHour
        alarmName = newName
        alarmState = false
    }
    
    /**
     Sets the hour value for an alarm
     
     - Parameter newHour: New hour value for the alarm.
     */
    mutating func setAlarmHour(newHour: Int){
        alarmHour = newHour
    }
    
    /**
     Sets the minute value for an alarm
     
     - Parameter newMinute: New hour value for the alarm.
     */
    mutating func setAlarmMinute(newMinute: Int){
        alarmMinute = newMinute
    }
    
    /**
     Sets the On value for an alarm
     
     - Parameter newState: New state value for the alarm.
     */
    mutating func setAlarmState(newState: Bool){
        alarmState = newState
    }
    
    /**
     Sets the name for an alarm
     
     - Parameter newName: New name for the alarm.
     */
    mutating func setAlarmName(newName: String){
        alarmName = newName
    }
    
    /**
     Sets the song or sound value for an alarm
     
     - Parameter newSound: New MPMediaItem value for the alarm.
     */
    mutating func setAlarmSound(newSound: MPMediaItem){
        alarmSound = newSound
    }
    
    /**
     Sets the notification value for an alarm
     
     - Parameter newNotification: New notification value for the alarm.
     */
    mutating func setAlarmNotification(newNotification: UILocalNotification) {
        alarmNotification = newNotification
    }
    
    /**
     Sets the repeat values for an alarm
     
     - Parameter newRepeat: New repeat values for the alarm.
     */
    mutating func setAlarmRepeat(newRepeat: [repeatType]){
        alarmRepeat = newRepeat
    }
    
    /**
     Sets the value to describe if the alarm has repeats
     
     - Parameter doesRepeat: New Boolean value to say if the alarm repeats.
     */
    mutating func setAlarmRepeats(doesRepeat: Bool){
        alarmRepeats = doesRepeat
    }
    
}

public protocol RepeatingType {
    
}

/// The kinds of reapeats that are available
enum repeatType: CustomStringConvertible, Equatable {
    /**
        
        Options for repeating
     
        - Monday: Repeat on Mondays
        - Tuesday Reapeat on Tuesdays
        - Wednesday: Repeat on Wednesdays
        - Thursday: Repeat on Thursdays
        - Friday: Repeat on Fridays
        - Saturday: Repeat on Saturdays
        - Sunday: Repeat on Sundays
        - Everyday: Repeat Everyday
        - None: Do not repeat

    */
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
    case Everyday
    case None
    
    /**
     A Variable for the description of a repeatType
     
     - Returns: a string of the repeated case
     */
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
        case .None: return "None";
        }
        
    }


}

// FIXME: Get working with repeatType

extension Array where Element :  Equatable {
    func chronSort() -> [repeatType] {
        var sortedArray: [repeatType] = [repeatType]()
        for aRepeat in RepeatMacros {
         //   sortedArray.insert(aRepeat, atIndex: sortedArray.count)
        }
        return sortedArray
    }
}

