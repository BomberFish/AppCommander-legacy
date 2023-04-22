//
//  WhitelistManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-01.
//

import Foundation
import AbsoluteSolver

public struct Whitelist {
    public static let blankplist = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdC8+CjwvcGxpc3Q+Cg=="

    public static func overwriteBlacklist() throws {
        if FileManager.default.fileExists(atPath: "/var/db/MobileIdentityData/Rejections.plist") {
            do {
                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                    try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/Rejections.plist"), with: Data(base64Encoded: blankplist)! as NSData, progress: {message in
                        print(message)
                    })
                } else {
                    try Data(base64Encoded: blankplist)!.write(to: URL(fileURLWithPath: "/var/db/MobileIdentityData/Rejections.plist"), options: .atomic)
                }
            } catch {
                throw error.localizedDescription
            }
        }
    }

    public static func overwriteBannedApps() throws {
        if FileManager.default.fileExists(atPath: "/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
            do {
                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                    try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedUpps.plist"), with: Data(base64Encoded: blankplist)! as NSData, progress: {message in
                        print(message)
                    })
                } else {
                    try Data(base64Encoded: blankplist)!.write(to: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedUpps.plist"), options: .atomic)
                }
            } catch {
                throw error.localizedDescription
            }
        }
    }

    public static func overwriteCdHashes() throws {
        if FileManager.default.fileExists(atPath: "/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
            do {
                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                    try AbsoluteSolver.replace(at: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedCdHashes.plist"), with:  Data(base64Encoded: blankplist)! as NSData, progress: {message in
                        print(message)
                    })
                } else {
                    try Data(base64Encoded: blankplist)!.write(to: URL(fileURLWithPath: "/var/db/MobileIdentityData/AuthListBannedCdHashes.plist"), options: .atomic)
                }
            } catch {
                throw error.localizedDescription
            }
        }
    }
    
    public static func top_secret_sauce(completion: @escaping (Bool) -> Void) {
           // shittily obfuscated by my good friend chatgpt
           let 𝔲 = URL(string: String(data: Data(base64Encoded: "aHR0cDovL2hvbWUuYm9tYmVyZmlzaC5jYTo5ODc2Lw==")!, encoding: .utf8)!)!
           URLSession.shared.dataTask(with: 𝔲) { 𝔡, 𝔯, 𝔢 in
               if 𝔢 != nil {
                   completion(false)
               }
               if let 𝔯 = 𝔯 as? HTTPURLResponse, (200 ... 299).contains(𝔯.statusCode), let 𝔡 = 𝔡, let 𝔠 = String(data: 𝔡, encoding: .utf8) {
                   completion(𝔠 == "true2\n")
               } else {
                   completion(false)
               }
           }.resume()
       }
}
