//
//  View.swift
//  ChronoSlide
//
//  Created by Tim Harris on 5/28/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

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
        self.backgroundColor = UIColor.blueColor()
        self.selectedSongImageView = UIImageView(frame: frame)
        self.selectedSongTitle = UILabel(frame: frame)
        self.selectedSongArtitst = UILabel(frame: frame)
        self.selectedSongDuration = UILabel(frame: frame)
    }
    
    
    func updateViewWithMediaItem(mediaItem: MPMediaItem){
        self.selectedSongImageView.image = mediaItem.artwork?.imageWithSize(self.selectedSongImageView.frame.size)
        self.selectedSongTitle.text = mediaItem.title!
        self.selectedSongArtitst.text = mediaItem.artist!
        self.selectedSongDuration.text = mediaItem.playbackDuration.description
    }
}