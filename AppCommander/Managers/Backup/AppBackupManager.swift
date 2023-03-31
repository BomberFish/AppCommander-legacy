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

public struct AppBackupManager {
    static func backup(app: SBApp) {
        let datadir = ApplicationManager.getDataDir(bundleID: app.bundleIdentifier)
        let fm = FileManager.default
        let docsdir = (fm.urls(for: .documentDirectory, in: .userDomainMask))[0]
        
        let backupfolderdir = docsdir.appendingPathComponent("Backups", conformingTo: .directory)
        let backupfolderdirexists = fm.fileExists(atPath: backupfolderdir.path)
        
        let backupdir = backupfolderdir.appendingPathComponent(app.bundleIdentifier, conformingTo: .directory)
        let backupdirexists = fm.fileExists(atPath: backupfolderdir.path)
        
        print(datadir, docsdir, backupfolderdir, backupdirexists)
        if !backupdirexists {
            do {
                try fm.createDirectory(at: backupdir, withIntermediateDirectories: true)
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
        do {
            try fm.zipItem(at: datadir, to: backupdir.appendingPathComponent(DateFormatter().string(from: Date())).appendingPathExtension("zip"))
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
        }
    }
    
    static func getBackups(app: SBApp) -> [Backup] {
        let fm = FileManager.default
        do {
            let contents = try fm.contentsOfDirectory(atPath: ((((fm.urls(for: .documentDirectory, in: .userDomainMask))[0]).appendingPathComponent("Backups", conformingTo: .directory)).appendingPathComponent(app.bundleIdentifier, conformingTo: .directory)).path)
            
            print(contents)
            var contentsURL: [Backup]? = nil
            for file in contents {
                print(file)
                contentsURL?.append(Backup(app: app, time: DateFormatter().date(from: NSString(string: file).lastPathComponent)!, path: URL(fileURLWithPath: file)))
            }
            return contentsURL ?? []    
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
        }
        return []
    }
}
