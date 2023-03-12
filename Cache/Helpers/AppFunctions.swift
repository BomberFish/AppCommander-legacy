//
//  AppFunctions.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit

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

