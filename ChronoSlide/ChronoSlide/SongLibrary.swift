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
    class func getSongs(_ withLowerBound: Int, andUpperBound: Int) -> [MPMediaItem] {
        print("\(withLowerBound) \(andUpperBound)")
        var songs:[MPMediaItem] = []
        //print( MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound])
       // var temp = MPMediaQuery.songsQuery().items![withLowerBound..<andUpperBound]
        //print(temp)
        for anItem in MPMediaQuery.songs().items![withLowerBound..<andUpperBound] {
           // print("1")
            songs.append(anItem)
        }
    
        return songs
    }
    class func getSongsB(_ withLowerBound: Int, andUpperBound: Int) -> [MPMediaItem] {
        print("\(withLowerBound) \(andUpperBound)")
        let songs:[MPMediaItem] = Array<MPMediaItem>(MPMediaQuery.songs().items![withLowerBound..<andUpperBound]) as [MPMediaItem]
        //DispatchQueue.main().sync() {
            //print(
            //songs = Array<MPMediaItem>(MPMediaQuery.songs().items![withLowerBound..<andUpperBound]) as [MPMediaItem]
          //  }
        
        //print(temp)
        
        
        return songs
    }
}
