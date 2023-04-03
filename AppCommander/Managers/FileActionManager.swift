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
    public static func delDirectoryContents(path: String) throws {
        var contents = [""]
        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: path)
            for file in contents {
                print("Deleting \(file)")
                do {
                    try AbsoluteSolver.delete(at: URL(fileURLWithPath: path).appendingPathComponent(file))
                } catch {
                    throw GenericError.runtimeError(error.localizedDescription)
                }
            }
        } catch {
            throw GenericError.runtimeError(error.localizedDescription)
        }
    }

}
