//
//  CacheApp.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")

@main
struct CacheApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    print("Caché version \(appVersion)")
                    unsandbox()
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
