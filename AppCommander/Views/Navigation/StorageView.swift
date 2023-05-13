//
//  StorageView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-05-05.
//

import MarqueeText
import SwiftUI
import AbsoluteSolver

struct StorageView: View {
    @Binding public var allApps: [SBApp]
    @State var sizes: [DataDir] = []
    @State var apps: [SBApp] = [SBApp(bundleIdentifier: "ca.bomberfish.AppCommander.GuruMeditation", name: "Application Error", bundleURL: URL(string: "/")!, version: "0.6.9", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
    @State var currentappsize: UInt64 = 0
    var body: some View {
        NavigationView {
            ZStack {
                GradientView()
                /// *@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/
                ScrollView {
                    //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    VStack {
                        ForEach(apps) { app in
                            // 💀
                            // TODO: I could probably do the datadir one in a way that doesnt make jetsam slice the process in half
                            MiniAppCell(imagePath: app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao").path, bundleid: app.bundleIdentifier, name: app.name, bundleURL: app.bundleURL, sbapp: app, size: 0)
                                .contextMenu {
                                    Button(action: {
                                        if ApplicationManager.openApp(bundleID: app.bundleIdentifier) {
                                            Haptic.shared.notify(.success)
                                        } else {
                                            Haptic.shared.notify(.error)
                                        }
                                    }, label: {
                                        Label("Open App", systemImage: "arrow.up.forward.app")
                                    })
                                }
                        }
                        .padding([.top], 10)
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(22)
                    .padding([.horizontal], 18)
                    .padding([.vertical], 8)
                    .padding([.top], 10)
                }
            }
            .onAppear {
                apps = allApps
                do {
                    sizes = try getSizes(apps: allApps)
                    print(sizes)
                } catch {
                    UIApplication.shared.alert(body: "Couldn't get app sizes: \(error.localizedDescription)")
                }
            }
            .navigationTitle("Storage")
        }
    }
    func getSizes(apps: [SBApp]) throws -> [DataDir] {
        let fm = FileManager.default
        var returnedurl = URL(string: "none")
        var dirlist = [""]
        var directories: [DataDir] = []

        do {
            dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
            // print(dirlist)
        } catch {
            throw "Could not access /var/mobile/Containers/Data/Application.\n\(error.localizedDescription)"
        }

        for dir in dirlist {
            // print(dir)
            let mmpath = "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
            // print(mmpath)
            do {
                var mmDict: [String: Any]
                if fm.fileExists(atPath: mmpath) {
                    if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                        mmDict = try PropertyListSerialization.propertyList(from: try AbsoluteSolver.readFile(path: mmpath, progress: {message in
                            print(message)
                        }), options: [], format: nil) as? [String: Any] ?? [:]
                    } else {
                        mmDict = try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: mmpath)), options: [], format: nil) as? [String: Any] ?? [:]
                    }
                    
                    // print(mmDict as Any)
                    directories.append(DataDir(size: try FileManager.default.allocatedSizeOfDirectory(at: URL(fileURLWithPath: dir)), bundleID: mmDict["MCMMetadataIdentifier"] as! String))
                        //returnedurl = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application").appendingPathComponent(dir)
                    //}
                } else {
                    print("WARNING: Directory \(dir) does not have a metadata plist, skipping.")
                }
            } catch {
                throw ((error.localizedDescription))
            }
        }
        return directories
    }
    
    struct DataDir {
        let size: UInt64
        let bundleID: String
    }
    
    struct MiniAppCell: View {
        var imagePath: String
        var bundleid: String
        var name: String
        var bundleURL: URL
        var sbapp: SBApp
        var size: UInt64? = 0
        var body: some View {
            VStack {
                HStack(alignment: .center) {
                    Group {
                        // 💀
                        if imagePath.contains("this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao") {
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            let image = UIImage(contentsOfFile: imagePath)
                            Image(uiImage: image ?? UIImage(named: "Placeholder")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .cornerRadius(6)
                    .frame(width: 20, height: 20)

                    VStack {
                        HStack {
                            MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: .subheadline), leftFade: 16, rightFade: 16, startDelay: 0.5)
                                .padding(.horizontal, 6)
                        }
                    }
                    Spacer()
                    Text("\(size ?? 0)")
                }
                .padding([.vertical], 6)
                .padding([.horizontal], 10)
                
                Divider()
            }
        }
    }
}

// struct StorageView_Previews: PreviewProvider {
//    static var previews: some View {
//        StorageView()
//    }
// }