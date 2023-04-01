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
                NavigationLink(destination: { WhitelistView() }, label: { Label("Whitelist", systemImage: "app.badge.checkmark") })
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
