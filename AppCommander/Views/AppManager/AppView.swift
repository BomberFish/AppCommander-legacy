//
//  AppView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import SwiftUI

struct AppView: View {
    @State public var iconPath: String
    @State public var bundleId: String
    @State public var name: String
    @State public var bundleurl: URL
    @State public var sbapp: SBApp
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
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
                NavigationLink(destination: { MoreInfoView(sbapp: sbapp, iconPath: iconPath) }, label: { Label("More Info", systemImage: "info.circle") })
            } header: { Label("App Details", systemImage: "info.circle") }

            if debugEnabled {
                Section {
                    NavigationLink(destination: { BackupView(app: sbapp) }, label: { Label("Backup and Restore [EXPERIMENTAL]", systemImage: "externaldrive.badge.timemachine") })
                } header: {
                    Label("Actions", systemImage: "gearshape.arrow.triangle.2.circlepath")
                }
            }

            Section {
                Button(role: .destructive) {
                    Haptic.shared.play(.medium)
                    UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Do you really want to do this?", onOK: {
                        Haptic.shared.play(.medium)
                        // on god fuck these warnings i could not give a singular flying fuck
                        do {
                            try FileActionManager.delDirectoryContents(path: ApplicationManager.getDataDir(bundleID: bundleId).path)
                            UIApplication.shared.alert(title: "Success", body: "Successfully deleted!")
                        } catch {
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
                        let dataDirectory = ApplicationManager.getDataDir(bundleID: bundleId)
                        do {
                            try FileActionManager.delDirectoryContents(path: dataDirectory.appendingPathComponent("Documents").path)
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }, destructActionText: "Delete")
                } label: {
                    Label("Delete app documents", systemImage: "trash")
                        .foregroundColor(Color(UIColor.systemRed))
                }
                Button {
                    Haptic.shared.play(.medium)
                    let dataDirectory = ApplicationManager.getDataDir(bundleID: bundleId)
                    let cachedir = ((dataDirectory.appendingPathComponent("Library")).appendingPathComponent("Caches"))
                    print(cachedir)
                    do {
                        try FileActionManager.delDirectoryContents(path: ((dataDirectory.appendingPathComponent("Library")).appendingPathComponent("Caches")).path)
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                } label: {
                    Label("Delete app cache", systemImage: "trash")
                }
            } header: {
                if !debugEnabled {
                    Label("Actions", systemImage: "gearshape.arrow.triangle.2.circlepath")
                }
            }

            Section {
                Button {
                    Haptic.shared.play(.medium)
                    ApplicationManager.exportIPA(app: sbapp)
                } label: {
                    Label("Export Encrypted IPA", systemImage: "arrow.down.app")
                }
            }
        }
        .navigationTitle(name)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(iconPath: "", bundleId: "com.example.placeholder", name: "Placeholder", bundleurl: URL(string: "/path/to/foo/bar/baz")!, sbapp: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
