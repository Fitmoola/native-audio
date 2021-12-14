//
//  BaseAudioAsset.swift
//

import Foundation

public class BaseAudioAsset: NSObject {
    var assetId: String = ""
    var owner: NativeAudio

    init(owner:NativeAudio, withAssetId assetId:String, withPath path: String!, withChannels channels: NSNumber!, withVolume volume: NSNumber!, withFadeDelay delay: NSNumber!) {
        self.owner = owner
        self.assetId = assetId
        
        super.init()
    }

    func getCurrentTime() -> TimeInterval {
        return 0
    }

    func getDuration() -> TimeInterval {
        return 0
    }

    func play(time: TimeInterval) {
    }

    func playWithFade(time: TimeInterval) {
    }

    func pause() {
    }

    func resume() {
    }

    func stop() {
    }

    func stopWithFade() {
    }

    func loop() {
    }

    func unload() {
    }

    func setVolume(volume: NSNumber!) {
    }
}
