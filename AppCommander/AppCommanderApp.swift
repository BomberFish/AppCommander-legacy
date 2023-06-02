//
//  CacheApp.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import AbsoluteSolver
import LocalConsole
@preconcurrency import MacDirtyCow
import SwiftUI

let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
let consoleManager = LCManager.shared
let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
let funny: URL = Bundle.main.url(forResource: "bite_me", withExtension: "png")! //equivalent of the fabled coconut.jpg from tf2
// var escaped = false
// var has_cooked = false

@main
struct AppCommanderApp: App {
    init() {
        UITableView.appearance().backgroundColor = .clear
    }

    @State var escaped = false
    @State var has_cooked = true
    var body: some Scene {
        WindowGroup {
            ZStack {
                if escaped && has_cooked {
                    RootView()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
                        .onAppear {
                            let userDefaults = UserDefaults.standard
                            // check for updates. this would be replaced by kouyou but its JUST NOT FINISHED!!!!!!!!!!!!!!
                            // F1shy I'm begging you PLEASE just FINISH the frontend PLEASE
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
                            consoleManager.isVisible = userDefaults.bool(forKey: "LCEnabled")
                            // DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                            // i just copied the entire code block, prints and everything, from stackoverflow.
                            // Will I change it at all? No!
                            if launchedBefore {
                                // print("Not first launch.")
                                // UIApplication.shared.alert(title: "⚠️ IMPORTANT ⚠️", body: "This app is still very much in development. If anything happens to your device, I will point and laugh at you.")
                            } else {
                                // print("First launch, setting UserDefault.")
                                // FIXME: body really sucks
//                                    UIApplication.shared.choiceAlert(title: "Analytics", body: "Allow AppCommander to send anonymized data to improve your experience?", yesAction: {
//                                        userDefaults.set(1, forKey: "analyticsLevel")
//                                        userDefaults.set(true, forKey: "launchedBefore")
//                                    }, noAction: {
//                                        userDefaults.set(0, forKey: "analyticsLevel")
//                                        userDefaults.set(true, forKey: "launchedBefore")
//                                    })
                            }

                            if !(userDefaults.bool(forKey: "AbsoluteSolverDisabled")) {
                                print("Absolute Solver ENABLED")
                            } else {
                                print("Absolute Solver DISABLED")
                            }
                            if FileManager.default.fileExists(atPath: (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Backups")).path) {
                                print("Backups not migrated, migrating now.")
                                UIApplication.shared.progressAlert(title: "Migrating backups...")
                                if userDefaults.bool(forKey: "AbsoluteSolverDisabled") {
                                    do {
                                        if FileManager.default.fileExists(atPath: "/var/mobile/.DO_NOT_DELETE-AppCommander") {
                                            try FileManager.default.createDirectory(at: URL(fileURLWithPath: "/var/mobile/.DO_NOT_DELETE-AppCommander"), withIntermediateDirectories: true)
                                        }
                                        try FileManager.default.copyItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], to: URL(fileURLWithPath: "/var/mobile/.DO_NOT_DELETE-AppCommander"))
                                        try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Backups"))
                                        UIApplication.shared.dismissAlert(animated: true)
                                        Haptic.shared.notify(.success)
                                    } catch {
                                        UIApplication.shared.dismissAlert(animated: true)
                                        Haptic.shared.notify(.error)
                                        UIApplication.shared.alert(body: "Error migrating backups: \(error.localizedDescription). Reopen the app to try again.", withButton: false)
                                    }
                                } else {
                                    do {
                                        if FileManager.default.fileExists(atPath: "/var/mobile/.DO_NOT_DELETE-AppCommander") {
                                            try FileManager.default.createDirectory(at: URL(fileURLWithPath: "/var/mobile/.DO_NOT_DELETE-AppCommander"), withIntermediateDirectories: true)
                                        }
                                        try AbsoluteSolver.copy(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], to: URL(fileURLWithPath: "/var/mobile/.DO_NOT_DELETE-AppCommander"), progress: { message in
                                            UIApplication.shared.changeBody("\n\n\n\(message)")
                                        })
                                        try AbsoluteSolver.delete(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Backups"), progress: { message in
                                            UIApplication.shared.changeBody("\n\n\n\(message)")
                                        })
                                        UIApplication.shared.dismissAlert(animated: true)
                                        Haptic.shared.notify(.success)
                                    } catch {
                                        UIApplication.shared.dismissAlert(animated: true)
                                        Haptic.shared.notify(.error)
                                        UIApplication.shared.alert(body: "Error migrating backups: \(error.localizedDescription). Reopen the app to try again.", withButton: false)
                                    }
                                }
                            } else {
                                print("Backups already migrated.")
                            }
                            // }
                        }
                } else {
                    LoadingView()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
                }
            }
            .onAppear {
                print("AppCommander v\(appVersion)")

                DispatchQueue.global(qos: .background).sync {
                    Whitelist.top_secret_sauce { baked_goods in
                        has_cooked = true
                        if baked_goods == false {
                            print("piss off pirate cunt")
                            DispatchQueue.main.async {
                                UIApplication.shared.alert(title: "Uh oh... 🏴‍☠️", body: "Looks like you're using a leaked build! Crashing in 5 seconds... Begone, pirate!", withButton: false)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000)) {
                                fatalError("piss off pirate cunt")
                            }
                        }
                    }
                }

                #if targetEnvironment(simulator)
                    escaped = true
                #else
                    if #available(iOS 16.2, *) {
                        // I'm sorry 16.2 dev beta 1 users, you are a vast minority.
                        print("Throwing not supported error (mdc patched)")
                        DispatchQueue.main.async {
                            UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.")
                        }
                        escaped = false
                    } else {
                        do {
                            if UserDefaults.standard.bool(forKey: "ForceMDC") == true {
                                throw "Force MDC"
                            }
                            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                            print("Using TrollStore.")
                        } catch {
                            // grant r/w access
                            
                            // ok this check is probably 100% useless
                            if #available(iOS 15, *) {
                                print("Using MacDirtyCow.")
                                // asyncAfter(deadline: .now())
                                sleep(UInt32(0.2))
                                print("Escaping Sandbox...")
                                do {
                                    try MacDirtyCow.unsandbox()
                                    escaped = true
                                    print("Successfully escaped sandbox!")
                                } catch {
                                    escaped = false
                                    var message = ""
                                    if error.localizedDescription == "" {
                                        // epic amiga reference
                                        message = "Error 48454C50. Please contact BomberFish."
                                    } else {
                                        message = error.localizedDescription
                                    }
                                    print("Unsandboxing error: \(message)")
                                    UIApplication.shared.choiceAlert(title: "💣 GURU MEDITATION ERROR 💣", body: "Unsandboxing Error: \(message)\nPlease close the app and retry. If the problem persists, reboot your device.", confirmTitle: "Dismiss", cancelTitle: "Reboot", yesAction: reboot, noAction: { escaped = true })
                                }
                            }
                        }
                    }
                #endif
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        MacDirtyCow.isMDCSafe = false
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.register(defaults: ["AbsoluteSolverDisabled": false])
        return true
    }
}
