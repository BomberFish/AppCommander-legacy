//
//  SettingsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-18.
//

import SwiftUI

struct SettingsView: View {
    @State var consoleEnabled: Bool = UserDefaults.standard.bool(forKey: "LCEnabled")
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    @State var analyticsLevel: Int = UserDefaults.standard.integer(forKey: "analyticsLevel")
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        FileActionManager.delDirectoryContents(path: FileManager.default.temporaryDirectory.path)
                    }, label: {
                        Label("Delete temporary storage", systemImage: "trash")
                    })
                } header: {
                    Label("Storage Management", systemImage: "internaldrive")
                }
                Section {
                    Picker(selection: $analyticsLevel) {
                        Text("None (Disabled)").tag(0)
                        Text("Limited").tag(1)
                        Text("Full").tag(2)
                    } label: {
                        Label("Analytics Level", systemImage: "chart.bar.xaxis")
                    }
                    .onChange(of: analyticsLevel) { new in
                        UserDefaults.standard.set(new, forKey: "analyticsLevel")
                        print(analyticsLevel)
                    }
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        if #available(iOS 16, *) {
                            Label("Privacy Policy", systemImage: "person.badge.shield.checkmark")
                        } else {
                            Label("Privacy Policy", systemImage: "checkmark.shield.fill")
                        }
                    }
                } header: {
                    Label("Analytics", systemImage: "chart.bar")
                } footer: {
                    // a little bit cring-eh 🇨🇦🇨🇦🇨🇦🇨🇦🇨🇦🇨🇦
                    Label("Powered by Kouyou", systemImage: "gearshape.2")
                }
                Section {
                    LinkCell(imageName: "bomberfish", url: "https://github.com/BomberFish", title: "BomberFish", contribution: "Main Developer", circle: true)
                    LinkCell(imageName: "floppa", url: "https://github.com/Avangelista", title: "Avangelista", contribution: "Appabetical", circle: true)
                    LinkCell(imageName: "suslocation", url: "https://github.com/sourcelocation", title: "sourcelocation", contribution: "Various Code Snippets, Appabetical", circle: true)
                    LinkCell(imageName: "other_fish", url: "https://github.com/f1shy-dev", title: "sneakyf1shy", contribution: "Analytics", circle: true)
                } header: {
                    Label("Credits", systemImage: "heart")
                }
                Section {
                    Toggle(isOn: $debugEnabled, label: { Label("Debug Mode", systemImage: "ladybug") })
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .onChange(of: debugEnabled) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "DebugEnabled")
                        }
                }
                if debugEnabled {
                    Section {
                        Toggle(isOn: $consoleEnabled, label: { Label("Enable in-app console", systemImage: "terminal") })
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                            .onChange(of: consoleEnabled) { new in
                                // set the user defaults
                                UserDefaults.standard.set(new, forKey: "LCEnabled")
                                if new {
                                    consoleManager.isVisible = true
                                } else {
                                    consoleManager.isVisible = false
                                }
                            }
                        Button(action: respringFrontboard, label: { Label("Restart frontboard", systemImage: "arrow.counterclockwise") })
                        Button(action: respringBackboard, label: { Label("Restart backboard", systemImage: "arrow.counterclockwise") })
                    } header: {
                        Label("Debug", systemImage: "ladybug")
                    }
                }
                Section(header: Label("AppCommander \(appVersion)\nMade with ❤️ by BomberFish", systemImage: "info.circle").textCase(.none)) {}
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
