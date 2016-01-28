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
        let chronoAlarmCell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as! AlarmTableCellView
        let chronoAlarm = ChronoAlarms[indexPath.row]
        chronoAlarmCell.alamTimeLabel.text = chronoAlarm.alarmHour.description + ":" + chronoAlarm.alarmMinute.description
        chronoAlarmCell.alarmOptionsLabel.text = chronoAlarm.alarmName
        return chronoAlarmCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChronoAlarms.count
    }
    
    override func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func addingNewAlarm(notification: NSNotification){
        let alarmDictionary = notification.userInfo!
        let tempdata = alarmDictionary["alarm"] as! Alarm
        print(tempdata.alarmHour.description + ": " + tempdata.alarmMinute.description)
        ChronoAlarms.append(tempdata)
        let tableView = self.view as! UITableView
        tableView.reloadData()
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
        let alarmDicationary:Dictionary = ["alarm": newAlarm as! AnyObject] //Need to fix cast or make a wrapper for values.
        NSNotificationCenter.defaultCenter().postNotificationName(AddingNewAlarmNotification, object: self, userInfo: alarmDicationary)
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
    @IBOutlet weak var alarmToggleSwitch: UISwitch!
    
    @IBAction func toggleAlarm(sender: AnyObject) {
    }
    

}
