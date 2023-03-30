//
//  AppabeticalView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-24.
//

import MobileCoreServices
import SwiftUI

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
                            Label("Select Pages", systemImage: "apps.iphone")
                            Spacer()
                            Text(selectedItems.isEmpty ? "None" : selectedItems.map { String($0 + 1) }.joined(separator: ", ")).foregroundColor(.secondary)
                        }
                    })
                    Picker(selection: $sortOp, label: Label("Ordering", systemImage: "line.3.horizontal.decrease.circle")) {
                        Text("A-Z").tag(IconStateManager.SortOption.alphabetically)
                        Text("Z-A").tag(IconStateManager.SortOption.alphabeticallyReversed)
                        Text("Color").tag(IconStateManager.SortOption.color)
                    }.onChange(of: sortOp, perform: { nv in if nv == .color, folderOp == .alongside { folderOp = .separately }})
                    Picker(selection: $pageOp, label: Label("Pages", systemImage: "rectangle.split.3x1")) {
                        Text("Sort pages independently").tag(IconStateManager.PageSortingOption.individually)
                        Text("Sort apps across pages").tag(IconStateManager.PageSortingOption.acrossPages)
                    }
                    Picker(selection: $folderOp, label: Label("Folders", systemImage: "folder")) {
                        Text("Retain current order").tag(IconStateManager.FolderSortingOption.noSort)
                        if sortOp == .alphabetically || sortOp == .alphabeticallyReversed {
                            Text("Sort mixed with apps").tag(IconStateManager.FolderSortingOption.alongside)
                        }
                        Text("Sort separate from apps").tag(IconStateManager.FolderSortingOption.separately)
                    }
                    Picker(selection: $widgetOp, label: Label("Widgets", systemImage: "rectangle")) {
                        Text("Move to top").tag(IconStateManager.WidgetOptions.top)
                    }
                    Button(action: {
                        sortPage()
                    }, label: {
                        Label("Sort Apps", systemImage: "checkmark.circle")
                    }).disabled(selectedItems.isEmpty)
                }
                Section(footer: Text(fm.fileExists(atPath: savedLayoutUrl.path) ? "The previously saved layout will be overwritten." : "It is recommended you save your current layout before experimenting as only one undo is possible.")) {
                    Button(action: {
                        restoreBackup()
                    }, label: {
                        Label("Undo Last Sort", systemImage: "arrow.uturn.backward")
                    }).disabled(!fm.fileExists(atPath: plistUrlBkp.path))
                    Button(action: {
                        restoreLayout()
                    }, label: {
                        Label("Restore Saved Layout", systemImage: "square.and.arrow.up.on.square")
                    }).disabled(!fm.fileExists(atPath: savedLayoutUrl.path))
                    Button(action: {
                        saveLayout()
                    }, label: {
                        Label("Back Up Current Layout", systemImage: "square.and.arrow.down.on.square")
                    })
                }
            }
            .navigationTitle("Home Screen")
        }
    }
    
    // Sort the selected pages
    func sortPage() {
        do {
            let pageCount = try IconStateManager.shared.pageCount()
            selectedItems = selectedItems.filter { $0 - 1 < pageCount }
            if selectedItems.isEmpty { return }
            
            try IconStateManager.shared.sortPages(selectedPages: selectedItems, sortOption: sortOp, pageSortingOption: pageOp, folderSortingOption: folderOp)
        } catch { UIApplication.shared.alert(body: error.localizedDescription) }
    }
    
    func saveLayout() {
        HomeBackupManager.saveLayout()
    }
    
    func restoreBackup() {
        UIApplication.shared.confirmAlert(title: "Confirm Undo", body: "This layout was saved on \(HomeBackupManager.getTimeSaved(url: plistUrlBkp) ?? "(unknown date)"). Be mindful if you've added/removed any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try HomeBackupManager.restoreBackup()
                respring()
            } catch { UIApplication.shared.alert(body: error.localizedDescription) }
        }, noCancel: false)
    }
    
    func restoreLayout() {
        UIApplication.shared.confirmAlert(title: "Confirm Restore", body: "This layout was saved on \(HomeBackupManager.getTimeSaved(url: savedLayoutUrl) ?? "(unknown date)"). Be mindful if you've added/removed any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try HomeBackupManager.restoreLayout()
                respring()
            } catch { UIApplication.shared.alert(body: error.localizedDescription) }
        }, noCancel: false)
    }
}

struct AppabeticalView_Previews: PreviewProvider {
    static var previews: some View {
        AppabeticalView()
    }
}
