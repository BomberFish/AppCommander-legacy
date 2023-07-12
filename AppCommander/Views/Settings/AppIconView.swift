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
    let isSelected: Bool = false
    let author: String
    let lore: String
}

struct IconTile: View {
    public var icon: AppIcon
    @State public var selected: Bool = false
    @State public var selectedicon: String
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {UIApplication.shared.alert(title: icon.displayName, body: "Author: \(icon.author)\n\n\(icon.lore)")}, label: {
                        Image(systemName: "info.circle")
                            .font(.system(.title3))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    })
                }
                .padding(-1)
                Button(action: {
                    UIApplication.shared.setAlternateIconName(icon.iconName) { error in
                        
                        selected = (UIApplication.shared.alternateIconName == icon.iconName)
                        if let error = error {
                            UIApplication.shared.alert(body: "Error setting app icon: \(error)")
                            Haptic.shared.notify(.error)
                        } else {
                            Haptic.shared.notify(.success)
                        }
                        selectedicon = UIApplication.shared.alternateIconName ?? "AppIcon"
                        selected = (UIApplication.shared.alternateIconName == icon.iconName)
                        //print(UIApplication.shared.alternateIconName)
                        //print(selected)
                        //print((UIApplication.shared.alternateIconName == icon.iconName))
                    }
                    selected = (UIApplication.shared.alternateIconName == icon.iconName)
                    if selectedicon == icon.iconName {
                        selected = true
                    } else {
                        selected = false
                    }
                }, label: {
                    VStack {
                        ZStack {
                            Image(icon.displayName)
                                .resizable()
                                .scaledToFill() // add if you need
                                .frame(width: 64.0, height: 64.0) // as per your requirement
                                .clipped()
                                .cornerRadius(14)
                                //.saturation(selected ? 0.6 : 1)
                                //.brightness(selected ? -0.15 : 0)
                            
                                if selected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.white)
                                        .hidden()
                                }
                        }
                        Text(icon.displayName)
                            .foregroundColor(Color(UIColor.label))
                            .font(.headline)
                    }
                })
            }
            .onAppear {
                selected = (UIApplication.shared.alternateIconName == icon.iconName)
            }
            .padding()
            .padding([.top], -10)
            .frame(width: 200, height: 200)
            .cornerRadius(16)
            .background(.ultraThinMaterial)
        }
        .cornerRadius(16)
    }
}

struct AppIconView: View {
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    @State var currentIcon: String? = nil
    
    let icons: [AppIcon] = [AppIcon(displayName: "Default", iconName: nil, author: "BomberFish", lore: "Tried and true."), AppIcon(displayName: "DarkCommander", iconName: "AppIcon2", author: "BomberFish", lore: "Come to the dark side, we have cookies."), AppIcon(displayName: "LightCommander", iconName: "AppIcon3", author: "BomberFish", lore: "My eyes!!!"), AppIcon(displayName: "“App-solute Solver”", iconName: "AppIcon4", author: "BomberFish", lore: "Hmmm yes totally not a massive reference to a specific sci-fi dystopian webseries..."), AppIcon(displayName: "Classic", iconName: "AppIcon5", author: "BomberFish", lore: "This one was never actually the default in any build of AppCommander. Not any *public* build, anyways...")]
    var body: some View {
        ZStack {
            GradientView()
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVGrid(columns: gridItemLayout, alignment: .center) {
                    ForEach(icons) {icon in
                        IconTile(icon: icon, selectedicon: currentIcon ?? "AppIcon")
                    }
                }
                .padding([.horizontal], 5)
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

fileprivate func getIcon() -> String? {
    return UIApplication.shared.alternateIconName
}
