//
//  BackupServices.swift
//  AppIndex
//
//  Created by Serena on 30/03/2023.
//

import CompressionWrapper
import Foundation
import AbsoluteSolver

public class BackupServices {
    public static let shared = BackupServices()
    
    private init() {
        self.docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Backups")
        self.backupsRegistryURL = docURL.appendingPathComponent(".DO-NOT-DELETE_backups.json")
    }
    
    let docURL: URL
    let backupsRegistryURL: URL
    
    /// Backup the given app
    func backup(application: SBApp, rootHelper: Bool, progress: ((String)) -> () /* urlHandler: @escaping (URL) -> Void */ ) throws {
//        if rootHelper {
//            let url = Bundle.main.url(forAuxiliaryExecutable: "RootHelper")!
//            spawn(command: url.path, args: ["backup-app", application.bundleID], root: true)
//            return
//        }
        do {
            print("Initializing...")
            progress("Initializing...")
            let applicationContainerURL = try ApplicationManager.getDataDir(bundleID: application.bundleIdentifier)
            if applicationContainerURL == URL(fileURLWithPath: "/var/mobile") || applicationContainerURL == URL(fileURLWithPath: "/var/root") {
                throw "Can't backup app with a container URL of /var/mobile or /var/root (App likely has no container in the first place to back up), sorry"
            }
            
            let stagingDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("APPLICATION-STAGING-\(application.bundleIdentifier)-\(UUID().uuidString.prefix(5))")
            let containerURL = stagingDirectory.appendingPathComponent("Container")
            let groups = stagingDirectory.appendingPathComponent("Groups")
            
            let item = BackupItem(application: application,
                                  stagingDirectoryName: stagingDirectory.pathComponents.suffix(2).joined(separator: "/"))
            let filename = item.backupFilename
            try FileManager.default.createDirectory(at: docURL, withIntermediateDirectories: true)
            
            try FileManager.default.createDirectory(at: stagingDirectory, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: groups, withIntermediateDirectories: true)
            print("Copying files...")
            progress("Copying files...")
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try AbsoluteSolver.copy(at: applicationContainerURL, to: containerURL, progress: {message in
                    print(message)
                })
            } else {
                try fm.copyItem(at: applicationContainerURL, to: containerURL)
            }
            
            //        for (groupID, groupContainerURL) in application.proxy.groupContainerURLs() {
            //            try FileManager.default.copyItem(at: groupContainerURL, to: groups.appendingPathComponent(groupID))
            //        }
            print("Compressing...")
            progress("Compressing...")
            try Compression.shared.compress(paths: [stagingDirectory], outputPath: docURL.appendingPathComponent(filename), format: .zip, filenameExcludes: ["v0", ".com.apple.mobile_container_manager.metadata.plist"])
            
            print("Finishing up...")
            progress("Finishing up...")
            var registry = savedBackups()
            
            registry.append(item)
            try JSONEncoder().encode(registry).write(to: backupsRegistryURL)
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try AbsoluteSolver.delete(at: stagingDirectory, progress: {message in
                    print(message)
                })
            } else {
                try fm.removeItem(at: stagingDirectory)
            }
        } catch {
            throw error.localizedDescription
        }
    }
    
    // Retrieve previously saved backups
    func savedBackups() -> [BackupItem] {
        if let existingData = try? Data(contentsOf: backupsRegistryURL),
           let decoded = try? JSONDecoder().decode([BackupItem].self, from: existingData)
        {
            return decoded
        }
        
        return [] // couldn't get the saved backups
    }
    
    func backups(for application: SBApp) -> [BackupItem] {
        return savedBackups().filter { item in
            item.applicationIdentifier == application.bundleIdentifier
        }
    }
    
    func removeBackup(_ backup: BackupItem) throws {
        var all = savedBackups()
        all.removeAll { item in
            item == backup
        }
        
        try JSONEncoder().encode(all).write(to: backupsRegistryURL)
    }
    
    /*
     func exportBackup(_ backup: BackupItem) {
        
     }
      */
    
    func importBackup(_ path: URL, application: SBApp, progress: ((String)) -> ()) throws {
        let fm = FileManager.default
        let tempurl = docURL.appendingPathComponent(path.lastPathComponent)
        try Compression.shared.extract(path: path, to: tempurl)
//        do {
//            if try fm.contentsOfDirectory(atPath: tempurl.path).contains(app.bundleIdentifier) {
//                print(docURL.appendingPathComponent(app.bundleIdentifier))
//                do {
//
//                    let item = BackupItem(application: app, stagingDirectoryName: tempurl.path)
//                    let filename = item.backupFilename
//                    try Compression.shared.compress(paths: [docURL.appendingPathComponent(app.bundleIdentifier)], outputPath: docURL.appendingPathComponent(filename), format: .zip, filenameExcludes: ["v0", ".com.apple.mobile_container_manager.metadata.plist"])
//                    let file = docURL.appendingPathComponent(app.bundleIdentifier).appendingPathExtension(".zip")
//                    print(file.path)
//                    var registry = savedBackups()
//                } catch {
//                    throw error.localizedDescription
//                }
//            } else {
//                throw "Backup is not for this app!"
//            }
//        } catch {
//            throw "Could not get contents of backup?!"
//        }
//        do {
//            if UserDefaults.standard.bool(forKey: "AbsoluteSolverEnabled") {
//                try AbsoluteSolver.delete(at: tempurl)
//            } else {
//                try fm.removeItem(at: tempurl)
//            }
//        } catch {
//            throw error.localizedDescription
//        }
        do {
            if try fm.contentsOfDirectory(atPath: tempurl.path).contains(application.bundleIdentifier) {
                print("Initializing...")
                progress("Initializing...")
                let applicationContainerURL = docURL.appendingPathComponent(application.bundleIdentifier)
                
                let stagingDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("APPLICATION-STAGING-\(application.bundleIdentifier)-\(UUID().uuidString.prefix(5))")
                let containerURL = stagingDirectory.appendingPathComponent("Container")
                let groups = stagingDirectory.appendingPathComponent("Groups")
                
                let item = BackupItem(application: application,
                                      stagingDirectoryName: stagingDirectory.pathComponents.suffix(2).joined(separator: "/"))
                let filename = item.backupFilename
                try FileManager.default.createDirectory(at: docURL, withIntermediateDirectories: true)
                
                try FileManager.default.createDirectory(at: stagingDirectory, withIntermediateDirectories: true)
                try FileManager.default.createDirectory(at: groups, withIntermediateDirectories: true)
                print("Copying files...")
                progress("Copying files...")
                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                    try AbsoluteSolver.copy(at: applicationContainerURL, to: containerURL, progress: {message in
                        print(message)
                    })
                } else {
                    try fm.copyItem(at: applicationContainerURL, to: containerURL)
                }
                
                //        for (groupID, groupContainerURL) in application.proxy.groupContainerURLs() {
                //            try FileManager.default.copyItem(at: groupContainerURL, to: groups.appendingPathComponent(groupID))
                //        }
                print("Compressing...")
                progress("Compressing...")
                try Compression.shared.compress(paths: [stagingDirectory], outputPath: docURL.appendingPathComponent(filename), format: .zip, filenameExcludes: ["v0", ".com.apple.mobile_container_manager.metadata.plist"])
                
                print("Finishing up...")
                progress("Finishing up...")
                var registry = savedBackups()
                
                registry.append(item)
                try JSONEncoder().encode(registry).write(to: backupsRegistryURL)
                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                    try AbsoluteSolver.delete(at: stagingDirectory, progress: {message in
                        print(message)
                    })
                } else {
                    try fm.removeItem(at: stagingDirectory)
                }
            } else {
                throw "Backup is not for this app!"
            }
        } catch {
            throw error.localizedDescription
        }
    }
    
    func restoreBackup(_ backup: BackupItem, progress: ((String)) -> ()) throws {
        do {
            print("Initializing...")
            progress("Initializing...")
            let appWeAreLookingFor = try ApplicationManager.getApps().first { $0.bundleIdentifier == backup.applicationIdentifier }
        
            guard let app = appWeAreLookingFor else {
                throw "Couldn't find application on device with bundle ID \(backup.applicationIdentifier)"
            }
        
            // Make sure we have the backup contents file
            let backupZIPURL = docURL.appendingPathComponent(backup.backupFilename)
            guard FileManager.default.fileExists(atPath: backupZIPURL.path) else {
                throw "Couldn't find backup zip file at \(backupZIPURL.path)"
            }
        
            print("Surgically operating on App \(app)")
            // get unique directory to do unzip in
            print("Extracting to temporary directory...")
            progress("Extracting to temporary directory...")
            let temporaryUnzippingDir = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("BACKUP-\(app.bundleIdentifier)-\(UUID().uuidString.prefix(5))")
            try FileManager.default.createDirectory(at: temporaryUnzippingDir, withIntermediateDirectories: true)
            try Compression.shared.extract(path: backupZIPURL, to: temporaryUnzippingDir)
        
            // This is where the stuff we want is
            let enumr = FileManager.default.enumerator(at: temporaryUnzippingDir, includingPropertiesForKeys: nil)
            var parentDirWeWant: URL?
            while let obj = enumr?.nextObject() as? URL {
                if obj.lastPathComponent.contains("APPLICATION-STAGING") {
                    parentDirWeWant = obj
                    break
                }
            }
        
            guard let parentDirWeWant, FileManager.default.fileExists(atPath: parentDirWeWant.path) else {
                throw "Was unable to find parent directory containing containers & groups, sorry"
            }
            let unzippedContainerURL = parentDirWeWant
                .appendingPathComponent("Container")
        
            print("parentDirWeWant contents = \(try FileManager.default.contentsOfDirectory(at: parentDirWeWant, includingPropertiesForKeys: nil))")
        
//        let unzippedGroupsURL = parentDirWeWant
//            .appendingPathComponent("Groups")
            do {
                let applicationContainerURL = try ApplicationManager.getDataDir(bundleID: app.bundleIdentifier)
                // remove app's current container URL
                for item in try FileManager.default.contentsOfDirectory(at: applicationContainerURL,
                                                                        includingPropertiesForKeys: nil)
                {
                    print("Deleting \(item.lastPathComponent)")
                    if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                        progress("Disassembling \(item.lastPathComponent)...")
                        try AbsoluteSolver.delete(at: item, progress: {message in
                            print(message)
                        })
                    } else {
                        progress("Deleting \(item.lastPathComponent)...")
                        try fm.removeItem(at: item)
                    }
                }
                
                print("Cleared out app's containerURL, replacing with unzippedContainerURL")
                
                for item in try FileManager.default.contentsOfDirectory(at: unzippedContainerURL, includingPropertiesForKeys: nil) {
                    print("Copying \(item.lastPathComponent)...")
                    progress("Copying \(item.lastPathComponent)...")
                    if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                        try AbsoluteSolver.copy(at: item, to: applicationContainerURL.appendingPathComponent(item.lastPathComponent), progress: {message in
                            print(message)
                        })
                    } else {
                        try fm.copyItem(at: item, to: applicationContainerURL.appendingPathComponent(item.lastPathComponent))
                    }
                }
                
                //        print("PART 2: Operating on the Groups dir")
                //        if FileManager.default.fileExists(atPath: unzippedGroupsURL.path) {
                //            for appGroupID in try FileManager.default.contentsOfDirectory(at: unzippedGroupsURL, includingPropertiesForKeys: nil) {
                //                if let existingContainerURL = app.proxy.groupContainerURLs()[appGroupID.lastPathComponent] {
                //                    for item in try FileManager.default.contentsOfDirectory(at: existingContainerURL, includingPropertiesForKeys: nil) {
                //                        try FileManager.default.removeItem(at: item)
                //                    }
                //
                //                    for item in try FileManager.default.contentsOfDirectory(at: appGroupID, includingPropertiesForKeys: nil) {
                //                        try FileManager.default.moveItem(at: item,
                //                                                         to: existingContainerURL.appendingPathComponent(item.lastPathComponent))
                //                    }
                //                }
                //            }
                //        }
                
                print("WE ARE DONE. GOODNIGHT!")
                progress("Finishing up...")
                if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                    try AbsoluteSolver.delete(at: temporaryUnzippingDir, progress: {message in
                        print(message)
                    })
                } else {
                    try fm.removeItem(at: temporaryUnzippingDir)
                }
            } catch {
                throw "Could not get app data directory! \(error.localizedDescription)"
            }
        } catch {
            throw "Could not get apps! \(error.localizedDescription)"
        }
    }
}
