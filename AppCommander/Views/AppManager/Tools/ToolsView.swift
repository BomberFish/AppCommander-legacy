//
//  ToolsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-01.
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: { WhitelistView() }, label: { Label("Whitelist", systemImage: "app.badge.checkmark") })
                }
                
                Section {
                    NavigationLink(destination: { ReplaceTestingView() }, label: { Label("Replace Testing", systemImage: "wrench.and.screwdriver") })
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
