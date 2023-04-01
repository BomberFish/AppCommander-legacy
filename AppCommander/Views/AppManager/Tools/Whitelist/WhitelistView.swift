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
    @State var banned_success = false
    @State var blacklist_success = false
    @State var hash_success = false
    @State var success = false
    @State var success_message = ""
    var body: some View {
            List {
                Section {
                    Button(
                        action: {
                            os_log(.debug, "FG: Applying!")
                            Haptic.shared.play(.heavy)
                            inProgress = true
                            
                            if banned {
                                banned_success = Whitelist.overwriteBannedApps()
                            }
                            if cdHash {
                                hash_success = Whitelist.overwriteCdHashes()
                            } else {
                                banned_success = false
                                hash_success = false
                            }
                            success = Whitelist.overwriteBlacklist()
                            
                            // FIXME: Bad.
                            if banned_success && hash_success {
                                success_message = "Successfully removed: Blacklist, Banned Apps, CDHashes\nDidn't overwrite: none"
                            } else if !banned_success && hash_success {
                                success_message = "Successfully removed: Blacklist, CDHashes\nDidn't overwrite: Banned Apps"
                            } else if banned_success && !hash_success {
                                success_message = "Successfully removed: Blacklist, Banned Apps\nDidn't overwrite: CDHashes"
                            } else {
                                success_message = "Successfully removed: Blacklist\nDidn't overwrite: Banned Apps, CDHashes"
                            }
                            
                            if success {
                                UIApplication.shared.alert(title: "Success", body: success_message, withButton: true)
                                inProgress = false
                                Haptic.shared.notify(.success)
                                os_log(.debug, "FG: Success! See UI for details.")
                            } else {
                                UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)
                                os_log(.debug, "FG: Error! See UI for details.")
                                inProgress = false
                                Haptic.shared.notify(.error)
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
