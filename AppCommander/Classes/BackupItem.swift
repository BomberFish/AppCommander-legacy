//
//  BackupItem.swift
//  AppIndex
//
//  Created by Serena on 30/03/2023.
//

import UIKit

struct BackupItem: Codable, Hashable, Identifiable {
    var id = UUID()
    
    let applicationIdentifier: String
    let name: String
    let creationDate: Date
    // let iconImageData: Data?
    let backupFilename: String
    let stagingDirectoryName: String
    var displayName: String
    
    init(application: SBApp, stagingDirectoryName: String) {
        self.applicationIdentifier = application.bundleIdentifier
        self.name = application.name
        self.creationDate = Date() // initialized now, created now.
        // self.iconImageData = UIImage(contentsOfFile: (application.pngIconPaths.first ?? Bundle.main.url(forResource: "iosplaceholder", withExtension: "png")?.path)!)!.pngData()
        self.backupFilename = "\(applicationIdentifier)-\(creationDate).zip"
        self.stagingDirectoryName = stagingDirectoryName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        displayName = dateFormatter.string(from: creationDate)
    }
}
