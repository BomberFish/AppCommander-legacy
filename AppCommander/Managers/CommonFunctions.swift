//
//  AppFunctions.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit
import AbsoluteSolver
import OSLog
import MacDirtyCow
import Dynamic

enum ApplicationMode {
    case MacDirtyCow
    case TrollStore
}

// MARK: - Print to localconsole. Totally not stolen from sneakyf1shy (who still needs to finish the damn frontend)

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n", loglevel: OSLogType = .default, logger: Logger = Logger(subsystem: "Default", category: "Uncategorized")) {
    let data = items.map { "\($0)" }.joined(separator: separator)
    //Swift.print(data, terminator: terminator)
    switch loglevel {
    case OSLogType.default:
        logger.log("\(data)")
    case .debug:
        logger.debug("\(data)")
    case .error:
        logger.error("\(data)")
    case .fault:
        logger.fault("\(data)")
    case .info:
        logger.info("\(data)")
    default:
        logger.log("\(data)")
    }
    consoleManager.print(data)
}

public func conditionalPrint(_ items: Any..., c: Bool, separator: String = " ", terminator: String = "\n", loglevel: OSLogType = .default) {
    if c {
        let data = items.map { "\($0)" }.joined(separator: separator)
        //Swift.print(data, terminator: terminator)
        os_log("%s", type: loglevel, data)
        consoleManager.print(data)
    }
}

// MARK: - Detect if Filza/Santander is installed

// Code is from some jailbreak detection I found online
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

func notimplementedalert() {
    UIApplication.shared.alert(title: "Not implemented", body: "")
}

// MARK: - solverless
func delDirectoryContents(path: String, progress: ((Double,String)) -> ()) throws {
    var contents = [""]
    var currentfile: Int = 0
    do {
        contents = try FileManager.default.contentsOfDirectory(atPath: path)
        for file in contents {
            print("Deleting \(file)", loglevel: .debug)
            do {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: path).appendingPathComponent(file))
                currentfile += 1
                progress((Double(currentfile / contents.count), file))
            } catch {
                throw error.localizedDescription
            }
        }
    } catch {
        throw error.localizedDescription
    }
}

// MARK: - Sexy respring

func respring() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()

    let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
        let windows: [UIWindow] = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
        
        for window in windows {
            window.alpha = 0
            window.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    animator.addCompletion { _ in
        MacDirtyCow.restartFrontboard()
        sleep(2) // give the springboard some time to restart before exiting
        exit(0)
    }
    
    animator.startAnimation()
}

func reboot() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()

    let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
        let windows: [UIWindow] = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
        
        for window in windows {
            window.alpha = 0
            window.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    animator.addCompletion { _ in
        trigger_memmove_oob_copy()
    }
    
    animator.startAnimation()
}

var connection: NSXPCConnection?

// name is 💀
func remvoeIconCache() {
    print("Removing icon cache", loglevel: .info)
    if connection == nil {
        let myCookieInterface = NSXPCInterface(with: ISIconCacheServiceProtocol.self)
        connection = Dynamic.NSXPCConnection(machServiceName: "com.apple.iconservices", options: []).asObject as? NSXPCConnection
        connection!.remoteObjectInterface = myCookieInterface
        connection!.resume()
        print("Connection: \(connection!)", loglevel: .debug)
    }
    
    (connection!.remoteObjectProxy as AnyObject).clearCachedItems(forBundeID: nil) { (a, b) in // passing nil to remove all icon cache
        print("Successfully responded (\(a), \(b ?? "(null)"))", loglevel: .info)
    }
}

func exitGracefully() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        exit(0)
    }
}
