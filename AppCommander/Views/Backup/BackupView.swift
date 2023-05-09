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
            .onAppear {
                backups = BackupServices.shared.backups(for: app)
            }
            .navigationTitle("Backups")
            
            
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
                        let size = FileManager.default.sizeOfFile(atPath: URL(fileURLWithPath: "/var/mobile/.DO_NOT_DELETE-AppCommander").appendingPathComponent("Backups").appendingPathComponent(backup.backupFilename).path)
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
                                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
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
                            Button(action: {
                                UIApplication.shared.dismissAlert(animated: true)
                                let vc = UIActivityViewController(activityItems: [URL(fileURLWithPath: "/var/mobile/.DO_NOT_DELETE-AppCommander").appendingPathComponent("Backups").appendingPathComponent(backup.backupFilename) as Any], applicationActivities: nil)
                                Haptic.shared.notify(.success)
                                vc.isModalInPresentation = true
                                UIApplication.shared.dismissAlert(animated: true)
                                UIApplication.shared.windows[0].rootViewController?.present(vc, animated: true)
                                UIApplication.shared.dismissAlert(animated: true)
                                vc.isModalInPresentation = true
                            }, label: {Label("Export Backup", systemImage: "square.and.arrow.up")})
                            Text("Creation Date: \(backup.creationDate)")
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text("Bundle ID: \(backup.applicationIdentifier)")
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text("Backup filename: \(backup.backupFilename)")
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            //                        Text("\(backup.stagingDirectoryName)")
                            //                        Text("\(backup.displayName)")
                        }
                    }
                }
            }
            // Section{}footer: {Label("Backups are still in beta. Unexpected issues may arise.", systemImage: "info.circle")}
        }
        
        //.listStyle(.sidebar)
        // .background(GradientView())
                .listRowBackground(Color.clear)
        
        .refreshable {
            backups = BackupServices.shared.backups(for: app)
        }
        .toolbar {
            FilePicker(types: [.init(filenameExtension: "abdk")!/*, .init(filenameExtension: "zip")!*/], allowMultiple: false, onPicked: { urls in
                print(urls.first ?? "no files picked?!")
                UIApplication.shared.progressAlert(title: "Backing up \(app.name)...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let path = urls.first {
                        do {
                            try BackupServices.shared.importBackup(path, application: app, progress: {message in
                                print(message)
                                UIApplication.shared.changeBody("\n\n\n\(message))")
                            })
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    } else {
                        UIApplication.shared.alert(body: "Error getting path of directory")
                    }
                }
            }, label: {
                Image(systemName: "square.and.arrow.down")
            })
        }
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        BackupView(app: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
