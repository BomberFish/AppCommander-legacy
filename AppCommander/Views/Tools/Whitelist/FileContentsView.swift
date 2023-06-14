//
//  ContentsView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import AbsoluteSolver
import OSLog
import SwiftUI

struct FileContentsView: View {
    @State var blacklistContent = "File is empty"
    @State var bannedAppsContent = "File is empty"
    @State var cdHashesContent = "File is empty"
    
    @State var refreshing = true
    
    let logger = Logger(subsystem: "FileContentsView", category: "Views")
    
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
        // .listStyle(.sidebar)
        .refreshable {
            refreshing = true
            Haptic.shared.play(.rigid)
            print("Updating files!", loglevel: .debug)
            // create the illusion of fully reloading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                getFiles()
                Haptic.shared.play(.light)
            }
        }
        .navigationTitle("Blacklist File Contents")
        .task(priority: .utility) {
            refreshing = true
            getFiles()
        }
    }

    func getFiles() {
        refreshing = true
        print("Reading files!")
        do {
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/Rejections.plist") {
                    blacklistContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist", progress: { message in
                        print(message, loglevel: .debug, logger: aslogger)
                    }), as: UTF8.self)
                }
                if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") {
                    bannedAppsContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist", progress: { message in
                        print(message, loglevel: .debug, logger: aslogger)
                    }), as: UTF8.self)
                }
                if fm.fileExists(atPath: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") {
                    cdHashesContent = String(decoding: try AbsoluteSolver.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist", progress: { message in
                        print(message, loglevel: .debug, logger: aslogger)
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
            print("error: \(error.localizedDescription)", loglevel: .error, logger: logger)
            UIApplication.shared.alert(body: error.localizedDescription)
        }
        refreshing = false
    }
}

struct FileContentsView_Previews: PreviewProvider {
    static var previews: some View {
        FileContentsView()
    }
}
