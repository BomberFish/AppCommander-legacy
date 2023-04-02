//
//  WhitelistManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-01.
//

import Foundation

public struct Whitelist {
    public static let blankplist = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdC8+CjwvcGxpc3Q+Cg=="

    public static func overwriteBlacklist() -> Bool {
        do {
            try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/Rejections.plist"), with: try! Data(base64Encoded: blankplist)! as NSData)
            return true
        } catch {
            return false
        }
    }

    public static func overwriteBannedApps() -> Bool {
        do {
            try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedUpps.plist"), with: try! Data(base64Encoded: blankplist)! as NSData)
            return true
        } catch {
            return false
        }
    }

    public static func overwriteCdHashes() -> Bool {
        do {
            try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedCdHashes.plist"), with: try! Data(base64Encoded: blankplist)! as NSData)
            return true
        } catch {
            return false
        }
    }

    public static func readFile(path: String) -> String? {
        return (try? String?(String(contentsOfFile: path)) ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?")
    }
}
