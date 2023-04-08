//
//  MainView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct MainView: View {
    @State private var searchText = ""
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")

    // MARK: - Literally the worst code ever. Will I fix it? No!

    @Binding public var allApps: [SBApp]
    @State var apps = [SBApp(bundleIdentifier: "", name: "", bundleURL: URL(string: "/")!, version: "1.0.0", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
    var body: some View {
        NavigationView {
            List {
                Section {
                    if apps == [SBApp(bundleIdentifier: "", name: "", bundleURL: URL(string: "/")!, version: "1.0.0", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)] {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        // TODO: icons!
                        ForEach(apps) { app in
                            // 💀
                            AppCell(imagePath: app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao").path, bundleid: app.bundleIdentifier, name: app.name, large: false, link: true, bundleURL: app.bundleURL, sbapp: app)
                                .contextMenu {
                                    Button(action: {
                                        if ApplicationManager.openApp(bundleID: app.bundleIdentifier) {
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
                HStack {
                    Menu(content: {
                        Button(action: {
                            apps = allApps
                        }, label: {
                            Label("None", systemImage: "list.bullet")
                        })
                        Menu("Alphabetical") {
                            Button(action: {
                                apps = allApps.sorted { $0.name < $1.name }
                            }, label: {
                                Label("Case-sensitive", systemImage: "character")
                            })

                            Button(action: {
                                apps = allApps.sorted { $0.name.lowercased() < $1.name.lowercased() }
                            }, label: {
                                Label("Case-insensitive", systemImage: "textformat")
                            })
                        }

                    }, label: {
                        Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                    })
                }
            }
            .onAppear {
                apps = allApps
            }
//            .onAppear {
            // #if targetEnvironment(simulator)
//            #else
//            isUnsandboxed = MDC.unsandbox()
//            if !isUnsandboxed {
//                isUnsandboxed = MDC.unsandbox()
//            } else {
//                allApps = try! ApplicationManager.getApps()
//                apps = allApps
//            }
//            #endif
//        }

            .refreshable {
                #if targetEnvironment(simulator)
                #else
//                if !isUnsandboxed {
//                    isUnsandboxed = MDC.unsandbox()
//                } else {
                    allApps = try! ApplicationManager.getApps()
                    apps = allApps
//                }
                #endif
            }.navigationViewStyle(StackNavigationViewStyle())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView(isUnsandboxed: true)
//    }
// }
