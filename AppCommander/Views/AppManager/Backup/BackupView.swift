//
//  BackupView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-27.
//

import SwiftUI
import UIKit

struct BackupView: View {
    @State public var app: SBApp
    @State private var backups: [Backup] = []
    
    var body: some View {
        List {
            HStack {
                Spacer()
                Text("🚧 UNDER CONSTRUCTION!! 🚧")
                    .font(.system(.title2))
                Spacer()
            }
            Section {
                Button(action: {
                    do {
                        try BackupServices.shared.backup(application: app, rootHelper: false)
                        Haptic.shared.notify(.success)
                    } catch {
                        Haptic.shared.notify(.error)
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }, label: {
                    Label("Back up now", systemImage: "arrow.down.app")
                })
            }
            Section {
                ForEach(backups) {backup in
                    HStack {
                        Text("Backup taken \(backup.time)")
                        Spacer()
                        Button(action: {
                            UIApplication.shared.confirmAlertDestructive(title:"Confirmation", body: "Restore this backup?", onOK: {UIApplication.shared.alert(body: "not implemented")}, destructActionText: "Restore")
                        }, label: {
                            Image(systemName: "clock.arrow.2.circlepath")
                        })
                    }
                }
            }
        }
        .navigationTitle("Backups")
        .refreshable {
            backups = AppBackupManager.getBackups(app: app)
        }
        .onAppear {
            let fm = FileManager.default
            let docsdir = (fm.urls(for: .documentDirectory, in: .userDomainMask))[0]
            
            let backupfolderdir = docsdir.appendingPathComponent("Backups", conformingTo: .directory)
            let backupfolderdirexists = fm.fileExists(atPath: backupfolderdir.path)
            
            let backupdir = backupfolderdir.appendingPathComponent(app.bundleIdentifier, conformingTo: .directory)
            let backupdirexists = fm.fileExists(atPath: backupfolderdir.path)
            
            print(docsdir, backupfolderdir, backupfolderdirexists, backupdir, backupdirexists)
            do {
                try fm.createDirectory(at: backupdir, withIntermediateDirectories: true)
                Haptic.shared.notify(.success)
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
                Haptic.shared.notify(.error)
            }
            
            backups = AppBackupManager.getBackups(app: app)
        }
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        BackupView(app: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
