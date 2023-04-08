//
//  AbsoluteSolver.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

// 🤖🔪


public enum AbsoluteSolver {
    // replace files
    public static func replace(at: URL, with: NSData) throws {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: at.path)
            let owner = fileAttributes[.ownerAccountName] as? String ?? "unknown"
            if owner == "root" {
                if MDC.isMDCSafe {
                    print("[AbsoluteSolver] Using MDC method for file \(at.path)")
                    let success = MDC.overwriteFileWithDataImpl(originPath: at.path, replacementData: Data(with))
                    if !success {
                        print("[AbsoluteSolver] MDC overwrite failed")
                        Haptic.shared.notify(.error)
                        throw "AbsoluteSolver: Error replacing file at \(at.path) (Using MDC)"
                    } else {
                        print("[AbsoluteSolver] MDC overwrite success!")
                        Haptic.shared.notify(.success)
                    }
                } else {
                    // you cant get ram out of thin air
                    // also prevents catastrophic failure and corruption 👍👍👍
                    print("[AbsoluteSolver] PANIC!!! OUT OF RAM!!! THIS IS REALLY REALLY REALLY BAD!!!!!")
                    Haptic.shared.notify(.error)
                    throw "AbsoluteSolver: Overwrite failed!\nInsufficient RAM! Please reopen the app."
                }
            } else if owner == "mobile" {
                print("[AbsoluteSolver] Using FM method for file \(at.path)")
                do {
                    let success = with.write(to: at, atomically: true)
                    if !success {
                        print("[AbsoluteSolver] FM overwrite failed!")
                        Haptic.shared.notify(.error)
                        throw "AbsoluteSolver: Error replacing file at \(at.path) Using unsandboxed FileManager"
                    } else {
                        print("[AbsoluteSolver] FM overwrite success!")
                        Haptic.shared.notify(.success)
                    }
                } catch {
                    throw "AbsoluteSolver: Error replacing file at \(at.path) \n\(error.localizedDescription)"
                }
            } else if owner == "unknown" {
                print("[AbsoluteSolver] Error: Could not find owner for file \(at.path)?!")
                Haptic.shared.notify(.error)
                throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\nCould not find owner?!")
            } else {
                print("[AbsoluteSolver] Warning: Unexpected owner for file \(at.path)! Using MDC...")
                // Haptic.shared.notify(.error)
                // throw "Error replacing file at \(at.path) (Edit Style: AbsoluteSolver)\nUnexpected file owner!"
                let success = MDC.overwriteFileWithDataImpl(originPath: at.path, replacementData: Data(with))
                if !success {
                    print("[AbsoluteSolver] MDC overwrite failed")
                    Haptic.shared.notify(.error)
                    throw "AbsoluteSolver: Error replacing file at \(at.path) (Using MDC)"
                } else {
                    print("[AbsoluteSolver] MDC overwrite success!")
                    Haptic.shared.notify(.success)
                }
            }
        } catch {
            print("[AbsoluteSolver] Error: \(error.localizedDescription)")
            Haptic.shared.notify(.error)
            throw "AbsoluteSolver: Error replacing file at \(at.path)\n\(error.localizedDescription)"
        }
    }

    // chainsaw hand time
    public static func delete(at: URL) throws {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: at.path)
            let owner = fileAttributes[.ownerAccountName] as? String ?? "unknown"
            if owner == "root" {
                print("[AbsoluteSolver] Skipping file \(at.path), owned by root")
//                print("[AbsoluteSolver] Using MDC method")
//                do {
//                    try MDCModify.delete(at: at)
//                } catch {
//                    throw "Error deleting file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)"
//                }
            } else if owner == "mobile" {
                print("[AbsoluteSolver] Using FM method for file \(at.path)")
                do {
                    try FileManager.default.removeItem(at: at)
                    print("[AbsoluteSolver] FM delete success!")
                    Haptic.shared.notify(.success)
                } catch {
                    throw "Error deleting file at \(at.path) (Edit Style: AbsoluteSolver)\n\(error.localizedDescription)"
                }
            } else if owner == "unknown" {
                print("[AbsoluteSolver] Error: Could not find owner for file \(at.path)?!")
                Haptic.shared.notify(.error)
                throw "AbsoluteSolver: Error deleting file at \(at.path)\nCould not find owner?!"
            } else {
                print("[AbsoluteSolver] Error: Unexpected owner for file \(at.path)!")
                Haptic.shared.notify(.error)
                throw "AbsoluteSolver: Error deleting file at \(at.path)\nUnexpected file owner!"
            }
        } catch {
            print("[AbsoluteSolver] Error deleting file \(at.path): \(error.localizedDescription)")
            Haptic.shared.notify(.error)
            throw "AbsoluteSolver: Error deleting file at \(at.path)\n\(error.localizedDescription)"
        }
    }
}
