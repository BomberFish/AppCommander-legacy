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
    @State var gridEnabled: Bool = false
    @State var compactEnabled: Bool = UserDefaults.standard.bool(forKey: "compactEnabled")

    // MARK: - Literally the worst code ever. Will I fix it? No!

    @Binding public var allApps: [SBApp]
    @State var apps = [SBApp(bundleIdentifier: "ca.bomberfish.AppCommander.Loading", name: "Application Error", bundleURL: URL(string: "/")!, version: "0.6.9", pngIconPaths: [""], hiddenFromSpringboard: false)]
    var body: some View {
        NavigationView {
            ZStack {
                GradientView()
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            Label("Apps (\(apps.count))", systemImage: "square.grid.2x2")
                                .font(.system(.caption))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        VStack {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: gridEnabled ? 150 : 4000))], alignment: .center) {
                                Section {
                                    if apps == [SBApp(bundleIdentifier: "ca.bomberfish.AppCommander.Loading", name: "Application Error", bundleURL: URL(string: "/")!, version: "0.6.9", pngIconPaths: [""], hiddenFromSpringboard: false)] { // mega jank
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    } else {
                                        ForEach(apps) { app in
                                            // 💀
                                            AppCell(bundleid: app.bundleIdentifier, name: app.name, large: false, link: true, bundleURL: app.bundleURL, sbapp: app, tile: $gridEnabled)
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
                                        .padding(compactEnabled ? 4 : 10)
                                        .padding([.vertical], compactEnabled ? 2 : 10)
                                    }
                                }
                                .listRowBackground(Color.clear)
                                
                                .background(.ultraThinMaterial)
                                .cornerRadius(16)
                            }
                            .padding([.horizontal], compactEnabled ? 4 : 16)
                            .padding([.vertical], compactEnabled ? 2 : 8)
                        }
                        .cornerRadius(16)
                        VStack(alignment: .leading) {
                            Text("You've come a long way, traveler. Have a :lungs:.\n🫁")
                                .font(.system(.caption))
                                .multilineTextAlignment(.center )
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }
                }
                // .background(GradientView())
                .listRowBackground(Color.clear)
                .listStyle(InsetGroupedListStyle())
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                        Button(action: {
                            gridEnabled.toggle()
                            Haptic.shared.notify(.success)
                        }, label: {
                            Label("View", systemImage: gridEnabled ? "list.bullet" : "square.grid.2x2")
                                .foregroundColor(Color(UIColor.label))
                        })
                        Menu(content: {
                            Section {
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
                            } header: {
                                Text("Sort Apps")
                            }
                            
                        }, label: {
                            Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                                .foregroundColor(Color(UIColor.label))
                        })
                        .foregroundColor(Color(UIColor.label))
                    }
                }
                .task(priority: .high)  {
                    apps = allApps
                    print("compactEnabled: \(compactEnabled)")
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
                    do {
                        allApps = try ApplicationManager.getApps()
                    } catch {
                        apps = [SBApp(bundleIdentifier: "ca.bomberfish.AppCommander.GuruMeditation", name: "Application Error", bundleURL: URL(string: "/")!, version: "0.6.9", pngIconPaths: [""], hiddenFromSpringboard: false)]
                        UIApplication.shared.alert(title: "WARNING", body: "AppCommander was unable to get installed apps. Press OK to continue in a feature-limited mode.")
                    }
                    apps = allApps
                    //                }
#endif
                }.navigationViewStyle(StackNavigationViewStyle())
                //.listStyle(.sidebar)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView(isUnsandboxed: true)
//    }
// }
