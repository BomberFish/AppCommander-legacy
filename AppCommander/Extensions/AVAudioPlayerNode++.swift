//
//  Player.swift
//  equal sounds
//
//  Created by Gray, John Walker on 12/12/20.
//
//

import Foundation
import AVFoundation

class AVAudioPlayerNodeClass: AVAudioPlayerNode {
  //    var timer = Timer()
  private var audioFile: AVAudioFile? {
    didSet {
      self.duration = audioFile?.duration ?? 0
      self.isPlayable = audioFile != nil
    }
  }
  @objc dynamic var duration: TimeInterval
  var canBeResumed: Bool
  var isPlayable: Bool
  
  //MARK:- Player Internal
  
  override init() {
    duration = 0
    audioFile = nil
    canBeResumed = false
    isPlayable = false
    super.init()
  }
  
  //available externally but low usage expected, primarily intended for internal use
  func openFile(at url: URL) {
    do {
      print(url.path)
      print("loading song")
      try audioFile = AVAudioFile(forReading: url)
      print("loaded song")
    } catch {
      print("an exception occured during audio file initialization")
      return //false
    }
    self.scheduleFile(audioFile!, at: nil, completionHandler: nil)
    //return true
  }
  
  override func scheduleFile(_ file: AVAudioFile, at when: AVAudioTime?, completionCallbackType callbackType: AVAudioPlayerNodeCompletionCallbackType, completionHandler: AVAudioPlayerNodeCompletionHandler? = nil) {
    self.duration = file.duration
    super.scheduleFile(file, at: when, completionCallbackType: callbackType, completionHandler: completionHandler)
  }
  
  //MARK:- Player Controls
  
  func prepare() {
    guard audioFile != nil else {return}
    self.scheduleFile(audioFile!, at: nil, completionHandler: nil)
  }
  
  override func play() {
    play(at: nil)
  }
  
  override func play(at when: AVAudioTime?) {
    super.play(at: when)
    canBeResumed = true
  }
  
  func play(file: AVAudioFile) {
    play(file: file, at: nil)
  }
  
  func play(file: AVAudioFile, at when: AVAudioTime?) {
    if isPlaying {
      stop()
    }
    audioFile = file
    prepare()
    play(at: when)
  }
  
  func resume() {
    resume(at: nil)
  }
  
  func resume(at when: AVAudioTime?) {
    if canBeResumed {
      super.play(at: when)
    }
  }
  
  override func pause() {
    if isPlaying {
      super.pause()
    }
  }
  
  override func stop() {
    super.stop()
    self.reset()
    canBeResumed = false
  }
  
  func setPlaybackPosition(_ newPos: Double) {
    pause()
    self.reset()
    play(at: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: newPos)))
  }
}

//MARK:- AVAudioFile Extension
extension AVAudioFile {
  var duration: TimeInterval {
    Double(Double(length) / processingFormat.sampleRate)
  }
}
