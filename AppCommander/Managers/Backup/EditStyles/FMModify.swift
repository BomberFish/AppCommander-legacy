//
//  FMModify.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct FMModify {
    public static func replaceFile(at: URL, with: NSData) -> Bool {
        let success = with.write(to: at, atomically: true)
        if !success {
            print("[FMModify] FM overwrite failed!")
            Haptic.shared.notify(.error)
            UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Edit Style: FileManager)")
        } else {
            print("[FMModify] FM overwrite success!")
            Haptic.shared.notify(.success)
        }
        return success
    }
    public static func deleteFile(at: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: at)
            print("[FMModify] FM delete success!")
            Haptic.shared.notify(.success)
            return true
        } catch {
            print("[FMModify] FM delete failed!")
            Haptic.shared.notify(.error)
            UIApplication.shared.alert(body: "Error deleting file at \(at.path) (Edit Style: FileManager)\n\(error.localizedDescription)")
            return false
        }
    }
}
