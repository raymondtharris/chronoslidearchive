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
    var alarmRepeat: [repeatType] = [.none]
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
    mutating func setAlarmHour(_ newHour: Int){
        alarmHour = newHour
    }
    
    /**
     Sets the minute value for an alarm
     
     - Parameter newMinute: New hour value for the alarm.
     */
    mutating func setAlarmMinute(_ newMinute: Int){
        alarmMinute = newMinute
    }
    
    /**
     Sets the On value for an alarm
     
     - Parameter newState: New state value for the alarm.
     */
    mutating func setAlarmState(_ newState: Bool){
        alarmState = newState
    }
    
    /**
     Sets the name for an alarm
     
     - Parameter newName: New name for the alarm.
     */
    mutating func setAlarmName(_ newName: String){
        alarmName = newName
    }
    
    /**
     Sets the song or sound value for an alarm
     
     - Parameter newSound: New MPMediaItem value for the alarm.
     */
    mutating func setAlarmSound(_ newSound: MPMediaItem){
        alarmSound = newSound
    }
    
    /**
     Sets the notification value for an alarm
     
     - Parameter newNotification: New notification value for the alarm.
     */
    mutating func setAlarmNotification(_ newNotification: UILocalNotification) {
        alarmNotification = newNotification
    }
    
    /**
     Sets the repeat values for an alarm
     
     - Parameter newRepeat: New repeat values for the alarm.
     */
    mutating func setAlarmRepeat(_ newRepeat: [repeatType]){
        alarmRepeat = newRepeat
    }
    
    /**
     Sets the value to describe if the alarm has repeats
     
     - Parameter doesRepeat: New Boolean value to say if the alarm repeats.
     */
    mutating func setAlarmRepeats(_ doesRepeat: Bool){
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
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    case everyday
    case none
    
    /**
     A Variable for the description of a repeatType
     
     - Returns: a string of the repeated case
     */
    var description: String {
        switch self {
        case .monday: return "Monday";
        case .tuesday: return "Tuesday";
        case .wednesday: return "Wednesday";
        case .thursday: return "Thursday";
        case .friday: return "Friday";
        case .saturday: return "Saturday";
        case .sunday: return "Sunday";
        case .everyday: return "Everyday";
        case .none: return "None";
        }
        
    }
    var minDescription: String {
        switch self {
        case .monday: return "Mon";
        case .tuesday: return "Tue";
        case .wednesday: return "Wed";
        case .thursday: return "Thur";
        case .friday: return "Fri";
        case .saturday: return "Sat";
        case .sunday: return "Sun";
        case .everyday: return "Everyday";
        case .none: return "None";
        }
        
    }

}

func sortRepeatArray(_ anArray: [repeatType]) -> [repeatType] {
    var sorted: [repeatType] = [repeatType]()
    for aRepeat in RepeatMacros {
        if anArray.contains(aRepeat) {
            sorted.append(aRepeat)
        }
    }
    return sorted
}

func repeatArrayToStringArray(_ anArray: [repeatType]) -> [String] {
    var strArray = [String]()
    for aRepeat in anArray {
        strArray.append(aRepeat.description)
    }
    return strArray
}

func repeatStringsToRepeatArray(_ anArray: [String]) -> [repeatType] {
    var newRepeats = [repeatType]()
    for aString in anArray{
        switch aString {
        case "None":
            newRepeats.append(repeatType.none)
            break
        case "Monday":
            newRepeats.append(repeatType.monday)
            break
        case "Tuesday":
            newRepeats.append(repeatType.tuesday)
            break
        case "Wednesday":
            newRepeats.append(repeatType.wednesday)
            break
        case "Thursday":
            newRepeats.append(repeatType.thursday)
            break
        case "Friday":
            newRepeats.append(repeatType.friday)
            break
        case "Saturday":
            newRepeats.append(repeatType.saturday)
            break
        case "Sunday":
            newRepeats.append(repeatType.sunday)
            break
        case "Everyday":
            newRepeats.append(repeatType.everyday)
            break
        default:
            break
        }
    }
     return newRepeats
}
