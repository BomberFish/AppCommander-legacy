//
//  ToolsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-01.
//

import SwiftUI

struct ToolsView: View {
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: { WhitelistView() }, label: { Label("Whitelist", systemImage: "app.badge.checkmark") })
                    NavigationLink(destination: { FreeloadView() }, label: { Label("Remove three-app limit", systemImage: "apps.iphone.badge.plus") })
                } header: {
                    Label("Sideloading Tools", systemImage: "iphone.and.arrow.forward")
                }
                
                Section {
                    NavigationLink(destination: { ReplaceTestingView() }, label: { Label("Replace Testing", systemImage: "wrench.and.screwdriver") })
                    if debugEnabled {
                        NavigationLink(destination: { AppleLoopsMixView() }, label: { Label("Apple Loops Mix :trolley:", systemImage: "apple.logo") })
                    }
                } header: {
                    Label("Testing Only", systemImage: "ladybug")
                }
            }
            .navigationTitle("Tools")
        }
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}
