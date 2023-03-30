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
                print("[AbsoluteSolver] Using MDC method")
                return MDCModify.replaceFile(at: at, with: with)
            } else if owner == "mobile" {
                print("[AbsoluteSolver] Using FM method")
                return FMModify.replaceFile(at: at, with: with)
            } else if owner == "unknown" {
                print("[AbsoluteSolver] Error: Could not find owner?!")
                UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: AS)\nCould not find owner?!")
            } else {
                print("[AbsoluteSolver] Error: Unexpected owner!")
                UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: AS)\nUnexpected file owner!")
            }
        } catch {
            print("[AbsoluteSolver] Error: \(error.localizedDescription)")
            UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: AS)\n\(error.localizedDescription)")
        }
        return false
    }
    
    public static func delete(at: URL) -> Bool {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: at.path)
            let owner = fileAttributes[.ownerAccountName] as? String ?? "unknown"
            if owner == "root" {
                print("[AbsoluteSolver] Using MDC method")
                return MDCModify.deleteFile(at: at)
            } else if owner == "mobile" {
                print("[AbsoluteSolver] Using FM method")
                return FMModify.deleteFile(at: at)
            } else if owner == "unknown" {
                print("[AbsoluteSolver] Error: Could not find owner?!")
                UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: AS)\nCould not find owner?!")
            } else {
                print("[AbsoluteSolver] Error: Unexpected owner!")
                UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: AS)\nUnexpected file owner!")
            }
        } catch {
            print("[AbsoluteSolver] Error: \(error.localizedDescription)")
            UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: AS)\n\(error.localizedDescription)")
        }
        return false
    }
}
