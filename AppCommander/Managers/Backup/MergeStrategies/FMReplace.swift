//
//  FMReplace.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public struct FMReplace {
    public static func replaceFile(at: URL, with: NSData) -> Bool {
        return with.write(to: at, atomically: true)
    }
}
