//
//  ViewController.swift
//  ChronoSlide
//
//  Created by Tim Harris on 1/21/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import UIKit
import MediaPlayer




let AddingNewAlarmNotification:String = "AddingNewAlarmNotification"

class AlarmTableViewController: UITableViewController {
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    
    var animator: UIDynamicAnimator?
    var ChronoAlarms: [Alarm] = [Alarm]()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addingNewAlarm:", name: AddingNewAlarmNotification, object: nil)
        animator = UIDynamicAnimator(referenceView: self.view)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chronoAlarmCell = tableView.dequeueReusableCellWithIdentifier("alarmCell", forIndexPath: indexPath) as! AlarmTableCellView
        let chronoAlarm = ChronoAlarms[indexPath.row]
        chronoAlarmCell.alamTimeLabel.text = chronoAlarm.alarmHour.description + ":" + chronoAlarm.alarmMinute.description
        chronoAlarmCell.alarmOptionsLabel.text = chronoAlarm.alarmName
        chronoAlarmCell.cellAnimator = UIDynamicAnimator(referenceView: self.view)
        
        
        // Spring
        chronoAlarmCell.springNode = UIAttachmentBehavior(item: chronoAlarmCell , attachedToAnchor: CGPoint(x: (chronoAlarmCell.frame.width * 1.25) , y: (chronoAlarmCell.frame.origin.y + (chronoAlarmCell.frame.height/2))))
        chronoAlarmCell.springNode?.length = chronoAlarmCell.frame.width * (1.25/2)
        chronoAlarmCell.springNode?.frequency = 0.6
        chronoAlarmCell.cellAnimator?.addBehavior(chronoAlarmCell.springNode!)
        //animator?.addBehavior(chronoAlarmCell.springNode!)
        //print(chronoAlarmCell.springNode!.length )
        
        //Collision
        chronoAlarmCell.boundingBox = UICollisionBehavior(items: [chronoAlarmCell])
        chronoAlarmCell.boundingBox?.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), toPoint: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.boundingBox?.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), toPoint: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.cellAnimator?.addBehavior(chronoAlarmCell.boundingBox!)
        //animator?.addBehavior(chronoAlarmCell.boundingBox!)
        
        //Elasticity
        chronoAlarmCell.cellElasticity = UIDynamicItemBehavior(items: [chronoAlarmCell])
        chronoAlarmCell.cellElasticity?.elasticity = 0.4
        chronoAlarmCell.cellAnimator?.addBehavior(chronoAlarmCell.cellElasticity!)
        //animator?.addBehavior(chronoAlarmCell.cellElasticity!)
        
        // Gesture
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
        
        let createdAlarm = Alarm(newMinute: Int(alarmDictionary["alarmMinute"] as! String)!, newHour: Int(alarmDictionary["alarmHour"] as! String)!, newName: alarmDictionary["alarmName"]as! String)
        print(createdAlarm.alarmHour.description + ": " + createdAlarm.alarmMinute.description)
        ChronoAlarms.append(createdAlarm)
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    func toggleAlarm(gestureRecognizer: UISwipeGestureRecognizer){
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let swipedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AlarmTableCellView
        
        //Swipe Push
        swipedCell.cellPush = UIPushBehavior(items: [swipedCell], mode: UIPushBehaviorMode.Instantaneous)
        swipedCell.cellPush?.pushDirection = CGVector(dx: -30.0, dy: 0.0)
        //print(swipedCell.cellPush?.magnitude)
        swipedCell.cellAnimator?.addBehavior(swipedCell.cellPush!)
        
        changeAlarmToggleState(swipedCell, currentRow: (indexPath?.row)!)
        //animator?.addBehavior(swipedCell.cellPush!)
        
    }
    
    func changeAlarmToggleState(interactedCell: AlarmTableCellView, currentRow: Int){
        UIView.animateWithDuration(0.6, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            if self.ChronoAlarms[currentRow].alarmState {
                interactedCell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            } else {
                interactedCell.backgroundColor = UIColor(red: 0.93, green: 0.17, blue: 0.17, alpha: 1.0)
            }

            }, completion: nil)
             ChronoAlarms[currentRow].setAlarmState(!ChronoAlarms[currentRow].alarmState)
        
    }
    
    
    @IBAction func goToSettings(sender: AnyObject) {
        if let chronoslideSettings = NSURL(string: UIApplicationOpenSettingsURLString){
            UIApplication.sharedApplication().openURL(chronoslideSettings)
        }
    }
    
    
}

class NewAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var hourTextLabel: UITextField!
    
    @IBOutlet weak var minuteTextLabel: UITextField!
    
    let hourPicker = UIPickerView()
    let minutePicker = UIPickerView()
    
    let toolbar = UIToolbar()
    
    var hourData = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    var minuteData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildArrays()
        
        hourPicker.delegate = self
        minutePicker.delegate = self
        hourPicker.dataSource = self
        minutePicker.dataSource = self
        hourTextLabel.inputView = hourPicker
        minuteTextLabel.inputView = minutePicker
        
    }
    
    func buildArrays(){
        for aNumber in 0..<60 {
            minuteData.append(aNumber.description)
        }
    }
    
    @IBAction func commitNewAlarm(sender: AnyObject) {
        
        let alarmDicationary = ["alarmHour": hourTextLabel.text!, "alarmMinute": minuteTextLabel.text!, "alarmName": "test alarm"] //Need to fix cast or make a wrapper for values.
        NSNotificationCenter.defaultCenter().postNotificationName(AddingNewAlarmNotification, object: self, userInfo: alarmDicationary as [NSObject : AnyObject])
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func testAlarm() -> Alarm{
        let temp = Alarm()
        return temp
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hourPicker{
            return hourData.count
        } else {
            return minuteData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == hourPicker{
            hourTextLabel.text = hourData[row]
        } else {
            minuteTextLabel.text = minuteData[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == hourPicker{
            return hourData[row]
        } else {
            return minuteData[row]
        }
    }
    
    

    
}

class EditAlarmViewController: UIViewController {
    
    @IBOutlet weak var updateAlarmButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


class AlarmTableCellView: UITableViewCell {
    
    @IBOutlet weak var alamTimeLabel: UILabel!
    @IBOutlet weak var alarmOptionsLabel: UILabel!
    var springNode: UIAttachmentBehavior?
    var boundingBox: UICollisionBehavior?
    var cellElasticity: UIDynamicItemBehavior?
    var cellPush: UIPushBehavior?
    var cellAnimator: UIDynamicAnimator?
}
