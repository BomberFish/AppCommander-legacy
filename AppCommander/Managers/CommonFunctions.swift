//
//  AppFunctions.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit
import ZIPFoundation
import os.log

// MARK: - Print to localconsole. Totally not stolen from sneakyf1shy (who still needs to finish the damn frontend)

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let data = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(data, terminator: terminator)
    os_log("%s", type: .default, data)
    consoleManager.print(data)
}

public func conditionalPrint(_ items: Any..., c: Bool, separator: String = " ", terminator: String = "\n") {
    if c {
        let data = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(data, terminator: terminator)
        os_log("%s", type: .default, data)
        consoleManager.print(data)
    }
}

// MARK: - Detect if Filza/Santander is installed

// Code is from some jailbreak detection I found online
// fucking retards think filza=jelbrek
func isFilzaInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "filza://")!)
}

func isSantanderInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "santander://")!)
}

// MARK: - Open path in file manager

// thanks serena uwu
func openInSantander(path: String) {
    UIApplication.shared.open(URL(string: "santander://\(path)")!, options: [:], completionHandler: nil)
}

// thanks bing ai
func openInFilza(path: String) {
    UIApplication.shared.open(URL(string: "filza://\(path)")!, options: [:], completionHandler: nil)
}

// MARK: - 💀

func notimplementedalert() {
    UIApplication.shared.alert(title: "Not implemented", body: "")
}
