//
//  AppFunctions.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit
import ZIPFoundation

func getDataDir(bundleID: String) -> URL {
    let fm = FileManager.default
    var returnedurl = URL.init(string: "none")
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
        print(mmDict)
        if mmDict!["MCMMetadataIdentifier"] as! String == bundleID {
            returnedurl = URL.init(string: "/var/mobile/Containers/Data/Application")!.appendingPathComponent(dir)
        }
    }
    return returnedurl!
}

func appToIpa(bundleurl: URL) {
    do {
        let uuid = UUID().uuidString
        try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid))
        print("rmed file")
        try FileManager.default.createDirectory(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload"), withIntermediateDirectories: true)
        print("made payload dir \(FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload"))")
        try FileManager.default.copyItem(at: bundleurl, to: FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload").appendingPathComponent(bundleurl.lastPathComponent))
        print("copied \(bundleurl) to \(FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload").appendingPathComponent(bundleurl.lastPathComponent))")
        try FileManager().zipItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload"), to: FileManager.default.temporaryDirectory.appendingPathComponent("App_Encrypted").appendingPathExtension("ipa"))
        print("zipped \(FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload")) to \(FileManager.default.temporaryDirectory.appendingPathComponent("App_Encrypted").appendingPathExtension("ipa"))")
        let vc = UIActivityViewController(activityItems: [FileManager.default.temporaryDirectory.appendingPathComponent("App_Encrypted").appendingPathExtension("ipa") as Any], applicationActivities: nil)
        UIApplication.shared.windows[0].rootViewController?.present(vc, animated: true)
    } catch {
        print("error at the next step")
        UIApplication.shared.alert(body: "There was an error exporting the ipa.")
    }
}

func isFilzaInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "filza://")!)
}

func isSantanderInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "santander://")!)
}

// thanks serena uwu
func openInSantander(path: String) {
    UIApplication.shared.open(URL(string: "santander://\(path)")!, options: [:], completionHandler: nil)
}

// thanks bing ai
func openInFilza(path: String) {
    UIApplication.shared.open(URL(string: "filza://\(path)")!, options: [:], completionHandler: nil)
}       

func delDirectoryContents(path: String) {
    var contents: [String] = [""]
    do {
        contents = try FileManager.default.contentsOfDirectory(atPath: path)
    } catch {
        UIApplication.shared.alert(body: "Could not get contents of directory?!")
    }
    if contents != [""] {
        for file in contents {
            do {
                try FileManager.default.removeItem(atPath: file)
                UIApplication.shared.alert(title: "Success", body: "Successfully deleted!")
                Haptic.shared.notify(.success)
            } catch {
                UIApplication.shared.alert(body: "Could not remove file \(file)")
                Haptic.shared.notify(.error)
            }
        }
    }
}
