//
//  MDCModify.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct MDCModify {
    public static func replace(at: URL, with: NSData) throws {
        let success = MDC.overwriteFileWithDataImpl(originPath: at.path, replacementData: Data(with))
        if !success {
            print("[MDCReplace] MDC overwrite failed")
            Haptic.shared.notify(.error)
            throw GenericError.runtimeError("Error replacing file at \(at.path) (Edit Style: MacDirtyCow)")
        } else {
            print("[MDCReplace] MDC overwrite success!")
            Haptic.shared.notify(.success)
        }
    }
    
    public static func delete(at: URL) throws {
        Haptic.shared.notify(.error)
        throw GenericError.runtimeError("Deleting files with MDC is not supported... yet.")
    }
}
