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


let RepeatMacros = [repeatType.none, repeatType.monday, repeatType.tuesday, repeatType.wednesday, repeatType.thursday, repeatType.friday, repeatType.saturday, repeatType.sunday, repeatType.everyday]

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
        UIApplication.shared().registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        NotificationCenter.default().addObserver(self, selector: #selector(AlarmTableViewController.addingNewAlarm(_:)), name: AddingNewAlarmNotification, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(AlarmTableViewController.deletingAlarm(_:)), name: DeletingAlarmNotification, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(AlarmTableViewController.updatingAlarm(_:)), name: UpdatingAlarmNotification, object: nil)
        
        animator = UIDynamicAnimator(referenceView: self.view)
        
        self.navigationController?.view.tintColor = UIColor(red: 0.93, green: 0.17, blue: 0.17, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.93, green: 0.17, blue: 0.17, alpha: 1.0)]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chronoAlarmCell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmTableCellView
        let chronoAlarm = ChronoAlarms[(indexPath as NSIndexPath).row]
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
        chronoAlarmCell.boundingBox?.addBoundary(withIdentifier: "right", from: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), to: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.boundingBox?.addBoundary(withIdentifier: "left", from: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), to: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.boundingBox?.addBoundary(withIdentifier: "bottom", from: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height), to: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y + chronoAlarmCell.frame.size.height))
        chronoAlarmCell.boundingBox?.addBoundary(withIdentifier: "top", from: CGPoint(x: -chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y), to: CGPoint(x: chronoAlarmCell.frame.size.width, y: chronoAlarmCell.frame.origin.y))
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChronoAlarms.count
    }
    

    func addingNewAlarm(_ notification: Notification){
        let alarmDictionary = (notification as NSNotification).userInfo!
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
    
    func createNotificationDate(_ alarmHour: Int, alarmMinute: Int, alarmRepeats: [repeatType]) -> Date?{
        let cal = Calendar.current()
        var calComponents = DateComponents()
        calComponents.hour = alarmHour
        calComponents.minute = alarmMinute
        calComponents.second = 0
        let returnDate = cal.date(from: calComponents)
        return returnDate
    }
    
    
    func deletingAlarm(_ notification: Notification){
        let removeDictionary = (notification as NSNotification).userInfo!
        
        let indexToRemove = Int(removeDictionary["index"] as! String)!
        ChronoAlarms.remove(at: indexToRemove)
        
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    
    
    func updatingAlarm(_ notification: Notification){
        let updateDictionary = (notification as NSNotification).userInfo!
        
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
    
    func notificationRepeat(_ repeats: [repeatType]){
        if !repeats.contains(.everyday) && !repeats.contains(.none) {
            for aRepeat in repeats {
                switch aRepeat {
                case .monday:
                    break
                case .tuesday:
                    break
                case .wednesday:
                    break
                case .thursday:
                    break
                case .friday:
                    break
                case .saturday:
                    break
                case .sunday:
                    break
                default:
                    break
                }
            }
        }
    }
    func toggleAlarm(_ gestureRecognizer: ChronoSwipeGesture){
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: location)
            if ((indexPath as NSIndexPath?)?.row) != nil  {
                let swipedCell = self.tableView.cellForRow(at: indexPath!) as! AlarmTableCellView
            
                startAlarmToggleState(swipedCell, currentRow: ((indexPath as NSIndexPath?)?.row)!)
            }
        }
        if gestureRecognizer.state == .changed {
            let location = gestureRecognizer.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: location)
            if ((indexPath as NSIndexPath?)?.row) != nil  {
                let swipedCell = self.tableView.cellForRow(at: indexPath!) as! AlarmTableCellView

                var positionDelta = gestureRecognizer.startPosition!.x - gestureRecognizer.storedPoint!.x
                print(positionDelta)
                if -positionDelta > 0 {
                    positionDelta = 0
                }
                swipedCell.frame.origin = CGPoint(x:  -positionDelta, y: swipedCell.frame.origin.y)
                changeAlarmToggleStress(swipedCell, currentRow: (indexPath! as NSIndexPath).row, startPosition: gestureRecognizer.startPosition!.x, currentPosition: gestureRecognizer.storedPoint!.x)
            }
        }
        if gestureRecognizer.state == .ended  {
            let location = gestureRecognizer.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: location)
            if ((indexPath as NSIndexPath?)?.row) != nil  {
                let swipedCell = self.tableView.cellForRow(at: indexPath!) as! AlarmTableCellView
               
                //Swipe Push
                swipedCell.cellPush = UIPushBehavior(items: [swipedCell], mode: UIPushBehaviorMode.instantaneous)
                swipedCell.cellPush?.pushDirection = CGVector(dx: gestureRecognizer.velocity!.dx, dy: 0.0) //used to be -30.0
                //print("active")
                //print(swipedCell.cellPush?.magnitude)
                swipedCell.cellAnimator?.addBehavior(swipedCell.cellPush!)
    
                changeAlarmToggleState(swipedCell, currentRow: ((indexPath as NSIndexPath?)?.row)!)
                
            }
            //animator?.addBehavior(swipedCell.cellPush!)

        }
        
        if gestureRecognizer.state == .failed || gestureRecognizer.state == .cancelled {
            let location = gestureRecognizer.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: location)
            if ((indexPath as NSIndexPath?)?.row) != nil  {
                selectedIndexPath = (indexPath! as NSIndexPath).row
                print("segue")
                self.performSegue(withIdentifier: "EditSegue", sender: self)
            }

        }
        
    }
    
    func startAlarmToggleState(_ interactedCell: AlarmTableCellView, currentRow: Int) -> Void {
        let alarmState = ChronoAlarms[currentRow].alarmState
        if alarmState == true { // Alarm State is on
            
        } else { // Alarm State is off
            
        }
    }
    
    func changeAlarmToggleState(_ interactedCell: AlarmTableCellView, currentRow: Int){
        UIView.animate(withDuration: 0.6, delay: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
            if self.ChronoAlarms[currentRow].alarmState {
                interactedCell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            } else {
                interactedCell.backgroundColor = UIColor(red: 0.93, green: 0.17, blue: 0.17, alpha: 1.0)
            }

            }, completion: nil)
             ChronoAlarms[currentRow].setAlarmState(!ChronoAlarms[currentRow].alarmState)
        
    }
    
    func changeAlarmToggleStress(_ interactedCell: AlarmTableCellView, currentRow: Int, startPosition: CGFloat, currentPosition: CGFloat) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSegue" {
            let destination = segue.destinationViewController as! EditAlarmViewController
            //let tView = self.view as! UITableView
            let indexPath = selectedIndexPath
            let tappedAlarm = ChronoAlarms[indexPath]
            destination.alarmToEdit = tappedAlarm
            destination.editRow = indexPath
        }
    }
    
    
    @IBAction func goToSettings(_ sender: AnyObject) {
        if let chronoslideSettings = URL(string: UIApplicationOpenSettingsURLString){
            UIApplication.shared().openURL(chronoslideSettings)
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
    var repeatData: [repeatType] = [.none]
    
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
        

        
        NotificationCenter.default().addObserver(self, selector: #selector(AddAlarmViewController.addSong(_:)), name: AddingSongNotification, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(AddAlarmViewController.addRepeat(_:)), name: AddingRepeatsNotification, object: nil)
    }
    
    func buildToolbar() -> UIToolbar{
        let aToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.size.width)!  , height: 50))
        let previousButton = UIBarButtonItem(title: "Prev", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddAlarmViewController.prevButtonAction(_:)))
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddAlarmViewController.nextButtonAction(_:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done , target: self, action: #selector(AddAlarmViewController.doneButtonAction(_:)))
        let items = [previousButton, nextButton, spacer, doneButton]
        aToolbar.items = items
        
        //aToolbar.sizeToFit()
        return aToolbar
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("edit")
        self.currentTextField = textField
        
        switch currentTextField {
        case alarmTimeTextField:
            toolbar.items![0].isEnabled = false
            toolbar.items![1].isEnabled = true
            let scrollHeight = alarmTimeTextField.inputView?.frame.height
            let scrollViewFrame = self.scrollView.frame
            let tempHeight =  scrollViewFrame.height - scrollHeight!
            //set new Frame
            scrollView.contentOffset.y = 0
            print(tempHeight)
            break
        case alarmNameTextField:
            toolbar.items![0].isEnabled = true
            toolbar.items![1].isEnabled = false
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
    
    
    func doneButtonAction(_ sender: AnyObject){
        //print("done")
        
        currentTextField.resignFirstResponder()
    }
    
    func nextButtonAction(_ sender: AnyObject){
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
    func prevButtonAction(_ sender: AnyObject){
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
    
    @IBAction func commitNewAlarm(_ sender: AnyObject) {
        let selectedIndex = alarmAMPMSegmentedControl.selectedSegmentIndex
        print(alarmAMPMSegmentedControl.titleForSegment(at: selectedIndex)!)
        let repeatDescriptions = repeatArrayToStringArray(repeatData)
        let alarmDicationary = ["alarmHour": hourValue, "alarmMinute": minuteValue, "alarmName": alarmNameTextField.text!, "alarmAMPM": alarmAMPMSegmentedControl.titleForSegment(at: selectedIndex)!, "alarmSong": songData!, "alarmRepeat": repeatDescriptions] //Need to fix cast or make a wrapper for values.
        NotificationCenter.default().post(name: Notification.Name(rawValue: AddingNewAlarmNotification), object: self, userInfo: alarmDicationary as [NSObject : AnyObject])
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func testAlarm() -> Alarm{
        let temp = Alarm()
        return temp
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hourData.count
        } else {
            return minuteData.count
        }
        

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timeStringBuild(hourData[row], minute: minuteValue)
        } else {
            timeStringBuild(hourValue, minute: minuteData[row])
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hourData[row]
        } else {
            return minuteData[row]
        }

    }
    
    
    func timeStringBuild(_ hour:String, minute:String){
        if hour == hourValue {
            alarmTimeTextField.text = hourValue + ":" + minute
            minuteValue = minute
        } else {
            alarmTimeTextField.text = hour + ":" + minuteValue
            hourValue = hour
        }
    }
    
    func addSong(_ notification: Notification){
        //print("received")
        let songDictionary = (notification as NSNotification).userInfo!
        //print(songDictionary)
        let song = songDictionary["songItem"] as! MPMediaItem
        //print("get")
        songData = song
        alarmToneLabel.text = song.title
    }
    
    func addRepeat(_ notification: Notification){
        let repeatsDictionary = (notification as NSNotification).userInfo!
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
        } else if repeatData[0] == .everyday {
            alarmRepeatLabel.text = "Everyday"
        } else if repeatData.contains( .none) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewRepeatSegue" {
            let dest = segue.destinationViewController as! AddAlarmRepeatTableViewController
            dest.selectedRepeats = repeatData
        }
    }
    
}




let loadedIncrement = 20

//MARK: SONGS

class AddSongsTableViewController: UITableViewController {
    let mediaLibrary: MPMediaLibrary = MPMediaLibrary.default()
    var songArray:[MPMediaItem] = MPMediaQuery().items!
    let mediaPlayer: MPMusicPlayerController = MPMusicPlayerController()
    var filteredSongArray:[MPMediaItem] = [MPMediaItem]()
    let searchbarController = UISearchController(searchResultsController: nil)
    var selectedSong: MPMediaItem? = nil
    var loadedLibrary: [MPMediaItem] =  Array<MPMediaItem>(MPMediaQuery.songs().items![0..<20])
    var lowerBound: Int = 0
    var upperBound: Int = loadedIncrement
    var isLoading = false
    var lastOffset: CGFloat = 0
    var hasMoved = false
    
    @IBOutlet var currentSongView: SelectedSongView!
    
    @IBOutlet var songsTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbarController.searchResultsUpdater = self
        searchbarController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchbarController.searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchbarController.searchBar.frame.size.height - 60), animated: false)
        //print(songArray.count)
        //selectedCellView = SelectedSongView(frame: CGRect(origin: CGPointMake(0, 60) , size: CGSize(width: (self.navigationController?.view.frame.width)!, height: 100 )))
        
        
        //print(selectedCellView.selectedSongTitle.text)
        //self.navigationController?.view.addSubview(selectedCellView)
        
        self.navigationController?.view.addSubview(currentSongView)
        currentSongView.frame = CGRect(origin: CGPoint(x: 0, y: 62) , size: CGSize(width: (self.navigationController?.view.frame.width)! , height: 110 ))
        let visEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visEffect.frame = CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: (self.navigationController?.view.frame.width)!, height: 110 ))
        visEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        currentSongView.addSubview(visEffect)
        currentSongView.sendSubview(toBack: visEffect)
        
        
        if selectedSong == nil {
            currentSongView.isHidden = true
        }
        
        //self.view.addSubview(selectedCellView)
        //self.navigationController?.view.bringSubviewToFront(selectedCellView)
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    func filterSongs(_ searchString: String){
        //print(searchString)
        filteredSongArray = songArray.filter { song in
            return (song.title!.lowercased().contains(searchString.lowercased()))
        }
        tableView.reloadData()
    }
    
    func loadSongLibrary(){
        songArray = MPMediaQuery.songs().items!
        //print(songArray.count)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddAlarmSongCell", for: indexPath) as! AddSongTableCellView
        
        
        
        if self.searchbarController.isActive && self.searchbarController.searchBar.text != "" {
            cell.alarmSongTextLabel.text = self.filteredSongArray[(indexPath as NSIndexPath).row].title!
            //cell.alarmSongImageView.image = self.filteredSongArray[x.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        } else {
            //print(indexPath.row)
            cell.alarmSongTextLabel.text = loadedLibrary[(indexPath as NSIndexPath).row].title!
            //cell.alarmSongImageView.image = self.songArray[x.row].artwork?.imageWithSize(cell.alarmSongImageView.frame.size)
        }
        cell.alarmSongImageView.isUserInteractionEnabled = true
        
        // Choose Song Gesture
        let chooseGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.togglePreview(_:)))
        self.view.addGestureRecognizer(chooseGesture)
        
        
        let queue = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault)
        queue.async {
            
            var cellImageView:UIImage?
            
            if self.searchbarController.isActive && self.searchbarController.searchBar.text != "" {
                //cell.alarmSongTextLabel.text = self.filteredSongArray[x.row].title!
                cellImageView = (self.filteredSongArray[(indexPath as NSIndexPath).row].artwork?.image(at: cell.alarmSongImageView.frame.size))
            } else {
                //cell.alarmSongTextLabel.text = self.songArray[x.row].title!
                cellImageView = (self.loadedLibrary[(indexPath as NSIndexPath).row].artwork?.image(at: cell.alarmSongImageView.frame.size))
            }
            
            DispatchQueue.main.sync {
                cell.alarmSongImageView.image = cellImageView
            }
            
            
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let songCell = cell as! AddSongTableCellView
            if self.searchbarController.active && self.searchbarController.searchBar.text != "" {
                songCell.alarmSongTextLabel.text = self.filteredSongArray[indexPath.row].title!
                songCell.alarmSongImageView.image = self.filteredSongArray[indexPath.row].artwork?.imageWithSize(songCell.alarmSongImageView.frame.size)
            } else {
                songCell.alarmSongTextLabel.text = self.songArray[indexPath.row].title!
                songCell.alarmSongImageView.image = self.songArray[indexPath.row].artwork?.imageWithSize(songCell.alarmSongImageView.frame.size)
            }
            songCell.alarmSongImageView.userInteractionEnabled = true
            
            // Choose Song Gesture
            let chooseGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.togglePreview(_:)))
            self.view.addGestureRecognizer(chooseGesture)
        }
        */
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbarController.isActive && searchbarController.searchBar.text != "" {
            //print(filteredSongArray.count)
            return filteredSongArray.count
        }
        return loadedLibrary.count
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffset = scrollView.contentOffset.y
        hasMoved = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //super.scrollViewDidScroll(scrollView)
        let currentOffset = scrollView.contentOffset.y
        
        
        if currentOffset < lastOffset {
            //print("up")
            let minOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if !isLoading && (currentOffset <= 100.0)  && hasMoved {
                print("load lower")
                isLoading = true
                lowerBound -= loadedIncrement
                if lowerBound < 0 {
                    lowerBound = 0
                }
                upperBound = lowerBound + loadedIncrement
                if upperBound > songArray.count {
                    upperBound = songArray.count
                }
                
                let queue = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault)
                queue.async {
                    self.isLoading = false
                    var swapData = SongLibrary.getSongsB(self.lowerBound, andUpperBound: self.upperBound)
                    //print(swapData)
                    var swapArray:[MPMediaItem] = [MPMediaItem]()
                    swapArray.append(contentsOf: swapData)
                    self.loadMoreData(&self.loadedLibrary, newData: swapArray)
                    //dispatch_sync(dispatch_get_main_queue()) {
                        self.tableView.contentOffset.y = scrollView.contentSize.height - 120
                        self.songsTableView.reloadData()
                        self.isLoading = false
                        //swapData.removeAll()
                        //swapArray.removeAll()
                    //}
               }
            }
        } else if currentOffset > lastOffset {
            //print("down")
            let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if !isLoading && (maxOffset - currentOffset <= 100.0) {
                print("load higher")
                isLoading = true
                upperBound += loadedIncrement
                if upperBound > songArray.count {
                    upperBound = songArray.count
                }
                lowerBound = upperBound - (loadedIncrement)
                if lowerBound < 0 {
                    lowerBound = 0
                }
                
                let queue = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault)
                queue.async {
                    self.isLoading = false
                    var swapData = SongLibrary.getSongs(self.lowerBound, andUpperBound: self.upperBound)
                    var swapArray:[MPMediaItem] = [MPMediaItem]()
                    swapArray.append(contentsOf: swapData)
                    self.loadMoreData(&self.loadedLibrary, newData: swapArray)
                    DispatchQueue.main.sync {
                        self.tableView.contentOffset.y = scrollView.frame.size.height - 100
                        self.songsTableView.reloadData()
                        self.isLoading = false
                        //swapData.removeAll()
                        //swapArray.removeAll()
                    }
                }
            }
            
        }
 
        //Check if we are close to top of bounds or bottom
        /*
        if !isLoading && (maxOffset - currentOffset <= 100.0) {
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue) {
                self.isLoading = true
                self.lowerBound += loadedIncrement
                
                self.upperBound += loadedIncrement
                if self.upperBound > self.songArray.count {
                    self.upperBound = self.songArray.count
                    self.lowerBound = self.upperBound - loadedIncrement
                }
                let swapData = self.songArray[(self.lowerBound)..<(self.upperBound)]
                var swapArray:[MPMediaItem] = [MPMediaItem]()
                swapArray.appendContentsOf(swapData)
                print(self.loadedLibrary)
                self.loadMoreData(&self.loadedLibrary, newData: swapArray)
                dispatch_sync(dispatch_get_main_queue()) {
                    self.songsTableView.reloadData()
                    self.isLoading = false
                }
            }
            
        }
        
        */
        // Swap in new data
        
        
        //reload With new info
        //
    }
    
    func loadMoreData(_ dataSource: inout [MPMediaItem], newData:[MPMediaItem]) {
        //print(dataSource)
        dataSource = newData
    }
    
    
    func togglePreview(_ gestureRecognizer: UIGestureRecognizer){
        //print("toggle Preview")
        let location = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)
        //let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AddSongTableCellView
        
        //print(songArray[indexPath!.row].title)
        //print(tappedCell)
        let queue = DispatchQueue.main
        queue.async {
            if self.searchbarController.isActive && self.searchbarController.searchBar.text != "" {
                self.previewSong(self.filteredSongArray[(indexPath! as NSIndexPath).row])
                self.currentSongView.updateViewWithMediaItem(self.filteredSongArray[(indexPath! as NSIndexPath).row])
                if self.selectedSong == nil {
                    self.displaySelectedView()
                }
                self.selectedSong = self.filteredSongArray[(indexPath! as NSIndexPath).row]
            } else {
                self.previewSong(self.loadedLibrary[(indexPath! as NSIndexPath).row])
                self.currentSongView.updateViewWithMediaItem(self.loadedLibrary[(indexPath! as NSIndexPath).row])
                if self.selectedSong == nil {
                    self.displaySelectedView()
                }
                self.selectedSong = self.loadedLibrary[(indexPath! as NSIndexPath).row]
                
            }
        }
        
    }
    
    
    func chooseSong(_ gestureRecognizer: UIGestureRecognizer){
        //print("Choose Song")
        let location = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)
        //let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AddSongTableCellView
        //print(songArray[indexPath!.row].albumTitle)
        //print(tappedCell)
        var songDictionary:[String: MPMediaItem]
        if searchbarController.isActive && searchbarController.searchBar.text != "" {
            songDictionary = ["songItem": filteredSongArray[(indexPath! as NSIndexPath).row]]
        } else {
            songDictionary = ["songItem": songArray[(indexPath! as NSIndexPath).row]]
        }
        NotificationCenter.default().post(name: Notification.Name(rawValue: AddingSongNotification), object: self, userInfo: songDictionary)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func previewSong(_ songItem: MPMediaItem){
        
        if mediaPlayer.nowPlayingItem != nil{
            //print(mediaPlayer.nowPlayingItem?.title!)
            if mediaPlayer.nowPlayingItem! == songItem {
                if mediaPlayer.playbackState == .playing {
                    mediaPlayer.pause()
                } else {
                    mediaPlayer.play()
                }
                
            } else {
                mediaPlayer.pause()
                let newQueue = MPMediaItemCollection(items: [songItem])
                mediaPlayer.setQueue(with: newQueue)
                mediaPlayer.play()
            }
            
        }
        
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            currentSongView.removeFromSuperview()
        }
    }
    
    func displaySelectedView() -> Void {
        currentSongView.isHidden = false
        //self.navigationController?.view.frame = CGRect(origin: (self.navigationController?.view.frame.origin)!, size: CGSize(width: (self.navigationController?.view.frame.width)!, height: 170))
        //let currentFrame = self.tableView.frame
        songsTableView.contentInset = UIEdgeInsets(top: 170, left: 0, bottom: 0, right: 0)
    }
    
    
    
    @IBAction func doneSongAction(_ sender: AnyObject) {
        let songDictionary:[String: MPMediaItem] = ["songItem": selectedSong!]
        NotificationCenter.default().post(name: Notification.Name(rawValue: AddingSongNotification), object: self, userInfo: songDictionary)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension AddSongsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
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
        repeatDoneButton.isEnabled = true
        print(selectedRepeats)
        //loadSelectedRepeats(self.tableView)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddAlarmRepeatCellView", for: indexPath) as! AddRepeatTableCellView
        cell.repeatTypeLabel.text = RepeatMacros[(indexPath as NSIndexPath).row].description
        if selectedRepeats.contains(RepeatMacros[(indexPath as NSIndexPath).row]) {
            cell.isChecked = true
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatMacros.count
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedCell = tableView.cellForRow(at: indexPath) as! AddRepeatTableCellView
        selectedCell.selectionStyle = UITableViewCellSelectionStyle.none
        if selectedCell.accessoryType == UITableViewCellAccessoryType.none {
            calculateOtherRepeats(selectedCell, row: (indexPath as NSIndexPath).row)
            //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.none
            //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        //self.tableView(tableView, willDeselectRowAtIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        //self.tableView(tableView, didDeselectRowAtIndexPath: indexPath)
        return indexPath
    }
    
    func calculateOtherRepeats(_ tappedOption: AddRepeatTableCellView, row: Int){
        let tapped = RepeatMacros[row]
        switch (tapped) {
        case .none:
            selectedRepeats = [.none]
            clearTableView()
            tappedOption.accessoryType = UITableViewCellAccessoryType.checkmark
            break
        case .everyday:
            if selectedRepeats.count > 0 {
                clearTableView()
            }
            selectedRepeats = [.everyday]
            tappedOption.accessoryType = UITableViewCellAccessoryType.checkmark
            break
        default:
            if selectedRepeats.contains(repeatType.none) || selectedRepeats.contains(repeatType.everyday) {
                clearTableView()
                selectedRepeats = [tapped]
            } else{
                selectedRepeats.append(tapped)
            }
            tappedOption.accessoryType = UITableViewCellAccessoryType.checkmark
            let noneOption = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddRepeatTableCellView
            noneOption.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    func clearTableView(){
        let view = self.tableView
        for anIndex in 0..<RepeatMacros.count  {
            //print(anIndex)
            let current =  view?.cellForRow(at: IndexPath(row: anIndex, section: 0)) as! AddRepeatTableCellView
            
            current.accessoryType = UITableViewCellAccessoryType.none
        }
        
    }
  
    
    @IBAction func commitRepeats(_ sender: AnyObject) {
        let sortedRepeats = sortRepeatArray(selectedRepeats)
        let temp = repeatArrayToStringArray(sortedRepeats)
        let repeatDictionary = ["repeats" as NSString: temp]
        NotificationCenter.default().post(name: Notification.Name(rawValue: AddingRepeatsNotification), object: self, userInfo: repeatDictionary)
        self.navigationController?.popViewController(animated: true)
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
        updateAlarmButton.isEnabled = false
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
        
        NotificationCenter.default().addObserver(self, selector: #selector(EditAlarmViewController.updateRepeat(_:)), name: UpdatingRepeatsNotification, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(EditAlarmViewController.updateSong(_:)), name: UpdatingSongNotification, object: nil)
        print(alarmToEdit)
    }
    
    func buildToolbar() -> UIToolbar{
        let aToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.size.width)!  , height: 50))
        let previousButton = UIBarButtonItem(title: "Prev", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddAlarmViewController.prevButtonAction(_:)))
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddAlarmViewController.nextButtonAction(_:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done , target: self, action: #selector(AddAlarmViewController.doneButtonAction(_:)))
        let items = [previousButton, nextButton, spacer, doneButton]
        aToolbar.items = items
        
        //aToolbar.sizeToFit()
        return aToolbar
    }
    
    @IBAction func updateAlarm(_ sender: AnyObject) {
        let repeatDescriptions = repeatArrayToStringArray(alarmToEdit.alarmRepeat)
        let selectedIndex = alarmAMPMSegmentControl.selectedSegmentIndex
        let updateDictionary = ["alarmHour": hourValue, "alarmMinute": minuteValue, "alarmName": alarmNameTextField.text!, "alarmAMPM": alarmAMPMSegmentControl.titleForSegment(at: selectedIndex)!, "alarmSound": alarmToEdit.alarmSound!, "alarmIndex": editRow, "alarmRepeat": repeatDescriptions]
        NotificationCenter.default().post(name: Notification.Name(rawValue: UpdatingAlarmNotification), object: self, userInfo: updateDictionary)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("edit")
        self.currentTextField = textField
        
        switch currentTextField {
        case alarmTimeTextField:
            toolbar.items![0].isEnabled = false
            toolbar.items![1].isEnabled = true
            break
        case alarmNameTextField:
            toolbar.items![0].isEnabled = true
            toolbar.items![1].isEnabled = false
            break
        default:
            break
        }
    }
    
    func doneButtonAction(_ sender: AnyObject){
        //print("done")
        
        currentTextField.resignFirstResponder()
    }
    
    func nextButtonAction(_ sender: AnyObject){
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
    func prevButtonAction(_ sender: AnyObject){
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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hourData.count
        } else {
            return minuteData.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timeStringBuild(hourData[row], minute: minuteValue)
        } else {
            timeStringBuild(hourValue, minute: minuteData[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hourData[row]
        } else {
            return minuteData[row]
        }
    }
    
    func timeStringBuild(_ hour:String, minute:String){
        if hour == hourValue {
            alarmTimeTextField.text = hourValue + ":" + minute
            minuteValue = minute
        } else {
            alarmTimeTextField.text = hour + ":" + minuteValue
            hourValue = hour
        }
    }
    
    @IBAction func removeAlarm(_ sender: AnyObject) {
        let dataDictionary = ["index": editRow.description]
        NotificationCenter.default().post(name: Notification.Name(rawValue: DeletingAlarmNotification), object: self, userInfo: dataDictionary as [NSObject : AnyObject])
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func chooseSong(_ sender: AnyObject) {
    }
    
    
    @IBOutlet weak var chooseRepeats: UIButton!
    
    func updateRepeat(_ notification: Notification){
        let repeatsDictionary = (notification as NSNotification).userInfo!
        let repeatStrings = repeatsDictionary["repeats"] as! [String]
        var repeats:[repeatType] = [repeatType]()
        for aString in repeatStrings{
            switch aString {
            case "None":
                repeats.append(repeatType.none)
                break
            case "Monday":
                repeats.append(repeatType.monday)
                break
            case "Tuesday":
                repeats.append(repeatType.tuesday)
                break
            case "Wednesday":
                repeats.append(repeatType.wednesday)
                break
            case "Thursday":
                repeats.append(repeatType.thursday)
                break
            case "Friday":
                repeats.append(repeatType.friday)
                break
            case "Saturday":
                repeats.append(repeatType.saturday)
                break
            case "Sunday":
                repeats.append(repeatType.sunday)
                break
            case "Everyday":
                repeats.append(repeatType.everyday)
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
        } else if alarmToEdit.alarmRepeat[0] == .everyday {
            alarmRepeatLabel.text = "Everyday"
        } else if alarmToEdit.alarmRepeat.contains( .none) {
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
    
    func updateSong(_ notification: Notification){
        //print("received")
        let songDictionary = (notification as NSNotification).userInfo!
        //print(songDictionary)
        let song = songDictionary["songItem"] as! MPMediaItem
        //print("get")
        alarmToEdit.alarmSound = song
        alarmSongLabel.text = song.title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
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
    let mediaLibrary: MPMediaLibrary = MPMediaLibrary.default()
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
    
    func filterSongs(_ searchString: String){
        //print(searchString)
        filteredSongArray = songArray.filter { song in
            return (song.title!.lowercased().contains(searchString.lowercased()))
        }
        tableView.reloadData()
    }
    
    func loadSongLibrary(){
        songArray = MPMediaQuery.songs().items!
        print(songArray.count)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditAlarmSongCell", for: indexPath) as! EditSongTableCellView
        
        if searchbarController.isActive && searchbarController.searchBar.text != "" {
            cell.alarmSongTextLabel.text = filteredSongArray[(indexPath as NSIndexPath).row].title!
            cell.alarmSongImageView.image = filteredSongArray[(indexPath as NSIndexPath).row].artwork?.image(at: cell.alarmSongImageView.frame.size)
        } else {
            cell.alarmSongTextLabel.text = songArray[(indexPath as NSIndexPath).row].title!
            cell.alarmSongImageView.image = songArray[(indexPath as NSIndexPath).row].artwork?.image(at: cell.alarmSongImageView.frame.size)
        }
        cell.alarmSongImageView.isUserInteractionEnabled = true
        
        // Choose Song Gesture
        let chooseGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.chooseSong(_:)))
        self.view.addGestureRecognizer(chooseGesture)
        
        // Preview Song Gesutre
        let previewGesture = UITapGestureRecognizer.init(target: self, action: #selector(AddSongsTableViewController.togglePreview(_:)))
        cell.alarmSongImageView.addGestureRecognizer(previewGesture)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbarController.isActive && searchbarController.searchBar.text != "" {
            //print(filteredSongArray.count)
            return filteredSongArray.count
        }
        return songArray.count
    }
    
    func togglePreview(_ gestureRecognizer: UIGestureRecognizer){
        print("toggle Preview")
        let location = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)
        let tappedCell = self.tableView.cellForRow(at: indexPath!) as! EditSongTableCellView
        print(songArray[(indexPath! as NSIndexPath).row].title)
        print(tappedCell)
        if searchbarController.isActive && searchbarController.searchBar.text != "" {
            previewSong(filteredSongArray[(indexPath! as NSIndexPath).row])
        } else {
            previewSong(songArray[(indexPath! as NSIndexPath).row])
        }
    }
    
    func chooseSong(_ gestureRecognizer: UIGestureRecognizer){
        print("Choose Song")
        let location = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)
        let tappedCell = self.tableView.cellForRow(at: indexPath!) as! EditSongTableCellView
        print(songArray[(indexPath! as NSIndexPath).row].albumTitle)
        print(tappedCell)
        var songDictionary:[String: MPMediaItem]
        if searchbarController.isActive && searchbarController.searchBar.text != "" {
            songDictionary = ["songItem": filteredSongArray[(indexPath! as NSIndexPath).row]]
        } else {
            songDictionary = ["songItem": songArray[(indexPath! as NSIndexPath).row]]
        }
        NotificationCenter.default().post(name: Notification.Name(rawValue: UpdatingSongNotification), object: self, userInfo: songDictionary)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func previewSong(_ songItem: MPMediaItem){
        
        if mediaPlayer.nowPlayingItem != nil{
            //print(mediaPlayer.nowPlayingItem?.title!)
            if mediaPlayer.nowPlayingItem! == songItem {
                if mediaPlayer.playbackState == .playing {
                    mediaPlayer.pause()
                } else {
                    mediaPlayer.play()
                }
                
            } else {
                mediaPlayer.pause()
                let newQueue = MPMediaItemCollection(items: [songItem])
                mediaPlayer.setQueue(with: newQueue)
                mediaPlayer.play()
            }
            
        }
        
        
    }
    
}

extension EditSongsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
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
        repeatDoneButton.isEnabled = true
        print(selectedRepeats)
        //loadRepeats()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditAlarmRepeatCellView", for: indexPath) as! EditRepeatTableCellView
        cell.repeatTypeLabel.text = RepeatMacros[(indexPath as NSIndexPath).row].description
        if selectedRepeats.contains(RepeatMacros[(indexPath as NSIndexPath).row]) {
            cell.isChecked = true
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatMacros.count
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedCell = tableView.cellForRow(at: indexPath) as! EditRepeatTableCellView
        selectedCell.selectionStyle = UITableViewCellSelectionStyle.none
        if selectedCell.accessoryType == UITableViewCellAccessoryType.none {
            calculateOtherRepeats(selectedCell, row: (indexPath as NSIndexPath).row)
            //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.none
            //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        //self.tableView(tableView, willDeselectRowAtIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        //self.tableView(tableView, didDeselectRowAtIndexPath: indexPath)
        return indexPath
    }
    
    
    func loadRepeats(){
        //for repeats found in selected repeats array remark them for the view.
        for aRepeat in selectedRepeats{
            switch (aRepeat) {
            case .none:
                addCheckmark(0)
                break
            case .monday:
                addCheckmark(1)
                break
            case .tuesday:
                addCheckmark(2)
                break
            case .wednesday:
                addCheckmark(3)
                break
            case .thursday:
                addCheckmark(4)
                break
            case .friday:
                addCheckmark(5)
                break
            case .saturday:
                addCheckmark(6)
                break
            case .sunday:
                addCheckmark(7)
                break
            case .everyday:
                addCheckmark(8)
                break
            }
        }
    }
    func addCheckmark(_ forIndex: Int){
        let indexPath = IndexPath(index: forIndex)
        let cell = self.tableView.cellForRow(at: indexPath) as! EditRepeatTableCellView
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    func calculateOtherRepeats(_ tappedOption: EditRepeatTableCellView, row: Int){
        let tapped = RepeatMacros[row]
        switch (tapped) {
        case .none:
            selectedRepeats = [.none]
            clearTableView()
            tappedOption.accessoryType = UITableViewCellAccessoryType.checkmark
            break
        case .everyday:
            if selectedRepeats.count > 0 {
                clearTableView()
            }
            selectedRepeats = [.everyday]
            tappedOption.accessoryType = UITableViewCellAccessoryType.checkmark
            break
        default:
            if selectedRepeats.contains(repeatType.none) || selectedRepeats.contains(repeatType.everyday) {
                clearTableView()
                selectedRepeats = [tapped]
            } else{
                selectedRepeats.append(tapped)
            }
            tappedOption.accessoryType = UITableViewCellAccessoryType.checkmark
            let noneOption = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditRepeatTableCellView
            noneOption.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    func clearTableView(){
        let view = self.tableView
        for anIndex in 0..<RepeatMacros.count  {
            let current =  view?.cellForRow(at: IndexPath(row: anIndex, section: 0)) as! EditRepeatTableCellView
            current.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    
    @IBAction func commitRepeats(_ sender: AnyObject) {
        let sortedRepeats = sortRepeatArray(selectedRepeats)
        let temp = repeatArrayToStringArray(sortedRepeats)
        let repeatDictionary = ["repeats" as NSString: temp]
        NotificationCenter.default().post(name: Notification.Name(rawValue: UpdatingRepeatsNotification), object: self, userInfo: repeatDictionary )
        self.navigationController?.popViewController(animated: true)
    }
    
}

class EditRepeatTableCellView: UITableViewCell {
    @IBOutlet weak var repeatTypeLabel: UILabel!
    var isChecked: Bool = false
    
    
}


public class RepeatDataManipulation {
       class func makeRepeatString(_ repeatData: [repeatType]) -> String {
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
    class func makeDurationString(_ song: MPMediaItem) -> String{
        var returnString = ""
        print(song.playbackDuration)
        let mins = Int(song.playbackDuration/60)
        print(mins)
        //let leftOver = song.playbackDuration - mins*60
        let secs = Int(song.playbackDuration.truncatingRemainder(dividingBy: 60))
        if secs < 10 {
            returnString = mins.description + ":0" + secs.description
        } else {
            returnString = mins.description + ":" + secs.description
        }
        return returnString
    }
}
