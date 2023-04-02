//
//  PlayerClass.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import Foundation
import SwiftUI
@preconcurrency import MediaPlayer
import AVFoundation
import Combine

// technically not a source leak, this is way too slimmed down

class Player: ObservableObject {
  static let shared = Player()

  @Published var trackTitle: String = "Apple Loops Mix"
  
  @Published var duration: Double = 0
  
  @Published var isPaused: Bool = true
  
  var ignoreCallback = false
  
  func resume(_ pos: AVAudioTime? = nil) {
    if !self.engine.isRunning { self.engine.prepare(); try? self.engine.start() }
    self.player.play(at: pos)
    
    DispatchQueue.main.async {
      self.isPaused = false
      self.updateElapsedTime()
      self.updatePausedState()
    }
  }
  
  func pause() {
    self.updateElapsedTime()
    self.player.pause()
    DispatchQueue.main.async {
      self.isPaused = true
      self.updatePausedState()
    }
  }
  
  func stop() {
    self.disableEofCallback = true
    self.player.stop()
    DispatchQueue.main.async {
      self.isPaused = true
    }
    self.disableEofCallback = false
  }
  
  func togglePlayback() {
    if !self.isPaused  {
      self.pause()
    } else {
      self.resume()
    }
  }
  
  var disableEofCallback = false
  
  public func playSongItem(fileURL: URL) async throws {
    
    // stop whats playing, also clears out player data for us
    self.stop()
    
    do {
      // reset end of file
      
      // schedules the track to be played if it can and inits the engine
      file = try AVAudioFile(forReading: fileURL)
      engineInit()
      
      // starts the player
      
      self.resume()
    } catch {
      // clears the data for the player view
      await UIApplication.shared.alert(title: "Track Error", body: "This track cannot be played.\n\(error.localizedDescription)\n\n\(String(reflecting: error))")
      throw error
    }
  }
  
  func reloadNowPlayingInfo() {
      var info = [String : Any]()
      info[MPMediaItemPropertyTitle] = "Apple Loops Mix"
      info[MPMediaItemPropertyAlbumTitle] = "Apple Loops Mix"
      info[MPMediaItemPropertyArtist] = "Apple"
      info[MPMediaItemPropertyComposer] = "Apple"
      MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
  func setupRemoteEvents() {
    let ev = MPRemoteCommandCenter.shared()
    ev.pauseCommand.addTarget { event in
      self.pause()
      return .success
    }
    ev.playCommand.addTarget { event in
      self.resume()
      return .success
    }
    ev.togglePlayPauseCommand.addTarget { event in
      self.togglePlayback()
      return .success
    }
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInterruption),
      name: AVAudioSession.interruptionNotification,
      object: nil
    )
  }
  
  func updateElapsedTime() {
    if let secs = self.getSecondsElapsed() {
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = secs.description
    }
  }
  func updatePausedState() {
    let val = isPaused ? 0 : 1
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = val.description
    MPNowPlayingInfoCenter.default().playbackState = isPaused ? .paused : .playing // for macos
  }
  
  internal func getSecondsElapsed() -> Double? {
    guard let nodeTime = self.player.lastRenderTime else { return nil }
    if let playerTime = self.player.playerTime(forNodeTime: nodeTime) {
      let secs = Double(playerTime.sampleTime) / playerTime.sampleRate
      return secs
    }
    return nil
  }
  
  @objc private func handleInterruption(notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: typeValue)
    else { return }
    
    switch type {
      case .began:
        self.pause()
      case .ended:
        guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
        if options.contains(.shouldResume) {
          self.resume()
        } else {
          self.pause()
        }
      @unknown default:
        break
    }
  }
  
  var currentlyPlaying: MPMediaItem? = nil
  var file: AVAudioFile?
  private let engine = AVAudioEngine()
  let player = AVAudioPlayerNodeClass()
  private let eq = AVAudioUnitEQ(numberOfBands: 10)
  
  var cancellable = Set<AnyCancellable>()
  
  init() {
    UIApplication.shared.beginReceivingRemoteControlEvents()
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetoothA2DP, .allowBluetooth, .allowAirPlay])
    reloadNowPlayingInfo()
    setupRemoteEvents()
    
    // attach nodes to engine
    engine.attach(eq)
    engine.attach(player)
    
    // connect player to eq node
    let mixer = engine.mainMixerNode
    engine.connect(player, to: eq, format: mixer.outputFormat(forBus: 0))
    
    // connect eq node to mixer
    engine.connect(eq, to: mixer, format: mixer.outputFormat(forBus: 0))
    
    player
      .publisher(for: \.duration)
      .sink { duration in
        DispatchQueue.main.async {
          self.duration = duration
        }
      }
      .store(in: &cancellable)
  }
  
  internal func engineInit() {
    guard let file = file else {
      UIApplication.shared.alert(title: "Engine Init Error", body: "Audio File did not exist.")
      return
    }
    player.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { type in
      guard type == .dataPlayedBack else { return }
      self.playerDidFinishPlaying()
    }
    
    engine.prepare()
    do {
      try engine.start()
    } catch {
      UIApplication.shared.alert(title: "Engine Init Error", body: error.localizedDescription)
    }
  }
  
  func playerDidFinishPlaying() {
    // playback ended, do any cleanup
    if !disableEofCallback {
      if let last = self.currentlyPlaying {
        let id = last.persistentID
      }
      DispatchQueue.main.async {
        self.isPaused = true
      }
    }
  }
}
