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

// MARK: - ALARMS

let AddingNewAlarmNotification:String = "AddingNewAlarmNotification"
let DeletingAlarmNotification:String = "DeletingAlarmNotification"
let UpdatingAlarmNotification:String = "UpdatingAlarmNotification"

class AlarmTableViewController: UITableViewController {
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    
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
        let gesture = UISwipeGestureRecognizer.init(target: self, action: #selector(AlarmTableViewController.toggleAlarm(_:)))
        gesture.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(gesture)
        return chronoAlarmCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChronoAlarms.count
    }
    
    //TODO: Fix up adding

    func addingNewAlarm(notification: NSNotification){
        let alarmDictionary = notification.userInfo!
        print("received")
        var createdAlarm = Alarm(newMinute: Int(alarmDictionary["alarmMinute"] as! String)!, newHour: Int(alarmDictionary["alarmHour"] as! String)!, newName: alarmDictionary["alarmName"]as! String)
        let song = alarmDictionary["songItem"] as! MPMediaItem
        let repeatDescriptions: [String] =  alarmDictionary["repeats"] as! [String]
        if song.title != nil {
            createdAlarm.alarmSound = song
        }
        var repeats = [repeatType]()
        for aString in repeatDescriptions{
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
        
        createdAlarm.setAlarmRepeat(repeats)
        
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
        
        let rowIndex = Int(updateDictionary["index"] as! String)!
        ChronoAlarms[rowIndex].setAlarmHour(Int(updateDictionary["alarmHour"] as! String)!)
        ChronoAlarms[rowIndex].setAlarmMinute(Int(updateDictionary["alarmMinute"] as! String)!)
        ChronoAlarms[rowIndex].setAlarmName(updateDictionary["alarmHour"] as! String)
        
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSegue" {
            let destination = segue.destinationViewController as! EditAlarmViewController
            let tView = self.view as! UITableView
            let indexPath = tView.indexPathForSelectedRow!
            let tappedAlarm = ChronoAlarms[indexPath.row]
            destination.alarmToEdit = tappedAlarm
            destination.editRow = indexPath.row
        }
    }
    
    
    @IBAction func goToSettings(sender: AnyObject) {
        if let chronoslideSettings = NSURL(string: UIApplicationOpenSettingsURLString){
            UIApplication.sharedApplication().openURL(chronoslideSettings)
        }
    }
    
    
}

//MARK: - ADD ALARMS

let AddingSongNotification:String = "AddingSongNotification"
let AddingRepeatsNotification:String = "AddingRepeatsNotification"


class AddAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var alarmAMPMSegmentedControl: UISegmentedControl!
    @IBOutlet weak var alarmNameTextField: UITextField!
    
    @IBOutlet weak var chooseToneButton: UIButton!
    @IBOutlet weak var alarmToneLabel: UILabel!
    
    
    @IBOutlet weak var alarmRepeatLabel: UILabel!
    @IBOutlet weak var chooseRepeatButton: UIButton!
    
    @IBOutlet weak var alarmRepeatTitleLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var hourPicker = UIPickerView()
    var minutePicker = UIPickerView()
    
    var toolbar = UIToolbar()
    
    var hourData = [String]()
    var minuteData = [String]()
    
    var songData: MPMediaItem?
    var repeatData: [repeatType] = [.None]
    
    var currentTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildArrays()
        
        hourPicker.delegate = self
        minutePicker.delegate = self
        hourPicker.dataSource = self
        minutePicker.dataSource = self
        hourTextField.inputView = hourPicker
        minuteTextField.inputView = minutePicker
        scrollView.contentSize.height = 800
        
        
        toolbar = buildToolbar()
        hourTextField.inputAccessoryView = toolbar
        minuteTextField.inputAccessoryView = toolbar
        alarmNameTextField.inputAccessoryView = toolbar
        hourTextField.delegate = self
        minuteTextField.delegate = self
        alarmNameTextField.delegate = self
        
        
        //alarmRepeatLabel.hidden = true
        //alarmRepeatTitleLabel.hidden = true
        //chooseRepeatButton.hidden = true
        
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
        case hourTextField:
            toolbar.items![0].enabled = false
            toolbar.items![1].enabled = true
            break
        case minuteTextField:
            toolbar.items![0].enabled = true
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
    
    
    //TODO: InputAccessoryView Button actions
    
    func doneButtonAction(sender: AnyObject){
        //print("done")
        
        currentTextField.resignFirstResponder()
    }
    
    func nextButtonAction(sender: AnyObject){
        print("next")
        switch currentTextField {
        case hourTextField:
            minuteTextField.becomeFirstResponder()
            break
        case minuteTextField:
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
        case hourTextField:
            break
        case minuteTextField:
            hourTextField.becomeFirstResponder()
            break
        case alarmNameTextField:
            minuteTextField.becomeFirstResponder()
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
        var repeatDescriptions: [String] = [String]()
        for aRepeat in repeatData {
            repeatDescriptions.append(aRepeat.description)
        }
        let alarmDicationary = ["alarmHour": hourTextField.text!, "alarmMinute": minuteTextField.text!, "alarmName": "test alarm", "alarmAMPM": alarmAMPMSegmentedControl.titleForSegmentAtIndex(selectedIndex)!, "alarmSong": songData!, "alarmRepeat": repeatDescriptions] //Need to fix cast or make a wrapper for values.
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
            hourTextField.text = hourData[row]
        } else {
            minuteTextField.text = minuteData[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == hourPicker{
            return hourData[row]
        } else {
            return minuteData[row]
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
        repeatData = repeats
        print(repeatData)
        determineRepeatLabel()
    }
    
    func determineRepeatLabel(){
        if repeatData.count > 1 {
            let labelString = buildRepeatString()
            alarmRepeatLabel.text = "Every " + labelString
        } else if repeatData[0] == .Everyday {
            alarmRepeatLabel.text = "Everyday"
        } else {
            alarmRepeatLabel.text = "Every " + repeatData[0].description
        }
    }
    
    func buildRepeatString() -> String{
        var str = ""
        var index = 0
        if repeatData.count == 2 {
            str = repeatData[0].description + " & " + repeatData[1].description
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


class AlarmTableCellView: UITableViewCell {
    
    @IBOutlet weak var alamTimeLabel: UILabel!
    @IBOutlet weak var alarmOptionsLabel: UILabel!
    var springNode: UIAttachmentBehavior?
    var boundingBox: UICollisionBehavior?
    var cellElasticity: UIDynamicItemBehavior?
    var cellPush: UIPushBehavior?
    var cellAnimator: UIDynamicAnimator?
}



class AddSongsTableViewController: UITableViewController {
    let mediaLibrary: MPMediaLibrary = MPMediaLibrary.defaultMediaLibrary()
    var songArray:[MPMediaItem] = [MPMediaItem]()
    let mediaPlayer: MPMusicPlayerController = MPMusicPlayerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSongLibrary()
    }
    
    func loadSongLibrary(){
        songArray = MPMediaQuery.songsQuery().items!
        print(songArray.count)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddAlarmSongCell", forIndexPath: indexPath) as! AddSongTableCellView
        cell.alarmSongTextLabel.text = songArray[indexPath.row].title!
        cell.alarmSongImageView.image = songArray[indexPath.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
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
        return songArray.count
    }
    
    func togglePreview(gestureRecognizer: UIGestureRecognizer){
        print("toggle Preview")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AddSongTableCellView
        print(songArray[indexPath!.row].title)
        print(tappedCell)
        previewSong(songArray[indexPath!.row])
    }
    
    func chooseSong(gestureRecognizer: UIGestureRecognizer){
        print("Choose Song")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AddSongTableCellView
        print(songArray[indexPath!.row].albumTitle)
        print(tappedCell)
        let songDictionary = ["songItem": songArray[indexPath!.row]]
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
    
}

class AddSongTableCellView: UITableViewCell {
    @IBOutlet weak var alarmSongTextLabel: UILabel!
    @IBOutlet weak var alarmSongImageView: UIImageView!
    
    var previewState: Bool = false
    
    
}

class AddAlarmRepeatTableViewController: UITableViewController {
    
    @IBOutlet weak var repeatDoneButton: UIBarButtonItem!
    var selectedRepeats: [repeatType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatDoneButton.enabled = true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddAlarmRepeatCellView", forIndexPath: indexPath) as! AddRepeatTableCellView
        cell.repeatTypeLabel.text = RepeatMacros[indexPath.row].description
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatMacros.count
    }
/*
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! AddRepeatTableCellView
        if selectedCell.accessoryType == UITableViewCellAccessoryType.None {
            calculateOtherRepeats(selectedCell, row: indexPath.row)
            //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.None
            //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        self.tableView(tableView, willDeselectRowAtIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView(tableView, didDeselectRowAtIndexPath: indexPath)
        self.tableView.reloadData()
    }
  */  
    
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
    // TODO: - SORT REPEATS
    @IBAction func commitRepeats(sender: AnyObject) {
        
        let temp: NSMutableArray = NSMutableArray()
        for aRepeat in selectedRepeats{
            temp.addObject(aRepeat.description)
        }
        let repeatDictionary = ["repeats" as NSString: temp]
        NSNotificationCenter.defaultCenter().postNotificationName(AddingRepeatsNotification, object: self, userInfo: repeatDictionary)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}

class AddRepeatTableCellView: UITableViewCell {
    @IBOutlet weak var repeatTypeLabel: UILabel!
    var isChecked: Bool = false
}





// MARK: - EDIT ALARMS

let UpdatingRepeatsNotification:String = "UpdatingRepeatsNotification"
let UpdatingSongNotification:String = "UpdatingSongNotification"


class EditAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var updateAlarmButton: UIBarButtonItem!
    
    
    @IBOutlet weak var hourTextLabel: UITextField!
    @IBOutlet weak var minuteTextLabel: UITextField!
    
    @IBOutlet weak var alarmAMPMSegmentControl: UISegmentedControl!
    @IBOutlet weak var alarmNameLabel: UITextField!
    
    
    @IBOutlet weak var alarmSoundLabel: UILabel!
    
    @IBOutlet weak var alarmToneChooseButton: UIButton!
    
    //Load Alarm Data
    
    var alarmToEdit: Alarm = Alarm()
    var editRow: Int = -1
    
    let hourPicker = UIPickerView()
    let minutePicker = UIPickerView()
    
    let toolbar = UIToolbar()
    
    var hourData = [String]()
    var minuteData = [String]()
    
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
        hourTextLabel.text = alarmToEdit.alarmHour.description
        minuteTextLabel.text = alarmToEdit.alarmMinute.description
        scrollView.contentSize.height = 800
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditAlarmViewController.updateRepeat(_:)), name: UpdatingRepeatsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditAlarmViewController.updateSong(_:)), name: UpdatingSongNotification, object: nil)
        
    }
    
    @IBAction func updateAlarm(sender: AnyObject) {
        let updateDictionary = ["alarmHour": hourTextLabel.text!, "alarmMinute": minuteTextLabel.text!, "alarmName": alarmNameLabel.text!, "alarmAMPM": alarmAMPMSegmentControl.description, "alarmSound": alarmToEdit.alarmSound!]
        NSNotificationCenter.defaultCenter().postNotificationName(UpdatingAlarmNotification, object: self, userInfo: updateDictionary)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    @IBAction func removeAlarm(sender: AnyObject) {
        let dataDictionary = ["index": editRow.description]
        NSNotificationCenter.defaultCenter().postNotificationName(DeletingAlarmNotification, object: self, userInfo: dataDictionary as [NSObject : AnyObject])
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    @IBAction func chooseSong(sender: AnyObject) {
    }
    
    
    @IBOutlet weak var chooseRepeats: UIButton!
    
    func updateRepeat(notification: NSNotification){
        
    }
    
    func updateSong(notification: NSNotification){
        
    }
    
}




class EditSongsTableViewController: UITableViewController {
    let mediaLibrary: MPMediaLibrary = MPMediaLibrary.defaultMediaLibrary()
    var songArray:[MPMediaItem] = [MPMediaItem]()
    let mediaPlayer: MPMusicPlayerController = MPMusicPlayerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSongLibrary()
    }
    
    func loadSongLibrary(){
        songArray = MPMediaQuery.songsQuery().items!
        print(songArray.count)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditAlarmSongCell", forIndexPath: indexPath) as! EditSongTableCellView
        cell.alarmSongTextLabel.text = songArray[indexPath.row].title!
        cell.alarmSongImageView.image = songArray[indexPath.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        cell.alarmSongImageView.userInteractionEnabled = true
        
        // Choose Song Gesture
        let chooseGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.chooseSong(_:)))
        self.view.addGestureRecognizer(chooseGesture)
        
        // Previe wSong Gesutre
        let previewGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.togglePreview(_:)))
        cell.alarmSongImageView.addGestureRecognizer(previewGesture)
        
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArray.count
    }
    
    func togglePreview(gestureRecognizer: UIGestureRecognizer){
        print("toggle Preview")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! EditSongTableCellView
        print(songArray[indexPath!.row].title)
        print(tappedCell)
        previewSong(songArray[indexPath!.row])
    }
    
    func chooseSong(gestureRecognizer: UIGestureRecognizer){
        print("Choose Song")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! EditSongTableCellView
        print(songArray[indexPath!.row].albumTitle)
        print(tappedCell)
        let songDictionary = ["songItem": songArray[indexPath!.row]]
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
        loadRepeats()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditAlarmRepeatCellView", forIndexPath: indexPath) as! EditRepeatTableCellView
        cell.repeatTypeLabel.text = RepeatMacros[indexPath.row].description
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatMacros.count
    }
    
    /*
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! EditRepeatTableCellView
        if selectedCell.accessoryType == UITableViewCellAccessoryType.None {
            calculateOtherRepeats(selectedCell, row: indexPath.row)
        } else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
 */
    
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
                addCheckmarck(0)
                break
            case .Monday:
                addCheckmarck(1)
                break
            case .Tuesday:
                addCheckmarck(2)
                break
            case .Wednesday:
                addCheckmarck(3)
                break
            case .Thursday:
                addCheckmarck(4)
                break
            case .Friday:
                addCheckmarck(5)
                break
            case .Saturday:
                addCheckmarck(6)
                break
            case .Sunday:
                addCheckmarck(7)
                break
            case .Everyday:
                addCheckmarck(8)
                break
            }
        }
    }
    func addCheckmarck(forIndex: Int){
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
        let temp: NSMutableArray = NSMutableArray()
        for aRepeat in selectedRepeats{
            temp.addObject(aRepeat.description)
        }
        let repeatDictionary = ["repeats" as NSString: temp]
        NSNotificationCenter.defaultCenter().postNotificationName(UpdatingRepeatsNotification, object: self, userInfo: repeatDictionary )
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}

class EditRepeatTableCellView: UITableViewCell {
    @IBOutlet weak var repeatTypeLabel: UILabel!
    var isChecked: Bool = false
    
    
}



