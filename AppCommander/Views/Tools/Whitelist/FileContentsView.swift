//
//  ContentsView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI
import AbsoluteSolver

struct FileContentsView: View {
    @State var blacklistContent = "File is empty"
    @State var bannedAppsContent = "File is empty"
    @State var cdHashesContent = "File is empty"
    
    @State var refreshing = false
    
    let fm = FileManager.default
    
    var body: some View {
        List {
            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/Rejections.plist") {
                Section {
                    if refreshing {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text(blacklistContent)
                            .font(.system(.subheadline, design: .monospaced))
                    }
                    
                } header: {
                    Label("Blacklist", systemImage: "xmark.seal")
                }
                .navigationTitle("Blacklist File Contents")
            }
            
            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
                Section {
                    if refreshing {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text(bannedAppsContent)
                            .font(.system(.subheadline, design: .monospaced))
                    }
                } header: {
                    Label("Banned Apps", systemImage: "xmark.app")
                }
            }
            
            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
                Section {
                    if refreshing {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text(cdHashesContent)
                            .font(.system(.subheadline, design: .monospaced))
                    }
                } header: {
                    Label("CD Hashes", systemImage: "number.square")
                }
            }

        }
        // .background(GradientView())
                .listRowBackground(Color.clear)
        //.listStyle(.sidebar)
        .refreshable {
            do {
                Haptic.shared.play(.rigid)
                print("Updating files!", loglevel: .debug)
                refreshing = true
                blacklistContent = ""
                bannedAppsContent = ""
                cdHashesContent = ""
                //create the illusion of fully reloading
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    do {
                        if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/Rejections.plist") {
                                blacklistContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist", progress: {message in
                                    print(message, loglevel: .debug)
                                }), as: UTF8.self)
                            }
                            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
                                bannedAppsContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist", progress: {message in
                                    print(message, loglevel: .debug)
                                }), as: UTF8.self)
                            }
                            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
                                cdHashesContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist", progress: {message in
                                    print(message, loglevel: .debug)
                                }), as: UTF8.self)
                            }
                        } else {
                            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/Rejections.plist") {
                                blacklistContent = try String(contentsOfFile: "/private/var/db/MobileIdentityData/Rejections.plist")
                            }
                            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
                                bannedAppsContent = try String(contentsOfFile: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist")
                            }
                            if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
                                cdHashesContent = try String(contentsOfFile: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist")
                            }
                        }
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                    print("Files updated!", loglevel: .info)
                    refreshing = false
                    Haptic.shared.play(.light)
                }
            }
        }
            .navigationTitle("Blacklist File Contents")
            .task(priority: .utility)  {
                print("Reading files!")
                do {
                    if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                        if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/Rejections.plist") {
                            blacklistContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist", progress: {message in
                                print(message, loglevel: .debug)
                            }), as: UTF8.self)
                        }
                        if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
                            bannedAppsContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist", progress: {message in
                                print(message, loglevel: .debug)
                            }), as: UTF8.self)
                        }
                        if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
                            cdHashesContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist", progress: {message in
                                print(message, loglevel: .debug)
                            }), as: UTF8.self)
                        }
                    } else {
                        if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/Rejections.plist") {
                            blacklistContent = try String(contentsOfFile: "/private/var/db/MobileIdentityData/Rejections.plist")
                        }
                        if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
                            bannedAppsContent = try String(contentsOfFile: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist")
                        }
                        if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
                            cdHashesContent = try String(contentsOfFile: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist")
                        }
                    }
                } catch {
                    print("error: \(error.localizedDescription)", loglevel: .debug)
                    UIApplication.shared.alert(body: error.localizedDescription)
                }
            }
    }
        
}

struct FileContentsView_Previews: PreviewProvider {
    static var previews: some View {
        FileContentsView()
    }
}
