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
    
    let translators: [Translator] = [
        Translator(lang: "🇫🇷", translators: "c22dev"),
        Translator(lang: "🇩🇪", translators: "zarapho & overwritemeoooow"),
        Translator(lang: "🇻🇳", translators: "odyssey#0666"), // havent been able to track this guy down
        Translator(lang: "🇰🇷", translators: "ancal_taekyung"),
        Translator(lang: "🇫🇮", translators: "korpiw"),
        Translator(lang: "🇨🇳", translators: "jbjf#1431") // hasnt gotten pomelo yet (???)
    ]
    
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
