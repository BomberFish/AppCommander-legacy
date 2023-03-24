//
//  AppUtils.swift
//  Appabetical
//
//  Created by Rory Madden on 12/12/22.
//

import Foundation
import AssetCatalogWrapper
import ApplicationsWrapper

class IconStateItemHelper {
    static let shared = IconStateItemHelper()
    private init() {
        fm = FileManager.default
        idToName = [:]
        idToBundle = [:]
        idToColor = [:]
        
        let apps = LSApplicationWorkspace.default().allApplications()
        if apps.isEmpty {
            // Private api didn't work, time to go old fashioned
            do {
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
                
                for bundleUrl in dotAppDirs {
                    let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
                    if !fm.fileExists(atPath: infoPlistUrl.path) {
                        // some system apps don't have it, just ignore it and move on.
                        continue
                    }
                    
                    guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String:AnyObject] else { throw "Error opening info.plist for \(bundleUrl.absoluteString)" }
                    guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { throw "No bundle ID for \(bundleUrl.absoluteString)" }
                    idToBundle[CFBundleIdentifier] = bundleUrl
                    if infoPlist.keys.contains("CFBundleDisplayName") {
                        guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { throw "Error reading display name for \(bundleUrl.absoluteString)" }
                        idToName[CFBundleIdentifier] = CFBundleDisplayName
                    } else if infoPlist.keys.contains("CFBundleName") {
                        guard let CFBundleName = infoPlist["CFBundleName"] as? String else { throw "Error reading name for \(bundleUrl.absoluteString)" }
                        idToName[CFBundleIdentifier] = CFBundleName
                    } else {
                        idToName[CFBundleIdentifier] = CFBundleIdentifier
                    }
                }
            } catch {
                UIApplication.shared.alert(body: "Error reading app information - \(error.localizedDescription)")
            }
        } else {
            for app in apps {
                // Get name
                let name = app.localizedName()
                idToName[app.applicationIdentifier()] = name
                
                // Get bundle
                let bundleUrl = app.bundleURL()
                idToBundle[app.applicationIdentifier()] = bundleUrl
            }
        }
    }

    private let fm: FileManager
    private var idToName: [String:String]
    private var idToBundle: [String:URL]
    private var idToColor: [String:UIColor]
    
    private func _getIcon(bundleUrl: URL) -> UIImage? {
        let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
        if !fm.fileExists(atPath: infoPlistUrl.path) {
            return nil
        }
        guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String:AnyObject] else { return nil }
        if infoPlist.keys.contains("CFBundleIcons") {
            guard let CFBundleIcons = infoPlist["CFBundleIcons"] as? [String:AnyObject] else { return nil }
            if CFBundleIcons.keys.contains("CFBundlePrimaryIcon") {
                guard let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String:AnyObject] else { return nil }
                if CFBundlePrimaryIcon.keys.contains("CFBundleIconName") {
                    // Check assets file, hope there's a better way than this
                    guard let CFBundleIconName = CFBundlePrimaryIcon["CFBundleIconName"] as? String else { return nil }
                    let assetsUrl = bundleUrl.appendingPathComponent("Assets.car")
                    do {
                        let (_, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: assetsUrl)
                        for rendition in renditionsRoot {
                            let renditions = rendition.renditions
                            for rend in renditions {
                                if rend.namedLookup.name == CFBundleIconName {
                                    guard let cgImage = rend.image else { return nil }
                                    return UIImage(cgImage: cgImage)
                                }
                            }
                        }
                    } catch {
                        // fall thru
                    }
                }
                if CFBundlePrimaryIcon.keys.contains("CFBundleIconFiles") {
                    // Check bundle file, happens when there is no assets.car
                    guard let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] else { return nil }
                    if !CFBundleIconFiles.isEmpty {
                        let iconName = CFBundleIconFiles[0]
                        let appIcon = _iconFromFile(iconName: iconName, bundleUrl: bundleUrl)
                        return appIcon
                    }
                }
            }
        }
        if infoPlist.keys.contains("CFBundleIconFile") {
            // Check bundle file, happens in the case of pseudo-installed apps
            guard let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String else { return nil }
            let appIcon = _iconFromFile(iconName: CFBundleIconFile, bundleUrl: bundleUrl)
            return appIcon
        }
        if infoPlist.keys.contains("CFBundleIconFiles") {
            // Check bundle file, only seen this happen in the case of Wallet
            guard let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String] else { return nil }
            if !CFBundleIconFiles.isEmpty {
                let iconName = CFBundleIconFiles[0]
                let appIcon = _iconFromFile(iconName: iconName, bundleUrl: bundleUrl)
                return appIcon
            }
        }
        // Nothing found
        return nil
    }
    
    // Get an app's icon from its bundle file
    private func _iconFromFile(iconName: String, bundleUrl: URL) -> UIImage? {
        var iconFile = ""
        var iconFound = true
        if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + ".png").path) {
            iconFile = iconName + ".png"
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "@2x.png").path) {
            iconFile = iconName + "@2x.png"
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "-large.png").path) {
            iconFile = iconName + "-large.png"
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "@23.png").path) {
            iconFile = iconName + "@23.png"
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "@3x.png").path) {
            iconFile = iconName + "@3x.png"
        } else {
            iconFound = false
        }

        if iconFound {
            let iconUrl = (bundleUrl.appendingPathComponent(iconFile))
            do {
                let iconData = try Data(contentsOf: iconUrl)
                guard let icon = UIImage(data: iconData) else { return nil }
                return icon
            } catch {
                return nil
            }
        }
        return nil
    }
    
    private func _getWebClipName(webClipID: String) -> String? {
        let infoPlistUrl = webClipFolderUrl.appendingPathComponent(webClipID + ".webclip").appendingPathComponent("Info.plist")
        if fm.fileExists(atPath: infoPlistUrl.path) {
            guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String:AnyObject] else { return nil }
            if infoPlist.keys.contains("Title") {
                guard let title = infoPlist["Title"] as? String else { return nil }
                return title
            }
        }
        return nil
    }
    
    private func _getWebClipIcon(webClipID: String) -> UIImage? {
        let iconUrl = webClipFolderUrl.appendingPathComponent(webClipID + ".webclip").appendingPathComponent("icon.png")
        if fm.fileExists(atPath: iconUrl.path) {
            do {
                let iconData = try Data(contentsOf: iconUrl)
                guard let icon = UIImage(data: iconData) else { return nil }
                return icon
            } catch {
                return nil
            }
        }
        return nil
    }
    
    /// Given an application/webclip identifier, return the average colour of its icon
    func getColor(id: String) -> UIColor {
        if let color = idToColor[id] {
            return color
        } else {
            if let bundleUrl = idToBundle[id] {
                // App
                guard let color = _getIcon(bundleUrl: bundleUrl)?.mergedColor() else { return UIColor.black }
                idToColor[id] = color
                return color
            } else {
                // Web clip
                guard let color = _getWebClipIcon(webClipID: id)?.mergedColor() else { return UIColor.black }
                idToColor[id] = color
                return color
            }
        }
    }
    
    /// Given an application/webclip identifier, return its name
    func getName(id: String) -> String {
        if let name = idToName[id] {
            return name
        } else {
            guard let webClipName = _getWebClipName(webClipID: id) else { return "" }
            idToName[id] = webClipName
            return webClipName
        }
    }
}

