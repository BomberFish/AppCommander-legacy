//
//  AppView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import AbsoluteSolver
import SwiftUI

struct AppView: View {
    @State public var iconPath: String
    @State public var bundleId: String
    @State public var name: String
    @State public var bundleurl: URL
    @State public var sbapp: SBApp
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    @State var ipapath: URL? = nil
    @State var dataDirectory: URL? = nil
    let jit = JITManager.shared
    var body: some View {
        List {
            Section {
                AppCell(imagePath: iconPath, bundleid: bundleId, name: name, large: true, link: false, bundleURL: bundleurl, sbapp: sbapp)
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
                    let message = "We will now try to enable JIT on \(sbapp.name). Make sure the app is opened in the background so we can find its PID and is signed with a free developer certificate!"
                    let onOK: () -> Void = {
                        UIApplication.shared.alert(title: "Please wait", body: "Enabling JIT...", withButton: false)
                        
                        callps()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            UIApplication.shared.dismissAlert(animated: true)
                            jit.enableJIT(pidApp: jit.returnPID(exec: sbapp.name))
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                ApplicationManager.openApp(bundleID: sbapp.bundleIdentifier)
                            }
                        }
                    }
                    UIApplication.shared.confirmAlert(title: title, body: message, onOK: onOK, noCancel: false)
                }, label: {
                    Label("Open with JIT", systemImage: "sparkles")
                })
                    
                NavigationLink(destination: { MoreInfoView(sbapp: sbapp, iconPath: iconPath) }, label: { Label("More Info", systemImage: "info.circle") })
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
                                    
                                    print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)")
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                                })
                            } else {
                                UIApplication.shared.progressAlert(title: "Deleting data of \(sbapp.name)...")
                                try delDirectoryContents(path: dataDirectory!.path, progress: { percentage, fileName in
                                    print("\(Int(percentage * 100))%: Deleting \(fileName)")
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
                                    print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)")
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                                })
                            } else {
                                UIApplication.shared.progressAlert(title: "Deleting documents of \(sbapp.name)...")
                                try delDirectoryContents(path: dataDirectory!.appendingPathComponent("Documents").path, progress: { percentage, fileName in
                                    print("\(Int(percentage * 100))%: Deleting \(fileName)")
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
                    print(cachedir)
                    do {
                        if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                            UIApplication.shared.progressAlert(title: "Disassembling cache of \(sbapp.name)...")
                            try AbsoluteSolver.delDirectoryContents(path: cachedir.path, progress: { percentage, fileName in
                                print(percentage, fileName)
                                print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)")
                                UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                            })
                        } else {
                            UIApplication.shared.progressAlert(title: "Deleting cache of \(sbapp.name)...")
                            try delDirectoryContents(path: cachedir.path, progress: { percentage, fileName in
                                print("\(Int(percentage * 100))%: Deleting \(fileName)")
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
                    // UIApplication.shared.progressAlert(title: "Exporting IPA of \(sbapp.name)...")

                    Haptic.shared.play(.medium)
                    do {
                        ipapath = try ApplicationManager.exportIPA(app: sbapp)
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

                } label: {
                    Label("Export Encrypted IPA", systemImage: "arrow.down.app")
                }
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.automatic)
            .onAppear {
                do {
                    dataDirectory = try ApplicationManager.getDataDir(bundleID: bundleId)
                } catch {
                    UIApplication.shared.alert(body: error.localizedDescription)
                }
            }
        }
        // .background(GradientView())
                .listRowBackground(Color.clear)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(iconPath: "", bundleId: "com.example.placeholder", name: "Placeholder", bundleurl: URL(string: "/path/to/foo/bar/baz")!, sbapp: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
