//
//  BackupView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-27.
//

import SwiftUI

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
                NavigationLink(destination: { ReplaceTestingView(app: app) }, label: { Label("Replace Testing", systemImage: "wrench.and.screwdriver") })
            }
            Section {
                Button(action: {
                    AppBackupManager.backup(app: app)
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
            backups = AppBackupManager.getBackups(app: app)
        }
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        BackupView(app: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
