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
    var body: some View {
        List {
            Section {
                AppCell(imagePath: iconPath, bundleid: bundleId, name: name, large: true, link: false, bundleURL: bundleurl, sbapp: sbapp)
                NavigationLink(destination: { MoreInfoView(sbapp: sbapp, iconPath: iconPath) }, label: { Label("More Info", systemImage: "info.circle") })
            } header: { Label("App Details", systemImage: "info.circle") }
            Section {
                Button(role: .destructive) {
                    Haptic.shared.play(.medium)
                    UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Do you really want to do this?", onOK: {
                        Haptic.shared.play(.medium)
                        // god fuck these warnings i could not give a singular flying fuck
                        delDirectoryContents(path: getDataDir(bundleID: bundleId).absoluteString)
                    }, destructActionText: "Delete")
                } label: {
                    Label("Delete app data", systemImage: "trash")
                        .foregroundColor(Color(UIColor.systemRed))
                }
                Button(role: .destructive) {
                    Haptic.shared.play(.medium)
                    UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Do you really want to do this?", onOK: {
                        Haptic.shared.play(.medium)
                        let dataDirectory = getDataDir(bundleID: bundleId)
                        delDirectoryContents(path: dataDirectory.appendingPathComponent("Documents").absoluteString)
                    }, destructActionText: "Delete")
                } label: {
                    Label("Delete app documents", systemImage: "trash")
                        .foregroundColor(Color(UIColor.systemRed))
                }
                Button {
                    Haptic.shared.play(.medium)
                    let dataDirectory = getDataDir(bundleID: bundleId)
                    delDirectoryContents(path: ((dataDirectory.appendingPathComponent("Library")).appendingPathComponent("Caches")).absoluteString)
                } label: {
                    Label("Delete app cache", systemImage: "trash")
                }

//                    Button {
//                        UIApplication.shared.alert(title: "Data directory", body: "Path: \(getDataDir(bundleID: bundleId))")
//                    } label: {
//                        Label("Get data directory (alert)", systemImage: "folder")
//                    }

                Button {
                    Haptic.shared.play(.medium)
                    appToIpa(bundleurl: bundleurl)
                } label: {
                    Label("Export IPA (Currently broken)", systemImage: "arrow.down.app")
                }
            } header: {
                Label("Actions", systemImage: "gearshape.arrow.triangle.2.circlepath")
            }
        }
        .navigationTitle(name)
    }

    // 💀
    func notimplementedalert() {
        UIApplication.shared.alert(title: "Not implemented", body: "lol")
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(iconPath: "", bundleId: "com.example.placeholder", name: "Placeholder", bundleurl: URL(string: "/path/to/foo/bar/baz")!, sbapp: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
