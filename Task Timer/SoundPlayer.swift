//
//  SoundPlayer.swift
//  Task Timer
//
//  Created by Joseph Chan on 4/21/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import UIKit
import AVFoundation

class SoundPlayer: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    
    func play() {
        if let asset = NSDataAsset(name: "alarm") {
            do {
                // Use NSDataAsset's data property to access the audio file stored in Sound.
                player = try AVAudioPlayer(data:asset.data, fileTypeHint: AVFileTypeWAVE)
                // Play the above sound file.
                player?.play()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Error: can't find sound alarm.wav")
        }
    }
    
    func stop() {
        if let p = player {
            p.stop()
            self.player = nil
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if self.player == player {
            self.player = nil
        }
    }
}
