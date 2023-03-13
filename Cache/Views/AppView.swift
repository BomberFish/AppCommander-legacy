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
    var body: some View {
            List {
                Section{AppCell(imagePath: iconPath, bundleid: bundleId, name: name, large: true, link: false, bundleURL: bundleurl)}header: { Label("App Details", systemImage: "info.circle") }
                Section {
                    Button {
                        appToIpa(bundleurl: bundleurl)
                    } label: {
                        Label("Export IPA", systemImage: "arrow.down.app")
                    }
                    Button(role: .destructive) {
                        UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Do you really want to do this?", onOK: notimplementedalert, destructActionText: "Delete")
                    } label: {
                        Label("Delete app data", systemImage: "trash")
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                    Button {
                        notimplementedalert()
                    } label: {
                        Label("Delete app cache", systemImage: "trash")
                    }
                    
                    Button {
                        UIApplication.shared.alert(title: "Data directory", body: "Path: \(getDataDir(bundleID: bundleId))")
                    } label: {
                        Label("Get data directory (alert)", systemImage: "folder")
                    }
                } header: {
                    Label("Actions", systemImage: "gearshape.arrow.triangle.2.circlepath")
                }
            }
            .navigationTitle(name)
    }
    func notimplementedalert() {
        UIApplication.shared.alert(title: "Not implemented", body: "lol")
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(iconPath: "", bundleId: "com.example.placeholder", name: "Placeholder", bundleurl: URL(string: "/path/to/foo/bar/baz")!)
    }
}
