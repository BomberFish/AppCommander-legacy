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
    @State private var backups: [BackupItem] = []

    var body: some View {
        List {
            Section {
                Button(action: {
                    do {
                        UIApplication.shared.progressAlert(title: "Backing up \(app.name)...")
                        try BackupServices.shared.backup(application: app, rootHelper: false)
                        backups = BackupServices.shared.backups(for: app)
                        UIApplication.shared.dismissAlert(animated: true)
                        Haptic.shared.notify(.success)
                        //UIApplication.shared.alert(body: "Successfully backed up \(app.name)!")
                    } catch {
                        UIApplication.shared.dismissAlert(animated: true)
                        Haptic.shared.notify(.error)
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }, label: {
                    Label("Back up now", systemImage: "arrow.down.app")
                })
            }

            if backups.isEmpty {
                Section {} footer: {
                    HStack {
                        Spacer()
                        Text("No backups!")
                            .font(.headline)
                        Spacer()
                    }
                }
            } else {
                Section {
                    ForEach(backups) { backup in
                        HStack {
                            Text("Backup taken \(backup.displayName)")
                            Spacer()
                            Button(action: {
                                UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Restore this backup?", onOK: {
                                    do {
                                        UIApplication.shared.progressAlert(title: "Restoring backup taken   \(backup.displayName)...")
                                        try BackupServices.shared.restoreBackup(backup)
                                        UIApplication.shared.dismissAlert(animated: true)
                                        Haptic.shared.notify(.success)
                                    } catch {
                                        UIApplication.shared.dismissAlert(animated: true)
                                        UIApplication.shared.alert(body: "Could not restore backup \(backup.backupFilename): \(error.localizedDescription)")
                                    }
                                }, destructActionText: "Restore")
                            }, label: {
                                Image(systemName: "clock.arrow.2.circlepath")
                            })
                        }
                        .swipeActions {
                            Button(action: {
                                do {
                                    UIApplication.shared.progressAlert(title: "Deleting backup taken   \(backup.displayName)...")
                                    try BackupServices.shared.removeBackup(backup)
                                    Haptic.shared.notify(.success)
                                    backups = BackupServices.shared.backups(for: app)
                                    UIApplication.shared.dismissAlert(animated: true)
                                } catch {
                                    Haptic.shared.notify(.error)
                                    UIApplication.shared.dismissAlert(animated: true)
                                    UIApplication.shared.alert(body: "Could not restore backup \(backup.backupFilename): \(error.localizedDescription)")
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        .contextMenu {
                            Text("Creation Date: \(backup.creationDate)")
                            Text("Bundle ID: \(backup.applicationIdentifier)")
                            Text("Backup filename: \(backup.backupFilename)")
                            //                        Text("\(backup.stagingDirectoryName)")
                            //                        Text("\(backup.displayName)")
                        }
                    }
                }
            }
            Section {} footer: {
                Label("Backups are still in beta. Unexpected issues may arise.", systemImage: "info.circle")
            }
        }
        .navigationTitle("Backups")
        .refreshable {
            backups = BackupServices.shared.backups(for: app)
        }
        .onAppear {
            backups = BackupServices.shared.backups(for: app)
        }
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        BackupView(app: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
