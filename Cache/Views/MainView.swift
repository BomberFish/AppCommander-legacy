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
                // TODO: list apps!!!!!!!
                if !isUnsandboxed {
                    ProgressView()
                } else {
                    // TODO: icons!
                    ForEach(try! ApplicationManager.getApps()) {app in
                        AppCell(imagePath: " ", bundleid: app.bundleIdentifier, title: app.name)
                    }
                }
                Section(footer: Label("Caché \(appVersion)", systemImage: "info.circle")){}
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
