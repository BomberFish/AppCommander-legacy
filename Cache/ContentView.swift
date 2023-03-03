//
//  ContentView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct ContentView: View {
    @State private var allAppsUpdated = allApps
    var body: some View {
        NavigationView {
            List {
                // TODO: list apps!!!!!!!
                if allAppsUpdated[0].bundleIdentifier == "ca.bomberfish.there.is.no.reason.for.this.bundleid.to.exist.seriously.placeholder" && allAppsUpdated[0].name == "Placeholder" {
                    ProgressView()
                } else {
                    ForEach(allAppsUpdated) {app in
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
