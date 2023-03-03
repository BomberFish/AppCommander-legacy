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
                AppCell(imageName: "Placeholder", bundleid: "com.example.placeholder", title: "Placeholder")
                Section(footer: Label("Caché \(appVersion)", systemImage: "info.circle")){}
                ForEach(getApps()) {SBApp in
                    AppCell(imageName: "Placeholder", bundleid: "com.example.placeholder", title: "Placeholder")
                }
            }
            .navigationTitle("Caché")
        }
    }
    private func getApps() -> [SBApp] {
        do {
            return try ApplicationManager.getApps()
        } catch {
            UIApplication.shared.alert(body: "Unable to get apps.", withButton: false)
        }
        fatalError()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
