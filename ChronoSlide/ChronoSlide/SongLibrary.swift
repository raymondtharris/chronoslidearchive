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
        print("\(withLowerBound) \(andUpperBound)")
        var songs:[MPMediaItem] = []
        //print( MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound])
       // var temp = MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound]
        //print(temp)
        for anItem in MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound] {
           // print("1")
            songs.append(anItem)
        }
    
        return songs
    }
    class func getSongsB(withLowerBound: Int, andUpperBound: Int) -> [MPMediaItem] {
        print("\(withLowerBound) \(andUpperBound)")
        var songs:[MPMediaItem] = []
        dispatch_sync(dispatch_get_main_queue()) {
            print( Array<MPMediaItem>(MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound]) as [MPMediaItem])
            songs = Array<MPMediaItem>(MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound]) as [MPMediaItem]
            }
        
        //print(temp)
        
        
        return songs
    }
}