//
//  LoadingView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-06.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
//        Text("Checking validity...")
//            .font(.title2)
        VStack {
            HStack {
                ProgressView()
                //.padding()
                Text("  Loading...")
                    .fontWeight(.semibold)
            }
            .padding()
        }
        .background(.regularMaterial)
        .cornerRadius(14)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
