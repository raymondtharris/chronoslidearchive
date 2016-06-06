//
//  ViewController.swift
//  ChronoSlide
//
//  Created by Tim Harris on 1/21/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import UIKit
import MediaPlayer
import Foundation


let RepeatMacros = [repeatType.None, repeatType.Monday, repeatType.Tuesday, repeatType.Wednesday, repeatType.Thursday, repeatType.Friday, repeatType.Saturday, repeatType.Sunday, repeatType.Everyday]

protocol pickerToolbar {
    func toolbar() -> UIToolbar
}

// MARK: ALARMS

let AddingNewAlarmNotification:String = "AddingNewAlarmNotification"
let DeletingAlarmNotification:String = "DeletingAlarmNotification"
let UpdatingAlarmNotification:String = "UpdatingAlarmNotification"

class AlarmTableViewController: UITableViewController {
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    var selectedIndexPath = -1
    
    var animator: UIDynamicAnimator?
    var ChronoAlarms: [Alarm] = [Alarm]()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlarmTableViewController.addingNewAlarm(_:)), name: AddingNewAlarmNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlarmTableViewController.deletingAlarm(_:)), name: DeletingAlarmNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlarmTableViewController.updatingAlarm(_:)), name: UpdatingAlarmNotification, object: nil)
        
        animator = UIDynamicAnimator(referenceView: self.view)
        
        self.navigationController?.view.tintColor = UIColor(red: 0.93, green: 0.17, blue: 0.17, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.93, green: 0.17, blue: 0.17, alpha: 1.0)]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chronoAlarmCell = tableView.dequeueReusableCellWithIdentifier("alarmCell", forIndexPath: indexPath) as! AlarmTableCellView
        let chronoAlarm = ChronoAlarms[indexPath.row]
        if chronoAlarm.alarmMinute < 10 {
            chronoAlarmCell.alamTimeLabel.text = chronoAlarm.alarmHour.description + ":0" + chronoAlarm.alarmMinute.description
        } else {
            chronoAlarmCell.alamTimeLabel.text = chronoAlarm.alarmHour.description + ":" + chronoAlarm.alarmMinute.description
        }
        chronoAlarmCell.alarmOptionsLabel.text = chronoAlarm.alarmName
        chronoAlarmCell.cellAnimator = UIDynamicAnimator(referenceView: self.view)
        
        
        // Spring
        chronoAlarmCell.springNode = UIAttachmentBehavior(item: chronoAlarmCell , attachedToAnchor: CGPoint(x: (chronoAlarmCell.frame.width * 1.25) , y: (chronoAlarmCell.frame.origin.y + (chronoAlarmCell.frame.height/2))))
        chronoAlarmCell.springNode?.length = chronoAlarmCell.frame.width * (1.25/2)
        chronoAlarmCell.springNode?.frequency = 0.6
        chronoAlarmCell.cellAnimator?.addBehavior(chronoAlarmCell.springNode!)
        
        //Collision
        chronoAlarmCell.boundingBox = UICollisionBehavior(items: [chronoAlarmCell])
        chronoAlarmCell.boundingBox?.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), toPoint: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.boundingBox?.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), toPoint: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.boundingBox?.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height), toPoint: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.boundingBox?.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), toPoint: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y))
        chronoAlarmCell.cellAnimator?.addBehavior(chronoAlarmCell.boundingBox!)
        
        //Elasticity
        chronoAlarmCell.cellElasticity = UIDynamicItemBehavior(items: [chronoAlarmCell])
        chronoAlarmCell.cellElasticity?.elasticity = 0.125
        chronoAlarmCell.cellAnimator?.addBehavior(chronoAlarmCell.cellElasticity!)
        
        // Gesture
        let gesture = ChronoSwipeGesture.init(target: self, action: #selector(AlarmTableViewController.toggleAlarm(_:)))
        //gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        return chronoAlarmCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChronoAlarms.count
    }
    

    func addingNewAlarm(notification: NSNotification){
        let alarmDictionary = notification.userInfo!
        //print("received")
        var createdAlarm = Alarm(newMinute: Int(alarmDictionary["alarmMinute"] as! String)!, newHour: Int(alarmDictionary["alarmHour"] as! String)!, newName: alarmDictionary["alarmName"]as! String)
        //print("1st")
        let song = alarmDictionary["alarmSong"] as! MPMediaItem
        //print("2nd")
        let repeatDescriptions: [String] =  alarmDictionary["alarmRepeat"] as! [String]
        //print("3rd")
        if song.title != nil {
            createdAlarm.alarmSound = song
        }
        let repeats = repeatStringsToRepeatArray(repeatDescriptions)
        createdAlarm.setAlarmRepeat(repeats)
        print(createdAlarm.alarmRepeat)
        let notificationDate = createNotificationDate(Int(alarmDictionary["alarmHour"] as! String)!, alarmMinute: Int(alarmDictionary["alarmMinute"] as! String)!, alarmRepeats: repeats)
        
        // setup notification.
        let notification = UILocalNotification()
        notification.alertBody = createdAlarm.alarmName
        notification.alertTitle = "Alarm"
        notification.alertAction = "Close"
        notification.fireDate = notificationDate
        notification.soundName = UILocalNotificationDefaultSoundName
        
        //conenct notification
        createdAlarm.alarmNotification = notification
        //UIApplication.sharedApplication().scheduleLocalNotification(createdAlarm.alarmNotification!)
        
        print(createdAlarm.alarmHour.description + ": " + createdAlarm.alarmMinute.description)
        ChronoAlarms.append(createdAlarm)
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    func createNotificationDate(alarmHour: Int, alarmMinute: Int, alarmRepeats: [repeatType]) -> NSDate?{
        let cal = NSCalendar.currentCalendar()
        let calComponents = NSDateComponents()
        calComponents.hour = alarmHour
        calComponents.minute = alarmMinute
        calComponents.second = 0
        let returnDate = cal.dateFromComponents(calComponents)
        return returnDate
    }
    
    
    func deletingAlarm(notification: NSNotification){
        let removeDictionary = notification.userInfo!
        
        let indexToRemove = Int(removeDictionary["index"] as! String)!
        ChronoAlarms.removeAtIndex(indexToRemove)
        
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    
    
    func updatingAlarm(notification: NSNotification){
        let updateDictionary = notification.userInfo!
        
        let rowIndex = Int(updateDictionary["alarmIndex"] as! String)!
        ChronoAlarms[rowIndex].setAlarmHour(Int(updateDictionary["alarmHour"] as! String)!)
        ChronoAlarms[rowIndex].setAlarmMinute(Int(updateDictionary["alarmMinute"] as! String)!)
        ChronoAlarms[rowIndex].setAlarmName(updateDictionary["alarmHour"] as! String)
        ChronoAlarms[rowIndex].setAlarmSound(updateDictionary["alarmSound"] as! MPMediaItem)
        
        let repeatDescriptions: [String] =  updateDictionary["alarmRepeat"] as! [String]
        let repeats = repeatStringsToRepeatArray(repeatDescriptions)
        ChronoAlarms[rowIndex].setAlarmRepeat(repeats)
        
        
        let notificationDate = createNotificationDate(Int(updateDictionary["alarmHour"] as! String)!, alarmMinute: Int(updateDictionary["alarmMinute"] as! String)!, alarmRepeats: repeats)
        
        // setup notification.
        let notification = UILocalNotification()
        notification.alertBody = ChronoAlarms[rowIndex].alarmName
        notification.alertTitle = "Alarm"
        notification.alertAction = "Close"
        notification.fireDate = notificationDate
        notification.soundName = UILocalNotificationDefaultSoundName
        
        //connect notification
        ChronoAlarms[rowIndex].alarmNotification = notification
        //UIApplication.sharedApplication().scheduleLocalNotification(createdAlarm.alarmNotification!)
        
        let tableView = self.view as! UITableView
        tableView.reloadData()
        
    }
    
    func notificationRepeat(repeats: [repeatType]){
        if !repeats.contains(.Everyday) && !repeats.contains(.None) {
            for aRepeat in repeats {
                switch aRepeat {
                case .Monday:
                    break
                case .Tuesday:
                    break
                case .Wednesday:
                    break
                case .Thursday:
                    break
                case .Friday:
                    break
                case .Saturday:
                    break
                case .Sunday:
                    break
                default:
                    break
                }
            }
        }
    }
    func toggleAlarm(gestureRecognizer: ChronoSwipeGesture){
        if gestureRecognizer.state == .Began {
            let location = gestureRecognizer.locationInView(self.tableView)
            let indexPath = self.tableView.indexPathForRowAtPoint(location)
            if (indexPath?.row) != nil  {
                let swipedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AlarmTableCellView
            
                startAlarmToggleState(swipedCell, currentRow: (indexPath?.row)!)
            }
        }
        if gestureRecognizer.state == .Changed {
            let location = gestureRecognizer.locationInView(self.tableView)
            let indexPath = self.tableView.indexPathForRowAtPoint(location)
            if (indexPath?.row) != nil  {
                let swipedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AlarmTableCellView

                var positionDelta = gestureRecognizer.startPosition!.x - gestureRecognizer.storedPoint!.x
                print(positionDelta)
                if -positionDelta > 0 {
                    positionDelta = 0
                }
                swipedCell.frame.origin = CGPoint(x:  -positionDelta, y: swipedCell.frame.origin.y)
                changeAlarmToggleStress(swipedCell, currentRow: indexPath!.row, startPosition: gestureRecognizer.startPosition!.x, currentPosition: gestureRecognizer.storedPoint!.x)
            }
        }
        if gestureRecognizer.state == .Ended  {
            let location = gestureRecognizer.locationInView(self.tableView)
            let indexPath = self.tableView.indexPathForRowAtPoint(location)
            if (indexPath?.row) != nil  {
                let swipedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AlarmTableCellView
               
                //Swipe Push
                swipedCell.cellPush = UIPushBehavior(items: [swipedCell], mode: UIPushBehaviorMode.Instantaneous)
                swipedCell.cellPush?.pushDirection = CGVector(dx: gestureRecognizer.velocity!.dx, dy: 0.0) //used to be -30.0
                //print("active")
                //print(swipedCell.cellPush?.magnitude)
                swipedCell.cellAnimator?.addBehavior(swipedCell.cellPush!)
    
                changeAlarmToggleState(swipedCell, currentRow: (indexPath?.row)!)
                
            }
            //animator?.addBehavior(swipedCell.cellPush!)

        }
        
        if gestureRecognizer.state == .Failed || gestureRecognizer.state == .Cancelled {
            let location = gestureRecognizer.locationInView(self.tableView)
            let indexPath = self.tableView.indexPathForRowAtPoint(location)
            if (indexPath?.row) != nil  {
                selectedIndexPath = indexPath!.row
                print("segue")
                self.performSegueWithIdentifier("EditSegue", sender: self)
            }

        }
        
    }
    
    func startAlarmToggleState(interactedCell: AlarmTableCellView, currentRow: Int) -> Void {
        let alarmState = ChronoAlarms[currentRow].alarmState
        if alarmState == true { // Alarm State is on
            
        } else { // Alarm State is off
            
        }
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
    
    func changeAlarmToggleStress(interactedCell: AlarmTableCellView, currentRow: Int, startPosition: CGFloat, currentPosition: CGFloat) {
        //Get distance between anchor and current distance. Calculate tension. Change color based on tension.
        let cellviewEndPoint = interactedCell.frame.width * 1.25
        let cellviewMidPoint = interactedCell.frame.origin.x + (interactedCell.frame.width/2)
        let distance = sqrt((cellviewMidPoint - cellviewEndPoint)*(cellviewMidPoint - cellviewEndPoint))
        //print(distance * (interactedCell.springNode?.frequency)!)
        let springTension = distance * (interactedCell.springNode?.frequency)!
        print(springTension)
        //print((interactedCell.springNode?.frequency.description)! + " " + (interactedCell.springNode?.length.description)! )
        
        let adjustTension = springTension/400
        print(adjustTension)
        
        interactedCell.backgroundColor = UIColor(red: 0.93 , green: 0.17 , blue: 0.17 , alpha: 1.0 * adjustTension)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSegue" {
            let destination = segue.destinationViewController as! EditAlarmViewController
            //let tView = self.view as! UITableView
            let indexPath = selectedIndexPath
            let tappedAlarm = ChronoAlarms[indexPath]
            destination.alarmToEdit = tappedAlarm
            destination.editRow = indexPath
        }
    }
    
    
    @IBAction func goToSettings(sender: AnyObject) {
        if let chronoslideSettings = NSURL(string: UIApplicationOpenSettingsURLString){
            UIApplication.sharedApplication().openURL(chronoslideSettings)
        }
    }
    
    
}
/*
extension AlarmTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        print("Touched")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        if (indexPath?.row) != nil  {
            //let swipedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AlarmTableCellView
            selectedIndexPath = indexPath!.row
            
            //self.performSegueWithIdentifier("EditSegue", sender: self)
        }
        
        return !(touch.view is AlarmTableCellView)
    }
}
*/

class AlarmTableCellView: UITableViewCell {
    
    @IBOutlet weak var alamTimeLabel: UILabel!
    @IBOutlet weak var alarmOptionsLabel: UILabel!
    var springNode: UIAttachmentBehavior?
    var boundingBox: UICollisionBehavior?
    var cellElasticity: UIDynamicItemBehavior?
    var cellPush: UIPushBehavior?
    var cellAnimator: UIDynamicAnimator?
}


//MARK: - ADD
//MARK: ALARMS
let AddingSongNotification:String = "AddingSongNotification"
let AddingRepeatsNotification:String = "AddingRepeatsNotification"


class AddAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var alarmTimeTextField: UITextField!

    @IBOutlet weak var alarmAMPMSegmentedControl: UISegmentedControl!
    @IBOutlet weak var alarmNameTextField: UITextField!
    
    @IBOutlet weak var chooseToneButton: UIButton!
    @IBOutlet weak var alarmToneLabel: UILabel!
    
    
    @IBOutlet weak var alarmRepeatLabel: UILabel!
    @IBOutlet weak var chooseRepeatButton: UIButton!
    
    @IBOutlet weak var alarmRepeatTitleLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var timePicker = UIPickerView()
    var minutePicker = UIPickerView()
    
    var toolbar = UIToolbar()
    
    var hourData = [String]()
    var minuteData = [String]()
    
    var songData: MPMediaItem?
    var repeatData: [repeatType] = [.None]
    
    var currentTextField = UITextField()
    
    var hourValue: String = "00"
    var minuteValue: String = "00"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildArrays()
        
        timePicker.delegate = self
        minutePicker.delegate = self
        timePicker.dataSource = self
        minutePicker.dataSource = self
        alarmTimeTextField.inputView = timePicker
        scrollView.contentSize.height = 800
        
        
        toolbar = buildToolbar()
        alarmTimeTextField.inputAccessoryView = toolbar
        alarmNameTextField.inputAccessoryView = toolbar
        alarmTimeTextField.delegate = self
        alarmNameTextField.delegate = self
        

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddAlarmViewController.addSong(_:)), name: AddingSongNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddAlarmViewController.addRepeat(_:)), name: AddingRepeatsNotification, object: nil)
    }
    
    func buildToolbar() -> UIToolbar{
        let aToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.size.width)!  , height: 50))
        let previousButton = UIBarButtonItem(title: "Prev", style: UIBarButtonItemStyle.Done, target: self, action: #selector(AddAlarmViewController.prevButtonAction(_:)))
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: #selector(AddAlarmViewController.nextButtonAction(_:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done , target: self, action: #selector(AddAlarmViewController.doneButtonAction(_:)))
        let items = [previousButton, nextButton, spacer, doneButton]
        aToolbar.items = items
        
        //aToolbar.sizeToFit()
        return aToolbar
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //print("edit")
        self.currentTextField = textField
        
        switch currentTextField {
        case alarmTimeTextField:
            toolbar.items![0].enabled = false
            toolbar.items![1].enabled = true
            let scrollHeight = alarmTimeTextField.inputView?.frame.height
            let scrollViewFrame = self.scrollView.frame
            let tempHeight =  scrollViewFrame.height - scrollHeight!
            //set new Frame
            scrollView.contentOffset.y = 0
            print(tempHeight)
            break
        case alarmNameTextField:
            toolbar.items![0].enabled = true
            toolbar.items![1].enabled = false
            let scrollHeight = alarmTimeTextField.inputView?.frame.height
            let scrollViewFrame = self.scrollView.frame
            let tempHeight =  scrollViewFrame.height - scrollHeight!
            //set new Frame
            scrollView.contentOffset.y = tempHeight
            print(tempHeight)

            break
        default:
            break
        }
    }
    
    
    func doneButtonAction(sender: AnyObject){
        //print("done")
        
        currentTextField.resignFirstResponder()
    }
    
    func nextButtonAction(sender: AnyObject){
        //print("next")
        switch currentTextField {
        case alarmTimeTextField:
            alarmNameTextField.becomeFirstResponder()
            break
        case alarmNameTextField:
            break
        default:
            break
        }
    }
    func prevButtonAction(sender: AnyObject){
        //print("prev")
        switch currentTextField {
        case alarmTimeTextField:
            break
        case alarmNameTextField:
            alarmTimeTextField.becomeFirstResponder()
            break
        default:
            break
        }
    }
    
    func buildArrays(){
        for aNumber in 0..<60 {
            if aNumber < 10 {
                minuteData.append("0" + aNumber.description)
            } else {
            minuteData.append(aNumber.description)
            }
        }
        for aNumber2 in 1..<13 {
            hourData.append(aNumber2.description)
        }
    }
    
    @IBAction func commitNewAlarm(sender: AnyObject) {
        let selectedIndex = alarmAMPMSegmentedControl.selectedSegmentIndex
        print(alarmAMPMSegmentedControl.titleForSegmentAtIndex(selectedIndex)!)
        let repeatDescriptions = repeatArrayToStringArray(repeatData)
        let alarmDicationary = ["alarmHour": hourValue, "alarmMinute": minuteValue, "alarmName": alarmNameTextField.text!, "alarmAMPM": alarmAMPMSegmentedControl.titleForSegmentAtIndex(selectedIndex)!, "alarmSong": songData!, "alarmRepeat": repeatDescriptions] //Need to fix cast or make a wrapper for values.
        NSNotificationCenter.defaultCenter().postNotificationName(AddingNewAlarmNotification, object: self, userInfo: alarmDicationary as [NSObject : AnyObject])
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func testAlarm() -> Alarm{
        let temp = Alarm()
        return temp
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hourData.count
        } else {
            return minuteData.count
        }
        

    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timeStringBuild(hourData[row], minute: minuteValue)
        } else {
            timeStringBuild(hourValue, minute: minuteData[row])
        }

    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hourData[row]
        } else {
            return minuteData[row]
        }

    }
    
    
    func timeStringBuild(hour:String, minute:String){
        if hour == hourValue {
            alarmTimeTextField.text = hourValue + ":" + minute
            minuteValue = minute
        } else {
            alarmTimeTextField.text = hour + ":" + minuteValue
            hourValue = hour
        }
    }
    
    func addSong(notification: NSNotification){
        //print("received")
        let songDictionary = notification.userInfo!
        //print(songDictionary)
        let song = songDictionary["songItem"] as! MPMediaItem
        //print("get")
        songData = song
        alarmToneLabel.text = song.title
    }
    
    func addRepeat(notification: NSNotification){
        let repeatsDictionary = notification.userInfo!
        let repeatStrings = repeatsDictionary["repeats"] as! [String]
        let repeats:[repeatType] = repeatStringsToRepeatArray(repeatStrings)
        repeatData = repeats
        print(repeatData)
        determineRepeatLabel()
    }
    
    func determineRepeatLabel(){
        if repeatData.count > 1 {
            let labelString = RepeatDataManipulation.makeRepeatString(repeatData)
            alarmRepeatLabel.text = "Every " + labelString
        } else if repeatData[0] == .Everyday {
            alarmRepeatLabel.text = "Everyday"
        } else if repeatData.contains( .None) {
            alarmRepeatLabel.text = "No Repeat"
        } else {
            alarmRepeatLabel.text = "Every " + repeatData[0].description
        }
    }
    /*
    func buildRepeatString() -> String{
        var str = ""
        var index = 0
        if repeatData.count == 2 {
            str = repeatData[0].description + " & " + repeatData[1].description
            return str
        }
        if repeatData.contains(.None) {
            return "No Repeat"
        }
        if repeatData.count > 3 {
            for repeatItem in repeatData {
                if index == repeatData.count - 1 {
                    str = str + " " + repeatItem.minDescription
                } else {
                    str = str + " " + repeatItem.minDescription + ","
                }
                index = index + 1
            }
            return str
        }
        for repeatItem in repeatData {
            if index == repeatData.count - 1 {
                str = str + " " + repeatItem.description
            } else {
                str = str + " " + repeatItem.description + ","
            }
            index = index + 1
        }
        return str
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewRepeatSegue" {
            let dest = segue.destinationViewController as! AddAlarmRepeatTableViewController
            dest.selectedRepeats = repeatData
        }
    }
    
}





//MARK: SONGS

class AddSongsTableViewController: UITableViewController {
    let mediaLibrary: MPMediaLibrary = MPMediaLibrary.defaultMediaLibrary()
    var songArray:[MPMediaItem] = MPMediaQuery().items!
    let mediaPlayer: MPMusicPlayerController = MPMusicPlayerController()
    var filteredSongArray:[MPMediaItem] = [MPMediaItem]()
    let searchbarController = UISearchController(searchResultsController: nil)
    var selectedSong: MPMediaItem? = nil
    
    @IBOutlet var currentSongView: SelectedSongView!
    
    @IBOutlet var songsTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbarController.searchResultsUpdater = self
        searchbarController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchbarController.searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchbarController.searchBar.frame.size.height - 60), animated: false)
        
        //selectedCellView = SelectedSongView(frame: CGRect(origin: CGPointMake(0, 60) , size: CGSize(width: (self.navigationController?.view.frame.width)!, height: 100 )))
        
        
        //print(selectedCellView.selectedSongTitle.text)
        //self.navigationController?.view.addSubview(selectedCellView)
        
        self.navigationController?.view.addSubview(currentSongView)
        currentSongView.frame = CGRect(origin: CGPointMake(0, 62) , size: CGSize(width: (self.navigationController?.view.frame.width)! , height: 110 ))
        let visEffect = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visEffect.frame = CGRect(origin: CGPointMake(0, 0) , size: CGSize(width: (self.navigationController?.view.frame.width)!, height: 110 ))
        visEffect.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        currentSongView.addSubview(visEffect)
        currentSongView.sendSubviewToBack(visEffect)
        
        
        if selectedSong == nil {
            currentSongView.hidden = true
        }
        
        //self.view.addSubview(selectedCellView)
        //self.navigationController?.view.bringSubviewToFront(selectedCellView)
        
    }
    
    func filterSongs(searchString: String){
        //print(searchString)
        filteredSongArray = songArray.filter { song in
            return (song.title!.lowercaseString.containsString(searchString.lowercaseString))
        }
        tableView.reloadData()
    }
    
    func loadSongLibrary(){
        songArray = MPMediaQuery.songsQuery().items!
        //print(songArray.count)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddAlarmSongCell", forIndexPath: indexPath) as! AddSongTableCellView
        /*
        if searchbarController.active && searchbarController.searchBar.text != "" {
            cell.alarmSongTextLabel.text = filteredSongArray[indexPath.row].title!
            cell.alarmSongImageView.image = filteredSongArray[indexPath.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        } else {
            cell.alarmSongTextLabel.text = songArray[indexPath.row].title!
            cell.alarmSongImageView.image = songArray[indexPath.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        }
        cell.alarmSongImageView.userInteractionEnabled = true
        
        // Choose Song Gesture
        let chooseGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.chooseSong(_:)))
        self.view.addGestureRecognizer(chooseGesture)
        
        // Preview Song Gesutre
        let previewGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.togglePreview(_:)))
        cell.alarmSongImageView.addGestureRecognizer(previewGesture)
        */
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let songCell = cell as! AddSongTableCellView
        if searchbarController.active && searchbarController.searchBar.text != "" {
            songCell.alarmSongTextLabel.text = filteredSongArray[indexPath.row].title!
            songCell.alarmSongImageView.image = filteredSongArray[indexPath.row].artwork?.imageWithSize(songCell.alarmSongImageView.frame.size)
        } else {
            songCell.alarmSongTextLabel.text = songArray[indexPath.row].title!
            songCell.alarmSongImageView.image = songArray[indexPath.row].artwork?.imageWithSize(songCell.alarmSongImageView.frame.size)
        }
        songCell.alarmSongImageView.userInteractionEnabled = true
        
        // Choose Song Gesture
        let chooseGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.togglePreview(_:)))
        self.view.addGestureRecognizer(chooseGesture)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbarController.active && searchbarController.searchBar.text != "" {
            //print(filteredSongArray.count)
            return filteredSongArray.count
        }
        return songArray.count
    }
    
    
    
    func togglePreview(gestureRecognizer: UIGestureRecognizer){
        print("toggle Preview")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AddSongTableCellView
        
        //print(songArray[indexPath!.row].title)
        print(tappedCell)
        if searchbarController.active && searchbarController.searchBar.text != "" {
            previewSong(filteredSongArray[indexPath!.row])
            currentSongView.updateViewWithMediaItem(filteredSongArray[indexPath!.row])
            if selectedSong == nil {
                displaySelectedView()
            }
            selectedSong = filteredSongArray[indexPath!.row]
        } else {
            previewSong(songArray[indexPath!.row])
            currentSongView.updateViewWithMediaItem(songArray[indexPath!.row])
            if selectedSong == nil {
                displaySelectedView()
            }
            selectedSong = songArray[indexPath!.row]
            
        }
    }
    
    
    func chooseSong(gestureRecognizer: UIGestureRecognizer){
        print("Choose Song")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AddSongTableCellView
        print(songArray[indexPath!.row].albumTitle)
        print(tappedCell)
        var songDictionary:[String: MPMediaItem]
        if searchbarController.active && searchbarController.searchBar.text != "" {
            songDictionary = ["songItem": filteredSongArray[indexPath!.row]]
        } else {
            songDictionary = ["songItem": songArray[indexPath!.row]]
        }
        NSNotificationCenter.defaultCenter().postNotificationName(AddingSongNotification, object: self, userInfo: songDictionary)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func previewSong(songItem: MPMediaItem){
        
        if mediaPlayer.nowPlayingItem != nil{
            //print(mediaPlayer.nowPlayingItem?.title!)
            if mediaPlayer.nowPlayingItem! == songItem {
                if mediaPlayer.playbackState == .Playing {
                    mediaPlayer.pause()
                } else {
                    mediaPlayer.play()
                }
                
            } else {
                mediaPlayer.pause()
                let newQueue = MPMediaItemCollection(items: [songItem])
                mediaPlayer.setQueueWithItemCollection(newQueue)
                mediaPlayer.play()
            }
            
        }
        
        
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            currentSongView.removeFromSuperview()
        }
    }
    
    func displaySelectedView() -> Void {
        currentSongView.hidden = false
        //self.navigationController?.view.frame = CGRect(origin: (self.navigationController?.view.frame.origin)!, size: CGSize(width: (self.navigationController?.view.frame.width)!, height: 170))
        //let currentFrame = self.tableView.frame
        songsTableView.contentInset = UIEdgeInsets(top: 170, left: 0, bottom: 0, right: 0)
    }
    
    
    
    @IBAction func doneSongAction(sender: AnyObject) {
        let songDictionary:[String: MPMediaItem] = ["songItem": selectedSong!]
        NSNotificationCenter.defaultCenter().postNotificationName(AddingSongNotification, object: self, userInfo: songDictionary)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}

extension AddSongsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterSongs(searchController.searchBar.text!)
    }
}

class AddSongTableCellView: UITableViewCell {
    @IBOutlet weak var alarmSongTextLabel: UILabel!
    @IBOutlet weak var alarmSongImageView: UIImageView!
    
    var previewState: Bool = false
    
    
}

// MARK: REPEAT

class AddAlarmRepeatTableViewController: UITableViewController {
    
    @IBOutlet weak var repeatDoneButton: UIBarButtonItem!
    var selectedRepeats: [repeatType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatDoneButton.enabled = true
        print(selectedRepeats)
        //loadSelectedRepeats(self.tableView)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddAlarmRepeatCellView", forIndexPath: indexPath) as! AddRepeatTableCellView
        cell.repeatTypeLabel.text = RepeatMacros[indexPath.row].description
        if selectedRepeats.contains(RepeatMacros[indexPath.row]) {
            cell.isChecked = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatMacros.count
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! AddRepeatTableCellView
        selectedCell.selectionStyle = UITableViewCellSelectionStyle.None
        if selectedCell.accessoryType == UITableViewCellAccessoryType.None {
            calculateOtherRepeats(selectedCell, row: indexPath.row)
            //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.None
            //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        //self.tableView(tableView, willDeselectRowAtIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //self.tableView(tableView, didDeselectRowAtIndexPath: indexPath)
        return indexPath
    }
    
    func calculateOtherRepeats(tappedOption: AddRepeatTableCellView, row: Int){
        let tapped = RepeatMacros[row]
        switch (tapped) {
        case .None:
            selectedRepeats = [.None]
            clearTableView()
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            break
        case .Everyday:
            if selectedRepeats.count > 0 {
                clearTableView()
            }
            selectedRepeats = [.Everyday]
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            break
        default:
            if selectedRepeats.contains(repeatType.None) || selectedRepeats.contains(repeatType.Everyday) {
                clearTableView()
                selectedRepeats = [tapped]
            } else{
                selectedRepeats.append(tapped)
            }
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            let noneOption = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! AddRepeatTableCellView
            noneOption.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func clearTableView(){
        let view = self.tableView
        for anIndex in 0..<RepeatMacros.count  {
            //print(anIndex)
            let current =  view.cellForRowAtIndexPath(NSIndexPath(forRow: anIndex, inSection: 0)) as! AddRepeatTableCellView
            
            current.accessoryType = UITableViewCellAccessoryType.None
        }
        
    }
  
    
    @IBAction func commitRepeats(sender: AnyObject) {
        let sortedRepeats = sortRepeatArray(selectedRepeats)
        let temp = repeatArrayToStringArray(sortedRepeats)
        let repeatDictionary = ["repeats" as NSString: temp]
        NSNotificationCenter.defaultCenter().postNotificationName(AddingRepeatsNotification, object: self, userInfo: repeatDictionary)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

class AddRepeatTableCellView: UITableViewCell {
    @IBOutlet weak var repeatTypeLabel: UILabel!
    var isChecked: Bool = false
}





// MARK: - EDIT
// MARK: ALARMS

let UpdatingRepeatsNotification:String = "UpdatingRepeatsNotification"
let UpdatingSongNotification:String = "UpdatingSongNotification"


class EditAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var updateAlarmButton: UIBarButtonItem!
    
    @IBOutlet weak var alarmTimeTextField: UITextField!
    
    //@IBOutlet weak var hourTextField: UITextField!
    //@IBOutlet weak var minuteTextField: UITextField!
    
    @IBOutlet weak var alarmAMPMSegmentControl: UISegmentedControl!
    @IBOutlet weak var alarmNameLabel: UITextField!
    
    
    @IBOutlet weak var alarmSoundLabel: UILabel!
    
    @IBOutlet weak var alarmToneChooseButton: UIButton!
    
    @IBOutlet weak var alarmNameTextField: UITextField!
    //Load Alarm Data
    
    var alarmToEdit: Alarm = Alarm()
    var editRow: Int = -1
    
    var timePicker = UIPickerView()
    let minutePicker = UIPickerView()
    
    var toolbar = UIToolbar()
    
    var hourData = [String]()
    var minuteData = [String]()
    
    var currentTextField = UITextField()
    
    var hourValue = "00"
    var minuteValue = "00"
    
    @IBOutlet weak var SongSectionLabel: UILabel!
    @IBOutlet weak var alarmSongLabel: UILabel!
    @IBOutlet weak var chooseSongButton: UIButton!
    
    @IBOutlet weak var RepeatSectionLabel: UILabel!
    @IBOutlet weak var alarmRepeatLabel: UILabel!
    
    @IBOutlet weak var chooseRepeatButton: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildArrays()
        updateAlarmButton.enabled = false
        if alarmToEdit.alarmMinute < 10 {
            alarmTimeTextField.text = alarmToEdit.alarmHour.description + ":0" + alarmToEdit.alarmMinute.description
        } else {
            alarmTimeTextField.text = alarmToEdit.alarmHour.description + ":" + alarmToEdit.alarmMinute.description
        }
        alarmNameTextField.text = alarmToEdit.alarmName
        scrollView.contentSize.height = 800
        
        timePicker.delegate = self
        //minutePicker.delegate = self
        timePicker.dataSource = self
        //minutePicker.dataSource = self
        alarmTimeTextField.inputView = timePicker
        //minuteTextField.inputView = minutePicker
        
        if alarmToEdit.alarmSound != nil {
            alarmSongLabel.text = alarmToEdit.alarmSound?.title!
        } else {
            alarmSongLabel.text = "None"
        }
        
        
        toolbar = buildToolbar()
        alarmTimeTextField.inputAccessoryView = toolbar
        //minuteTextField.inputAccessoryView = toolbar
        alarmNameTextField.inputAccessoryView = toolbar
        alarmTimeTextField.delegate = self
        //minuteTextField.delegate = self
        alarmNameTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditAlarmViewController.updateRepeat(_:)), name: UpdatingRepeatsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditAlarmViewController.updateSong(_:)), name: UpdatingSongNotification, object: nil)
        print(alarmToEdit)
    }
    
    func buildToolbar() -> UIToolbar{
        let aToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.size.width)!  , height: 50))
        let previousButton = UIBarButtonItem(title: "Prev", style: UIBarButtonItemStyle.Done, target: self, action: #selector(AddAlarmViewController.prevButtonAction(_:)))
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: #selector(AddAlarmViewController.nextButtonAction(_:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done , target: self, action: #selector(AddAlarmViewController.doneButtonAction(_:)))
        let items = [previousButton, nextButton, spacer, doneButton]
        aToolbar.items = items
        
        //aToolbar.sizeToFit()
        return aToolbar
    }
    
    @IBAction func updateAlarm(sender: AnyObject) {
        let repeatDescriptions = repeatArrayToStringArray(alarmToEdit.alarmRepeat)
        let selectedIndex = alarmAMPMSegmentControl.selectedSegmentIndex
        let updateDictionary = ["alarmHour": hourValue, "alarmMinute": minuteValue, "alarmName": alarmNameTextField.text!, "alarmAMPM": alarmAMPMSegmentControl.titleForSegmentAtIndex(selectedIndex)!, "alarmSound": alarmToEdit.alarmSound!, "alarmIndex": editRow, "alarmRepeat": repeatDescriptions]
        NSNotificationCenter.defaultCenter().postNotificationName(UpdatingAlarmNotification, object: self, userInfo: updateDictionary)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //print("edit")
        self.currentTextField = textField
        
        switch currentTextField {
        case alarmTimeTextField:
            toolbar.items![0].enabled = false
            toolbar.items![1].enabled = true
            break
        case alarmNameTextField:
            toolbar.items![0].enabled = true
            toolbar.items![1].enabled = false
            break
        default:
            break
        }
    }
    
    func doneButtonAction(sender: AnyObject){
        //print("done")
        
        currentTextField.resignFirstResponder()
    }
    
    func nextButtonAction(sender: AnyObject){
        print("next")
        switch currentTextField {
        case alarmTimeTextField:
            alarmNameTextField.becomeFirstResponder()
            break
        case alarmNameTextField:
            break
        default:
            break
        }
    }
    func prevButtonAction(sender: AnyObject){
        print("prev")
        switch currentTextField {
        case alarmTimeTextField:
            break
        case alarmNameTextField:
            alarmTimeTextField.becomeFirstResponder()
            break
        default:
            break
        }
    }
    
    func buildArrays(){
        for aNumber in 0..<60 {
            if aNumber < 10 {
                minuteData.append("0" + aNumber.description)
            } else {
                minuteData.append(aNumber.description)
            }
        }
        for aNumber2 in 1..<13 {
            hourData.append(aNumber2.description)
        }
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hourData.count
        } else {
            return minuteData.count
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timeStringBuild(hourData[row], minute: minuteValue)
        } else {
            timeStringBuild(hourValue, minute: minuteData[row])
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hourData[row]
        } else {
            return minuteData[row]
        }
    }
    
    func timeStringBuild(hour:String, minute:String){
        if hour == hourValue {
            alarmTimeTextField.text = hourValue + ":" + minute
            minuteValue = minute
        } else {
            alarmTimeTextField.text = hour + ":" + minuteValue
            hourValue = hour
        }
    }
    
    @IBAction func removeAlarm(sender: AnyObject) {
        let dataDictionary = ["index": editRow.description]
        NSNotificationCenter.defaultCenter().postNotificationName(DeletingAlarmNotification, object: self, userInfo: dataDictionary as [NSObject : AnyObject])
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    @IBAction func chooseSong(sender: AnyObject) {
    }
    
    
    @IBOutlet weak var chooseRepeats: UIButton!
    
    func updateRepeat(notification: NSNotification){
        let repeatsDictionary = notification.userInfo!
        let repeatStrings = repeatsDictionary["repeats"] as! [String]
        var repeats:[repeatType] = [repeatType]()
        for aString in repeatStrings{
            switch aString {
            case "None":
                repeats.append(repeatType.None)
                break
            case "Monday":
                repeats.append(repeatType.Monday)
                break
            case "Tuesday":
                repeats.append(repeatType.Tuesday)
                break
            case "Wednesday":
                repeats.append(repeatType.Wednesday)
                break
            case "Thursday":
                repeats.append(repeatType.Thursday)
                break
            case "Friday":
                repeats.append(repeatType.Friday)
                break
            case "Saturday":
                repeats.append(repeatType.Saturday)
                break
            case "Sunday":
                repeats.append(repeatType.Sunday)
                break
            case "Everyday":
                repeats.append(repeatType.Everyday)
                break
            default:
                break
            }
        }
        alarmToEdit.alarmRepeat = repeats
        print(alarmToEdit.alarmRepeat)
        determineRepeatLabel()
    }
    
    func determineRepeatLabel(){
        if alarmToEdit.alarmRepeat.count > 1 {
            let labelString = RepeatDataManipulation.makeRepeatString(alarmToEdit.alarmRepeat)
            alarmRepeatLabel.text = "Every " + labelString
        } else if alarmToEdit.alarmRepeat[0] == .Everyday {
            alarmRepeatLabel.text = "Everyday"
        } else if alarmToEdit.alarmRepeat.contains( .None) {
          alarmRepeatLabel.text = "No Repeat"
        } else {
            alarmRepeatLabel.text = "Every " + alarmToEdit.alarmRepeat[0].description
        }
    }
    /*
    func buildRepeatString() -> String{
        var str = ""
        var index = 0
        if alarmToEdit.alarmRepeat.count == 2 {
            str = alarmToEdit.alarmRepeat[0].description + " & " + alarmToEdit.alarmRepeat[1].description
            return str
        }
        if alarmToEdit.alarmRepeat.count > 3 {
            for repeatItem in alarmToEdit.alarmRepeat {
                if index == alarmToEdit.alarmRepeat.count - 1 {
                    str = str + " " + repeatItem.minDescription
                } else {
                    str = str + " " + repeatItem.minDescription + ","
                }
                index = index + 1
            }
            return str
        }
        for repeatItem in alarmToEdit.alarmRepeat {
            if index == alarmToEdit.alarmRepeat.count - 1 {
                str = str + " " + repeatItem.description
            } else {
                str = str + " " + repeatItem.description + ","
            }
            index = index + 1
        }
        return str
    }
    */
    
    func updateSong(notification: NSNotification){
        //print("received")
        let songDictionary = notification.userInfo!
        //print(songDictionary)
        let song = songDictionary["songItem"] as! MPMediaItem
        //print("get")
        alarmToEdit.alarmSound = song
        alarmSongLabel.text = song.title
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditRepeatSegue" {
            let destController = segue.destinationViewController as! EditAlarmRepeatTableViewController
            destController.selectedRepeats = alarmToEdit.alarmRepeat
        } else if segue.identifier == "EditSongSegue" {
            let destController = segue.destinationViewController as! EditSongsTableViewController
            destController.chosenSong = alarmToEdit.alarmSound!
        }
    }
    
}




class EditSongsTableViewController: UITableViewController {
    let mediaLibrary: MPMediaLibrary = MPMediaLibrary.defaultMediaLibrary()
    var songArray:[MPMediaItem] = MPMediaQuery().items!
    let mediaPlayer: MPMusicPlayerController = MPMusicPlayerController()
    var chosenSong: MPMediaItem = MPMediaItem()
    var filteredSongArray:[MPMediaItem] = [MPMediaItem]()
    let searchbarController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbarController.searchResultsUpdater = self
        searchbarController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchbarController.searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchbarController.searchBar.frame.size.height), animated: false)
    }
    
    func filterSongs(searchString: String){
        //print(searchString)
        filteredSongArray = songArray.filter { song in
            return (song.title!.lowercaseString.containsString(searchString.lowercaseString))
        }
        tableView.reloadData()
    }
    
    func loadSongLibrary(){
        songArray = MPMediaQuery.songsQuery().items!
        print(songArray.count)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditAlarmSongCell", forIndexPath: indexPath) as! EditSongTableCellView
        
        if searchbarController.active && searchbarController.searchBar.text != "" {
            cell.alarmSongTextLabel.text = filteredSongArray[indexPath.row].title!
            cell.alarmSongImageView.image = filteredSongArray[indexPath.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        } else {
            cell.alarmSongTextLabel.text = songArray[indexPath.row].title!
            cell.alarmSongImageView.image = songArray[indexPath.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        }
        cell.alarmSongImageView.userInteractionEnabled = true
        
        // Choose Song Gesture
        let chooseGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.chooseSong(_:)))
        self.view.addGestureRecognizer(chooseGesture)
        
        // Preview Song Gesutre
        let previewGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.togglePreview(_:)))
        cell.alarmSongImageView.addGestureRecognizer(previewGesture)
        
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbarController.active && searchbarController.searchBar.text != "" {
            //print(filteredSongArray.count)
            return filteredSongArray.count
        }
        return songArray.count
    }
    
    func togglePreview(gestureRecognizer: UIGestureRecognizer){
        print("toggle Preview")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! EditSongTableCellView
        print(songArray[indexPath!.row].title)
        print(tappedCell)
        if searchbarController.active && searchbarController.searchBar.text != "" {
            previewSong(filteredSongArray[indexPath!.row])
        } else {
            previewSong(songArray[indexPath!.row])
        }
    }
    
    func chooseSong(gestureRecognizer: UIGestureRecognizer){
        print("Choose Song")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! EditSongTableCellView
        print(songArray[indexPath!.row].albumTitle)
        print(tappedCell)
        var songDictionary:[String: MPMediaItem]
        if searchbarController.active && searchbarController.searchBar.text != "" {
            songDictionary = ["songItem": filteredSongArray[indexPath!.row]]
        } else {
            songDictionary = ["songItem": songArray[indexPath!.row]]
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UpdatingSongNotification, object: self, userInfo: songDictionary)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func previewSong(songItem: MPMediaItem){
        
        if mediaPlayer.nowPlayingItem != nil{
            //print(mediaPlayer.nowPlayingItem?.title!)
            if mediaPlayer.nowPlayingItem! == songItem {
                if mediaPlayer.playbackState == .Playing {
                    mediaPlayer.pause()
                } else {
                    mediaPlayer.play()
                }
                
            } else {
                mediaPlayer.pause()
                let newQueue = MPMediaItemCollection(items: [songItem])
                mediaPlayer.setQueueWithItemCollection(newQueue)
                mediaPlayer.play()
            }
            
        }
        
        
    }
    
}

extension EditSongsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterSongs(searchController.searchBar.text!)
    }
}


class EditSongTableCellView: UITableViewCell {
    @IBOutlet weak var alarmSongTextLabel: UILabel!
    @IBOutlet weak var alarmSongImageView: UIImageView!
    
    var previewState: Bool = false
    
    
}



class EditAlarmRepeatTableViewController: UITableViewController {
    
    @IBOutlet weak var repeatDoneButton: UIBarButtonItem!
    var selectedRepeats: [repeatType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatDoneButton.enabled = true
        print(selectedRepeats)
        //loadRepeats()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditAlarmRepeatCellView", forIndexPath: indexPath) as! EditRepeatTableCellView
        cell.repeatTypeLabel.text = RepeatMacros[indexPath.row].description
        if selectedRepeats.contains(RepeatMacros[indexPath.row]) {
            cell.isChecked = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatMacros.count
    }
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! EditRepeatTableCellView
        selectedCell.selectionStyle = UITableViewCellSelectionStyle.None
        if selectedCell.accessoryType == UITableViewCellAccessoryType.None {
            calculateOtherRepeats(selectedCell, row: indexPath.row)
            //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.None
            //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        //self.tableView(tableView, willDeselectRowAtIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //self.tableView(tableView, didDeselectRowAtIndexPath: indexPath)
        return indexPath
    }
    
    
    func loadRepeats(){
        //for repeats found in selected repeats array remark them for the view.
        for aRepeat in selectedRepeats{
            switch (aRepeat) {
            case .None:
                addCheckmark(0)
                break
            case .Monday:
                addCheckmark(1)
                break
            case .Tuesday:
                addCheckmark(2)
                break
            case .Wednesday:
                addCheckmark(3)
                break
            case .Thursday:
                addCheckmark(4)
                break
            case .Friday:
                addCheckmark(5)
                break
            case .Saturday:
                addCheckmark(6)
                break
            case .Sunday:
                addCheckmark(7)
                break
            case .Everyday:
                addCheckmark(8)
                break
            }
        }
    }
    func addCheckmark(forIndex: Int){
        let indexPath = NSIndexPath(index: forIndex)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EditRepeatTableCellView
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    func calculateOtherRepeats(tappedOption: EditRepeatTableCellView, row: Int){
        let tapped = RepeatMacros[row]
        switch (tapped) {
        case .None:
            selectedRepeats = [.None]
            clearTableView()
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            break
        case .Everyday:
            if selectedRepeats.count > 0 {
                clearTableView()
            }
            selectedRepeats = [.Everyday]
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            break
        default:
            if selectedRepeats.contains(repeatType.None) || selectedRepeats.contains(repeatType.Everyday) {
                clearTableView()
                selectedRepeats = [tapped]
            } else{
                selectedRepeats.append(tapped)
            }
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            let noneOption = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! EditRepeatTableCellView
            noneOption.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func clearTableView(){
        let view = self.tableView
        for anIndex in 0..<RepeatMacros.count  {
            let current =  view.cellForRowAtIndexPath(NSIndexPath(forRow: anIndex, inSection: 0)) as! EditRepeatTableCellView
            current.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    
    @IBAction func commitRepeats(sender: AnyObject) {
        let sortedRepeats = sortRepeatArray(selectedRepeats)
        let temp = repeatArrayToStringArray(sortedRepeats)
        let repeatDictionary = ["repeats" as NSString: temp]
        NSNotificationCenter.defaultCenter().postNotificationName(UpdatingRepeatsNotification, object: self, userInfo: repeatDictionary )
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

class EditRepeatTableCellView: UITableViewCell {
    @IBOutlet weak var repeatTypeLabel: UILabel!
    var isChecked: Bool = false
    
    
}


public class RepeatDataManipulation {
       class func makeRepeatString(repeatData: [repeatType]) -> String {
        var str = ""
        var index = 0
        if repeatData.count == 2 {
            str = repeatData[0].description + " & " + repeatData[1].description
            return str
        }
        if repeatData.count > 3 {
            for repeatItem in repeatData {
                if index == repeatData.count - 1 {
                    str = str + " " + repeatItem.minDescription
                } else {
                    str = str + " " + repeatItem.minDescription + ","
                }
                index = index + 1
            }
            return str
        }
        for repeatItem in repeatData {
            if index == repeatData.count - 1 {
                str = str + " " + repeatItem.description
            } else {
                str = str + " " + repeatItem.description + ","
            }
            index = index + 1
        }
        return str
    }
}

public class SongDataManipulation {
    class func makeDurationString(song: MPMediaItem) -> String{
        var returnString = ""
        print(song.playbackDuration)
        let mins = Int(song.playbackDuration/60)
        print(mins)
        //let leftOver = song.playbackDuration - mins*60
        let secs = Int(song.playbackDuration%60)
        if secs < 10 {
            returnString = mins.description + ":0" + secs.description
        } else {
            returnString = mins.description + ":" + secs.description
        }
        return returnString
    }
}
