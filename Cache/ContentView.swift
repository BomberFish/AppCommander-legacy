//
//  ContentView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                // TODO: list apps!!!!!!!
                ForEach(getApps()) {app in
                    AppCell(imageName: "Placeholder", bundleid: app.bundleIdentifier, title: app.name)
                }
                Section(footer: Label("Caché \(appVersion)", systemImage: "info.circle")){}
            }
            .navigationTitle("Caché")
        }
    }
    private func getApps() -> [SBApp] {
        do {
            return try ApplicationManager.getApps()
        } catch {
            UIApplication.shared.alert(body: "Unable to get installed apps.", withButton: false)
        }
        return [SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL.init(string: "/")!, pngIconPaths: [""], hiddenFromSpringboard: false)]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
