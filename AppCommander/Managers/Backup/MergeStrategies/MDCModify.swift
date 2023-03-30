//
//  MDCModify.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct MDCModify {
    public static func replaceFile(at: URL, with: NSData) -> Bool {
        let success = MDC.overwriteFileWithDataImpl(originPath: at.path, replacementData: Data(with))
        if !success {
            print("[MDCReplace] MDC overwrite failed")
            UIApplication.shared.alert(body: "Error replacing file at \(at.path) (Strategy: MDC)")
        } else {
            print("[MDCReplace] MDC overwrite success!")
        }
        return success
    }
    
    public static func deleteFile(at: URL) -> Bool {
        UIApplication.shared.alert(body: "Deleting files with MDC is not supported!")
        return false
    }
}
