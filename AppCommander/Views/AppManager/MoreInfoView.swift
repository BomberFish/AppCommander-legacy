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
    @State private var appsize: UInt64 = 0
    @State private var docsize: UInt64 = 0
    @State private var datadir: String = ""
    @State private var action: Int? = 0
    
    var body: some View {
        // TODO: Make this look nice
        NavigationLink(destination: FileBrowserView(path: (sbapp.bundleURL.path) + "/", title: sbapp.bundleURL.lastPathComponent), tag: 1, selection: $action) {
            EmptyView()
        }
        NavigationLink(destination: FileBrowserView(path: datadir + "/", title: sbapp.name + " Data"), tag: 2, selection: $action) {
            EmptyView()
        }
        List {
            Text("Name: \(sbapp.name)")
                // TODO: 💀
                .contextMenu {
                    Button(action: { UIPasteboard.general.string = sbapp.name }, label: { Label("Copy", systemImage: "doc.on.clipboard") })
                }
            Text("Bundle ID: \(sbapp.bundleIdentifier)")
                .contextMenu {
                    Button(action: { UIPasteboard.general.string = sbapp.bundleIdentifier }, label: { Label("Copy", systemImage: "doc.on.clipboard") })
                }
            Text("Version: \(sbapp.version)")
                .contextMenu {
                    Button(action: { UIPasteboard.general.string = sbapp.version }, label: { Label("Copy", systemImage: "doc.on.clipboard") })
                }
            Text("Bundle Path: \(sbapp.bundleURL.path)")
                .contextMenu {
                    Button(action: { self.action = 1 }, label: { Label("Open in built-in browser", systemImage: "folder.badge.gearshape") })
                    if isFilzaInstalled() {
                        Button(action: { openInFilza(path: sbapp.bundleURL.path) }, label: { Label("Open in Filza", systemImage: "arrow.up.forward.app") })
                    }
                    if isSantanderInstalled() {
                        Button(action: { openInSantander(path: sbapp.bundleURL.path) }, label: { Label("Open in Santander", systemImage: "arrow.up.forward.app") })
                    }
                    Button(action: { UIPasteboard.general.string = sbapp.bundleURL.path }, label: { Label("Copy", systemImage: "doc.on.clipboard") })
                }
            Text("Data directory: \(datadir)")
                .contextMenu {
                    Button(action: { self.action = 2 }, label: { Label("Open in built-in browser", systemImage: "folder.badge.gearshape") })
                    if isFilzaInstalled() {
                        Button(action: { openInFilza(path: datadir) }, label: { Label("Open in Filza", systemImage: "arrow.up.forward.app") })
                    }
                    if isSantanderInstalled() {
                        Button(action: { openInSantander(path: datadir) }, label: { Label("Open in Santander", systemImage: "arrow.up.forward.app") })
                    }
                    Button(action: { UIPasteboard.general.string = datadir }, label: { Label("Copy", systemImage: "doc.on.clipboard") })
                }
            Text("App Size: \(ByteCountFormatter().string(fromByteCount: Int64(appsize)))")
                .contextMenu {
                    Button(action: { UIPasteboard.general.string = ByteCountFormatter().string(fromByteCount: Int64(appsize)) }, label: { Label("Copy", systemImage: "doc.on.clipboard") })
                }
            Text("Documents Size: \(ByteCountFormatter().string(fromByteCount: Int64(docsize)))")
                .contextMenu {
                    Button(action: { UIPasteboard.general.string = ByteCountFormatter().string(fromByteCount: Int64(docsize)) }, label: { Label("Copy", systemImage: "doc.on.clipboard") })
                }
        }
        .navigationTitle("More Info")
        .onAppear {
            do {
                appsize = try FileManager.default.allocatedSizeOfDirectory(at: sbapp.bundleURL)
                docsize = try FileManager.default.allocatedSizeOfDirectory(at: ApplicationManager.getDataDir(bundleID: sbapp.bundleIdentifier))
                datadir = try ApplicationManager.getDataDir(bundleID: sbapp.bundleIdentifier).path
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }

        .refreshable {
            do {
                appsize = try FileManager.default.allocatedSizeOfDirectory(at: sbapp.bundleURL)
                docsize = try FileManager.default.allocatedSizeOfDirectory(at: ApplicationManager.getDataDir(bundleID: sbapp.bundleIdentifier))
                datadir = try ApplicationManager.getDataDir(bundleID: sbapp.bundleIdentifier).path
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
        // .background(GradientView())
                .listRowBackground(Color.clear)
        //.listStyle(.sidebar)
    }
}

struct MoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfoView(sbapp: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false), iconPath: "")
    }
}
