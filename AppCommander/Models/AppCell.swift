//
//  AppCell.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import MarqueeText
import SwiftUI

// this is actually a HEAVILY modified LinkCell from cowabunga

struct AppCell: View {
    var bundleid: String
    var name: String
    var large: Bool
    var link: Bool
    var bundleURL: URL
    var sbapp: SBApp
    @Binding var tile: Bool

    var body: some View {
        if link {
            NavigationLink(destination: AppView(bundleId: bundleid, name: name, bundleurl: bundleURL, sbapp: sbapp)) {
                if tile {
                    VStack(alignment: .center) {
                        Group {
                            if let image = UIImage(contentsOfFile: sbapp.bundleURL.appendingPathComponent(sbapp.pngIconPaths.first ?? "").path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .background(Color.black)
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image("Placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .cornerRadius(large ? 14 : 12)
                        .frame(width: large ? 58 : 48, height: large ? 58 : 48)
                        
                        VStack {
                            HStack {
                                MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                            HStack {
                                MarqueeText(text: bundleid, font: UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                        }
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .font(.system(.headline))
//                            .multilineTextAlignment(.center )
//                            .foregroundColor(Color(UIColor.secondaryLabel))
//                            .padding([.trailing], 10)
                    }
                    .foregroundColor(Color(UIColor.label))
                    .padding(10)
                    .padding([.vertical], 8)
                } else {
                    HStack(alignment: .center) {
                        Group {
                            if let image = UIImage(contentsOfFile: sbapp.bundleURL.appendingPathComponent(sbapp.pngIconPaths.first ?? "").path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .background(Color.black)
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image("Placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .cornerRadius(large ? 14 : 12)
                        .frame(width: large ? 58 : 48, height: large ? 58 : 48)
                        
                        VStack {
                            HStack {
                                MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                            HStack {
                                MarqueeText(text: bundleid, font: UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(.headline))
                            .multilineTextAlignment(.center )
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding([.trailing], 10)
                    }
                    .foregroundColor(Color(UIColor.label))
                    
                        .padding(10)
                        .padding([.vertical], 8)
                }
            }
        } else {
            VStack {
                HStack(alignment: .center) {
                    Group {
                        if let image = UIImage(contentsOfFile: sbapp.bundleURL.appendingPathComponent(sbapp.pngIconPaths.first ?? "").path) {
                            Image(uiImage: image)
                                .resizable()
                                .background(Color.black)
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .cornerRadius(large ? 14 : 12)
                    .frame(width: large ? 58 : 48, height: large ? 58 : 48)

                    VStack {
                        HStack {
                            MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                        HStack {
                            MarqueeText(text: bundleid, font: UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
