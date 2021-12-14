import AVFoundation
import Foundation
import Capacitor
import CoreAudio

enum MyError: Error {
    case runtimeError(String)
}

extension String {
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().path
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(NativeAudio)
public class NativeAudio: CAPPlugin {

    var audioList: [String : Any] = [:]
    var fadeMusic = false

    public override func load() {
        super.load()

        self.fadeMusic = false

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playback, options: [
                AVAudioSession.CategoryOptions.mixWithOthers
            ])
            try session.setActive(false)
        } catch {
            print("Failed to ")
        }
    }

    @objc func configure(_ call: CAPPluginCall) {
        let fade: Bool = call.getBool(Constant.FadeKey) ?? false

        fadeMusic = fade
    }

    @objc func preload(_ call: CAPPluginCall) {
        preloadAsset(call, isComplex: true)
    }

    @objc func play(_ call: CAPPluginCall) {
        let audioId = call.getString(Constant.AssetIdKey) ?? ""
        let time = call.getDouble("time") ?? 0
        if audioId != "" {
            let queue = DispatchQueue(label: "com.getcapacitor.community.audio.complex.queue", qos: .userInitiated)

            queue.async {
                if self.audioList.count > 0 {
                    let asset = self.audioList[audioId]

                    if asset != nil {
                        if asset is BaseAudioAsset {
                            let audioAsset = asset as? AudioAsset

                            if self.fadeMusic {
                                audioAsset?.playWithFade(time: time)
                            } else {
                                audioAsset?.play(time: time)
                            }

                            call.success()
                        } else if (asset is Int32) {
                            let audioAsset = asset as? NSNumber ?? 0

                            AudioServicesPlaySystemSound(SystemSoundID(audioAsset.intValue ))

                            call.success()
                        } else {
                            call.error(Constant.ErrorAssetNotFound)
                        }
                    }
                }
            }
        }
    }

    @objc private func getAudioAsset(_ call: CAPPluginCall) -> BaseAudioAsset? {
        let audioId = call.getString(Constant.AssetIdKey) ?? ""
        if audioId == "" {
            call.error(Constant.ErrorAssetId)
            return nil
        }
        if self.audioList.count > 0 {
            let asset = self.audioList[audioId]
            if asset != nil && asset is BaseAudioAsset {
                return asset as? BaseAudioAsset
            }
        }
        call.error(Constant.ErrorAssetNotFound + " - " + audioId)
        return nil
    }


    @objc func getDuration(_ call: CAPPluginCall) {
        guard let audioAsset: BaseAudioAsset = self.getAudioAsset(call) else {
            return
        }

        call.resolve([
            "duration": audioAsset.getDuration()
        ])
    }

    @objc func getCurrentTime(_ call: CAPPluginCall) {
        guard let audioAsset: BaseAudioAsset = self.getAudioAsset(call) else {
            return
        }

        call.resolve([
            "currentTime": audioAsset.getCurrentTime()
        ])
    }

    @objc func resume(_ call: CAPPluginCall) {
        guard let audioAsset: BaseAudioAsset = self.getAudioAsset(call) else {
            return
        }

        audioAsset.resume()
        call.success()
    }

    @objc func pause(_ call: CAPPluginCall) {
        guard let audioAsset: BaseAudioAsset = self.getAudioAsset(call) else {
           return
        }

        audioAsset.pause()
        call.success()
    }

    @objc func stop(_ call: CAPPluginCall) {
        let audioId = call.getString(Constant.AssetIdKey) ?? ""

        do {
            try stopAudio(audioId: audioId)
        } catch {
            call.error(Constant.ErrorAssetNotFound)
        }
    }

    @objc func loop(_ call: CAPPluginCall) {
        guard let audioAsset: BaseAudioAsset = self.getAudioAsset(call) else {
            return
        }

        audioAsset.loop()
        call.success()
    }

    @objc func unload(_ call: CAPPluginCall) {
        let audioId = call.getString(Constant.AssetIdKey) ?? ""
        if self.audioList.count > 0 {
            let asset = self.audioList[audioId]
            if asset != nil && asset is BaseAudioAsset {
                let audioAsset = asset as! AudioAsset
                audioAsset.unload();
                self.audioList[audioId] = nil
            }
        }

        call.success()
    }

    @objc func setVolume(_ call: CAPPluginCall) {
        guard let audioAsset: BaseAudioAsset = self.getAudioAsset(call) else {
            return
        }

        let volume = call.getFloat(Constant.Volume) ?? 1.0

        audioAsset.setVolume(volume: volume as NSNumber)
        call.success()
    }

    private func preloadAsset(_ call: CAPPluginCall, isComplex complex: Bool) {
        let audioId = call.getString(Constant.AssetIdKey) ?? ""
        let channels: NSNumber?
        let volume: Float?
        let delay: NSNumber?
        let isUrl: Bool?

        if audioId != "" {
            let assetPath: String = call.getString(Constant.AssetPathKey) ?? ""

            if (complex) {
                volume = call.getFloat("volume") ?? 1.0
                channels = NSNumber(value: call.getInt("channels") ?? 1)
                delay = NSNumber(value: call.getInt("delay") ?? 1)
                isUrl = call.getBool("isUrl") ?? false
            } else {
                channels = 0
                volume = 0
                delay = 0
                isUrl = false
            }

            if audioList.isEmpty {
                audioList = [:]
            }

            let asset = audioList[audioId]
            let queue = DispatchQueue(label: "com.getcapacitor.community.audio.simple.queue", qos: .userInitiated)

            queue.async {
                if asset == nil {
                    // Check if the assetPath is an HTTP URL
                    if assetPath.starts(with: "http") || assetPath.starts(with: "https") {
                        let remoteAudioAsset = RemoteAudioAsset(owner: self, withAssetId: audioId, withPath: assetPath, withVolume: volume as NSNumber?)
                        self.audioList[audioId] = remoteAudioAsset

                        call.resolve()
                    } else {
                        // It's a File from local file system
                        var basePath: String?
                        if isUrl == false {
                            let ofType = assetPath.fileExtension()
                            let forResource = assetPath.fileName()
                            basePath = Bundle.main.path(forResource: forResource, ofType: ofType)
                        } else {
                            let url = URL(string: assetPath)
                            basePath = url!.path
                        }

                        if FileManager.default.fileExists(atPath: basePath ?? "") {
                            if !complex {
                                let pathUrl = URL(fileURLWithPath: basePath ?? "")
                                let soundFileUrl: CFURL = CFBridgingRetain(pathUrl) as! CFURL
                                var soundId = SystemSoundID()

                                AudioServicesCreateSystemSoundID(soundFileUrl, &soundId)
                                self.audioList[audioId] = NSNumber(value: Int32(soundId))

                                call.success()
                            } else {
                                let audioAsset: AudioAsset = AudioAsset(owner: self, withAssetId: audioId, withPath: basePath, withChannels: channels, withVolume: volume as NSNumber?, withFadeDelay: delay)

                                self.audioList[audioId] = audioAsset

                                call.success()
                            }
                        } else {
                            call.error(Constant.ErrorAssetPath + " - " + assetPath)
                        }
                    }
                }
            }
        }
    }

    private func stopAudio(audioId: String) throws {
        if self.audioList.count > 0 {
            let asset = self.audioList[audioId]

            if asset != nil {
                if asset is BaseAudioAsset {
                    let audioAsset = asset as? AudioAsset

                    if self.fadeMusic {
                        audioAsset?.playWithFade(time: audioAsset?.getCurrentTime() ?? 0)
                    } else {
                        audioAsset?.stop()
                    }
                }
            } else {
                throw MyError.runtimeError(Constant.ErrorAssetNotFound)
            }
        }
    }
}
