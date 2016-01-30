//
//  ViewController.swift
//  ChronoSlide
//
//  Created by Tim Harris on 1/21/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import UIKit
import MediaPlayer


class ViewController: UIViewController {
    var mediaLibrary: MPMediaLibrary = MPMediaLibrary.defaultMediaLibrary()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let songs = MPMediaQuery.songsQuery().items
        
        templabel.text = songs?.count.description
        print(songs?.count.description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBOutlet weak var templabel: UILabel!
}

let AddingNewAlarmNotification:String = "AddingNewAlarmNotification"

class AlarmTableViewController: UITableViewController {
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    
    
    var ChronoAlarms: [Alarm] = [Alarm]()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addingNewAlarm:", name: AddingNewAlarmNotification, object: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chronoAlarmCell = tableView.dequeueReusableCellWithIdentifier("alarmCell", forIndexPath: indexPath) as! AlarmTableCellView
        let chronoAlarm = ChronoAlarms[indexPath.row]
        chronoAlarmCell.alamTimeLabel.text = chronoAlarm.alarmHour.description + ":" + chronoAlarm.alarmMinute.description
        chronoAlarmCell.alarmOptionsLabel.text = chronoAlarm.alarmName
        
        let gesture = UISwipeGestureRecognizer.init(target: self, action: "toggleAlarm:")
        gesture.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(gesture)
        return chronoAlarmCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChronoAlarms.count
    }
    
    

    func addingNewAlarm(notification: NSNotification){
        let alarmDictionary = notification.userInfo!
        
        let createdAlarm = Alarm(newMinute: alarmDictionary["alarmMinute"] as! Int, newHour: alarmDictionary["alarmHour"] as! Int, newName: alarmDictionary["alarmName"]as! String)
        print(createdAlarm.alarmHour.description + ": " + createdAlarm.alarmMinute.description)
        ChronoAlarms.append(createdAlarm)
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    func toggleAlarm(gestureRecongnizer: UIGestureRecognizer){
        //print("left")
       let location = gestureRecongnizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        print(indexPath?.row)
        
        ChronoAlarms[(indexPath?.row)!].setAlarmState(!ChronoAlarms[(indexPath?.row)!].alarmState)
        
        print(ChronoAlarms[(indexPath?.row)!].alarmState.boolValue)
        let swipedCell = self.tableView.cellForRowAtIndexPath(indexPath!)
        if ChronoAlarms[(indexPath?.row)!].alarmState {
            let animOption = UIViewAnimationOptions.AllowUserInteraction
            UIView.animateWithDuration(0.275, delay: 0.0, options: animOption, animations: {
                swipedCell?.frame = CGRect(x: -((swipedCell?.frame.width)!/5), y: (swipedCell?.frame.origin.y)!, width: (swipedCell?.frame.size.width)!, height: (swipedCell?.frame.size.height)!)
                }, completion:{ (finished: Bool) in
                    swipedCell?.backgroundColor = UIColor(red: 0.93, green: 0.17, blue: 0.17, alpha: 1.0)
            })

            
        } else {
            swipedCell?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        }
    }
    
    
    @IBAction func goToSettings(sender: AnyObject) {
        if let chronoslideSettings = NSURL(string: UIApplicationOpenSettingsURLString){
            UIApplication.sharedApplication().openURL(chronoslideSettings)
        }
    }
    
    
}

class NewAlarmViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func commitNewAlarm(sender: AnyObject) {
        let newAlarm = testAlarm()
        let alarmDicationary = ["alarmHour": newAlarm.alarmHour, "alarmMinute": newAlarm.alarmMinute, "alarmName": newAlarm.alarmName] //Need to fix cast or make a wrapper for values.
        NSNotificationCenter.defaultCenter().postNotificationName(AddingNewAlarmNotification, object: self, userInfo: alarmDicationary as [NSObject : AnyObject])
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func testAlarm() -> Alarm{
        let temp = Alarm()
        return temp
    }
    
}


class AlarmTableCellView: UITableViewCell {
    
    @IBOutlet weak var alamTimeLabel: UILabel!
    @IBOutlet weak var alarmOptionsLabel: UILabel!

    

}
