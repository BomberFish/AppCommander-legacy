//
//  AppCell.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
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
                        if imagePath != "" {
                            //Image(uiImage: UIImage(contentsOfFile: imagePath) ?? UIImage(imageLiteralResourceName: "placeholder"))
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .cornerRadius(10)
                    .frame(width: large ? 80 : 48, height: large ? 80 : 48)
                    
                    VStack {
                        HStack {
                            Text(name)
                                .fontWeight(.bold)
                                .font(large ? .title : .headline)
                            .padding(.horizontal, 6)
                            Spacer()
                        }
                        HStack {
                            Text(bundleid)
                                .padding(.horizontal, 6)
                                .font(large ? .title2 : .footnote)
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
                .cornerRadius(10)
                .frame(width: large ? 80 : 48, height: large ? 80 : 48)
                
                VStack {
                    HStack {
                        Text(name)
                            .fontWeight(.bold)
                            .font(large ? .title2 : .headline)
                        .padding(.horizontal, 6)
                        Spacer()
                    }
                    HStack {
                        Text(bundleid)
                            .padding(.horizontal, 6)
                            .font(large ? .headline : .footnote)
                        Spacer()
                    }
                }
            }
        }
    }
}
