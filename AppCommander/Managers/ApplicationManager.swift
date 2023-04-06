//
//  ApplicationManager.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import SwiftUI

// does nothing lololo
enum GenericError: Error {
    case runtimeError(String)
}

// stolen from appabetical :trolley:
// I do not know how this code works but all I know is that it does.
enum ApplicationManager {
    private static var fm = FileManager.default
    
    private static let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
    private static let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
    
    // MARK: - Goofy ahh function

    public static func getDataDir(bundleID: String) -> URL {
        let fm = FileManager.default
        var returnedurl = URL(string: "none")
        var dirlist = [""]

        do {
            dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
            print(dirlist)
        } catch {
            UIApplication.shared.alert(body: "Could not access /var/mobile/Containers/Data/Application.\n\(error.localizedDescription)")
        }

        for dir in dirlist {
            // print(dir)
            let mmpath = "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
            // print(mmpath)
            let mmDict = NSDictionary(contentsOfFile: mmpath)
            // print(mmDict as Any)
            if mmDict!["MCMMetadataIdentifier"] as! String == bundleID {
                returnedurl = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application").appendingPathComponent(dir)
            }
        }
        return returnedurl!
    }

    public static func exportIPA(app: SBApp) throws -> URL {
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
            try FileManager().zipItem(at: payloaddir, to: FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"))
            print("zipped \(payloaddir) to \(FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"))")
            return FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa")
        } catch {
            print("error at the next step")
            Haptic.shared.notify(.error)
            throw "There was an error exporting the ipa.\n\(error.localizedDescription)"
        }
    }
    
    // MARK: - opens apps

    // from stackoverflow
    public static func openApp(bundleID: String) -> Bool {
        guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return false }
        let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
        let open = workspace?.perform(Selector(("openApplicationWithBundleID:")), with: bundleID) != nil
        return open
    }

    static func getApps() throws -> [SBApp] {
        var dotAppDirs: [URL] = []
        
        let systemAppsDir = try fm.contentsOfDirectory(at: systemApplicationsUrl, includingPropertiesForKeys: nil)
        let userAppsDir = try fm.contentsOfDirectory(at: userApplicationsUrl, includingPropertiesForKeys: nil)
        
        for userAppFolder in userAppsDir {
            let userAppFolderContents = try fm.contentsOfDirectory(at: userAppFolder, includingPropertiesForKeys: nil)
            if let dotApp = userAppFolderContents.first(where: { $0.absoluteString.hasSuffix(".app/") }) {
                dotAppDirs.append(dotApp)
            }
        }
        
        dotAppDirs += systemAppsDir
        
        var apps: [SBApp] = []
        
        for bundleUrl in dotAppDirs {
            let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
            if !fm.fileExists(atPath: infoPlistUrl.path) {
                // some system apps don't have it, just ignore it and move on.
                continue
            }
            
            guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String: AnyObject] else { UIApplication.shared.alert(body: "Error opening info.plist for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error opening info.plist for \(bundleUrl.absoluteString)") }
            guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { UIApplication.shared.alert(body: "App \(bundleUrl.absoluteString) doesn't have bundleid"); throw GenericError.runtimeError("App \(bundleUrl.absoluteString) doesn't have bundleid") }
            
            var app = SBApp(bundleIdentifier: CFBundleIdentifier, name: "Unknown", bundleURL: bundleUrl, version: "Unknown", pngIconPaths: [], hiddenFromSpringboard: false)
            
            if infoPlist.keys.contains("CFBundleShortVersionString") {
                guard let CFBundleShortVersionString = infoPlist["CFBundleShortVersionString"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error reading display name for \(bundleUrl.absoluteString)") }
                app.version = CFBundleShortVersionString
            } else if infoPlist.keys.contains("CFBundleVersion") {
                guard let CFBundleVersion = infoPlist["CFBundleVersion"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error reading display name for \(bundleUrl.absoluteString)") }
                app.version = CFBundleVersion
            }
            
            if infoPlist.keys.contains("CFBundleDisplayName") {
                guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error reading display name for \(bundleUrl.absoluteString)") }
                if CFBundleDisplayName != "" {
                    app.name = CFBundleDisplayName
                } else {
                    app.name = ((NSURL(fileURLWithPath: bundleUrl.path).deletingPathExtension)?.lastPathComponent)!
                }
            } else if infoPlist.keys.contains("CFBundleName") {
                guard let CFBundleName = infoPlist["CFBundleName"] as? String else { UIApplication.shared.alert(body: "Error reading name for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error reading name for \(bundleUrl.absoluteString)") }
                app.name = CFBundleName
            }
            
            // obtaining png icons inside bundle. defined in info.plist
            if app.bundleIdentifier == "com.apple.mobiletimer" {
                // use correct paths for clock, because it has arrows
                // This looks absolutely horrible, why do we even try
                app.pngIconPaths += ["circle_borderless@2x~iphone.png"]
            }
            if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String: AnyObject] {
                    if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                        app.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png" }
                    }
                }
            }
            if infoPlist.keys.contains("CFBundleIconFile") {
                // happens in the case of pseudo-installed apps
                if let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String {
                    app.pngIconPaths.append(CFBundleIconFile + ".png")
                }
            }
            if infoPlist.keys.contains("CFBundleIconFiles") {
                // only seen this happen in the case of Wallet
                if let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String], !CFBundleIconFiles.isEmpty {
                    app.pngIconPaths += CFBundleIconFiles.map { $0 + ".png" }
                }
            }
            
            apps.append(app)
        }
        
        return apps
    }
}

struct SBApp: Identifiable, Equatable {
    var id = UUID()
    var bundleIdentifier: String
    var name: String
    var bundleURL: URL
    var version: String
    
    var pngIconPaths: [String]
    var hiddenFromSpringboard: Bool
}
