//
//  ReplaceTestingView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-30.
//

import SwiftUI
import AbsoluteSolver

struct ReplaceTestingView: View {
    let testfile = FileManager.default.temporaryDirectory.appendingPathComponent("testfile")
    
    var body: some View {
        List {
            Section {
                Button(action: {
                    FileManager.default.createFile(atPath: testfile.path, contents: Data(base64Encoded: "Zg=="))
                }, label: {
                    Label("Make Test File", systemImage: "doc")
                })
            }
            Section {
                Button(action: {
                    do {
                        try AbsoluteSolver.replace(at: testfile, with: NSData(data: Data(base64Encoded: "dA==")!), progress: {message in
                            print(message, loglevel: .debug)
                        })
                        UIApplication.shared.alert(body: "Success!")
                    } catch {
                        UIApplication.shared.alert(body: "Failed!")
                    }
                }, label: {
                    Label("Replace with Absolute Solver", systemImage: "arrow.3.trianglepath")
                })
            }
            Section {
                Button(action: {
                    do {
                        let contents = try String(contentsOf: testfile)
                        print(contents, loglevel: .debug)
                        if contents == "t" {
                            UIApplication.shared.alert(body: "Success!")
                        } else {
                            UIApplication.shared.alert(body: "Failed!")
                        }

                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }, label: {
                    Label("Check Results", systemImage: "checkmark.seal")
                })
            }
            Section {
                Button(action: {
                    do {
                        try FileManager.default.removeItem(at: testfile)
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }, label: {
                    Label("Delete Test File", systemImage: "trash")
                })
            }
        }
        // .background(GradientView())
                .listRowBackground(Color.clear)
        //.listStyle(.sidebar)
        .navigationTitle("AbsoluteSolver Testing")
    }
}

struct ReplaceTestingView_Previews: PreviewProvider {
    static var previews: some View {
        ReplaceTestingView()
    }
}
