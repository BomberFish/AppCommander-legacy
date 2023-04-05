//
//  ContentView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI
import os.log

struct WhitelistView: View {
    @State var blacklist = true
    @State var banned: Bool = UserDefaults.standard.bool(forKey: "BannedEnabled")
    @State var cdHash: Bool = UserDefaults.standard.bool(forKey: "CdEnabled")
    @State var inProgress = false
    @State var message = ""
    @State var success = false
    @State var error_message = ""
    var body: some View {
            List {
                Section {
                    Button(
                        action: {
                            os_log(.debug, "FG: Applying!")
                            Haptic.shared.play(.heavy)
                            inProgress = true
                            
                            if banned {
                                do {
                                    try Whitelist.overwriteBannedApps()
                                } catch {
                                    error_message = "\(error_message) \(error.localizedDescription)"
                                }
                            }
                            if cdHash {
                                do {
                                    try Whitelist.overwriteCdHashes()
                                } catch {
                                    error_message = "\(error_message) \(error.localizedDescription)"
                                }
                            }
                            
                            if blacklist {
                                do {
                                    try Whitelist.overwriteBlacklist()
                                } catch {
                                    error_message = "\(error_message) \(error.localizedDescription)"
                                }
                            }
                            
                            if error_message != "" {
                                UIApplication.shared.alert(body: error_message)
                            } else {
                                UIApplication.shared.alert(title: "Success!",body: error_message)
                            }
                            inProgress = false
                        },
                        label: { Label("Apply", systemImage: "app.badge.checkmark") }
                    )
                } header: {
                    Label("Make It So, Number One", systemImage: "arrow.right.circle")
                }
                Section {
                    Toggle(isOn: $blacklist, label:{Label("Overwrite Blacklist", systemImage: "xmark.seal")})
                        .toggleStyle(.switch)
                        .disabled(true)
                        .tint(.accentColor)
                        .disabled(inProgress)
                    Toggle(isOn: $banned, label:{Label("Overwrite Banned Apps", systemImage: "xmark.app")})
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .disabled(inProgress)
                        .onChange(of: banned) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "BannedEnabled")
                        }
                    Toggle(isOn: $cdHash, label:{Label("Overwrite CDHashes", systemImage: "number.square")})
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .disabled(inProgress)
                        .onChange(of: cdHash) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "CdEnabled")
                        }
                } header: {
                    Label("Options", systemImage: "gear")
                }
                
                Section {
                    NavigationLink(destination: FileContentsView()) {
                        Label("View contents of blacklist files", systemImage: "doc.text")
                    }
                } header : {
                    Label("Advanced", systemImage: "wrench.and.screwdriver")
                }
            }
            .navigationTitle("Whitelist")
    }
}

struct WhitelistView_Previews: PreviewProvider {
    static var previews: some View {
        WhitelistView()
    }
}
