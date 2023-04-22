//
//  AppIconView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-21.
//

import FluidGradient
import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            FluidGradient(blobs: [.accentColor, .accentColor, .accentColor, .accentColor, .accentColor],
                          highlights: [.blue, .purple, .blue, .purple],
                          speed: 0.25,
                          blur: 0)
                .background(.ultraThickMaterial)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))]) {
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
                            }, label: {
                                VStack {
                                    Image("Icon")
                                        .resizable()
                                        .scaledToFill() // add if you need
                                        .frame(width: 64.0, height: 64.0) // as per your requirement
                                        .clipped()
                                        .cornerRadius(14)
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
                            }, label: {
                                VStack {
                                    Image("DarkCommander")
                                        .resizable()
                                        .scaledToFill() // add if you need
                                        .frame(width: 64.0, height: 64.0) // as per your requirement
                                        .clipped()
                                        .cornerRadius(14)
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
                            }, label: {
                                VStack {
                                    Image("LightCommander")
                                        .resizable()
                                        .scaledToFill() // add if you need
                                        .frame(width: 64.0, height: 64.0) // as per your requirement
                                        .clipped()
                                        .cornerRadius(14)
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
                            }, label: {
                                VStack {
                                    Image("AppSolver")
                                        .resizable()
                                        .scaledToFill() // add if you need
                                        .frame(width: 64.0, height: 64.0) // as per your requirement
                                        .clipped()
                                        .cornerRadius(14)
                                    Text("“Appsolute Solver”")
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
                            }, label: {
                                VStack {
                                    Image("ClassicIcon")
                                        .resizable()
                                        .scaledToFill() // add if you need
                                        .frame(width: 64.0, height: 64.0) // as per your requirement
                                        .clipped()
                                        .cornerRadius(14)
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
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
    }
}
