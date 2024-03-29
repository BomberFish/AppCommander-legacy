//
//  ApplicationManager.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import CompressionWrapper
import CoreServices
import Foundation
import MobileCoreServices
import SwiftUI
import AbsoluteSolver
import OSLog

// stolen from appabetical :trolley:
// I do not know how this code works but all I know is that it does.
enum ApplicationManager {
    private static var fm = FileManager.default
    
    private static let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
    private static let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
    
    private static let logger = Logger(subsystem: "Application Manager", category: "Uncategorized")
    
    // MARK: - Goofy ahh function

    public static func getDataDir(bundleID: String) throws -> URL {
        if currentAppMode == .TrollStore {
            // FIXME: Probably very unstable, needs to be rewritten
            let lsapps = LSApplicationWorkspace.default().allApplications()
            let app = lsapps!.first(where: {$0.bundleIdentifier == bundleID})
            return (app?.dataContainerURL)!
        } else {
            let fm = FileManager.default
            var returnedurl = URL(string: "none")
            var dirlist = [""]
            
            do {
                dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
                // print(dirlist)
            } catch {
                throw "Could not access /var/mobile/Containers/Data/Application.\n\(error.localizedDescription)"
            }
            
            for dir in dirlist {
                // print(dir)
                let mmpath = "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
                // print(mmpath)
                do {
                    var mmDict: [String: Any]
                    if fm.fileExists(atPath: mmpath) {
                        if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                            mmDict = try PropertyListSerialization.propertyList(from: try AbsoluteSolver.readFile(path: mmpath, progress: {message in
                                print(message, loglevel: .debug, logger: aslogger)
                            }), options: [], format: nil) as? [String: Any] ?? [:]
                        } else {
                            mmDict = try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: mmpath)), options: [], format: nil) as? [String: Any] ?? [:]
                        }
                        
                        // print(mmDict as Any)
                        if mmDict["MCMMetadataIdentifier"] as! String == bundleID {
                            returnedurl = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application").appendingPathComponent(dir)
                        }
                    } else {
                        print("WARNING: Directory \(dir) does not have a metadata plist, skipping.", loglevel: .info, logger: logger)
                    }
                } catch {
                    print ("Could not get data of \(mmpath): \(error.localizedDescription)", loglevel: .error, logger: logger)
                    throw ("Could not get data of \(mmpath): \(error.localizedDescription)")
                }
            }
            if returnedurl != URL(string: "none") {
                return returnedurl!
            } else {
                throw "Error getting data directory for app \(bundleID)"
            }
        }
    }

    public static func exportIPA(app: SBApp) async throws -> URL {
        // UIApplication.shared.progressAlert(title: "Exporting \(app.name)...")
        do {
            let uuid = UUID().uuidString
            let payloaddir = FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload")
            let filename = app.name + "_" + app.version + "_" + uuid
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try? AbsoluteSolver.delete(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid), progress: {message in
                    print(message, loglevel: .debug, logger: aslogger)
                })
            } else {
                try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid))
            }
            print("rmed file", loglevel: .debug, logger: logger)
            try FileManager.default.createDirectory(at: payloaddir, withIntermediateDirectories: true)
            print("made payload dir \(payloaddir)", loglevel: .debug, logger: logger)
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try AbsoluteSolver.copy(at: app.bundleURL, to: payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent), progress: {message in
                    print(message, loglevel: .debug, logger: aslogger)
                })
            } else {
                try fm.copyItem(at: app.bundleURL, to: payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent))
            }
            print("copied \(app.bundleURL) to \(payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent))", loglevel: .info, logger: logger)
            // try FileManager().zipItem(at: payloaddir, to: FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"))
            try Compression.shared.compress(paths: [payloaddir], outputPath: FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"), format: .zip)
            await UIApplication.shared.dismissAlert(animated: false)
            print("zipped \(payloaddir) to \(FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"))", loglevel: .info, logger: logger)
            // sleep(UInt32(0.5))
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try? AbsoluteSolver.delete(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid), progress: {message in
                    print(message, logger: logger)
                })
            } else {
                try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid))
            }
            return FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa")
        } catch {
            print("error at the next step \(error.localizedDescription)", loglevel: .error, logger: logger)
            Haptic.shared.notify(.error)
            throw "There was an error exporting the ipa.\n\(error.localizedDescription)"
        }
    }
    
    // MARK: - opens apps

    public static func openApp(bundleID: String) -> Bool {
        return LSApplicationWorkspace.default().openApplication(withBundleID: bundleID)
    }

    static func getApps() throws -> [SBApp] {
        let lsapps = LSApplicationWorkspace.default().allApplications()

        // If allApplications() returns nothing, we likely aren't using TrollStore. Alternatively, we COULD use currentAppMode like in getDataDir(), but thats a change for another day.
        if ((lsapps?.isEmpty) != nil) {
            
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
                
                guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String: AnyObject] else { UIApplication.shared.alert(body: "Error opening info.plist for \(bundleUrl.absoluteString)"); throw "Error opening info.plist for \(bundleUrl.absoluteString)" }
                guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { UIApplication.shared.alert(body: "App \(bundleUrl.absoluteString) doesn't have bundleid"); throw ("App \(bundleUrl.absoluteString) doesn't have bundleid") }
                
                var app = SBApp(bundleIdentifier: CFBundleIdentifier, name: "Unknown", bundleURL: bundleUrl, version: "Unknown", pngIconPaths: [], hiddenFromSpringboard: false)
                
                if infoPlist.keys.contains("CFBundleShortVersionString") {
                    guard let CFBundleShortVersionString = infoPlist["CFBundleShortVersionString"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
                    app.version = CFBundleShortVersionString
                } else if infoPlist.keys.contains("CFBundleVersion") {
                    guard let CFBundleVersion = infoPlist["CFBundleVersion"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
                    app.version = CFBundleVersion
                }
                
                if infoPlist.keys.contains("CFBundleDisplayName") {
                    guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
                    if CFBundleDisplayName != "" {
                        app.name = CFBundleDisplayName
                    } else {
                        app.name = ((NSURL(fileURLWithPath: bundleUrl.path).deletingPathExtension)?.lastPathComponent)!
                    }
                } else if infoPlist.keys.contains("CFBundleName") {
                    guard let CFBundleName = infoPlist["CFBundleName"] as? String else { UIApplication.shared.alert(body: "Error reading name for \(bundleUrl.absoluteString)"); throw ("Error reading name for \(bundleUrl.absoluteString)") }
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
        } else {
            // TODO: LSApplicationWorkspace support
            let apps: [LSApplicationProxy] = lsapps!
            var sbapps: [SBApp] = []
            for app in apps {
                let infoPlistUrl = app.bundleURL.appendingPathComponent("Info.plist")
                if !fm.fileExists(atPath: infoPlistUrl.path) {
                    // some system apps don't have it, just ignore it and move on.
                    continue
                }
                guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String: AnyObject] else { UIApplication.shared.alert(body: "Error opening info.plist for \(app.bundleURL.absoluteString)"); throw "Error opening info.plist for \(app.bundleURL.absoluteString)" }
                guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { UIApplication.shared.alert(body: "App \(app.bundleURL.absoluteString) doesn't have bundleid"); throw ("App \(app.bundleURL.absoluteString) doesn't have bundleid") }
                // FIXME: isRestricted is likely NOT whether app is hidden from SpringBoard.
                var sbapp = SBApp(bundleIdentifier: app.bundleIdentifier, name: app.localizedName(), bundleURL: app.bundleURL, version: "Unknown", pngIconPaths: [], hiddenFromSpringboard: app.isRestricted)
                
                if infoPlist.keys.contains("CFBundleShortVersionString") {
                    guard let CFBundleShortVersionString = infoPlist["CFBundleShortVersionString"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(app.bundleURL.absoluteString)"); throw ("Error reading display name for \(app.bundleURL.absoluteString)") }
                    sbapp.version = CFBundleShortVersionString
                } else if infoPlist.keys.contains("CFBundleVersion") {
                    guard let CFBundleVersion = infoPlist["CFBundleVersion"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(app.bundleURL.absoluteString)"); throw ("Error reading display name for \(app.bundleURL.absoluteString)") }
                    sbapp.version = CFBundleVersion
                }
                
                // obtaining png icons inside bundle. defined in info.plist
                if app.bundleIdentifier == "com.apple.mobiletimer" {
                    // use correct paths for clock, because it has arrows
                    // This looks absolutely horrible, why do we even try
                    sbapp.pngIconPaths += ["circle_borderless@2x~iphone.png"]
                }
                if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                    if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String: AnyObject] {
                        if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                            sbapp.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png" }
                        }
                    }
                }
                if infoPlist.keys.contains("CFBundleIconFile") {
                    // happens in the case of pseudo-installed apps
                    if let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String {
                        sbapp.pngIconPaths.append(CFBundleIconFile + ".png")
                    }
                }
                if infoPlist.keys.contains("CFBundleIconFiles") {
                    // only seen this happen in the case of Wallet
                    if let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String], !CFBundleIconFiles.isEmpty {
                        sbapp.pngIconPaths += CFBundleIconFiles.map { $0 + ".png" }
                    }
                }
                
                sbapps.append(sbapp)
            }
            return sbapps
        }
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
