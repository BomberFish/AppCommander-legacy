//
//  MDCReplace.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct MDCReplace {
    public static func replaceFile(at: URL, with: NSData) -> Bool {
        return MDC.overwriteFileWithDataImpl(originPath: at.path, replacementData: Data(with))
    }
}
