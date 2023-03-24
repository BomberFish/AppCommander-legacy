//
//  IconStateManager.swift
//  Appabetical
//
//  Created by exerhythm on 17.12.2022.
//

import Foundation

public class IconStateManager {
    
    static var shared = IconStateManager()
    
    public func pageCount() throws -> Int {
        guard let plist = NSDictionary(contentsOf: plistUrl) as? [String:AnyObject] else { throw "no iconstate" }
        guard let iconLists = plist["iconLists"] as? [[AnyObject]] else { throw "no iconlists?" }
        return iconLists.count
    }
    
    public func sortPages(selectedPages: [Int], sortOption: SortOption, pageSortingOption: PageSortingOption, folderSortingOption: FolderSortingOption) throws {
        try BackupManager.makeBackup()
        
        // Open IconState.plist
        guard var plist = NSDictionary(contentsOf: plistUrl) as? [String:AnyObject] else { return }
        guard var iconLists = plist["iconLists"] as? [[AnyObject]] else { return }
        print(iconLists)
        let springBoardItemLists = iconLists.map { $0.map { SpringBoardItem(from: $0) } }
        
        var newSpringBoardItems: [[SpringBoardItem]]!
        
        // Store only selected pages in newSpringBoardItems. If acrossPages, then there's only one array
        if pageSortingOption == .acrossPages {
            newSpringBoardItems = [selectedPages.sorted().map { springBoardItemLists[$0] }.reduce([], +)]
        } else if pageSortingOption == .individually {
            newSpringBoardItems = selectedPages.sorted().map { springBoardItemLists[$0] }
        }
        
        // Sort each selected page
        newSpringBoardItems = newSpringBoardItems.enumerated().map { (i, page) in
            page.sorted { item1, item2 in
                item1.compare(to: item2, folderSortingOption: folderSortingOption, sortingOption: sortOption)
            }
        }
        
        print(newSpringBoardItems as Any)
        
        // Evenly distribute newSpringBoardItems amongst pages to avoid overflow
        var newIconLists: [[AnyObject]] = []
        
        for page in newSpringBoardItems {
            var pageSize = 0
            var pageNew: [AnyObject] = []
            
            for item in page {
                let itemSize = item.widgetSize?.rawValue ?? 1 // 1 is the size of one single icon
                if pageSize + itemSize > iconsOnAPage {
                    pageSize = 0
                    newIconLists.append(pageNew)
                    pageNew.removeAll()
                }
                pageNew.append(item.originalObject)
                pageSize += itemSize
            }
            
            newIconLists.append(pageNew)
        }
        
        print(newIconLists)
        
        // Set selected pages in iconLists to [], so indicies don't fuck up. Removes all remaining [] values later
        for i in selectedPages {
            iconLists[i] = []
        }
        print(selectedPages)
        
        // Insert new pages into old iconLists
        for (newPageI, page) in newIconLists.enumerated() {
            let pageI = selectedPages[newPageI] // can this crash?
            
            iconLists[pageI] = page
        }
        
        // Remove all remaining [] values created earlier
        iconLists = iconLists.filter({ page in !page.isEmpty })
        
        print(iconLists)
        
        plist["iconLists"] = iconLists as AnyObject
        let pageCount = iconLists.count

        // Show all hidden pages
        plist["listMetadata"] = nil

        // Generate new UUIDs for pages
        var newUUIDs = [String]()
        for _ in 0..<pageCount {
            newUUIDs.append(UUID().uuidString)
        }
        plist["listUniqueIdentifiers"] = newUUIDs as AnyObject

        // Save and validate the new file
        (plist as NSDictionary).write(to: plistUrlNew, atomically: true)

        do {
            if try validateIconState(old: plistUrl, new: plistUrlNew) {
                let _ = try fm.replaceItemAt(plistUrl, withItemAt: plistUrlNew)
                respring()
            }
        } catch {
            throw "New IconState appears to be invalid. Sorting has been aborted, and no system files have been edited. Specific error: \(error.localizedDescription). Please screenshot and report."
        }
    }
    
    /// Get the pages on the user's home screen, as well as any hidden pages
    public static func getPages() -> (Int, [Int]) {
        guard let plist = NSDictionary(contentsOf: plistUrl) as? [String:Any] else { return (0, []) }
        guard let iconLists = plist["iconLists"] as? [[Any]] else { return (0, []) }
        // Hidden pages
        var hiddenPages = [Int]()
        if let listMetadata = plist["listMetadata"] as? [String:[String:Any]] {
            guard let listUniqueIdentifiers = plist["listUniqueIdentifiers"] as? [String] else { return (0, []) }
            for (index, page) in listUniqueIdentifiers.enumerated() {
                for (key, value) in listMetadata {
                    if key == page && value.keys.contains("hiddenDate") {
                        hiddenPages.append(index)
                    }
                }
            }
        }
        return (iconLists.count, hiddenPages)
    }

    private func validateIconState(old: URL, new: URL) throws -> Bool {
        guard let oldState = NSDictionary(contentsOf: old) as? [String : NSObject] else { throw "Could not read \(old.lastPathComponent) in expected format" }
        guard let newState = NSDictionary(contentsOf: new) as? [String : NSObject] else { throw "Could not read \(new.lastPathComponent) in expected format" }
        
        // Make sure the file contains expected data
        guard newState.keys.contains("buttonBar") else { throw "Could not find key buttonBar in \(new.lastPathComponent)" }
        guard newState.keys.contains("iconLists") else { throw "Could not find key iconLists in \(new.lastPathComponent)" }
        
        for (key, value) in oldState {
            // Check that all keys are present in both
            if let value2 = newState[key] {
                if key == "iconLists" {
                    // Ensure all apps and folders are present in both
                    guard let iconListsOld = value as? [[NSObject]] else { throw "Could not read value of key \(key) in \(old.lastPathComponent) in expected format" }
                    guard let iconListsNew = newState[key] as? [[NSObject]] else { throw "Could not read value of key \(key) in \(new.lastPathComponent) in expected format" }
                    var iconSetOld: Set<NSObject> = []
                    var iconSetNew: Set<NSObject> = []
                    
                    for p in iconListsOld {
                        iconSetOld.formUnion(p)
                    }
                    for p in iconListsNew {
                        iconSetNew.formUnion(p)
                    }
                    if iconSetOld != iconSetNew { throw "Contents of iconLists array differs between \(old.lastPathComponent) and \(new.lastPathComponent)" }
                } else if key == "listMetadata" {
                    // listMetadata should be empty as we are showing all hidden pages
                    throw "Contents of listMetadata should be empty in \(new.lastPathComponent)"
                } else if key == "listUniqueIdentifiers" {
                    // Size of iconLists should equal size of listUniqueIdentifiers
                    guard let iconListsNew = newState["iconLists"] as? [[NSObject]] else { throw "Could not read value of key iconLists in \(new.lastPathComponent) in expected format" }
                    guard let listUniqueIdentifiers = newState["listUniqueIdentifiers"] as? [NSObject] else { throw "Could not read value of key listUniqueIdentifiers in \(new.lastPathComponent) in expected format" }
                    guard iconListsNew.count == listUniqueIdentifiers.count else { throw "Number of pages and page identifiers differs in \(new.lastPathComponent)" }
                } else if !value.isEqual(value2) {
                    throw "Value of key \(key) differs between \(old.lastPathComponent) and \(new.lastPathComponent)"
                }
            } else {
                guard key == "listMetadata" else { throw "Key \(key) missing from \(new.lastPathComponent)" }
            }
        }
        // Ensure no extraneous keys are present in the new file
        for (key, _) in newState {
            if oldState[key] == nil {
                throw "Additional key \(key) erroneously present in \(new.lastPathComponent)"
            }
        }
        return true
    }
    
    
    public enum PageSortingOption {
        case individually
        case acrossPages
    }
    
    // Options for sorting folders
    public enum FolderSortingOption {
        case noSort
        case alongside
        case separately
    }
    
    // Options for type of sort to use
    public enum SortOption: Equatable {
        case alphabetically
        case alphabeticallyReversed
        case color // swift language standart is US English :troll:
    }
    
    
    enum WidgetOptions {
        case top
    }
}
