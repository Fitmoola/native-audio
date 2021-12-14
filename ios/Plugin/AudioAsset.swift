//
//  AudioAsset.swift
//  Plugin
//
//  Created by priyank on 2020-05-29.
//  Copyright © 2020 Max Lynch. All rights reserved.
//

import AVFoundation

public class AudioAsset: BaseAudioAsset, AVAudioPlayerDelegate {
    
    var channels: NSMutableArray = NSMutableArray()
    var playIndex: Int = 0
    var initialVolume: NSNumber = 1.0
    var fadeDelay: NSNumber = 1.0

    let FADE_STEP: Float = 0.05
    let FADE_DELAY: Float = 0.08
    
    override init(owner:NativeAudio, withAssetId assetId:String, withPath path: String!, withChannels channels: NSNumber!, withVolume volume: NSNumber!, withFadeDelay delay: NSNumber!) {
        super.init(owner: owner, withAssetId: assetId, withPath: path, withChannels: channels, withVolume: volume, withFadeDelay: delay)

        self.channels = NSMutableArray.init(capacity: channels as! Int)

        let pathUrl: NSURL! = NSURL.fileURL(withPath: path) as NSURL
        
        for _ in 0..<channels.intValue {
            do {
                let player: AVAudioPlayer! = try AVAudioPlayer(contentsOf: pathUrl as URL)
                
                if player != nil {
                    player.volume = volume.floatValue
                    player.prepareToPlay()
                    self.channels.addObjects(from: [player as Any])
                    if channels == 1 {
                        player.delegate = self
                    }
                }
            } catch {
                
            }
        }
    }
    
    override func getCurrentTime() -> TimeInterval {
        if channels.count != 1 {
            return 0
        }

        let player: AVAudioPlayer = channels.object(at: playIndex) as! AVAudioPlayer

        return player.currentTime
    }
    
    override func getDuration() -> TimeInterval {
        if channels.count != 1 {
            return 0
        }

        let player: AVAudioPlayer = channels.object(at: playIndex) as! AVAudioPlayer

        return player.duration
    }

    override func play(time: TimeInterval) {
        let player: AVAudioPlayer = channels.object(at: playIndex) as! AVAudioPlayer
        player.currentTime = time
        player.numberOfLoops = 0
        player.play()
        playIndex = Int(truncating: NSNumber(value: playIndex + 1))
        playIndex = Int(truncating: NSNumber(value: playIndex % channels.count))
    }
    
    override func playWithFade(time: TimeInterval) {
        let player: AVAudioPlayer! = channels.object(at: playIndex) as? AVAudioPlayer
        player.currentTime = time
        
        if !player.isPlaying {
            player.numberOfLoops = 0
            player.volume = 0
            player.play()
            playIndex = Int(truncating: NSNumber(value: playIndex + 1))
            playIndex = Int(truncating: NSNumber(value: playIndex % channels.count))
        } else {
            if player.volume < initialVolume.floatValue {
                player.volume = player.volume + self.FADE_STEP
            }
        }
        
    }

    override func pause() {
        let player: AVAudioPlayer = channels.object(at: playIndex) as! AVAudioPlayer
        player.pause()
    }

    override func resume() {
        let player: AVAudioPlayer = channels.object(at: playIndex) as! AVAudioPlayer

        let timeOffset = player.deviceCurrentTime + 0.01
        player.play(atTime: timeOffset)
    }
    
    override func stop() {
        for i in 0..<channels.count {
            let player: AVAudioPlayer! = channels.object(at: i) as? AVAudioPlayer
            player.stop()
        }
    }
    
    override func stopWithFade() {
        let player: AVAudioPlayer! = channels.object(at: playIndex) as? AVAudioPlayer
        
        if !player.isPlaying {
            player.currentTime = 0.0
            player.numberOfLoops = 0
            player.volume = 0
            player.play()
            playIndex = Int(truncating: NSNumber(value: playIndex + 1))
            playIndex = Int(truncating: NSNumber(value: playIndex % channels.count))
        } else {
            if player.volume < initialVolume.floatValue
            {
                player.volume = player.volume + self.FADE_STEP
            }
        }
    }
    
    override func loop() {
        self.stop()
        
        let player: AVAudioPlayer! = channels.object(at: Int(playIndex)) as? AVAudioPlayer
        player.numberOfLoops = -1
        player.play()
        playIndex = Int(truncating: NSNumber(value: playIndex + 1))
        playIndex = Int(truncating: NSNumber(value: playIndex % channels.count))
    }
    
    override func unload() {
        self.stop()
        
//        for i in 0..<channels.count {
//            var player: AVAudioPlayer! = channels.object(at: i) as? AVAudioPlayer
//
//            player = nil
//        }
        
        channels = NSMutableArray()
    }
    
    override func setVolume(volume: NSNumber!) {
        for i in 0..<channels.count {
            let player: AVAudioPlayer! = channels.object(at: i) as? AVAudioPlayer
            player.volume = volume.floatValue
        }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NSLog("playerDidFinish")
        self.owner.notifyListeners("complete", data: [
            "assetId": self.assetId
        ])
    }
    
    func playerDecodeError(player: AVAudioPlayer!, error: NSError!) {
        
    }
}
