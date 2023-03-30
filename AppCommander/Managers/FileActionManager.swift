//
//  FileActionManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
public struct FileActionManager {
    // MARK: - deletes all the contents of directories. usually.
    public static func delDirectoryContents(path: String) -> Bool {
        var contents = [""]
        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            UIApplication.shared.alert(body: "Could not get contents of directory?!")
            return false
        }
        if contents != [""] {
            for file in contents {
                print("Deleting \(file)")
                do {
                    try FileManager.default.removeItem(atPath: file)
                    print("Probably deleted \(file)")
                    UIApplication.shared.alert(title: "Success", body: "Successfully deleted!")
                    Haptic.shared.notify(.success)
                    return true
                } catch {
                    print("Failed to delete \(file)")
                    UIApplication.shared.alert(body: error.localizedDescription)
                    Haptic.shared.notify(.error)
                    return false
                }
            }
        }
        return false
    }

}
