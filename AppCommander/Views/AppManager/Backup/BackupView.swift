//
//  BackupView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-27.
//

import SwiftUI
import UIKit
import FilePicker

struct BackupView: View {
    @State public var app: SBApp
    @State private var backups: [BackupItem] = []
    @State var errormsg: String = ""
    var body: some View {
        List {
            Section {
                Button(action: {
                    UIApplication.shared.progressAlert(title: "Backing up \(app.name)...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        do {
                            try BackupServices.shared.backup(application: app, rootHelper: false, progress: {message in
                                print(message)
                                UIApplication.shared.changeBody("\n\n\n\(message))")
                            })
                            backups = BackupServices.shared.backups(for: app)
                            UIApplication.shared.dismissAlert(animated: true)
                            Haptic.shared.notify(.success)
                            //UIApplication.shared.alert(body: "Successfully backed up \(app.name)!")
                        } catch {
                            errormsg = error.localizedDescription
                            UIApplication.shared.dismissAlert(animated: true)
                            Haptic.shared.notify(.error)
                        }
                        if errormsg != "" {
                            UIApplication.shared.alert(body: errormsg)
                        }
                        errormsg = ""
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
                        let size = FileManager.default.sizeOfFile(atPath: (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Backups").appendingPathComponent(backup.backupFilename)).path)
                        HStack {
                            Text("Backup taken \(backup.displayName)")
                            Spacer()
                            Text(ByteCountFormatter().string(fromByteCount: size ?? 0))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .fontWeight(.medium)
                            Button(action: {
                                UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Restore this backup?", onOK: {
                                    UIApplication.shared.progressAlert(title: "Restoring backup taken   \(backup.displayName)...")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        do {
                                            try BackupServices.shared.restoreBackup(backup, progress: {message in
                                                UIApplication.shared.changeBody("\n\n\n\(message))")
                                            })
                                            UIApplication.shared.dismissAlert(animated: true)
                                            Haptic.shared.notify(.success)
                                        } catch {
                                            errormsg = error.localizedDescription
                                            Haptic.shared.notify(.error)
                                            UIApplication.shared.dismissAlert(animated: true)
                                        }
                                        if errormsg != "" {
                                            UIApplication.shared.alert(body: "Could not restore backup \(backup.backupFilename): \(errormsg)")
                                        }
                                        errormsg = ""
                                    }
                                }, destructActionText: "Restore")
                            }, label: {
                                Image(systemName: "clock.arrow.2.circlepath")
                            })
                        }
                        .swipeActions {
                            Button(action: {
                                if UserDefaults.standard.bool(forKey: "AbsoluteSolverEnabled") {
                                    UIApplication.shared.progressAlert(title: "Disassembling backup taken   \(backup.displayName)...")
                                } else {
                                    UIApplication.shared.progressAlert(title: "Deleting backup taken   \(backup.displayName)...")
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    do {
                                        try BackupServices.shared.removeBackup(backup)
                                        Haptic.shared.notify(.success)
                                        backups = BackupServices.shared.backups(for: app)
                                        UIApplication.shared.dismissAlert(animated: true)
                                    } catch {
                                        errormsg = error.localizedDescription
                                        Haptic.shared.notify(.error)
                                        UIApplication.shared.dismissAlert(animated: true)
                                    }
                                    if errormsg != "" {
                                        UIApplication.shared.alert(body: "Could not restore backup \(backup.backupFilename): \(errormsg)")
                                    }
                                    errormsg = ""
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
        .toolbar {
            FilePicker(types: [.init(filenameExtension: "abdk")!, .init(filenameExtension: "zip")!], allowMultiple: false, onPicked: { urls in
                print(urls.first ?? "no files picked?!")
            }, label: {
                Image(systemName: "square.and.arrow.down")
            })
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
