//
//  AbsoluteSolver.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI


// Absolute Solver: A file manager that will modify/delete files By Any Means Necessary™
public struct AbsoluteSolver {
    // replace files
    public static func replace(at: URL, with: NSData) throws{
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: at.path)
            let owner = fileAttributes[.ownerAccountName] as? String ?? "unknown"
            if owner == "root" {
                if MDC.isMDCSafe {
                    print("[AbsoluteSolver] Using MDC method")
                    do {
                        try MDCModify.replace(at: at, with: with)
                    } catch {
                        throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)")
                    }
                } else {
                    print("[AbsoluteSolver] PANIC!!! OUT OF RAM!!! THIS IS REALLY REALLY REALLY BAD!!!!!")
                    Haptic.shared.notify(.error)
                    throw GenericError.runtimeError("AbsoluteSolver: Overwrite failed!\nInsufficient RAM! Please reopen the app.")
                }
            } else if owner == "mobile" {
                print("[AbsoluteSolver] Using FM method")
                do {
                    try FMModify.replace(at: at, with: with)
                } catch {
                    throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)")
                }
            } else if owner == "unknown" {
                print("[AbsoluteSolver] Error: Could not find owner?!")
                Haptic.shared.notify(.error)
                throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\nCould not find owner?!")
            } else {
                print("[AbsoluteSolver] Error: Unexpected owner!")
                Haptic.shared.notify(.error)
                throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\nUnexpected file owner!")
            }
        } catch {
            print("[AbsoluteSolver] Error: \(error.localizedDescription)")
            Haptic.shared.notify(.error)
            throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)")
        }
    }
    
    // chainsaw hand time
    public static func delete(at: URL) throws{
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: at.path)
            let owner = fileAttributes[.ownerAccountName] as? String ?? "unknown"
            if owner == "root" {
                print("[AbsoluteSolver] Using MDC method")
                do {
                    try MDCModify.delete(at: at)
                } catch {
                    throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)")
                }
            } else if owner == "mobile" {
                print("[AbsoluteSolver] Using FM method")
                do {
                    try FMModify.delete(at: at)
                } catch {
                    throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)")
                }
            } else if owner == "unknown" {
                print("[AbsoluteSolver] Error: Could not find owner?!")
                Haptic.shared.notify(.error)
                throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\nCould not find owner?!")
            } else {
                print("[AbsoluteSolver] Error: Unexpected owner!")
                Haptic.shared.notify(.error)
                throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\nUnexpected file owner!")
            }
        } catch {
            print("[AbsoluteSolver] Error: \(error.localizedDescription)")
            Haptic.shared.notify(.error)
            throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)")
        }
    }
}
