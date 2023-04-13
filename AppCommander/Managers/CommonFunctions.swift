//
//  AppFunctions.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit
import AbsoluteSolver
import os.log
import MacDirtyCow

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

func delDirectoryContents(path: String, progress: ((Double,String)) -> ()) throws {
    var contents = [""]
    var currentfile: Int = 0
    do {
        contents = try FileManager.default.contentsOfDirectory(atPath: path)
        for file in contents {
            print("Deleting \(file)")
            do {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: path).appendingPathComponent(file))
                currentfile += 1
                progress((Double(currentfile / contents.count), file))
            } catch {
                throw error.localizedDescription
            }
        }
    } catch {
        throw error.localizedDescription
    }
}

// MARK: - Sexy respring

func respring() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()

    let view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = .black
    view.alpha = 0

    for window in UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).flatMap({ $0.windows.map { $0 } }) {
        window.addSubview(view)
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            view.alpha = 1
        })
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        MacDirtyCow.restartFrontboard()
        sleep(2) // give the springboard some time to restart before exiting
        exit(0)
    }
}

func reboot() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()

    let view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = .black
    view.alpha = 0

    for window in UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).flatMap({ $0.windows.map { $0 } }) {
        window.addSubview(view)
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            view.alpha = 1
        })
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        trigger_memmove_oob_copy()
        sleep(2) // give the springboard some time to restart before exiting
        exit(0)
    }
}
