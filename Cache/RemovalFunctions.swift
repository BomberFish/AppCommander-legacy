//
//  RemovalFunctions.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit

func getDataDir(bundleID: String) -> URL {
    let fm = FileManager.default
    var returnedurl = URL.init(string: "none")
    var dirlist = [""]
    var mmcontents = ""
    
    do {
        dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
        print(dirlist)
    } catch {
        UIApplication.shared.alert(body: "Could not access /var/mobile/Containers/Data/Application")
    }
    
    for dir in dirlist {
        print(dir)
        do {
            mmcontents = try String(contentsOf: URL.init(string: "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist")!)
        } catch {
            UIApplication.shared.alert(body: "Error reading \("/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist")")
        }
        if mmcontents.contains(bundleID) {
            returnedurl = URL.init(string: "/var/mobile/Containers/Data/Application")!.appendingPathComponent(dir)
        }
    }
    return returnedurl!
}
