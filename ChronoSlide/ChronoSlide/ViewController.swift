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
let DeletingAlarmNotification:String = "DeletingAlarmNotification"
let UpdatingAlarmNotification:String = "UpdatingAlarmNotification"
let RepeatMacros = [repeatType.None, repeatType.Monday, repeatType.Tuesday, repeatType.Wednesday, repeatType.Thursday, repeatType.Friday, repeatType.Saturday, repeatType.Sunday, repeatType.Everyday, repeatType.Weekly, repeatType.Monthly]


class AlarmTableViewController: UITableViewController {
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    
    var animator: UIDynamicAnimator?
    var ChronoAlarms: [Alarm] = [Alarm]()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addingNewAlarm:", name: AddingNewAlarmNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deletingAlarm:", name: DeletingAlarmNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatingAlarm", name: UpdatingAlarmNotification, object: nil)
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
        
        var createdAlarm = Alarm(newMinute: Int(alarmDictionary["alarmMinute"] as! String)!, newHour: Int(alarmDictionary["alarmHour"] as! String)!, newName: alarmDictionary["alarmName"]as! String)
        let song = alarmDictionary["songItem"] as! MPMediaItem
        if song.title != nil {
            createdAlarm.alarmSound = song
        }
        print(createdAlarm.alarmHour.description + ": " + createdAlarm.alarmMinute.description)
        ChronoAlarms.append(createdAlarm)
        let tableView = self.view as! UITableView
        tableView.reloadData()
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

let AddingSongNotification:String = "AddingSongNotification"


class NewAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var hourTextLabel: UITextField!
    @IBOutlet weak var minuteTextLabel: UITextField!
    @IBOutlet weak var alarmAMPMSegmentedControl: UISegmentedControl!
    @IBOutlet weak var alarmNameTextField: UITextField!
    
    @IBOutlet weak var chooseToneButton: UIButton!
    @IBOutlet weak var alarmToneLabel: UILabel!
    
    
    @IBOutlet weak var alarmRepeatLabel: UILabel!
    @IBOutlet weak var chooseRepeatButton: UIButton!
    
    @IBOutlet weak var alarmRepeatTitleLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let hourPicker = UIPickerView()
    let minutePicker = UIPickerView()
    
    let toolbar = UIToolbar()
    
    var hourData = [String]()
    var minuteData = [String]()
    
    var songData: MPMediaItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildArrays()
        
        hourPicker.delegate = self
        minutePicker.delegate = self
        hourPicker.dataSource = self
        minutePicker.dataSource = self
        hourTextLabel.inputView = hourPicker
        minuteTextLabel.inputView = minutePicker
        scrollView.contentSize.height = 800
        
        alarmRepeatLabel.hidden = true
        alarmRepeatTitleLabel.hidden = true
        chooseRepeatButton.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addSong:", name: AddingSongNotification, object: nil)
        
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
        print(alarmAMPMSegmentedControl.description)
        
        let alarmDicationary = ["alarmHour": hourTextLabel.text!, "alarmMinute": minuteTextLabel.text!, "alarmName": "test alarm", "alarmAMPM": alarmAMPMSegmentedControl.description, "alarmSong": songData!] //Need to fix cast or make a wrapper for values.
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
    
    func addSong(notification: NSNotification){
        let songDictionary = notification.userInfo!
        print(songDictionary)
        let song = songDictionary["songitem"] as! MPMediaItem
        songData = song
        alarmToneLabel.text = song.title
    }
    
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildArrays()
        updateAlarmButton.enabled = false
        hourTextLabel.text = alarmToEdit.alarmHour.description
        minuteTextLabel.text = alarmToEdit.alarmMinute.description
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



class SongsTableViewController: UITableViewController {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("AlarmSongCell", forIndexPath: indexPath) as! SongTableCellView
        cell.alarmSongTextLabel.text = songArray[indexPath.row].title!
        cell.alarmSongImageView.image = songArray[indexPath.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        cell.alarmSongImageView.userInteractionEnabled = true
        
        // Choose Song Gesture
        let chooseGesture = UITapGestureRecognizer.init(target: self, action: "chooseSong:")
        self.view.addGestureRecognizer(chooseGesture)
        
        // Previe wSong Gesutre
        let previewGesture = UITapGestureRecognizer.init(target: self, action: "togglePreview:")
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
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! SongTableCellView
        print(songArray[indexPath!.row].title)
        print(tappedCell)
        previewSong(songArray[indexPath!.row])
    }
    
    func chooseSong(gestureRecognizer: UIGestureRecognizer){
        print("Choose Song")
        let location = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! SongTableCellView
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

class SongTableCellView: UITableViewCell {
    @IBOutlet weak var alarmSongTextLabel: UILabel!
    @IBOutlet weak var alarmSongImageView: UIImageView!
    
    var previewState: Bool = false
    
    
}

class AlarmRepeatTableViewController: UITableViewController {
    
    @IBOutlet weak var repeatDoneButton: UIBarButtonItem!
    var selectedRepeats: [repeatType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatDoneButton.enabled = false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as! RepeatTableCellView
        cell.repeatTypeLabel.text = RepeatMacros[indexPath.row].description
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatMacros.count
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! RepeatTableCellView
        if selectedCell.accessoryType == UITableViewCellAccessoryType.None {
            calculateOtherRepeats(selectedCell, row: indexPath.row)
        } else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func calculateOtherRepeats(tappedOption: RepeatTableCellView, row: Int){
        let tapped = RepeatMacros[row]
        switch (tapped) {
        case .None:
            selectedRepeats = [.None]
            
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            break
        case .Weekly:
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
            break
        case .Monthly:
            break
        case .Everyday:
            break
        default:
            if selectedRepeats.contains(repeatType.Monthly) || selectedRepeats.contains(repeatType.Weekly) {
                
            }
            tappedOption.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }
    
    
}

class RepeatTableCellView: UITableViewCell {
    @IBOutlet weak var repeatTypeLabel: UILabel!
    var isChecked: Bool = false
    
  
    
    
}

