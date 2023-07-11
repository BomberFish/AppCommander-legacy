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
import OSLog
import TelemetryClient

let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
let consoleManager = LCManager.shared
let funny: URL = Bundle.main.url(forResource: "bite_me", withExtension: "png")! //equivalent of the fabled coconut.jpg from tf2
var currentAppMode: ApplicationMode = ApplicationMode.MacDirtyCow
let aslogger = Logger(subsystem: "AbsoluteSolver", category: "")
// var escaped = false
// var has_cooked = false
let analyticsLogger = Logger(subsystem: "Analytics", category: "Telemetry")

@main
struct AppCommanderApp: App {
    @AppStorage("analyticsEnabled") var analyticsEnabled: Bool = true
    @AppStorage("launchedBefore") var launchedBefore: Bool = false
    
    init() {
        /// This initializes analytics from TelemetryDeck. By default the API keys are not included in the public source release. You can supply your own by setting the `telemetryDeckID` variable. It is recommended to store it in a file named `APIKeys.swift` in the top-level directory of the repository, as the path is included in the gitignore.
        if telemetryDeckID != nil {
            if analyticsEnabled {
                //initialize analytics
                print("Initializing Analytics...", loglevel: .info, logger: analyticsLogger)
                let configuration = TelemetryManagerConfiguration(appID: telemetryDeckID)
                TelemetryManager.initialize(with: configuration)
                print("Sending app launch signal!", loglevel: .info, logger: analyticsLogger)
                TelemetryManager.send("appLaunchedRegularly") // TODO: Add more signals
            } else {
                print("Analytics disabled by user.", loglevel: .info, logger: analyticsLogger)
            }
        } else {
            print("No Analytics ID provided!", loglevel: .fault, logger: analyticsLogger)
        }
    }
    fileprivate let logger = Logger(subsystem: "AppCommanderApp", category: "Uncategorized")
    @State var escaped = false
    @State var has_cooked = true
    var body: some Scene {
        WindowGroup {
            ZStack {
                if escaped && has_cooked {
                    RootView()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
                        .task(priority: .high)  {
                            let userDefaults = UserDefaults.standard
                            // check for updates. this would be replaced by kouyou but its JUST NOT FINISHED!!!!!!!!!!!!!!
                            // F1shy I'm begging you PLEASE just FINISH the frontend PLEASE
                            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/BomberFish/AppCommander/releases/latest") {
                                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                                    guard let data = data else { return }

                                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                        if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                            print("Update found: \(appVersion) -> \(json["tag_name"] ?? "null")", loglevel: .debug, logger: logger)
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
                                 print("Not first launch.")
                                // UIApplication.shared.alert(title: "⚠️ IMPORTANT ⚠️", body: "This app is still very much in development. If anything happens to your device, I will point and laugh at you.")
                            } else {
                                 print("First launch, displaying telemetry notice.")
                                // FIXME: body really sucks
                                UIApplication.shared.alert(title: "Notice", body: "AppCommander uses anonymized telemetry for analytics purposes. You can change your preference anytime in Settings.")
                                launchedBefore = true
                            }

                            if !(userDefaults.bool(forKey: "AbsoluteSolverDisabled")) {
                                print("Absolute Solver ENABLED", loglevel: .debug, logger: logger)
                            } else {
                                print("Absolute Solver DISABLED", loglevel: .debug, logger: logger)
                            }
                            if FileManager.default.fileExists(atPath: (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Backups")).path) {
                                print("Backups not migrated, migrating now.", loglevel: .info, logger: logger)
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
                                print("Backups already migrated.", loglevel: .debug, logger: logger)
                            }
                            // }
                        }
                } else {
                    LoadingView()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
                }
            }
            .task(priority: .high)  {
                print("AppCommander v\(appVersion)", loglevel: .info, logger: logger)

                DispatchQueue.global(qos: .background).sync {
                    Whitelist.top_secret_sauce { baked_goods in
                        has_cooked = true
                        if baked_goods == false {
                            print("piss off pirate cunt", loglevel: .fault, logger: logger)
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
                        print("Throwing not supported error (mdc patched)", loglevel: .error, logger: logger)
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
                            print("Using TrollStore.", loglevel: .info, logger: logger)
                            currentAppMode = .TrollStore
                            UIApplication.shared.alert(title: "Warning", body: "AppCommander has detected it has been installed using TrollStore, which is not fully supported. Press OK to continue.")
                        } catch {
                            // grant r/w access
                                print("Using MacDirtyCow.", loglevel: .info, logger: logger)
                                currentAppMode = .MacDirtyCow
                                // asyncAfter(deadline: .now())
                                sleep(UInt32(0.2))
                                print("Escaping Sandbox...", loglevel: .debug, logger: logger)
                                do {
                                    try MacDirtyCow.unsandbox()
                                    escaped = true
                                    print("Successfully escaped sandbox!", loglevel: .debug, logger: logger)
                                } catch {
                                    escaped = false
                                    var message = ""
                                    if error.localizedDescription == "" {
                                        // epic amiga reference
                                        message = "Error 48454C50. Please contact BomberFish."
                                    } else {
                                        message = error.localizedDescription
                                    }
                                    print("Unsandboxing error: \(message)", loglevel: .error, logger: logger)
                                    UIApplication.shared.choiceAlert(title: "💣 GURU MEDITATION ERROR 💣", body: "Unsandboxing Error: \(message)\nPlease close the app and retry. If the problem persists, reboot your device.", confirmTitle: "Dismiss", cancelTitle: "Reboot", yesAction: reboot, noAction: { escaped = true })
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
