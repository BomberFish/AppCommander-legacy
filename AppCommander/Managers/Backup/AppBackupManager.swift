//
//  AppBackupManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-27.
//

import Foundation
import ZIPFoundation

struct Backup: Identifiable, Equatable {
    var app: SBApp
    var id = UUID()
    var time: Date
    var path: URL
}

public enum AppBackupManager {
    static func backup(app: SBApp) {
        let datadir = ApplicationManager.getDataDir(bundleID: app.bundleIdentifier)
        let fm = FileManager.default
        let docsdir = (fm.urls(for: .documentDirectory, in: .userDomainMask))[0]
        
        let backupfolderdir = docsdir.appendingPathComponent("Backups", conformingTo: .directory)
        let backupfolderdirexists = fm.fileExists(atPath: backupfolderdir.path)
        
        let backupdir = backupfolderdir.appendingPathComponent(app.bundleIdentifier, conformingTo: .directory)
        let backupdirexists = fm.fileExists(atPath: backupfolderdir.path)
        
        print(datadir, docsdir, backupfolderdir, backupfolderdirexists, backupdir, backupdirexists)
        do {
            try fm.createDirectory(at: backupdir.appendingPathComponent("test", conformingTo: .directory), withIntermediateDirectories: true)
            Haptic.shared.notify(.success)
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
            Haptic.shared.notify(.error)    
        }
        do {
            try fm.zipItem(at: datadir, to: backupdir.appendingPathComponent(DateFormatter().string(from: Date())).appendingPathExtension("zip"))
            Haptic.shared.notify(.success)
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
            Haptic.shared.notify(.error)
        }
    }
    
    static func getBackups(app: SBApp) -> [Backup] {
        let datadir = ApplicationManager.getDataDir(bundleID: app.bundleIdentifier)
        let fm = FileManager.default
        let docsdir = (fm.urls(for: .documentDirectory, in: .userDomainMask))[0]
            
        let backupfolderdir = docsdir.appendingPathComponent("Backups", conformingTo: .directory)
        let backupfolderdirexists = fm.fileExists(atPath: backupfolderdir.path)
            
        let backupdir = backupfolderdir.appendingPathComponent(app.bundleIdentifier, conformingTo: .directory)
        let backupdirexists = fm.fileExists(atPath: backupfolderdir.path)
            
        do {
            let contents = try fm.contentsOfDirectory(atPath: backupdir.path)
            print(contents)
            var contentsURL: [Backup]?
            for file in contents {
                print(file)
                contentsURL?.append(Backup(app: app, time: DateFormatter().date(from: NSString(string: file).lastPathComponent)!, path: URL(fileURLWithPath: file)))
            }
            Haptic.shared.notify(.success)
            return contentsURL ?? []
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
            Haptic.shared.notify(.error)
        }
        return []
    }
}
