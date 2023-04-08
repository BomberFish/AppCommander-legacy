//
//  SpringBoardItem.swift
//  Appabetical
//
//  Created by exerhythm on 17.12.2022.
//

import Foundation


class SpringBoardItem {
    func compare(to item2: SpringBoardItem, folderSortingOption: IconStateManager.FolderSortingOption, sortingOption: IconStateManager.SortOption) -> Bool {
        func compareByTitle() -> Bool {
            return sortingOption == .alphabeticallyReversed ? item1.title.lowercased() > item2.title.lowercased() : item1.title.lowercased() < item2.title.lowercased()
        }
        
        let item1 = self
        
        if item1.type == .widget || item2.type == .widget {
            if item1.type == .widget, item2.type == .widget {
                return item1.widgetSize?.rawValue ?? 0 > item2.widgetSize?.rawValue ?? 0
            } else if item1.type == .widget {
                return true
            } else if item2.type == .widget {
                return false
            }
        } else if item1.type == .folder || item2.type == .folder {
            if item1.type == .folder, item2.type == .folder {
                return folderSortingOption == .noSort ? false : compareByTitle()
            } else if item1.type == .folder {
                return folderSortingOption == .alongside ? compareByTitle() : true
            } else if item2.type == .folder {
                return folderSortingOption == .alongside ? compareByTitle() : false
            }
        }
        if sortingOption == .color {
            if item1.type == .app, item2.type == .app {
               var hue1: CGFloat = 0
               var saturation1: CGFloat = 0
               var brightness1: CGFloat = 0
               var alpha1: CGFloat = 0
                IconStateItemHelper.shared.getColor(id: item1.bundleID).getHue(&hue1, saturation: &saturation1, brightness: &brightness1, alpha: &alpha1)

               var hue2: CGFloat = 0
               var saturation2: CGFloat = 0
               var brightness2: CGFloat = 0
               var alpha2: CGFloat = 0
                IconStateItemHelper.shared.getColor(id: item2.bundleID).getHue(&hue2, saturation: &saturation2, brightness: &brightness2, alpha: &alpha2)

               if hue1 < hue2 {
                   return true
               } else if hue1 > hue2 {
                   return false
               }

               if saturation1 < saturation2 {
                   return true
               } else if saturation1 > saturation2 {
                   return false
               }

               if brightness1 < brightness2 {
                   return true
               } else if brightness1 > brightness2 {
                   return false
               }
           }
        }
        return compareByTitle()
    }
    
    private(set) var title: String
    private(set) var bundleID: String
    private(set) var widgetSize: ItemSize?
    private(set) var type: ItemType
    
    /// An object (dict for widgets, folders and duplicate apps) that was obtained from iconstate.plist
    public var originalObject: AnyObject!
    
    private init(title: String,  bundleID: String, widgetSize: ItemSize? = nil, type: ItemType) {
        self.title = title
        self.bundleID = bundleID
        self.widgetSize = widgetSize
        self.type = type
    }
    
    convenience init(from item: AnyObject) {
        func getItemSize(size: String) -> ItemSize {
            switch size {
            case "small": return .small
            case "medium": return .medium
            case "large": return .large
            default: return .unknown
            }
        }
        
        self.init(title: "", bundleID: "", type: .unknown)
        
        if let bundleID = item as? String {
            // App / web clip / app clip
            self.init(title: IconStateItemHelper.shared.getName(id: bundleID), bundleID: bundleID, type: .app)
        } else if let dict = item as? [String : Any] {
            if let iconType = item["iconType"] as? String {
                // Duplicate app
                if iconType == "app" {
                    if let bundleID = dict["bundleIdentifier"] as? String {
                        self.init(title: IconStateItemHelper.shared.getName(id: bundleID), bundleID: bundleID, type: .app)
                    }
                } else if iconType == "custom" {
                    // Widget
                    if let gridSize = item["gridSize"] as? String {
                        self.init(title: "", bundleID: "", widgetSize: getItemSize(size: gridSize), type: .widget)
                    }
                }
            } else if let listType = dict["listType"] as? String {
                // Folder
                if listType == "folder" {
                    if let displayName = dict["displayName"] as? String {
                        self.init(title: displayName, bundleID: "", type: .folder)
                    }
                }
            }
        }
        
        originalObject = item
        
    }
    
    
    // MARK: Enums
    
    enum ItemSize: Int {
        case normal = 1
        case small = 4
        case medium = 8
        case large = 16
        case unknown = 0
    }

    enum ItemType: Int {
        case app
        case folder
        case widget
        case unknown
    }

}
