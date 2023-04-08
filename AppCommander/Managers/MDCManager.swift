//
//  MDCManager.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import Foundation
import SwiftUI

public enum MDC {
    public static var isMDCSafe: Bool = true

    public static func top_secret_sauce(completion: @escaping (Bool) -> Void) {
        // shittily obfuscated by my good friend chatgpt
        let 𝔲 = URL(string: String(data: Data(base64Encoded: "aHR0cDovL2hvbWUuYm9tYmVyZmlzaC5jYTo5ODc2Lw==")!, encoding: .utf8)!)!
        URLSession.shared.dataTask(with: 𝔲) { 𝔡, 𝔯, 𝔢 in
            if 𝔢 != nil {
                completion(false)
            }
            if let 𝔯 = 𝔯 as? HTTPURLResponse, (200 ... 299).contains(𝔯.statusCode), let 𝔡 = 𝔡, let 𝔠 = String(data: 𝔡, encoding: .utf8) {
                completion(𝔠 == "true\n")
            } else {
                completion(false)
            }
        }.resume()
    }

    // MARK: - Literally black magic.

    public static func overwriteFileWithDataImpl(originPath: String, replacementData: Data) -> Bool {
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

    public static func xpc_crash(_ serviceName: String) {
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: serviceName.utf8.count)
        defer { buffer.deallocate() }
        strcpy(buffer, serviceName)
        xpc_crasher(buffer)
    }

    // MARK: -  Respring

    public static func respring() {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            respringFrontboard()
            sleep(2) // give the springboard some time to restart before exiting
            exit(0)
        }
    }
}
