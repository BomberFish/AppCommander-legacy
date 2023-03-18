//
//  MainView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct MainView: View {
    @State var isUnsandboxed = false
    @State private var searchText = ""
    @State var allApps = [SBApp(bundleIdentifier: "", name: "", bundleURL: URL.init(string: "/")!, version: "1.0.0", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
    @State var apps = [SBApp(bundleIdentifier: "", name: "", bundleURL: URL.init(string: "/")!, version: "1.0.0", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
    var body: some View {
        NavigationView {
            List {
                Section(header:
                    Label("AppCommander \(appVersion)\nMade with ❤️ by BomberFish", systemImage: "info.circle").textCase(.none)){}
                Section {
                    if apps == [SBApp(bundleIdentifier: "", name: "", bundleURL: URL.init(string: "/")!, version: "1.0.0", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)] {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        // TODO: icons!
                        ForEach(apps) {app in
                            AppCell(imagePath: (app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao").path), bundleid: app.bundleIdentifier, name: app.name, large: false, link: true, bundleURL: app.bundleURL, sbapp: app)
                                .onAppear {
                                    print("===")
                                    print((app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao")).path)
                                    print(((app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao")).path).contains("this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"))
                                    print("=====")
                                    print(app.bundleURL)
                                    print("=======")
                                    print(app.pngIconPaths)
                                    print("=========")
                                }
                                .contextMenu {
                                    Button(action: {
                                        if openApp(bundleID: app.bundleIdentifier) {
                                            Haptic.shared.notify(.success)
                                        } else {
                                            Haptic.shared.notify(.error)
                                        }
                                    }, label: {
                                        Label("Open App", systemImage: "arrow.up.forward.app")
                                    })
                                }
                        }
                    }
                } header: {
                    Label("Apps (\(apps.count))", systemImage: "square.grid.2x2")
                } footer: {
                    // haha take that suslocation!
                    Text("You've come a long way, traveler. Have a :lungs:.\n🫁")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search apps...")
            .navigationTitle("AppCommander")
            .onChange(of: searchText) { searchText in
             
                if !searchText.isEmpty {
                    apps = allApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                } else {
                    apps = allApps
                }
            }
            .toolbar {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("", systemImage: "gear")
                }
            }
        }
        .onAppear {
            isUnsandboxed = unsandbox()
            if !isUnsandboxed {
                isUnsandboxed = unsandbox()
            } else {
                allApps = try! ApplicationManager.getApps()
                apps = allApps
            }
        }
        .refreshable {
            if !isUnsandboxed {
                isUnsandboxed = unsandbox()
            } else {
                allApps = try! ApplicationManager.getApps()
                apps = allApps
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
