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
            UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: FM)")
        } else {
            print("[FMModify] FM overwrite success!")
        }
        return success
    }
    public static func deleteFile(at: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: at)
            print("[FMModify] FM delete success!")
            return true
        } catch {
            print("[FMModify] FM delete failed!")
            UIApplication.shared.alert(body: "Error deleting file at \(at.path) (Strategy: FM)\n\(error.localizedDescription)")
            return false
        }
    }
}
