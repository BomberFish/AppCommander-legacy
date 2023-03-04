//
//  ApplicationManager.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit

// does nothing lololo
enum GenericError: Error {
    case runtimeError(String)
}

// stolen from appabetical :trolley:
class ApplicationManager {
    private static var fm = FileManager.default
    
    private static let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
    private static let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
    
    static func getApps() throws -> [SBApp] {
        var dotAppDirs: [URL] = []
        
        let systemAppsDir = try fm.contentsOfDirectory(at: systemApplicationsUrl, includingPropertiesForKeys: nil)
        dotAppDirs += systemAppsDir
        let userAppsDir = try fm.contentsOfDirectory(at: userApplicationsUrl, includingPropertiesForKeys: nil)
        
        for userAppFolder in userAppsDir {
            let userAppFolderContents = try fm.contentsOfDirectory(at: userAppFolder, includingPropertiesForKeys: nil)
            if let dotApp = userAppFolderContents.first(where: { $0.absoluteString.hasSuffix(".app/") }) {
                dotAppDirs.append(dotApp)
            }
        }
        
        var apps: [SBApp] = []
        
        for bundleUrl in dotAppDirs {
            let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
            if !fm.fileExists(atPath: infoPlistUrl.path) {
                // some system apps don't have it, just ignore it and move on.
                continue
            }
            
            guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String:AnyObject] else { UIApplication.shared.alert(body: "Error opening info.plist for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error opening info.plist for \(bundleUrl.absoluteString)") }
            guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { UIApplication.shared.alert(body: "App \(bundleUrl.absoluteString) doesn't have bundleid"); throw GenericError.runtimeError("App \(bundleUrl.absoluteString) doesn't have bundleid")}
            
            var app = SBApp(bundleIdentifier: CFBundleIdentifier, name: "Unknown", bundleURL: bundleUrl, pngIconPaths: [], hiddenFromSpringboard: false)
            
            if infoPlist.keys.contains("CFBundleDisplayName") {
                guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error reading display name for \(bundleUrl.absoluteString)") }
                app.name = CFBundleDisplayName
            } else if infoPlist.keys.contains("CFBundleName") {
                guard let CFBundleName = infoPlist["CFBundleName"] as? String else { UIApplication.shared.alert(body: "Error reading name for \(bundleUrl.absoluteString)");throw GenericError.runtimeError("Error reading name for \(bundleUrl.absoluteString)")}
                app.name = CFBundleName
            }
            
            // obtaining png icons inside bundle. defined in info.plist
            if app.bundleIdentifier == "com.apple.mobiletimer" {
                // use correct paths for clock, because it has arrows
                app.pngIconPaths += ["circle_borderless@2x~iphone.png"]
            }
            if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String : AnyObject] {
                    if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                        app.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png"}
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
    
    var pngIconPaths: [String]
    var hiddenFromSpringboard: Bool
}
