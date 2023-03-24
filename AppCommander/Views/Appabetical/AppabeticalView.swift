//
//  AppabeticalView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-24.
//

import SwiftUI
import MobileCoreServices

struct AppabeticalView: View {
    
    // Settings variables
    @State private var selectedItems = [Int]()
    @State private var pageOp = IconStateManager.PageSortingOption.individually
    @State private var folderOp = IconStateManager.FolderSortingOption.noSort
    @State private var sortOp = IconStateManager.SortOption.alphabetically
    @State private var widgetOp = IconStateManager.WidgetOptions.top
    
    @Environment(\.openURL) var openURL
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: {
                        MultiSelectPickerView(pages: IconStateManager.getPages(), selectedItems: $selectedItems, pageOp: $pageOp).navigationBarTitle("", displayMode: .inline)
                    }, label: {
                        HStack {
                            Text("Select Pages")
                            Spacer()
                            Text(selectedItems.isEmpty ? "None" : selectedItems.map { String($0 + 1) }.joined(separator: ", ")).foregroundColor(.secondary)
                        }
                    })
                    Picker("Ordering", selection: $sortOp) {
                        Text("A-Z").tag(IconStateManager.SortOption.alphabetically)
                        Text("Z-A").tag(IconStateManager.SortOption.alphabeticallyReversed)
                        Text("Color").tag(IconStateManager.SortOption.color)
                    }.onChange(of: sortOp, perform: {nv in if nv == .color && folderOp == .alongside { folderOp = .separately }})
                    Picker("Pages", selection: $pageOp) {
                        Text("Sort pages independently").tag(IconStateManager.PageSortingOption.individually)
                        Text("Sort apps across pages").tag(IconStateManager.PageSortingOption.acrossPages)
                    }
                    Picker("Folders", selection: $folderOp) {
                        Text("Retain current order").tag(IconStateManager.FolderSortingOption.noSort)
                        if (sortOp == .alphabetically || sortOp == .alphabeticallyReversed) {
                            Text("Sort mixed with apps").tag(IconStateManager.FolderSortingOption.alongside)
                        }
                        Text("Sort separate from apps").tag(IconStateManager.FolderSortingOption.separately)
                    }
                    Picker("Widgets", selection: $widgetOp) {
                        Text("Move to top").tag(IconStateManager.WidgetOptions.top)
                    }
                    Button("Sort Apps") {
                        sortPage()
                    }.disabled(selectedItems.isEmpty)
                }
                Section(footer: Text((fm.fileExists(atPath: savedLayoutUrl.path) ?  "The previously saved layout will be overwritten." : "It is recommended you save your current layout before experimenting as only one undo is possible." ) + "\n\nVersion \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "pirate version bozo®")")) {
                    Button("Undo Last Sort") {
                        restoreBackup()
                    }.disabled(!fm.fileExists(atPath: plistUrlBkp.path))
                    Button("Restore Saved Layout") {
                        restoreLayout()
                    }.disabled(!fm.fileExists(atPath: savedLayoutUrl.path))
                    Button("Back Up Current Layout") {
                        saveLayout()
                    }
                }
            }
            .navigationTitle("Appabetical")
            .toolbar {
                // Credit to SourceLocation
                // https://github.com/sourcelocation/AirTroller/blob/main/AirTroller/ContentView.swift
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        openURL(URL(string: "https://discord.gg/VyVcNjRMeg")!)
                    }) {
                        Image("discord")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    Menu {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            openURL(URL(string: "https://github.com/Avangelista/Appabetical")!)
                        } label: {
                            Label("Source Code", systemImage: "shippingbox")
                        }
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            openURL(URL(string: "https://github.com/Avangelista")!)
                        } label: {
                            Label("Avangelista", systemImage: "person")
                        }
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            openURL(URL(string: "https://github.com/sourcelocation")!)
                        } label: {
                            Label("sourcelocation", systemImage: "person")
                        }
                    } label: {
                        Image("github")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    Menu {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            openURL(URL(string: "https://ko-fi.com/avangelista")!)
                        } label: {
                            Label("Avangelista", systemImage: "1.circle")
                        }
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            openURL(URL(string: "https://ko-fi.com/sourcelocation")!)
                        } label: {
                            Label("sourcelocation", systemImage: "2.circle")
                        }
                    } label: {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .onAppear {
                
            }
        }
    }
    
    
    // Sort the selected pages
    func sortPage() {
        do {
            let pageCount = try IconStateManager.shared.pageCount()
            selectedItems = selectedItems.filter {$0 - 1 < pageCount }
            if selectedItems.isEmpty { return }
            
            try IconStateManager.shared.sortPages(selectedPages: selectedItems, sortOption: sortOp, pageSortingOption: pageOp, folderSortingOption: folderOp)
        } catch {  UIApplication.shared.alert(body: error.localizedDescription) }
    }
    
    func saveLayout() {
        BackupManager.saveLayout()
    }
    
    func restoreBackup() {
        UIApplication.shared.confirmAlert(title: "Confirm Undo", body: "This layout was saved on \(BackupManager.getTimeSaved(url: plistUrlBkp) ?? "(unknown date)"). Be mindful if you've added/removed any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try BackupManager.restoreBackup()
                respringFrontboard()
            } catch {  UIApplication.shared.alert(body: error.localizedDescription) }
        }, noCancel: false)
    }
    
    func restoreLayout() {
        UIApplication.shared.confirmAlert(title: "Confirm Restore", body: "This layout was saved on \(BackupManager.getTimeSaved(url: savedLayoutUrl) ?? "(unknown date)"). Be mindful if you've added/removed any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try BackupManager.restoreLayout()
                respringFrontboard()
            } catch {  UIApplication.shared.alert(body: error.localizedDescription) }
        }, noCancel: false)
    }
}

struct AppabeticalView_Previews: PreviewProvider {
    static var previews: some View {
        AppabeticalView()
    }
}

