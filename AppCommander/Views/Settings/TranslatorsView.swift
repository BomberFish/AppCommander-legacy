//
//  TranslatorsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-11.
//

import SwiftUI

struct TranslatorsView: View {
    var body: some View {
        List {
            Text("🇫🇷 C22#9618")
            Text("🇩🇪 Zarapho#1453")
            Text("🇨🇳 jbjf#1431")
            Text("🇻🇳 odyssey#0666")
        }
        .navigationTitle("Translators")
    }
}

struct TranslatorsView_Previews: PreviewProvider {
    static var previews: some View {
        TranslatorsView()
    }
}
