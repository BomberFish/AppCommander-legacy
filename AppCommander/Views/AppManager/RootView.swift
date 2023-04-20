//
//  RootView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-24.
//

import SwiftUI

struct RootView: View {
    @State var allApps = try! ApplicationManager.getApps()

    var body: some View {
        TabView {
            MainView(allApps: $allApps)
                .tabItem {
                    Label("App Manager", systemImage: "list.bullet")
                }
            ToolsView()
                .tabItem {
                    Label("Tools", systemImage: "hammer")
                }
            if !(UIDevice.current.userInterfaceIdiom == .pad) {
                AppabeticalView()
                    .tabItem {
                        Label("Home Screen", systemImage: "apps.iphone")
                    }
            }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
