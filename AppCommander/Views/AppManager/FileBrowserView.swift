//
//  ContentView.swift
//  files
//
//  Created by Mineek on 28/12/2022.
//

import AbsoluteSolver
import MacDirtyCow
import SwiftUI

// A elegant file manager for CVE-2022-446689

// Structs
struct File: Identifiable {
    var id = UUID()
    var name: String
    var type: String
    var size: String
    var date: String
}

struct Folder: Identifiable {
    var id = UUID()
    var name: String
    var size: String
    var contents: [File]
}

// the main magic: the CVE
// based on: https://github.com/zhuowei/WDBFontOverwrite/blob/main/WDBFontOverwrite/OverwriteFontImpl.swift#L34
// func overwriteFile(fileDataLocked: Data, pathtovictim: String) -> Bool {
//  var fileData = fileDataLocked
//  let fd = open(pathtovictim, O_RDONLY | O_CLOEXEC)
//  NSLog("Path to victim: \(pathtovictim)")
//  if fd == -1 {
//    print("can't open font?!")
//    return false
//  }
//  defer { close(fd) }
//  let originalFileSize = lseek(fd, 0, SEEK_END)
//  guard originalFileSize >= fileData.count else {
//    print("font too big!")
//    return false
//  }
//  lseek(fd, 0, SEEK_SET)
//
//  NSLog("data: \(fileData)")
//
//  let fileMap = mmap(nil, fileData.count, PROT_READ, MAP_SHARED, fd, 0)
//  if fileMap == MAP_FAILED {
//    print("can't mmap font?!")
//    return false
//  }
//  guard mlock(fileMap, fileData.count) == 0 else {
//    print("can't mlock")
//    return false
//  }
//
//  print(Date())
//  for chunkOff in stride(from: 0, to: fileData.count, by: 0x4000) {
//    print(String(format: "%lx", chunkOff))
//    // we only rewrite 16383 bytes out of every 16384 bytes.
//    let dataChunk = fileData[chunkOff..<min(fileData.count, chunkOff + 0x3fff)]
//    var overwroteOne = false
//    for _ in 0..<2 {
//      let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
//        return unaligned_copy_switch_race(
//          fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
//      }
//      if overwriteSucceeded {
//        overwroteOne = true
//        break
//      }
//      print("try again?!")
//    }
//    guard overwroteOne else {
//      print("can't overwrite")
//      return false
//    }
//  }
//  print(Date())
//  print("successfully overwrote everything")
//  return true
// }

func overwriteFile(fileDataLocked: Data, pathtovictim: String) -> Bool {
    if UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled") {
        do {
            try AbsoluteSolver.replace(at: URL(fileURLWithPath: pathtovictim), with: fileDataLocked as NSData, progress: { message in
                print(message)
            })
            return true
        } catch {
            print(error.localizedDescription)
            UIApplication.shared.alert(body: error.localizedDescription)
            return false
        }
    } else {
        do {
            print("Overwriting \(pathtovictim)")
            try fileDataLocked.write(to: URL(fileURLWithPath: pathtovictim), options: .atomic)
            return true
        } catch {
            print("Error: \(error.localizedDescription)")
            UIApplication.shared.alert(body: error.localizedDescription)
            return false
        }
    }
}

func deleteFile(_ path: String) throws {
    print(path)
    if UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled") {
        do {
            try AbsoluteSolver.delete(at: URL(fileURLWithPath: path), progress: { message in
                print(message)
            })
        } catch {
            print(error.localizedDescription)
            throw error.localizedDescription
        }
    } else {
        do {
            print("Deleting \(path)")
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("Error: \(error.localizedDescription)")
            UIApplication.shared.alert(body: error.localizedDescription)
            throw error.localizedDescription
        }
    }
}

// FileManager ListItem

struct ListItem: View {
    var file: File
    var body: some View {
        HStack {
            Image(systemName: "doc")
                // .resizable()
                // .frame(width: 20, height: 20)
                .font(.title3)
            VStack(alignment: .leading) {
                Text(file.name)
                    .font(.headline)
                Text(file.type)
                    .font(.subheadline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(file.size)
                    .font(.subheadline)
                Text(file.date)
                    .font(.subheadline)
            }
        }
    }
}

struct FolderItem: View {
    var folder: Folder
    var items: Int = 0
    var body: some View {
        HStack {
            Image(systemName: "folder")
                // .resizable()
                // .frame(width: 20, height: 20)
                .font(.title3)
            VStack(alignment: .leading) {
                Text(folder.name)
                    .font(.headline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                if items == 0 {
                    if folder.contents.count == 1 {
                        Text("1 file")
                            .font(.subheadline)
                    } else if folder.contents.count > 1 {
                        Text("\(folder.contents.count) files")
                            .font(.subheadline)
                    }
                } else {
                    if items == 1 {
                        Text("1 file")
                            .font(.subheadline)
                    } else if items > 1 {
                        Text("\(items) files")
                            .font(.subheadline)
                    }
                }
                Text(folder.size)
                    .font(.subheadline)
            }
        }
    }
}

// FileManager ContentView, begin in path "/"
// make sure the filemanagers don't overlap
struct FileBrowserView: View {
    @State var path: String = "/"
    @State var folders: [Folder] = []
    @State var files: [File] = []
    @State var empty: Bool = false
    @State var title: String = ""
    @State var skipped: Int = 0
    @State var count = 0

    var body: some View {
        List {
            ForEach(folders, id: \.id) { folder in
                NavigationLink(destination: FileBrowserView(path: path + folder.name + "/", title: folder.name)) {
                    FolderItem(folder: folder, items: 0)
                }
                .onAppear {
                    do {
                        count = try FileManager.default.contentsOfDirectory(atPath: path + folder.name).count
                    } catch {
                        count = 0
                    }
                }
                .contextMenu {
                    Button(role: .destructive, action: {
                        do {
                            try deleteFile(path + folder.name)
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }, label: { Label("Delete", systemImage: "trash") })
                }
            }
            ForEach(files, id: \.id) { file in
                Button(action: {
                    // if the file is a plist, open the plist editor
                    if file.type == "plist" || file.type == "strings" {
                        let fileManager = FileManager.default
                        let data = fileManager.contents(atPath: path + file.name)
                        do {
                            guard let plist = try PropertyListSerialization.propertyList(from: data!, options: [], format: nil) as? [String: Any] else { throw "Could not serialize plist" }
                            let keys = plist.keys.sorted()
                            var values: [String] = []
                            var types: [String] = []
                            for key in keys {
                                let value = plist[key]!
                                values.append("\(value)")
                                types.append("\(type(of: value))")
                            }
                            let vc = UIHostingController(rootView: PlistEditorView(path: path + file.name, plist: plist, keys: keys, values: values, types: types))
                            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
                        } catch {
                            print("WARNING: Error opening plist \(file.name): \(error.localizedDescription), Falling back to texteditor...")
                            // use TextEditor to edit the file
                            let vc = UIHostingController(rootView: TextEditorView(path: path + file.name))
                            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        // use TextEditor to edit the file
                        let vc = UIHostingController(rootView: TextEditorView(path: path + file.name))
                        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
                    }
                }) {
                    ListItem(file: file)
                }
                .contextMenu {
                    Button(role: .destructive, action: {
                        do {
                            try deleteFile(path + file.name)
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }, label: { Label("Delete", systemImage: "trash") })
                }
            }

            .navigationTitle(title)
            if empty {
                Text("Folder either is empty or does not have read access.")
                Text("If you know the direct path to the file you are trying to access, please enter it here.")
                Button(action: {
                    // ask user for direct path to FOLDER
                    let alert = UIAlertController(title: "Enter Direct Path", message: "Enter the direct path to the folder you want to access.", preferredStyle: .alert)
                    alert.addTextField { textField in
                        textField.text = path
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { _ in
                        let text = alert.textFields![0].text!
                        if text.last != "/" {
                            path = text + "/"
                        } else {
                            path = text
                        }
                        // navigate to the new path
                        folders = []
                        files = []
                        let fileManager = FileManager.default
                        let enumerator = fileManager.enumerator(atPath: path)
                        while let element = enumerator?.nextObject() as? String {
                            // only do the top level files and folders
                            if element.contains("/") {
                                continue
                            }
                            do {
                                let attrs = try fileManager.attributesOfItem(atPath: path + element)
                                let type = attrs[.type] as! FileAttributeType
                                if type == .typeDirectory {
                                    let size = try fileManager.allocatedSizeOfDirectory(at: URL(fileURLWithPath: path + element))
                                    let sizeString = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
                                    folders.append(Folder(name: element, size: sizeString, contents: []))
                                } else if type == .typeRegular {
                                    let size = attrs[.size] as! UInt64
                                    let date = attrs[.modificationDate] as! Date
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "MMM dd, yyyy"
                                    let dateString = dateFormatter.string(from: date)
                                    let sizeString = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
                                    let fileExtension = element.split(separator: ".").last!
                                    files.append(File(name: element, type: "\(fileExtension)", size: sizeString, date: dateString))
                                }
                            } catch {
                                skipped += 1
                            }
                        }
                        if folders.count == 0, files.count == 0 {
                            empty = true
                        } else {
                            empty = false
                        }
                    }))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }) {
                    Text("Enter Direct Path")
                }
            }

            if skipped > 1 {
                Section(header: Label("\(skipped) files skipped due to errors.", systemImage: "exclamationmark.triangle").textCase(.none)) {}
            } else if skipped == 1 {
                Section(header: Label("1 file skipped due to errors.", systemImage: "exclamationmark.triangle").textCase(.none)) {}
            }
        }
        .onAppear(perform: {
            // clear the arrays
            folders = []
            files = []
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: path)
            while let element = enumerator?.nextObject() as? String {
                // only do the top level files and folders
                if element.contains("/") {
                    continue
                }
                do {
                    let attrs = try fileManager.attributesOfItem(atPath: path + element)
                    let type = attrs[.type] as! FileAttributeType
                    if type == .typeDirectory {
                        let size = try fileManager.allocatedSizeOfDirectory(at: URL(fileURLWithPath: path + element))
                        let sizeString = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
                        folders.append(Folder(name: element, size: sizeString, contents: []))
                    } else if type == .typeRegular {
                        let size = attrs[.size] as! UInt64
                        let date = attrs[.modificationDate] as! Date
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        let dateString = formatter.string(from: date)
                        var sizeString = ""
                        sizeString = ByteCountFormatter().string(fromByteCount: Int64(size))
                        files.append(File(name: element, type: element.components(separatedBy: ".").last!, size: sizeString, date: dateString))
                    }
                } catch {
                    skipped += 1
                }
            }
            // if they're empty, add a "no files" message in gray
            if folders.isEmpty, files.isEmpty {
                empty = true
            }
        })
    }
}

// PlistEditorView
struct PlistEditorView: View {
    @State var path: String
    @State var plist: [String: Any] = [:]
    @State var keys: [String] = []
    @State var values: [String] = []
    @State var types: [String] = []
    @State var newKey: String = ""
    @State var newValue: String = ""
    @State var newType: String = "String"
    @State var showAdd: Bool = false
    @State var showEdit: Bool = false
    @State var editIndex: Int = 0
    @State var showDelete: Bool = false
    @State var deleteIndex: Int = 0
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showAdd = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding()
                }
                Spacer()
                Button(action: {
                    // save the plist
                    for index in keys.indices {
                        if types[index] == "String" {
                            plist[keys[index]] = values[index]
                        } else if types[index] == "Integer" {
                            plist[keys[index]] = Int(values[index])
                        } else if types[index] == "Boolean" {
                            plist[keys[index]] = Bool(values[index])
                        } else if types[index] == "Float" {
                            plist[keys[index]] = Float(values[index])
                        } else if types[index] == "Double" {
                            plist[keys[index]] = Double(values[index])
                        }
                    }
                    let data = try! PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                    // use the CVE to write the file
                    // overwriteFile(fileDataLocked: data, pathtovictim: path)
                    if overwriteFile(fileDataLocked: data, pathtovictim: path) {
                        // alert the user that the file was saved
                        let alert = UIAlertController(title: "Success", message: "The file was saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    } else {
                        // alert the user that the file was not saved
                        let alert = UIAlertController(title: "Error", message: "The file was not saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        // UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                        .padding()
                }
            }
            List {
                ForEach(keys.indices, id: \.self) { index in
                    HStack {
                        // check if they're in range
                        if index < keys.count && index < values.count && index < types.count {
                            Text(keys[index])
                                .font(.headline)
                            Spacer()
                            Text(values[index])
                                .font(.subheadline)
                            Text(types[index])
                                .font(.subheadline)
                        }
                    }
                    .onTapGesture {
                        showEdit = true
                        editIndex = index
                    }
                    .contextMenu {
                        Button(action: {
                            showEdit = true
                            editIndex = index
                        }) {
                            Text("Edit")
                        }
                        Button(action: {
                            showDelete = true
                            deleteIndex = index
                        }) {
                            Text("Delete")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                NavigationView {
                    VStack {
                        TextField("Key", text: $newKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Value", text: $newValue)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Picker("Type", selection: $newType) {
                            Text("String").tag("String")
                            Text("Integer").tag("Integer")
                            Text("Boolean").tag("Boolean")
                            Text("Float").tag("Float")
                            Text("Double").tag("Double")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Button(action: {
                            if newKey != "", newValue != "" {
                                keys.append(newKey)
                                values.append(newValue)
                                types.append(newType)
                                newKey = ""
                                newValue = ""
                                newType = "String"
                                showAdd = false
                            }
                        }) {
                            Text("Add")
                        }
                    }
                    .padding()
                    .navigationTitle("Add Key")
                }
            }
            .sheet(isPresented: $showEdit) {
                VStack {
                    Text("Edit Key")
                        .font(.title2)
                    TextField("Key", text: $keys[editIndex])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Value", text: $values[editIndex])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Picker("Type", selection: $types[editIndex]) {
                        Text("String").tag("String")
                        Text("Integer").tag("Integer")
                        Text("Boolean").tag("Boolean")
                        Text("Float").tag("Float")
                        Text("Double").tag("Double")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Button(action: {
                        showEdit = false
                    }) {
                        Text("Done")
                    }
                }
                .padding()
            }
            .alert(isPresented: $showDelete) {
                Alert(title: Text("Delete Key"), message: Text("Are you sure you want to delete the key \(keys[deleteIndex])?"), primaryButton: .destructive(Text("Delete")) {
                    keys.remove(at: deleteIndex)
                    values.remove(at: deleteIndex)
                    types.remove(at: deleteIndex)
                    showDelete = false
                }, secondaryButton: .cancel())
            }
        }
        .onAppear {
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            do {
                guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else { throw "Could not serialize plist" }
                for (key, value) in plist {
                    keys.append(key)
                    if value is String {
                        values.append(value as! String)
                        types.append("String")
                    } else if value is Int {
                        values.append(String(value as! Int))
                        types.append("Integer")
                    } else if value is Bool {
                        values.append(String(value as! Bool))
                        types.append("Boolean")
                    } else if value is Float {
                        values.append(String(value as! Float))
                        types.append("Float")
                    } else if value is Double {
                        values.append(String(value as! Double))
                        types.append("Double")
                    }
                }
            } catch {
                print(error.localizedDescription)
                UIApplication.shared.alert(body: "Error opening plist: \(error.localizedDescription)")
            }
        }
    }
}

// TextEditorView, a view that allows the user to edit a file if it isn't a plist
struct TextEditorView: View {
    @State var path: String
    @State var text: String = ""
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    // save the file
                    let data = text.data(using: .utf8)!
                    // use the CVE to write the file
                    // overwriteFile(fileDataLocked: data, pathtovictim: path)
                    if overwriteFile(fileDataLocked: data, pathtovictim: path) {
                        // alert the user that the file was saved
                        let alert = UIAlertController(title: "Success", message: "The file was saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    } else {
                        // alert the user that the file was not saved
                        let alert = UIAlertController(title: "Error", message: "The file was not saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        // UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                        .padding()
                }
            }
            TextEditor(text: $text)
                .font(.system(.subheadline, design: .monospaced))
                .padding()
        }
        .onAppear {
            do {
                text = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            } catch {
                let alert = UIAlertController(title: "Error", message: "The file could not be opened.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: {
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
}

// struct ContentView: View {
//    @State var path: String = "/"
//    var body: some View {
//        NavigationView {
//            FileManagerView(path: path)
//        }
//    }
// }

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
// }
