//
//  FMModify.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct FMModify {
    public static func replace(at: URL, with: NSData) throws {
        let success = with.write(to: at, atomically: true)
        if !success {
            print("[FMModify] FM overwrite failed!")
            Haptic.shared.notify(.error)
            throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: FileManager)")
        } else {
            print("[FMModify] FM overwrite success!")
            Haptic.shared.notify(.success)
        }
    }
    public static func delete(at: URL) throws {
        do {
            try FileManager.default.removeItem(at: at)
            print("[FMModify] FM delete success!")
            Haptic.shared.notify(.success)
        } catch {
            print("[FMModify] FM delete failed!")
            Haptic.shared.notify(.error)
            throw GenericError.runtimeError("Error deleting file at \(at.path) (Edit Style: FileManager)\n\(error.localizedDescription)")
        }
    }
}
