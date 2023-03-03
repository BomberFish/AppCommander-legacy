//
//  CacheApp.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

var isUnsandboxed = false
let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")

@main
struct CacheApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("Caché version \(appVersion)")
                    if #available(iOS 16.2, *) {
                        #if targetEnvironment(simulator)
                        #else
                        // I'm sorry 16.2 dev beta 1 users, you are a vast minority.
                        print("Throwing not supported error (mdc patched)")
                        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.", withButton: false)
                        #endif
                    } else {
                        do {
                            // TrollStore method
                            print("Checking if installed with TrollStore...")
                            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                            print("99% probably installed with TrollStore")
                            isUnsandboxed = true
                        } catch {
                            isUnsandboxed = false
                            print("Trying MDC method...")
                            // MDC method
                            // grant r/w access
                            if #available(iOS 15, *) {
                                print("Escaping Sandbox...")
                                grant_full_disk_access { error in
                                    if error != nil {
                                        print("Unable to escape sandbox!! Error: ", String(describing: error?.localizedDescription ?? "unknown?!"))
                                        UIApplication.shared.alert(title: "Access Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.", withButton: false)
                                        isUnsandboxed = false
                                    } else {
                                        print("Successfully escaped sandbox!")
                                    }
                                }
                                isUnsandboxed = true
                            } else {
                                print("Throwing not supported error (too old?!)")
                                UIApplication.shared.alert(title: "Exploit Not Supported", body: "Please install via TrollStore")
                                isUnsandboxed = false
                            }
                        }
                    }
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/BomberFish/Caché/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                            guard let data = data else { return }

                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    print("Update found: \(appVersion) -> \(json["tag_name"] ?? "null")")
                                    UIApplication.shared.confirmAlert(title: "Update available!", body: "A new app update is available, do you want to visit the releases page?", onOK: {
                                        UIApplication.shared.open(URL(string: "https://github.com/BomberFish/Caché/releases/latest")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }

                    Haptic.shared.notify(.success)
                    UIApplication.shared.alert(title: "Please read", body: "This app is still very much in development. If you bootloop, I will laugh at you.")
                }
        }
    }
}
