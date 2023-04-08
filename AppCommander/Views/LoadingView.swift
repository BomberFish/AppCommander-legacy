//
//  LoadingView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-06.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Text("Checking validity...")
            .font(.title2)
        ProgressView()
            .padding()
            .scaleEffect(CGSize(width: 1.5, height: 1.5))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
