//
//  ContentView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct ContentView: View {
    @State var allApps =  try! ApplicationManager.getApps()
    var body: some View {
        NavigationView {
            List {
                // TODO: list apps!!!!!!!
                if allApps[0].bundleIdentifier == "ca.bomberfish.there.is.no.reason.for.this.bundleid.to.exist.seriously.placeholder" && allApps[0].name == "Placeholder" {
                    ProgressView()
                } else {
                    ForEach(allApps) {app in
                        AppCell(imageName: "Placeholder", bundleid: app.bundleIdentifier, title: app.name)
                    }
                    Section(footer: Label("Caché \(appVersion)", systemImage: "info.circle")){}
                }
            }
            .navigationTitle("Caché")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
