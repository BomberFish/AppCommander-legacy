//
//  AppleLoopsMixView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-02.
//

import SwiftUI

struct AppleLoopsMixView: View {
    @ObservedObject var player = Player.shared
    let mediaURL: URL = Bundle.main.url(forResource: "Apple Loops Mix", withExtension: "m4a")!
    var body: some View {
        Text("")
        Button(action: {
            Task {
                try await player.playSongItem(fileURL: mediaURL)
            }
            player.reloadNowPlayingInfo()
        }, label:  {
            Label("Play", systemImage: "play")
        })
        .tint(.accentColor)
        .buttonStyle(.bordered)
        
        Button(action: {
               player.togglePlayback()
            player.reloadNowPlayingInfo()
        }, label:  {
            if player.isPaused {
                Label("Resume", systemImage: "play")
            } else {
                Label("Pause", systemImage: "pause")
            }
        })
        .tint(.accentColor)
        .buttonStyle(.bordered)
        
        .navigationTitle("Apple Loops Mix")
            
    }
}

struct AppleLoopsMixView_Previews: PreviewProvider {
    static var previews: some View {
        AppleLoopsMixView()
    }
}
