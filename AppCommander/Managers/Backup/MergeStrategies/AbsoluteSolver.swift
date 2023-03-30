//
//  AbsoluteSolver.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct AbsoluteSolver {
    public static func replaceFile(at: URL, with: NSData) -> Bool {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: at.path)
            let owner = fileAttributes[.ownerAccountName] as? String ?? "unknown"
            if owner == "root" {
                return MDCReplace.replaceFile(at: at, with: with)
            } else if owner == "mobile" {
                return FMReplace.replaceFile(at: at, with: with)
            } else if owner == "unknown" {
                UIApplication.shared.alert(body: "Error removing file at \(at.path) (Strategy: AS)\nCould not find owner?!")
            } else {
                UIApplication.shared.alert(body: "Error removing file at \(at.path) (Strategy: AS)\nUnexpected file owner!")
            }
        } catch {
            UIApplication.shared.alert(body: "Error removing file at \(at.path) (Strategy: AS)\n\(error.localizedDescription)")
        }
        return false
    }
}
