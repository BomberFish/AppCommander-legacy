//
//  FileActionManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct FileActionManager {
    // MARK: - deletes all the contents of directories. usually.
    public static func delDirectoryContents(path: String) -> Bool {
        var contents = [""]
        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            UIApplication.shared.alert(body: "Could not get contents of directory?!\n\(error.localizedDescription)")
            return false
        }
        if contents != [""] {
            for file in contents {
                print("Deleting \(file)")
                return AbsoluteSolver.delete(at: URL(fileURLWithPath: file))
            }
        }
        return false
    }

}
