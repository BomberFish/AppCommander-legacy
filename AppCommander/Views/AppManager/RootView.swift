//
//  RootView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-24.
//

import SwiftUI
import UIKit

struct RootView: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                            Label("App Manager", systemImage: "list.bullet")
                        }
            if !(UIDevice.current.userInterfaceIdiom == .pad) {
                AppabeticalView()
                    .tabItem {
                        Label("Home Screen", systemImage: "apps.iphone")
                    }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
