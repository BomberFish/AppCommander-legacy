//
//  ContentView.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                AppCell(imageName: "Placeholder", bundleid: "com.example.placeholder", title: "Placeholder")
                Section(footer: Label("Caché \(appVersion)", systemImage: "info.circle")){}
            }
            .navigationTitle("Caché")
        }
    }
    struct AppCell: View {
        var imageName: String
        var bundleid: String
        var title: String
        
        var body: some View {
            HStack(alignment: .center) {
                Group {
                        if imageName != "" {
                            Image(imageName)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
