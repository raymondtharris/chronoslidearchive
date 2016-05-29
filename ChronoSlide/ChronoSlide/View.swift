//
//  View.swift
//  ChronoSlide
//
//  Created by Tim Harris on 5/28/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import Foundation
import UIKit

class SelectedSongView: UIView{
    @IBOutlet weak var selectedSongImageView: UIImageView!
    @IBOutlet weak var selectedSongTitle: UILabel!
    @IBOutlet weak var selectedSongArtitst: UILabel!
    @IBOutlet weak var selectedSongDuration: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blueColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
}