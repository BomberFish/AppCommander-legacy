//
//  RadioButtonGroup.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-06-29.
//

import SwiftUI

/// ~~Stolen~~ Borrowed™ from https://stackoverflow.com/a/61949896

struct RadioButton: View {

    @Environment(\.colorScheme) var colorScheme

    let id: String
    let callback: (String)->()
    let selectedID : String
    let size: CGFloat
    let color: Color
    let textSize: CGFloat

    init(
        _ id: String,
        callback: @escaping (String)->(),
        selectedID: String,
        size: CGFloat = 20,
        color: Color = Color.primary,
        textSize: CGFloat = 16
        ) {
        self.id = id
        self.size = size
        self.color = color
        self.textSize = textSize
        self.selectedID = selectedID
        self.callback = callback
    }

    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.selectedID == self.id ? "checkmark.circle.fill" : "circle")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.size, height: self.size)
                    .foregroundColor(.accentColor)
                Text(id)
                    .foregroundColor(Color(uiColor: UIColor.label))
                    .font(Font.system(size: textSize))
                Spacer()
            }.foregroundColor(.accentColor)
        }
        .foregroundColor(.accentColor)
    }
}

struct RadioButtonGroup: View {

    let items : [String]

    @State var selectedId: String = ""

    let callback: (String) -> ()

    var body: some View {
        Section {
            ForEach(0..<items.count) { index in
                RadioButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId)
                    .listRowBackground(
                        Rectangle()
                            .background(Color(uiColor: UIColor.systemGray6))
                            .opacity(0.05)
                    )
            }
            .listRowBackground(
                Rectangle()
                    .background(Color(uiColor: UIColor.systemGray6))
                    .opacity(0.05)
            )
        }
    }

    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
}
