//
//  AbsoluteSolver.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

// Absolute Solver: A file manager that will modify/delete files By Any Means Necessary™

// ObjC bridge
fileprivate class AbsoluteSolver_ObjC {
    private let objectiveCInstance = AbsoluteSolver_ObjC()
    func readFromFileAtPath(filePath: String) throws -> String {
        do {
            return try objectiveCInstance.readFromFileAtPath(filePath: filePath)
        } catch {
            throw error.localizedDescription
        }
    }
}

public class AbsoluteSolver {
    // replace files
    public static func replace(at: URL, with: NSData) throws {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: at.path)
            let owner = fileAttributes[.ownerAccountName] as? String ?? "unknown"
            if owner == "root" {
                // Do not show to Apple employees.
                // They will NOT like it.
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
    
    public static func copy(at: URL, to: URL) throws {
        do {

                do {
                    try FileManager.default.copyItem(at: at, to: to)
                } catch {
                    throw "AbsoluteSolver: Cannot copy file \(to.path) to \(at.path): \(error.localizedDescription)"
                }
            
        } catch {
            print("[AbsoluteSolver] Error: \(error.localizedDescription)")
            Haptic.shared.notify(.error)
            throw "AbsoluteSolver: Error replacing file at \(at.path)\n\(error.localizedDescription)"
        }
    }
    
    public static func readFile(path: String) throws -> String {
        do {
            return (try String(contentsOfFile: path))
        } catch {
            do {
                print("[AbsoluteSolver] Warning: Swift read failed for file \(path)! Using ObjC read...")
                return try AbsoluteSolver_ObjC().readFromFileAtPath(filePath: path)
            } catch {
                throw "AbsoluteSolver: Error reading from file \(path): \(error.localizedDescription)"
            }
        }
    }
}
