//
//  AppIconView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-21.
//

import FluidGradient
import SwiftUI

struct AppIconView: View {
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    @State var isDefaultIcon = false
    @State var isIcon2 = false
    @State var isIcon3 = false
    @State var isIcon4 = false
    @State var isIcon5 = false
    var body: some View {
        ZStack {
            FluidGradient(blobs: [.accentColor, .accentColor, .accentColor, .accentColor, .accentColor],
                          highlights: [.blue, .purple, .blue, .purple],
                          speed: 0.25,
                          blur: 0)
                .background(.ultraThickMaterial)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVGrid(columns: gridItemLayout, alignment: .center) {
                    ZStack {
                        HStack {
                            Button(action: {
                                UIApplication.shared.setAlternateIconName(nil) { error in
                                    if let error = error {
                                        UIApplication.shared.alert(body: "Error setting app icon: \(error)")
                                        Haptic.shared.notify(.error)
                                    } else {
                                        Haptic.shared.notify(.success)
                                    }
                                }
                                updateCurrentIcon()
                            }, label: {
                                VStack {
                                    if isDefaultIcon {
                                        ZStack {
                                            Image(systemName: "checkmark")
                                            Image("Icon")
                                                .resizable()
                                                .scaledToFill() // add if you need
                                                .frame(width: 64.0, height: 64.0) // as per your requirement
                                                .clipped()
                                                .cornerRadius(14)
                                                .saturation(0.6)
                                            Image(systemName: "checkmark")
                                        }
                                    } else {
                                        Image("Icon")
                                            .resizable()
                                            .scaledToFill() // add if you need
                                            .frame(width: 64.0, height: 64.0) // as per your requirement
                                            .clipped()
                                            .cornerRadius(14)
                                    }
                                    Text("Default")
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.headline)
                                }
                            })
                        }
                        .padding()
                        .frame(width: 180, height: 150)
                        .cornerRadius(16)
                        .background(.ultraThinMaterial)
                    }
                    .cornerRadius(16)

                    ZStack {
                        HStack {
                            Button(action: {
                                UIApplication.shared.setAlternateIconName("AppIcon2") { error in
                                    if let error = error {
                                        UIApplication.shared.alert(body: "Error setting app icon: \(error)")
                                        Haptic.shared.notify(.error)
                                    } else {
                                        Haptic.shared.notify(.success)
                                    }
                                }
                                updateCurrentIcon()
                            }, label: {
                                VStack {
                                    if isIcon2 {
                                        ZStack {
                                            Image(systemName: "checkmark")
                                            Image("DarkCommander")
                                                .resizable()
                                                .scaledToFill() // add if you need
                                                .frame(width: 64.0, height: 64.0) // as per your requirement
                                                .clipped()
                                                .cornerRadius(14)
                                                .saturation(0.6)
                                            Image(systemName: "checkmark")
                                        }
                                    } else {
                                        Image("DarkCommander")
                                            .resizable()
                                            .scaledToFill() // add if you need
                                            .frame(width: 64.0, height: 64.0) // as per your requirement
                                            .clipped()
                                            .cornerRadius(14)
                                    }
                                    Text("DarkCommander")
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.headline)
                                }
                            })
                        }
                        .padding()
                        .frame(width: 180, height: 150)
                        .cornerRadius(16)
                        .background(.ultraThinMaterial)
                    }
                    .cornerRadius(16)

                    ZStack {
                        HStack {
                            Button(action: {
                                UIApplication.shared.setAlternateIconName("AppIcon3") { error in
                                    if let error = error {
                                        UIApplication.shared.alert(body: "Error setting app icon: \(error)")
                                        Haptic.shared.notify(.error)
                                    } else {
                                        Haptic.shared.notify(.success)
                                    }
                                }
                                updateCurrentIcon()
                            }, label: {
                                VStack {
                                    if isIcon3 {
                                        ZStack {
                                            Image(systemName: "checkmark")
                                            Image("LightCommander")
                                                .resizable()
                                                .scaledToFill() // add if you need
                                                .frame(width: 64.0, height: 64.0) // as per your requirement
                                                .clipped()
                                                .cornerRadius(14)
                                                .saturation(0.6)
                                            Image(systemName: "checkmark")
                                        }
                                    } else {
                                        Image("LightCommander")
                                            .resizable()
                                            .scaledToFill() // add if you need
                                            .frame(width: 64.0, height: 64.0) // as per your requirement
                                            .clipped()
                                            .cornerRadius(14)
                                    }
                                    Text("LightCommander")
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.headline)
                                }
                            })
                        }
                        .padding()
                        .frame(width: 180, height: 150)
                        .cornerRadius(16)
                        .background(.ultraThinMaterial)
                    }
                    .cornerRadius(16)

                    ZStack {
                        HStack {
                            Button(action: {
                                UIApplication.shared.setAlternateIconName("AppIcon4") { error in
                                    if let error = error {
                                        UIApplication.shared.alert(body: "Error setting app icon: \(error)")
                                        Haptic.shared.notify(.error)
                                    } else {
                                        Haptic.shared.notify(.success)
                                    }
                                }
                                updateCurrentIcon()
                            }, label: {
                                VStack {
                                    if isIcon4 {
                                        ZStack {
                                            Image(systemName: "checkmark")
                                            Image("AppSolver")
                                                .resizable()
                                                .scaledToFill() // add if you need
                                                .frame(width: 64.0, height: 64.0) // as per your requirement
                                                .clipped()
                                                .cornerRadius(14)
                                                .saturation(0.6)
                                            Image(systemName: "checkmark")
                                        }
                                    } else {
                                        Image("AppSolver")
                                            .resizable()
                                            .scaledToFill() // add if you need
                                            .frame(width: 64.0, height: 64.0) // as per your requirement
                                            .clipped()
                                            .cornerRadius(14)
                                    }
                                    Text("“App-solute Solver”")
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.headline)
                                }
                            })
                        }
                        .padding()
                        .frame(width: 180, height: 150)
                        .cornerRadius(16)
                        .background(.ultraThinMaterial)
                    }
                    .cornerRadius(16)
                    
                    ZStack {
                        HStack {
                            Button(action: {
                                UIApplication.shared.setAlternateIconName("AppIcon5") { error in
                                    if let error = error {
                                        UIApplication.shared.alert(body: "Error setting app icon: \(error)")
                                        Haptic.shared.notify(.error)
                                    } else {
                                        Haptic.shared.notify(.success)
                                    }
                                }
                                updateCurrentIcon()
                            }, label: {
                                VStack {
                                    if isIcon5 {
                                        ZStack {
                                            Image(systemName: "checkmark")
                                            Image("ClassicIcon")
                                                .resizable()
                                                .scaledToFill() // add if you need
                                                .frame(width: 64.0, height: 64.0) // as per your requirement
                                                .clipped()
                                                .cornerRadius(14)
                                                .saturation(0.6)
                                            Image(systemName: "checkmark")
                                        }
                                    } else {
                                        Image("ClassicIcon")
                                            .resizable()
                                            .scaledToFill() // add if you need
                                            .frame(width: 64.0, height: 64.0) // as per your requirement
                                            .clipped()
                                            .cornerRadius(14)
                                    }
                                    Text("Old icon")
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.headline)
                                }
                            })
                        }
                        .padding()
                        .frame(width: 180, height: 150)
                        .cornerRadius(16)
                        .background(.ultraThinMaterial)
                    }
                    .cornerRadius(16)
                }
            }
            .background(.thinMaterial)
            .navigationTitle("Alternate Icons")
        }
        .onAppear {
            updateCurrentIcon()
        }
    }
    
    func updateCurrentIcon() {
        if UIApplication.shared.alternateIconName == nil {
            isDefaultIcon = true
        } else {
            isDefaultIcon = false
        }
        
        if UIApplication.shared.alternateIconName == "AppIcon2" {
            isIcon2 = true
        } else {
            isIcon2 = false
        }
        
        if UIApplication.shared.alternateIconName == "AppIcon3" {
            isIcon3 = true
        } else {
            isIcon3 = false
        }
        
        if UIApplication.shared.alternateIconName == "AppIcon4" {
            isIcon4 = true
        } else {
            isIcon4 = false
        }
        
        if UIApplication.shared.alternateIconName == "AppIcon5" {
            isIcon5 = true
        } else {
            isIcon5 = false
        }
        
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
    }
}
