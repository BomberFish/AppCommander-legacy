//
//  GradientView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-29.
//

import SwiftUI
import FluidGradient

struct GradientView: View {
    var body: some View {
        ZStack {
            FluidGradient(blobs: [.accentColor, .accentColor, .accentColor, .accentColor, .accentColor, .accentColor, .accentColor, .accentColor, .accentColor, .accentColor],
                          highlights: [.blue, .purple, .blue, .purple],
                          speed: 0.25,
                          blur: 0)
                .background(.quaternary)
                .edgesIgnoringSafeArea(.all)
            
        }
        .background(.thinMaterial)
        .edgesIgnoringSafeArea(.all)
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView()
    }
}
