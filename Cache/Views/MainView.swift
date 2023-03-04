//
//  MainView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct MainView: View {
    @State var isUnsandboxed = false
    var body: some View {
        NavigationView {
            List {
                Section(header: Label("Caché \(appVersion)", systemImage: "info.circle").textCase(.none)){}
                Section {
                    // TODO: list apps!!!!!!!
                    if !isUnsandboxed {
                        ProgressView()
                    } else {
                        // TODO: icons!
                        ForEach(try! ApplicationManager.getApps()) {app in
                            AppCell(imagePath: " ", bundleid: app.bundleIdentifier, name: app.name, large: false, link: true)
                        }
                    }
                } header: {
                    Label("Apps", systemImage: "square.grid.2x2")
                } footer: {
                    // haha take that suslocation!
                    Text("You've come a long way, traveler. Have a :lungs:.\n🫁")
                }
            }
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
