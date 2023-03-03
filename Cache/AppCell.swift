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
    var title: String
    
    var body: some View {
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
            .frame(width: 48, height: 48)
            
            VStack {
                HStack {
                    Button(action: {
                        print("lol")
                    }) {
                        Text(title)
                            .fontWeight(.bold)
                            .font(.headline)
                    }
                    .padding(.horizontal, 6)
                    Spacer()
                }
                HStack {
                    Text(bundleid)
                        .padding(.horizontal, 6)
                        .font(.footnote)
                    Spacer()
                }
            }
        }
        .foregroundColor(.accentColor)
    }
}
