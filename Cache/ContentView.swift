//
//  ContentView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct ContentView: View {
    @State var isUnsandboxed = false
    var body: some View {
        NavigationView {
            List {
                // TODO: list apps!!!!!!!
                if !isUnsandboxed {
                    ProgressView()
                } else {
                    ForEach(try! ApplicationManager.getApps()) {app in
                        AppCell(imageName: "Placeholder", bundleid: app.bundleIdentifier, title: app.name)
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
        ContentView()
    }
}
