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
    public static func delDirectoryContents(path: String, progress: ((Double,String)) -> ()) throws {
        var contents = [""]
        var currentfile: Int = 0
        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: path)
            for file in contents {
                print("Deleting \(file)")
                do {
                    try AbsoluteSolver.delete(at: URL(fileURLWithPath: path).appendingPathComponent(file))
                    currentfile += 1
                    progress((Double(currentfile / contents.count), file))
                } catch {
                    throw error.localizedDescription
                }
            }
        } catch {
            throw error.localizedDescription
        }
    }

}
