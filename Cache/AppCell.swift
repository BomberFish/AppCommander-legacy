//
//  AppCell.swift
//  Cache
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
    
    var body: some View {
        if link {
            NavigationLink(destination: AppView(iconPath: imagePath, bundleId: bundleid, name: name)) {
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
                    .cornerRadius(large ? 16 : 14)
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
            HStack(alignment: .center) {
                Group {
                    if imagePath != "" {
                        //Image(uiImage: UIImage(contentsOfFile: imagePath) ?? UIImage(imageLiteralResourceName: "placeholder"))
                        Image("Placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .cornerRadius(large ? 16 : 14)
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
        }
    }
}
