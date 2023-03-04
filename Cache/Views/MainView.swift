//
//  MainView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct MainView: View {
    @State var isUnsandboxed = false
    @State private var searchText = ""
    var body: some View {
        NavigationView {
            List {
                Section(header: Label("Caché \(appVersion)", systemImage: "info.circle").textCase(.none)){}
                Section {
                    // TODO: list apps!!!!!!!
                    if !isUnsandboxed {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        // TODO: icons!
                        ForEach(try! ApplicationManager.getApps()) {app in
                            AppCell(imagePath: (app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao").path), bundleid: app.bundleIdentifier, name: app.name, large: false, link: true)
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
                        }
                    }
                } header: {
                    Label("Apps", systemImage: "square.grid.2x2")
                } footer: {
                    // haha take that suslocation!
                    Text("You've come a long way, traveler. Have a :lungs:.\n🫁")
                }
            }
            // FIXME: Search is currently broken
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Caché")
            
        }
        .onAppear {
            isUnsandboxed = unsandbox()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
