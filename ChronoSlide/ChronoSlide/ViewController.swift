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


class AlarmTableViewController: UITableViewController {
    var ChronoAlarms: [Alarm] = [Alarm]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chronoAlarmCell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath)
        let chronoAlarm = ChronoAlarms[indexPath.row]
        chronoAlarmCell.textLabel?.text = chronoAlarm.alarmName
        return chronoAlarmCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChronoAlarms.count
    }
    
}

class NewAlarmViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
