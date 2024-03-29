//
//  AppView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import AbsoluteSolver
import SwiftUI
import OSLog
import TelemetryClient

struct AppView: View {
    @State private var test: Bool = false
    @State public var bundleId: String
    @State public var name: String
    @State public var bundleurl: URL
    @State public var sbapp: SBApp
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    @State var ipapath: URL? = nil
    @State var dataDirectory: URL? = nil
    var currentAccentColor: Color {
        return Color(uiColor: ((cs == .light ? palette.DarkMuted?.uiColor : palette.Vibrant?.uiColor) ?? UIColor(named: "AccentColor"))!)
    }
    @State var palette: Palette = .init()
    @Environment(\.colorScheme) var cs
    let jit = JITManager.shared
    let logger = Logger(subsystem: "AppView", category: "Views")
    @AppStorage("vibrantTheming") var vibrantTheming: Bool = true
    
    
    var body: some View {
        List {
            Section {
                AppCell(bundleid: bundleId, name: name, large: true, link: false, bundleURL: bundleurl, sbapp: sbapp, tile: $test)
                Button(action: {
                    if ApplicationManager.openApp(bundleID: sbapp.bundleIdentifier) {
                        Haptic.shared.notify(.success)
                    } else {
                        Haptic.shared.notify(.error)
                    }
                }, label: {
                    Label("Open App", systemImage: "arrow.up.forward.app")
                })
                Button(action: {
                    let title = "Warning"
                    let message = "AppCommander will now try to enable JIT on \(sbapp.name). Make sure the app is opened in the background so we can find its PID and is signed with the same *developer* certificate used to sign AppCommander!"
                    let onOK: () -> Void = {
                        UIApplication.shared.alert(title: "Please wait", body: "Replacing DDI certificate...", withButton: false)
                        do {
                            TelemetryManager.send("jitAttempted")
                            try AbsoluteSolver.replaceDDICert()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                UIApplication.shared.changeBody("Enabling JIT...")
                                callps()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                UIApplication.shared.dismissAlert(animated: true)
                                jit.enableJIT(pidApp: jit.returnPID(exec: sbapp.name))
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if !(ApplicationManager.openApp(bundleID: sbapp.bundleIdentifier)) {
                                        UIApplication.shared.alert(body: "Could not open app \(sbapp.name)")
                                        Haptic.shared.notify(.error)
                                    }
                                }
                            }
                        } catch {
                            UIApplication.shared.alert(body: "Could not replace DDI cert! Error: \(error.localizedDescription)")
                        }
                    }
                    UIApplication.shared.confirmAlert(title: title, body: message, onOK: onOK, noCancel: false)
                }, label: {
                    Label("Open with JIT", systemImage: "sparkles")
                })
                
                NavigationLink(destination: { MoreInfoView(sbapp: sbapp) }, label: { Label("More Info", systemImage: "info.circle") })
            } header: { Label("App Details", systemImage: "info.circle") }
            Section {
                NavigationLink(destination: { BackupView(app: sbapp) }, label: { Label("Backup and Restore", systemImage: "externaldrive.badge.timemachine") })
            } header: {
                Label("Actions", systemImage: "gearshape.arrow.triangle.2.circlepath")
            }
            
            Section {
                NavigationLink(destination: FileBrowserView(path: (dataDirectory?.path ?? "/var/mobile") + "/", title: sbapp.name), label: {
                    Label("Browse app data", systemImage: "folder")
                })
            }
            
            Section {
                Button(role: .destructive) {
                    Haptic.shared.play(.medium)
                    UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Do you really want to do this?", onOK: {
                        Haptic.shared.play(.medium)
                        // on god fuck these warnings i could not give a singular flying fuck
                        do {
                            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                                UIApplication.shared.progressAlert(title: "Disassembling data of \(sbapp.name)...")
                                try AbsoluteSolver.delDirectoryContents(path: dataDirectory!.path, progress: { percentage, fileName in
                                    
                                    print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)", logger: logger)
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                                })
                            } else {
                                UIApplication.shared.progressAlert(title: "Deleting data of \(sbapp.name)...")
                                try delDirectoryContents(path: dataDirectory!.path, progress: { percentage, fileName in
                                    print("\(Int(percentage * 100))%: Deleting \(fileName)", logger: logger)
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Deleting \(fileName)")
                                })
                            }
                            // UIApplication.shared.alert(title: "Success", body: "Successfully deleted!"
                            UIApplication.shared.dismissAlert(animated: true)
                        } catch {
                            UIApplication.shared.dismissAlert(animated: true)
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }, destructActionText: "Delete")
                } label: {
                    Label("Delete app data", systemImage: "trash")
                        .foregroundColor(Color(UIColor.systemRed))
                }
                Button(role: .destructive) {
                    Haptic.shared.play(.medium)
                    UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Do you really want to do this?", onOK: {
                        Haptic.shared.play(.medium)
                        do {
                            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                                UIApplication.shared.progressAlert(title: "Disassembling documents of \(sbapp.name)...")
                                try AbsoluteSolver.delDirectoryContents(path: dataDirectory!.appendingPathComponent("Documents").path, progress: { percentage, fileName in
                                    print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)", logger: logger)
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                                })
                            } else {
                                UIApplication.shared.progressAlert(title: "Deleting documents of \(sbapp.name)...")
                                try delDirectoryContents(path: dataDirectory!.appendingPathComponent("Documents").path, progress: { percentage, fileName in
                                    print("\(Int(percentage * 100))%: Deleting \(fileName)", logger: logger)
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Deleting \(fileName)")
                                })
                            }
                            UIApplication.shared.dismissAlert(animated: true)
                        } catch {
                            UIApplication.shared.dismissAlert(animated: true)
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }, destructActionText: "Delete")
                } label: {
                    if !(FileManager.default.fileExists(atPath: dataDirectory?.appendingPathComponent("Documents").path ?? "/yourmother6969696969696969")) {
                        Label("Delete app documents", systemImage: "trash")
                    } else {
                        Label("Delete app documents", systemImage: "trash")
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }
                .disabled(!(FileManager.default.fileExists(atPath: dataDirectory?.appendingPathComponent("Documents").path ?? "/yourmother6969696969696969")))
                
                Button {
                    Haptic.shared.play(.medium)
                    let cachedir = ((dataDirectory!.appendingPathComponent("Library")).appendingPathComponent("Caches"))
                    print(cachedir, loglevel: .debug, logger: logger)
                    do {
                        if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                            UIApplication.shared.progressAlert(title: "Disassembling cache of \(sbapp.name)...")
                            try AbsoluteSolver.delDirectoryContents(path: cachedir.path, progress: { percentage, fileName in
                                print(percentage, fileName)
                                print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)", logger: logger)
                                UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                            })
                        } else {
                            UIApplication.shared.progressAlert(title: "Deleting cache of \(sbapp.name)...")
                            try delDirectoryContents(path: cachedir.path, progress: { percentage, fileName in
                                print("\(Int(percentage * 100))%: Deleting \(fileName)", logger: logger)
                                UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Deleting \(fileName)")
                            })
                        }
                        UIApplication.shared.dismissAlert(animated: true)
                    } catch {
                        UIApplication.shared.dismissAlert(animated: true)
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                } label: {
                    Label("Delete app cache", systemImage: "trash")
                }
                .disabled(!(FileManager.default.fileExists(atPath: dataDirectory?.appendingPathComponent("Library").appendingPathComponent("Caches").path ?? "/")))
            }
            
            Section {
                Button {
                    UIApplication.shared.progressAlert(title: "Exporting IPA of \(sbapp.name)...")
                    Task {
                        Haptic.shared.play(.medium)
                        do {
                            ipapath = try await ApplicationManager.exportIPA(app: sbapp)
                            UIApplication.shared.dismissAlert(animated: true)
                        } catch {
                            UIApplication.shared.dismissAlert(animated: true)
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                        UIApplication.shared.dismissAlert(animated: true)
                        sleep(UInt32(0.5))
                        if ipapath != nil {
                            UIApplication.shared.dismissAlert(animated: true)
                            let vc = UIActivityViewController(activityItems: [ipapath as Any], applicationActivities: nil)
                            Haptic.shared.notify(.success)
                            vc.isModalInPresentation = true
                            UIApplication.shared.dismissAlert(animated: true)
                            UIApplication.shared.windows[0].rootViewController?.present(vc, animated: true)
                            UIApplication.shared.dismissAlert(animated: true)
                            vc.isModalInPresentation = true
                        } else {
                            UIApplication.shared.dismissAlert(animated: true)
                            UIApplication.shared.alert(body: "Error!")
                        }
                    }
                } label: {
                    Label("Export Encrypted IPA", systemImage: "arrow.down.app")
                }
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.automatic)
            .task(priority: .utility) {
                do {
                    dataDirectory = try ApplicationManager.getDataDir(bundleID: bundleId)
                } catch {
                    UIApplication.shared.alert(body: error.localizedDescription)
                }
            }
            .task(priority: .background) {
                if vibrantTheming {
                    self.palette = Vibrant.from((UIImage(contentsOfFile: sbapp.bundleURL.appendingPathComponent(sbapp.pngIconPaths.first ?? "").path) ?? UIImage(named: "Placeholder"))!).getPalette()
                }
            }
        }
        // .background(GradientView())
        .listRowBackground(Color.clear)
        .tint(currentAccentColor)
        .animation(.easeInOut(duration: 0.25), value: currentAccentColor)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(bundleId: "com.example.placeholder", name: "Placeholder", bundleurl: URL(string: "/path/to/foo/bar/baz")!, sbapp: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
