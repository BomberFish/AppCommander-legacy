//
//  Unsandbox.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import Foundation
import SwiftUI

func unsandbox() -> Bool {
    // MARK: 🫁

    var 🫁 = false
    #if targetEnvironment(simulator)
    🫁 = true
    #else
    if #available(iOS 16.2, *) {
        // I'm sorry 16.2 dev beta 1 users, you are a vast minority.
        print("Throwing not supported error (mdc patched)")
        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.", withButton: false)
        🫁 = false
    } else {
        // grant r/w access
        if #available(iOS 15, *) {
            print("Escaping Sandbox...")
            grant_full_disk_access { error in
                if error != nil {
                    print("Unable to escape sandbox!! Error: ", String(describing: error?.localizedDescription ?? "unknown?!"))
                    UIApplication.shared.alert(title: "Unsandboxing Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.", withButton: false)
                    🫁 = false
                } else {
                    print("Successfully escaped sandbox!")
                    🫁 = true
                }
            }
        }
    }
    #endif
    return 🫁
}
