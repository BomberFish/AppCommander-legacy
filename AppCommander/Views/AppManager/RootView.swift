//
//  RootView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-24.
//

import SwiftUI
import UIKit

struct RootView: View {
    @State var isUnsandboxed = MDC.unsandbox()
    @State var allApps = try! ApplicationManager.getApps()
    var body: some View {
        TabView {
            MainView(isUnsandboxed: $isUnsandboxed, allApps: $allApps)
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
        .onAppear {
#if targetEnvironment(simulator)
            #else
            do {
                allApps = try ApplicationManager.getApps()
            } catch {
                isUnsandboxed = MDC.unsandbox()
                allApps = try! ApplicationManager.getApps()
            }
            #endif
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
