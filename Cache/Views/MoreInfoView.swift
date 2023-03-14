//
//  MoreInfoView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-14.
//

import SwiftUI

struct MoreInfoView: View {
    @State public var sbapp: SBApp
    @State public var iconPath: String
    var body: some View {
        List {
            Text("Name: \(sbapp.name)")
                .contextMenu {
                    Button(action: {UIPasteboard.general.string = sbapp.name}, label: {Label("Copy", systemImage: "doc.on.clipboard")})
                }
            Text("Bundle ID: \(sbapp.bundleIdentifier)")
                .contextMenu {
                    Button(action: {UIPasteboard.general.string = sbapp.bundleIdentifier}, label: {Label("Copy", systemImage: "doc.on.clipboard")})
                }
            Text("Version: \(sbapp.version)")
                .contextMenu {
                    Button(action: {UIPasteboard.general.string = sbapp.name}, label: {Label("Copy", systemImage: "doc.on.clipboard")})
                }
            Text("Bundle Path: \(sbapp.bundleURL.path)")
                .contextMenu {
                    if isFilzaInstalled() {
                        Button(action: {openInFilza(path: sbapp.bundleURL.path)}, label: {Label("Open in Filza", systemImage: "arrow.up.forward.app")})
                    }
                    if isSantanderInstalled() {
                        Button(action: {openInFilza(path: sbapp.bundleURL.path)}, label: {Label("Open in Santander", systemImage: "arrow.up.forward.app")})
                    }
                }
            Text("Data directory: \(getDataDir(bundleID: sbapp.bundleIdentifier))")
                .contextMenu {
                    if isFilzaInstalled() {
                        Button(action: {openInFilza(path: getDataDir(bundleID: sbapp.bundleIdentifier).path)}, label: {Label("Open in Filza", systemImage: "arrow.up.forward.app")})
                    }
                    if isSantanderInstalled() {
                        Button(action: {openInFilza(path: getDataDir(bundleID: sbapp.bundleIdentifier).path)}, label: {Label("Open in Santander", systemImage: "arrow.up.forward.app")})
                    }
                    Button(action: {UIPasteboard.general.string =  getDataDir(bundleID: sbapp.bundleIdentifier).path}, label: {Label("Copy", systemImage: "doc.on.clipboard")})
                }
        }
        .navigationTitle("More Info")
    }
    
}

struct MoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfoView(sbapp: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false), iconPath: "")
    }
}
