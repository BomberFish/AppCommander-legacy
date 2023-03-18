//
//  CacheApp.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI
import LocalConsole

let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
let consoleManager = LCManager.shared
let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

@main
struct AppCommanderApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    print("AppCommander version \(appVersion)")
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/BomberFish/AppCommander/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                            guard let data = data else { return }

                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    print("Update found: \(appVersion) -> \(json["tag_name"] ?? "null")")
                                    UIApplication.shared.confirmAlert(title: "Update available!", body: "A new app update is available, do you want to visit the releases page?", onOK: {
                                        UIApplication.shared.open(URL(string: "https://github.com/BomberFish/AppCommander/releases/latest")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }

                    Haptic.shared.notify(.success)
                    consoleManager.isVisible = UserDefaults.standard.bool(forKey: "LCEnabled")
                    if launchedBefore  {
                        print("Not first launch.")
                        UIApplication.shared.alert(title: "⚠️ IMPORTANT ⚠️", body: "This app is still very much in development. If anything happens to your device, I will point and laugh at you.")
                    } else {
                        print("First launch, setting UserDefault.")
                        // FIXME: body really sucks
                        UIApplication.shared.choiceAlert(title: "Analytics", body: "Allow AppCommander to send anonymized data to improve your experience?", onOK: {
                            UserDefaults.standard.set(1, forKey: "analyticsLevel")
                            UIApplication.shared.alert(title: "⚠️ IMPORTANT ⚠️", body: "This app is still very much in development. If anything happens to your device, I will point and laugh at you.")
                        })
                        UserDefaults.standard.set(true, forKey: "launchedBefore")
                    }
                }
        }
    }
}
