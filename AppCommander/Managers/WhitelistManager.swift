//
//  WhitelistManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-01.
//

import Foundation

public struct Whitelist {
    public static let blankplist = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdC8+CjwvcGxpc3Q+Cg=="

    public static func overwriteBlacklist() throws {
        if FileManager.default.fileExists(atPath: "/var/db/MobileIdentityData/Rejections.plist") {
            do {
                try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/Rejections.plist"), with: Data(base64Encoded: blankplist)! as NSData)
            } catch {
                throw error.localizedDescription
            }
        }
    }

    public static func overwriteBannedApps() throws {
        if FileManager.default.fileExists(atPath: "/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
            do {
                try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedUpps.plist"), with: Data(base64Encoded: blankplist)! as NSData)
            } catch {
                throw error.localizedDescription
            }
        }
    }

    public static func overwriteCdHashes() throws {
        if FileManager.default.fileExists(atPath: "/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
            do {
                try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedCdHashes.plist"), with:  Data(base64Encoded: blankplist)! as NSData)
            } catch {
                throw error.localizedDescription
            }
        }
    }
}
