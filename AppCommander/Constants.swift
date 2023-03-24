//
//  Constants.swift
//  Appabetical
//
//  Created by exerhythm on 17.12.2022.
//

import Foundation

#if targetEnvironment(simulator)
fileprivate let iconStatePath = "/Users/hariz/Library/Developer/CoreSimulator/Devices/6E533057-14B7-4EA5-8580-D22D300CD2D7/data/Library/SpringBoard/IconState.plist"
#else
fileprivate let iconStatePath = "/var/mobile/Library/SpringBoard/IconState.plist"
#endif

let fm = FileManager.default
let plistUrl = URL(fileURLWithPath: iconStatePath)
let plistUrlBkp = URL(fileURLWithPath: iconStatePath + ".bkp")
let plistUrlNew = URL(fileURLWithPath: iconStatePath + ".new")
let savedLayoutUrl = URL(fileURLWithPath: iconStatePath + ".saved")
let webClipFolderUrl = URL(fileURLWithPath: "/var/mobile/Library/WebClips/")
let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let iconsOnAPage = 24 // iPads are either 20 or 30 I believe... no support yet
let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
