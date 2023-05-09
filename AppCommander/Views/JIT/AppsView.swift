//
//  AppsView.swift
//  DirtyJIT
//
//  Created by Анохин Юрий on 05.03.2023.
//

import SwiftUI

struct AppsView: View {
    @Binding var searchText: String
    let apps: [SBApp]
    let jit = JITManager.shared
    
    var body: some View {
        List(apps.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }) { app in
            HStack {
                if let image = UIImage(contentsOfFile: app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "").path) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .cornerRadius(10)
                } else {
                    Image("DefaultIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading) {
                    Text(app.name)
                        .font(.headline)
                    
                    Text(app.bundleIdentifier)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                let title = "Warning"
                let message = "We will now try to enable JIT on \(app.name). Make sure the app is opened in the background so we can find its PID and is signed with a free developer certificate!"
                let onOK: () -> Void = {
                    UIApplication.shared.alert(title: "Please wait", body: "Enabling JIT...", withButton: false)
                    
                    callps()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        UIApplication.shared.dismissAlert(animated: true)
                        jit.enableJIT(pidApp: jit.returnPID(exec: app.name))
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            ApplicationManager.openApp(bundleID: app.bundleIdentifier)
                        }
                    }
                }
                UIApplication.shared.confirmAlert(title: title, body: message, onOK: onOK, noCancel: false)
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
    }
}
