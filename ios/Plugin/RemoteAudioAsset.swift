//
//  RemoteAudioAsset.swift
//

import Foundation
import AVFoundation

extension AVPlayer {
   func stop(){
    self.seek(to: CMTime.zero)
    self.pause()
   }
}

public class RemoteAudioAsset: BaseAudioAsset {
    var player: AVPlayer?

    init(owner:NativeAudio, withAssetId assetId:String, withPath path: String!, withVolume volume: NSNumber!) {
        super.init(owner: owner, withAssetId: assetId, withPath: path, withChannels: 0, withVolume: volume, withFadeDelay: 0)

        let assetUrl: URL? = URL(string: path)

        if let remoteUrl = assetUrl {
            let playerItem = AVPlayerItem(url: remoteUrl)
            player = AVPlayer(playerItem: playerItem)
            player?.volume = volume.floatValue

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: nil
            )

        } else {
            // TODO: handle this scenario
        }
    }

    override func getCurrentTime() -> TimeInterval {
        if let currentPlayer = player {
            let currentSeconds = CMTimeGetSeconds(currentPlayer.currentTime())
            if !currentSeconds.isNaN {
                return TimeInterval(currentSeconds)
            }
        }
        return 0
    }

    override func getDuration() -> TimeInterval {
        if let currentItem = player?.currentItem {
            let seconds = CMTimeGetSeconds(currentItem.duration)
            if !seconds.isNaN {
                return TimeInterval(seconds)
            }
        }
        return 0
    }

    override func play(time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1000000))
        player?.play()
    }

    override func playWithFade(time: TimeInterval) {
        // NOTE: not supported for now, just play
        self.play(time: time)
    }

    override func pause() {
        player?.pause()
    }

    override func resume() {
        if let currentPlayer = player {
            let currentTime = currentPlayer.currentTime()
            currentPlayer.seek(to: currentTime)
            currentPlayer.play()
        }
    }

    override func stop() {
        player?.stop()
    }

    override func stopWithFade() {
        // NOTE: not supported for now, just stop
        self.stop()
    }

    override func loop() {
        // NOTE: not supported
    }

    override func unload() {
        self.stop()
        player?.replaceCurrentItem(with: nil)
        player = nil
        NotificationCenter.default.removeObserver(self)
    }

    override func setVolume(volume: NSNumber!) {
        player?.volume = volume.floatValue
    }

    @objc func playerDidFinishPlaying() {
        NSLog("avPlayerDidFinish")
        self.owner.notifyListeners("complete", data: [
            "assetId": self.assetId
        ])
    }
}
