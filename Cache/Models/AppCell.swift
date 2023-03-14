//
//  AppCell.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import MarqueeText
import SwiftUI

struct AppCell: View {
    var imagePath: String
    var bundleid: String
    var name: String
    var large: Bool
    var link: Bool
    var bundleURL: URL
    var sbapp: SBApp
    
    var body: some View {
        if link {
            NavigationLink(destination: AppView(iconPath: imagePath, bundleId: bundleid, name: name, bundleurl: bundleURL, sbapp: sbapp)) {
                HStack(alignment: .center) {
                    Group {
                        if imagePath.contains("this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao") {
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }  else {
                            let image = UIImage(contentsOfFile: imagePath)
                            Image(uiImage: image ?? UIImage.init(named: "Placeholder")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .cornerRadius(large ? 14 : 12)
                    .frame(width: large ? 58 : 48, height: large ? 58 : 48)
                    
                    VStack {
                        HStack {
                            MarqueeText(text: name, font:  UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 0.5)
                            .padding(.horizontal, 6)
                            Spacer()
                        }
                        HStack {
                            MarqueeText(text: bundleid, font:  UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 0.5)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                    }
                }
                .foregroundColor(.accentColor)
            }
        } else {
            VStack {
                HStack(alignment: .center) {
                    Group {
                        if imagePath.contains("this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao") {
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }  else {
                            let image = UIImage(contentsOfFile: imagePath)
                            Image(uiImage: image ?? UIImage.init(named: "Placeholder")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .cornerRadius(large ? 14 : 12)
                    .frame(width: large ? 58 : 48, height: large ? 58 : 48)
                    
                    VStack {
                        HStack {
                            MarqueeText(text: name, font:  UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 0.5)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                        HStack {
                            MarqueeText(text: bundleid, font:  UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 0.5)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                    }
                }
                MarqueeText(text: bundleURL.relativePath, font:  UIFont.preferredFont(forTextStyle: large ? .subheadline : .footnote), leftFade: 16, rightFade: 16, startDelay: 0.5)
                    .contextMenu {
                        if isFilzaInstalled() {
                            Button(action: {openInFilza(path: bundleURL.path)}, label: {Label("Open in Filza", systemImage: "arrow.up.forward.app")})
                        }
                        if isSantanderInstalled() {
                            Button(action: {openInFilza(path: bundleURL.path)}, label: {Label("Open in Santander", systemImage: "arrow.up.forward.app")})
                        }
                    }
            }
        }
    }
}
