//
//  AppView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import SwiftUI

struct AppView: View {
    @State public var iconPath = ""
    @State public var bundleId = ""
    @State public var name = ""
    var body: some View {
        NavigationView {
            List {
                AppCell(imagePath: iconPath, bundleid: bundleId, name: name, large: true, link: false)
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(iconPath: "", bundleId: "com.example.placeholder", name: "Placeholder")
    }
}
