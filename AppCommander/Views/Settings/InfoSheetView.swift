//
//  InfoSheetView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-05-04.
//

import SwiftUI

struct SheetView: View {
    @State public var symbol: String
    @State public var title: String
    @State public var description: String
    @State public var buttons: [SheetButton]
    var body: some View {
        VStack {
            Image(systemName: symbol)
                .font(.system(size: 50, weight: .semibold))
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 15)
                .padding(.bottom, 25)
            Text(description)
                .font(.headline)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 23)
            Spacer()
            ForEach(buttons) { button in
                if button.type == ButtonType.primary {
                    Button(action: button.action, label: {
                        Text(button.title)
                            .font(.headline)
                            .fontWeight(.medium)
                            .padding([.horizontal], 130)
                            .padding([.vertical], 8)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                        .buttonStyle(.borderedProminent)
                } else {
                    Button(action: button.action, label: {
                        Text(button.title)
                            .padding([.horizontal], 110)
                            .padding([.vertical], 6)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                        .buttonStyle(.borderless)
                }
            }
        }
        .padding(.top, 50)
    }
}

enum ButtonType {
    case primary,secondary
}

struct SheetButton: Identifiable {
    var id = UUID()
    let title: String
    let action: () -> Void
    let type: ButtonType
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(symbol: "info.circle", title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur pretium, enim a tempus sollicitudin, diam nulla vestibulum velit, eget placerat massa orci sit amet nisl. Aenean sollicitudin rutrum lobortis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ac velit quis justo viverra gravida eu nec nibh. Vestibulum rhoncus, magna et finibus ultrices, mi enim condimentum odio, eget pellentesque magna tellus vitae nisi. Phasellus interdum condimentum ante, rutrum lacinia massa tristique vel. Curabitur euismod tristique elit, vitae lobortis arcu condimentum et. Vivamus pellentesque leo quis mi laoreet pulvinar.", buttons: [SheetButton(title: "Confirm", action: {print("confirm pressed")}, type: .primary), SheetButton(title: "Cancel", action: {print("cancel pressed")}, type: .secondary)])
    }
}
