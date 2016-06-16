//
//  SongLibrary.swift
//  ChronoSlide
//
//  Created by Tim Harris on 6/15/16.
//  Copyright © 2016 Tim Harris. All rights reserved.
//

import Foundation
import MediaPlayer

class SongLibrary {
    class func getSongs(withLowerBound: Int, andUpperBound: Int) -> [MPMediaItem] {
        var songs = [MPMediaItem]()
        songs = Array<MPMediaItem>( MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound])
        return songs
    }
}