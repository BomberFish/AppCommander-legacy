//
//  AppFunctions.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit
import ZIPFoundation

// MARK: - Print to localconsole. Totally not stolen from sneakyf1shy (who still needs to finish the damn frontend)
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let data = items.map { "\($0)" }.joined(separator: separator)
    consoleManager.print(data)
    Swift.print(data, terminator: terminator)
}

public func conditionalPrint(_ items: Any..., c: Bool, separator: String = " ", terminator: String = "\n") {
    if c {
        let data = items.map { "\($0)" }.joined(separator: separator)
        consoleManager.print(data)
        Swift.print(data, terminator: terminator)
    }
}

// MARK: - Goofy ahh function
func getDataDir(bundleID: String) -> URL {
    let fm = FileManager.default
    var returnedurl = URL(string: "none")
    var dirlist = [""]

    do {
        dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
        print(dirlist)
    } catch {
        UIApplication.shared.alert(body: "Could not access /var/mobile/Containers/Data/Application")
    }

    for dir in dirlist {
        print(dir)
        let mmpath = "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
        print(mmpath)
        let mmDict = NSDictionary(contentsOfFile: mmpath)
        print(mmDict as Any)
        if mmDict!["MCMMetadataIdentifier"] as! String == bundleID {
            returnedurl = URL(string: "/var/mobile/Containers/Data/Application")!.appendingPathComponent(dir)
        }
    }
    return returnedurl!
}

// MARK: - This should convert an app to an encrypted ipa, but it doesn't work. See the FIXME.
func appToIpa(bundleurl: URL) {
    do {
        let uuid = UUID().uuidString
        try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid))
        print("rmed file")
        try FileManager.default.createDirectory(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload"), withIntermediateDirectories: true)
        print("made payload dir \(FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload"))")
        try FileManager.default.copyItem(at: bundleurl, to: FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload").appendingPathComponent(bundleurl.lastPathComponent))
        print("copied \(bundleurl) to \(FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload").appendingPathComponent(bundleurl.lastPathComponent))")
        // FIXME: This always fails. I don't know why, and I am losing my sanity over it.
        try FileManager().zipItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload"), to: FileManager.default.temporaryDirectory.appendingPathComponent("App_Encrypted").appendingPathExtension("ipa"))
        print("zipped \(FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload")) to \(FileManager.default.temporaryDirectory.appendingPathComponent("App_Encrypted").appendingPathExtension("ipa"))")
        let vc = UIActivityViewController(activityItems: [FileManager.default.temporaryDirectory.appendingPathComponent("App_Encrypted").appendingPathExtension("ipa") as Any], applicationActivities: nil)
        Haptic.shared.notify(.success)
        UIApplication.shared.windows[0].rootViewController?.present(vc, animated: true)
    } catch {
        print("error at the next step")
        Haptic.shared.notify(.error)
        UIApplication.shared.alert(body: "There was an error exporting the ipa.")
    }
}

// MARK: - Detect if Filza/Santander is installed
// Code is from some jailbreak detection I found
// fucking retards think filza=jelbrek
func isFilzaInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "filza://")!)
}

func isSantanderInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "santander://")!)
}

// MARK: - Open path in file manager
// thanks serena uwu
func openInSantander(path: String) {
    UIApplication.shared.open(URL(string: "santander://\(path)")!, options: [:], completionHandler: nil)
}

// thanks bing ai
func openInFilza(path: String) {
    UIApplication.shared.open(URL(string: "filza://\(path)")!, options: [:], completionHandler: nil)
}


// MARK: - deletes all the contents of directories. usually.
func delDirectoryContents(path: String) -> Bool {
    var contents = [""]
    do {
        contents = try FileManager.default.contentsOfDirectory(atPath: path)
    } catch {
        UIApplication.shared.alert(body: "Could not get contents of directory?!")
        return false
    }
    if contents != [""] {
        for file in contents {
            print("Deleting \(file)")
            do {
                try FileManager.default.removeItem(atPath: file)
                print("Probably deleted \(file)")
                UIApplication.shared.alert(title: "Success", body: "Successfully deleted!")
                Haptic.shared.notify(.success)
                return true
            } catch {
                print("Failed to delete \(file)")
                UIApplication.shared.alert(body: "Could not remove file \(file)")
                Haptic.shared.notify(.error)
                return false
            }
        }
    }
    return false
}

// MARK: - opens apps
// from stackoverflow
func openApp(bundleID: String) -> Bool {
    guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return false }
    let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
    let open = workspace?.perform(Selector(("openApplicationWithBundleID:")), with: bundleID) != nil
    return open
}

// MARK: - Literally black magic.
func overwriteFileWithDataImpl(originPath: String, replacementData: Data) -> Bool {
    #if false
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].path

        let pathToRealTarget = originPath
        let originPath = documentDirectory + originPath
        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
        try! origData.write(to: URL(fileURLWithPath: originPath))
    #endif

    // open and map original font
    let fd = open(originPath, O_RDONLY | O_CLOEXEC)
    if fd == -1 {
        print("Could not open target file")
        return false
    }
    defer { close(fd) }
    // check size of font
    let originalFileSize = lseek(fd, 0, SEEK_END)
    guard originalFileSize >= replacementData.count else {
        print("Original file: \(originalFileSize)")
        print("Replacement file: \(replacementData.count)")
        print("File too big!")
        return false
    }
    lseek(fd, 0, SEEK_SET)

    // Map the font we want to overwrite so we can mlock it
    let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
    if fileMap == MAP_FAILED {
        print("Failed to map")
        return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, replacementData.count) == 0 else {
        print("Failed to mlock")
        return true
    }

    // for every 16k chunk, rewrite
    print(Date())
    for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
        print(String(format: "%lx", chunkOff))
        let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
        var overwroteOne = false
        for _ in 0..<2 {
            let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                unaligned_copy_switch_race(
                    fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count
                )
            }
            if overwriteSucceeded {
                overwroteOne = true
                print("Successfully overwrote!")
                break
            }
            print("try again?!")
        }
        guard overwroteOne else {
            print("Failed to overwrite")
            return false
        }
    }
    print(Date())
    print("Successfully overwrote!")
    return true
}

// MARK: - i aint smart enough to know what any of this does
func xpc_crash(_ serviceName: String) {
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: serviceName.utf8.count)
    defer { buffer.deallocate() }
    strcpy(buffer, serviceName)
    xpc_crasher(buffer)
}

//MARK: -  Respring
func respring() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    
    let view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = .black
    view.alpha = 0

    for window in UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).flatMap({ $0.windows.map { $0 } }) {
        window.addSubview(view)
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            view.alpha = 1
        })
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
        respringFrontboard()
        sleep(2) // give the springboard some time to restart before exiting
        exit(0)
    })
}
