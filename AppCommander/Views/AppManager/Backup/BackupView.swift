//
//  BackupView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-27.
//

import SwiftUI

struct BackupView: View {
    @State public var app: SBApp
    @State private var fakebackups: [Backup] = []
    var body: some View {
        List {
            Section {
                NavigationLink(destination: { ReplaceTestingView(app: app) }, label: { Label("Replace Testing", systemImage: "wrench.and.screwdriver") })
            }
            Section {
                Button(action: {
                    fakebackups.append(Backup(app: app, time: Date()))
                }, label: {
                    Label("Back up now", systemImage: "arrow.down.app")
                })
            }
            Section {
                ForEach(fakebackups) { fakebackup in
                    HStack {
                        Text("Backup taken \(fakebackup.time)")
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
//        .onAppear {
//            fakebackups.append(Backup(app: app, time: Date()))
//        }
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        BackupView(app: SBApp(bundleIdentifier: "com.example.placeholder", name: "Placeholder", bundleURL: URL(string: "/path/to/foo/bar/baz")!, version: "1.0.0", pngIconPaths: [""], hiddenFromSpringboard: false))
    }
}
