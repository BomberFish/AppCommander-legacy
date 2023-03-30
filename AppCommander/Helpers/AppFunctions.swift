//
//  AppFunctions.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit
import ZIPFoundation

// MARK: - Print to localconsole. Totally not stolen from sneakyf1shy (who still needs to finish the damn frontend)
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let data = items.map { "\($0)" }.joined(separator: separator)
    consoleManager.print(data)
    Swift.print(data, terminator: terminator)
}

public func conditionalPrint(_ items: Any..., c: Bool, separator: String = " ", terminator: String = "\n") {
    if c {
        let data = items.map { "\($0)" }.joined(separator: separator)
        consoleManager.print(data)
        Swift.print(data, terminator: terminator)
    }
}

// MARK: - Goofy ahh function
func getDataDir(bundleID: String) -> URL {
    let fm = FileManager.default
    var returnedurl = URL(string: "none")
    var dirlist = [""]

    do {
        dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
        print(dirlist)
    } catch {
        UIApplication.shared.alert(body: "Could not access /var/mobile/Containers/Data/Application")
    }

    for dir in dirlist {
        print(dir)
        let mmpath = "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
        print(mmpath)
        let mmDict = NSDictionary(contentsOfFile: mmpath)
        print(mmDict as Any)
        if mmDict!["MCMMetadataIdentifier"] as! String == bundleID {
            returnedurl = URL(string: "/var/mobile/Containers/Data/Application")!.appendingPathComponent(dir)
        }
    }
    return returnedurl!
}

// MARK: - This should convert an app to an encrypted ipa, but it doesn't work. See the FIXME.
func appToIpa(app: SBApp) {
    do {
        let uuid = UUID().uuidString
        let payloaddir = FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload")
        let filename = app.name + "_" + app.version + "_" + uuid
        try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid))
        print("rmed file")
        try FileManager.default.createDirectory(at: payloaddir, withIntermediateDirectories: true)
        print("made payload dir \(payloaddir)")
        try FileManager.default.copyItem(at: app.bundleURL, to: payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent))
        print("copied \(app.bundleURL) to \(payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent))")
        // FIXME: This always fails. I don't know why, and I am losing my sanity over it.
        try FileManager().zipItem(at: payloaddir, to: FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"))
        print("zipped \(payloaddir) to \(FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"))")
        let vc = UIActivityViewController(activityItems: [FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa") as Any], applicationActivities: nil)
        Haptic.shared.notify(.success)
        UIApplication.shared.windows[0].rootViewController?.present(vc, animated: true)
    } catch {
        print("error at the next step")
        Haptic.shared.notify(.error)
        UIApplication.shared.alert(body: "There was an error exporting the ipa.\n\(error.localizedDescription)")
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


// MARK: - deletes all the contents of directories. usually.
func delDirectoryContents(path: String) -> Bool {
    var contents = [""]
    do {
        contents = try FileManager.default.contentsOfDirectory(atPath: path)
    } catch {
        UIApplication.shared.alert(body: "Could not get contents of directory?!")
        return false
    }
    if contents != [""] {
        for file in contents {
            print("Deleting \(file)")
            do {
                try FileManager.default.removeItem(atPath: file)
                print("Probably deleted \(file)")
                UIApplication.shared.alert(title: "Success", body: "Successfully deleted!")
                Haptic.shared.notify(.success)
                return true
            } catch {
                print("Failed to delete \(file)")
                UIApplication.shared.alert(body: error.localizedDescription)
                Haptic.shared.notify(.error)
                return false
            }
        }
    }
    return false
}

// MARK: - opens apps
// from stackoverflow
func openApp(bundleID: String) -> Bool {
    guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return false }
    let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
    let open = workspace?.perform(Selector(("openApplicationWithBundleID:")), with: bundleID) != nil
    return open
}

// MARK: - Backup & Restore
