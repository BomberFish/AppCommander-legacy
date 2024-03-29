//
//  SettingsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-18.
//

import AbsoluteSolver
import FLEX
import MacDirtyCow
import SwiftUI
import TelemetryClient
import OSLog

struct SettingsView: View {
    
    @State var consoleEnabled: Bool = UserDefaults.standard.bool(forKey: "LCEnabled")
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    @State var analyticsLevel: Int = UserDefaults.standard.integer(forKey: "analyticsLevel")
    // found the funny!
    @State var sex: Bool = UserDefaults.standard.bool(forKey: "sex")
    @State var ASEnabled: Bool = UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")
    
    @State var forceMDC: Bool = UserDefaults.standard.bool(forKey: "ForceMDC")

    @State var sheet: Bool = false
    @State var setupsheet: Bool = false
    
    @AppStorage("analyticsEnabled") var analyticsEnabled: Bool = true
    
    let logger = Logger(subsystem: "SettingsView", category: "Views")

    var body: some View {
        NavigationView {
            List {
                //Section(header: Label("AppCommander \(appVersion)", systemImage: "info.circle").textCase(.none)) {}
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About AppCommander", systemImage: "info.circle")
                    }
                    
                    Button(action: {
                        TelemetryManager.send("joinedDiscord")
                        UIApplication.shared.open(URL(string: "https://discord.gg/Cowabunga")!)
                    }, label: {
                        HStack {
                            Image("discordo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .colorMultiply(.accentColor)
                                .tint(.accentColor)
                                .foregroundColor(.accentColor)
                                .frame(width: 20, height: 20)
                            Text("  Join the Discord!")
                        }
                    })
                }
                Section {
                    Button(action: {
                        TelemetryManager.send("jitSetupViewed")
                        setupsheet = true
                    }, label: { Label("Set up JIT", systemImage: "sparkles") })
                        .sheet(isPresented: $setupsheet, content: { JITSetupView() })
                }
                Section {
                    NavigationLink {
                        AppIconView()
                    } label: {
                        Label("Alternate App Icons", systemImage: "app.badge")
                    }

                    NavigationLink {
                        ViewSettings()
                    } label: {
                        Label("View Options", systemImage: "paintbrush")
                    }
                }
                
                Section {
                    Button(action: {
                        UIApplication.shared.confirmAlertDestructive(title: "Confirmation", body: "Do you really want to do this?", onOK: {
                            do {
                                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                                    UIApplication.shared.progressAlert(title: "Disassembling app documents...")
                                    try AbsoluteSolver.delDirectoryContents(path: "/var/mobile/.DO_NOT_DELETE-AppCommander", progress: { percentage, fileName in
                                        print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)", logger: logger)
                                        UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                                    })
                                } else {
                                    UIApplication.shared.progressAlert(title: "Deleting app documents...")
                                    try delDirectoryContents(path: "/var/mobile/.DO_NOT_DELETE-AppCommander", progress: { percentage, fileName in
                                        print("\(Int(percentage * 100))%: Deleting \(fileName)", logger: logger)
                                        UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Deleting \(fileName)")
                                    })
                                }
                                UIApplication.shared.dismissAlert(animated: true)
                                Haptic.shared.notify(.success)
                                // UIApplication.shared.alert(title: "Success", body: "Successfully deleted app data!")
                            } catch {
                                UIApplication.shared.dismissAlert(animated: true)
                                Haptic.shared.notify(.error)
                                UIApplication.shared.alert(body: error.localizedDescription)
                            }
                        }, destructActionText: "Delete")
                    }, label: {
                        Label("Delete app documents (including backups)", systemImage: "trash")
                    })
                    Button(action: {
                        do {
                            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                                UIApplication.shared.progressAlert(title: "Disassembling app cache...")
                                try AbsoluteSolver.delDirectoryContents(path: FileManager.default.temporaryDirectory.path, progress: { percentage, fileName in
                                    print("[AbsoluteSolver]: \(Int(percentage * 100))%: Disassembling \(fileName)")
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Disassembling \(fileName)")
                                })
                            } else {
                                UIApplication.shared.progressAlert(title: "Deleting app cache...")
                                try delDirectoryContents(path: FileManager.default.temporaryDirectory.path, progress: { percentage, fileName in
                                    print("\(Int(percentage * 100))%: Deleting \(fileName)", logger: logger)
                                    UIApplication.shared.changeBody("\n\n\n\(Int(percentage * 100))%: Deleting \(fileName)")
                                })
                            }
                            UIApplication.shared.dismissAlert(animated: true)
                            Haptic.shared.notify(.success)
                            // UIApplication.shared.alert(title: "Success", body: "Successfully deleted app cache!")
                        } catch {
                            UIApplication.shared.dismissAlert(animated: true)
                            Haptic.shared.notify(.error)
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }, label: {
                        Label("Delete temporary storage", systemImage: "trash")
                    })
                    NavigationLink {
                        FileBrowserView(path: "/var/mobile/.DO_NOT_DELETE-AppCommander/Backups/", title: "Backups")
                    } label: {
                        Label("Manage Backups", systemImage: "folder.badge.gearshape")
                    }
                } header: {
                    Label("Storage Management", systemImage: "internaldrive")
                }
                Section {
                    Toggle(isOn: $analyticsEnabled, label: {
                        Label("Analytics", systemImage: "chart.bar.xaxis")
                    })
                        .tint(.accentColor)
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        if #available(iOS 16, *) {
                            Label("Privacy Policy", systemImage: "person.badge.shield.checkmark")
                        } else {
                            Label("Privacy Policy", systemImage: "checkmark.shield.fill")
                        }
                    }
                } header: {
                    Label("Analytics", systemImage: "chart.bar")
                }

//                Section {
//                    ForEach(contribs) { contrib in
//                        LinkCell(imageName: contrib.image, url: contrib.url, title: contrib.name, contribution: contrib.contribution)
//                    }
//                    NavigationLink {
//                        TranslatorsView()
//                    } label: {
//                        Label("Translators", systemImage: "character.bubble")
//                    }
//                    NavigationLink {
//                        PackageCreditsView()
//                    } label: {
//                        Label("Swift Packages", systemImage: "shippingbox")
//                    }
//                } header: {
//                    Label("Credits", systemImage: "heart")
//                }

                Section {
                    Toggle(isOn: $debugEnabled, label: { Label("Debug Mode", systemImage: "ladybug") })
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .onChange(of: debugEnabled) { new in
                            // set the user defaults
                            if debugEnabled {
                                TelemetryManager.send("debugModeEnabled")
                            }
                            UserDefaults.standard.set(new, forKey: "DebugEnabled")
                        }

                    Toggle(isOn: $ASEnabled, label: { Label("Disable Absolute Solver", systemImage: "move.3d") })
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .onChange(of: ASEnabled) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "AbsoluteSolverDisabled")
                        }

                } header: {
                    Label("Advanced", systemImage: "gearshape.2")
                }

                if debugEnabled {
                    Section {
                        Toggle(isOn: $consoleEnabled, label: { Label("Enable in-app console", systemImage: "terminal") })
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                            .onChange(of: consoleEnabled) { new in
                                // set the user defaults
                                UserDefaults.standard.set(new, forKey: "LCEnabled")
                                if new {
                                    consoleManager.isVisible = true
                                } else {
                                    consoleManager.isVisible = false
                                }
                            }
                        Toggle(isOn: $forceMDC, label: { Label("Force MacDirtyCow", systemImage: "terminal") })
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                            .onChange(of: consoleEnabled) { new in
                                // set the user defaults
                                UserDefaults.standard.set(new, forKey: "ForceMDC")
                                if new {
                                    consoleManager.isVisible = true
                                } else {
                                    consoleManager.isVisible = false
                                }
                            }
                        Toggle(isOn: $sex, label: { Text("😏      Sex") })
                            .tint(.accentColor)
                            .onChange(of: sex) { new in
                                if new == true {
                                    let alert = UIAlertController(title: "Confirmation", message: NSLocalizedString("You are about to enable extra debugging settings meant only for developers. If you understand the risks, please type 'I solemnly swear that I am up to no good' in the textfield below.", comment: "Do NOT under ANY circumstances translate the string 'I solemnly swear that I am up to no good'."), preferredStyle: .alert)
                                    alert.addTextField { textField in
                                        textField.text = ""
                                    }
                                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                                        sex = false
                                    }))
                                    alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { _ in
                                        let text = alert.textFields![0].text!
                                        if text == "I solemnly swear that I am up to no good" {
                                            // set the user defaults
                                            Haptic.shared.notify(.success)
                                            sex = true
                                            TelemetryManager.send("extraDebugEnabled")
                                            UserDefaults.standard.set(true, forKey: "sex")
                                        } else {
                                            Haptic.shared.notify(.error)
                                            sex = false
                                            UserDefaults.standard.set(false, forKey: "sex")
                                            UIApplication.shared.alert(body: "Incorrect phrase entered.")
                                        }
                                    }))
                                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                                } else {
                                    Haptic.shared.notify(.success)
                                    sex = false
                                    UserDefaults.standard.set(false, forKey: "sex")
                                }
                            }
                    } header: {
                        Label("Debug", systemImage: "ladybug")
                    }

                    if sex {
                        Section {
                            NavigationLink {
                                FileBrowserView(path: "/", title: "Root")
                            } label: {
                                Label("Open file browser in /", systemImage: "folder.badge.gearshape")
                            }
                            Button(action: { sheet = true }, label: { Label("Test InfoSheetView", systemImage: "info.circle") })
                                .sheet(isPresented: $sheet, content: { SheetView(symbol: "info.circle", title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur pretium, enim a tempus sollicitudin, diam nulla vestibulum velit, eget placerat massa orci sit amet nisl. Aenean sollicitudin rutrum lobortis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ac velit quis justo viverra gravida eu nec nibh. Vestibulum rhoncus, magna et finibus ultrices, mi enim condimentum odio, eget pellentesque magna tellus vitae nisi. Phasellus interdum condimentum ante, rutrum lacinia massa tristique vel. Curabitur euismod tristique elit, vitae lobortis arcu condimentum et. Vivamus pellentesque leo quis mi laoreet pulvinar.", buttons: [SheetButton(title: "Confirm", action: { print("confirm pressed") }, type: .primary), SheetButton(title: "Cancel", action: { print("cancel pressed") }, type: .secondary)]) })
                            Button(action: { FLEXManager.shared.showExplorer() }, label: { Label("Show FLEX", systemImage: "gear") })
                            Button(action: respring, label: { Label("Restart frontboard", systemImage: "arrow.counterclockwise") })
                            Button(action: MacDirtyCow.restartBackboard, label: { Label("Restart backboard", systemImage: "arrow.counterclockwise") })
                            Button(action: reboot, label: { Label("Trigger kernel panic", systemImage: "exclamationmark.arrow.circlepath") })
                        } header: {
                            Label("Extra Debug Settings", systemImage: "ant.fill")
                        }
                        // 💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀
                        Section {
                            Button(action: {
                                // create and configure alert controller
                                let alert = UIAlertController(title: "", message: "This will completely wipe your device", preferredStyle: .actionSheet)

                                // create the actions
                                let newAction = UIAlertAction(title: "Brick Device", style: .default) { _ in
                                    do {
                                        TelemetryManager.send("idiotBrickedDevice")
                                        try AbsoluteSolver.delDirectoryContents(path: "/private/preboot", progress: { percentage, fileName in
                                            print("[\(percentage)%] deleting \(fileName)", logger: logger)
                                        })
                                        UIApplication.shared.alert(title: "You fucked up big time.", body: "You absolute moron. You bloody idiot. Congratulations. You irreversably fucked your phone. Do you feel happy? Proud, even? You ignored the big fat warning that said this wouldn't end well, and look where it got you. You'd better pray that you have your data backed up SOMEWHERE, because this phone will turn off in 10 seconds and not boot again until you restore using a computer.", withButton: false)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                            reboot()
                                        }
                                    } catch {
                                        Haptic.shared.notify(.error)
                                    }
                                }
                                alert.addAction(newAction)

                                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                                    // cancels the action
                                }

                                // add the actions
                                alert.addAction(cancelAction)

                                let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                                // present popover for iPads
                                alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                                alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads

                                // present the alert
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                            }, label: {
                                Text("Brick Device")

                            })
                        } header: {
                            // omg internalui!!!!!!!!!!!!!!!!!!!!!
                            Text("Wipe your device before returning to the person collecting hardware")
                        }
                    }
                }
            }
            // .background(GradientView())
            .listRowBackground(Color.clear)
            // .listStyle(.sidebar)
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
