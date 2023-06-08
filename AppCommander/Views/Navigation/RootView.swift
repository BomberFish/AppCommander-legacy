//
//  RootView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-24.
//

import SwiftUI

struct RootView: View {
    @State var allApps: [SBApp] = [SBApp(bundleIdentifier: "ca.bomberfish.AppCommander.Loading", name: "Application Error", bundleURL: URL(string: "/")!, version: "0.6.9", pngIconPaths: [""], hiddenFromSpringboard: false)]

    init() {
        let transparentAppearence = UITabBarAppearance()
        transparentAppearence.configureWithDefaultBackground() // 🔑
        UITabBar.appearance().standardAppearance = transparentAppearence
    }
    
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
            // you could call this a cancelled feature :trolley:
            /*StorageView(allApps: $allApps)
                .tabItem {
                    Label("Storage", systemImage: "internaldrive")
                }*/
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
        //.listStyle(.sidebar)
        // .background(GradientView())
                .listRowBackground(Color.clear)
        .onAppear {
            do {
                allApps = try ApplicationManager.getApps()
            } catch {
                UIApplication.shared.alert(title: "WARNING", body: "AppCommander was unable to get installed apps. Press OK to continue in a feature-limited mode.")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
