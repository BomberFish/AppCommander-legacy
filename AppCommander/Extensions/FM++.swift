//
//  FM++.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-31.
//

import Foundation

extension FileManager {
    func sizeOfFile(atPath path: String) -> Int64? {
            guard let attrs = try? attributesOfItem(atPath: path) else {
                return nil
            }

            return attrs[.size] as? Int64
    }
}
