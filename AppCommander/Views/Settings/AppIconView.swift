//
//  AppIconView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-21.
//

import SwiftUI

struct AppIcon: Identifiable {
    var id = UUID()
    let displayName: String
    let iconName: String?
    // let isSelected: Bool
}

struct IconTile: View {
    public var icon: AppIcon
    @State public var selected: Bool = false
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    UIApplication.shared.setAlternateIconName(icon.iconName) { error in
                        if let error = error {
                            UIApplication.shared.alert(body: "Error setting app icon: \(error)")
                            Haptic.shared.notify(.error)
                        } else {
                            Haptic.shared.notify(.success)
                        }
                    }
                    selected = (UIApplication.shared.alternateIconName == icon.iconName)
                }, label: {
                    VStack {
                        ZStack {
                            Image(icon.displayName)
                                .resizable()
                                .scaledToFill() // add if you need
                                .frame(width: 64.0, height: 64.0) // as per your requirement
                                .clipped()
                                .cornerRadius(14)
                                .saturation(selected ? 0.6 : 1)
                                .brightness(selected ? -0.15 : 0)
                            
                                if selected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.white)
                                }
                        }
                        Text(icon.displayName)
                            .foregroundColor(Color(UIColor.label))
                            .font(.headline)
                    }
                })
            }
            .onAppear {
                // FIXME: this may or may not affect the trout population
                while true {
                    selected = (UIApplication.shared.alternateIconName == icon.iconName)
                }
            }
            .padding()
            .frame(width: 180, height: 150)
            .cornerRadius(16)
            .background(.ultraThinMaterial)
        }
        .cornerRadius(16)
    }
}

struct AppIconView: View {
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    
    let icons: [AppIcon] = [AppIcon(displayName: "Default", iconName: nil), AppIcon(displayName: "DarkCommander", iconName: "AppIcon2"), AppIcon(displayName: "LightCommander", iconName: "AppIcon3"), AppIcon(displayName: "“App-solute Solver”", iconName: "AppIcon4"), AppIcon(displayName: "Classic", iconName: "AppIcon5")]
    var body: some View {
        ZStack {
            GradientView()
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVGrid(columns: gridItemLayout, alignment: .center) {
                    ForEach(icons) {icon in
                        IconTile(icon: icon, selected: UIApplication.shared.alternateIconName == icon.iconName)
                    }
                }
            }
            //.background(.thinMaterial)
            .navigationTitle("Alternate Icons")
        }
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
    }
}
