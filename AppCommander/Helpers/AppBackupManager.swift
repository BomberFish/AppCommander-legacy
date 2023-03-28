//
//  AppBackupManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-27.
//

import Foundation

struct Backup: Identifiable, Equatable {
    var app: SBApp
    var id = UUID()
    var time: Date
}
