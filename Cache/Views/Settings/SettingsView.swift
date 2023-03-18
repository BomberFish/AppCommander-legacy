//
//  SettingsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-18.
//

import SwiftUI

struct SettingsView: View {
    @State var consoleEnabled: Bool = UserDefaults.standard.bool(forKey: "LCEnabled")
    var body: some View {
        List {
            Toggle(isOn: $consoleEnabled, label:{Label("Enable in-app console", systemImage: "terminal")})
                .toggleStyle(.switch)
                .tint(.accentColor)
                .onChange(of: consoleEnabled) { new in
                    // set the user defaults
                    UserDefaults.standard.set(new, forKey: "LCEnabled")
                    if new == false {
                        consoleManager.isVisible = false
                    } else {
                        consoleManager.isVisible = true
                    }
                }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
