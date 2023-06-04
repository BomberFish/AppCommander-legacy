//
//  TranslatorsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-11.
//

import SwiftUI

struct TranslatorsView: View {
    struct Translator: Identifiable, Equatable {
        var id = UUID()
        let lang: String
        let translators: String
    }
    
    let translators: [Translator] = [Translator(lang: "🇫🇷", translators: "C22#9618"), Translator(lang: "🇩🇪", translators: "Zarapho#1453 & SeanMC#1024"), Translator(lang: "🇻🇳", translators: "odyssey#0666"), Translator(lang: "🇰🇷", translators: "TaekyungAncal#7857"), Translator(lang: "🇫🇮", translators: "Spongebob#9593"), Translator(lang: "🇨🇳", translators: "jbjf#1431")]
    
    var body: some View {
        List {
            ForEach(translators) {translator in
                Text("\(translator.lang) \(translator.translators)")
            }
        }
        //.listStyle(.sidebar)
        // .background(GradientView())
                .listRowBackground(Color.clear)
        .navigationTitle("Translators")
    }
}

struct TranslatorsView_Previews: PreviewProvider {
    static var previews: some View {
        TranslatorsView()
    }
}
