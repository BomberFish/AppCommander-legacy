//
//  ViewSettings.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-06-29.
//

import SwiftUI

struct ViewSettings: View {
    let options: [String] = ["Cozy", "Compact"]
    @State var selected: Int = UserDefaults.standard.bool(forKey: "compactEnabled") ? 1 : 0
    @State var compactEnabled: Bool = UserDefaults.standard.bool(forKey: "compactEnabled")
    @AppStorage("vibrantTheming") var vibrantTheming: Bool = true // finally using this api lmao

//    init() { // finally learned what this does
//        options = ["Cozy", "Compact"]
//        compactEnabled = UserDefaults.standard.bool(forKey: "compactEnabled")
//        selected = compactEnabled ? 1 : 0
//        selectedName = options[selected]
//    }
    
    var body: some View {
        List {
            Section {
                ZStack {
                    if selected == 0 {
                        ZStack {
                            
                            HStack(alignment: .center) {
                                RoundedRectangle(cornerSize: CGSize(width: 12, height: 12))
                                    .background(.ultraThinMaterial)
                                    .frame(width: 48, height: 48)
                                VStack {
                                    RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                        .background(.ultraThinMaterial)
                                        .frame(width: 80, height: 20)
                                    RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                        .background(.ultraThinMaterial)
                                        .frame(width: 80, height: 20)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(.headline))
                                    .multilineTextAlignment(.center )
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .padding([.trailing], 10)
                            }
                            .foregroundColor(Color(UIColor.label))
                            
                            .padding(10)
                            .padding([.vertical], 8)
                        }
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
                    } else {
                        ZStack {
                            HStack(alignment: .center) {
                                
                                RoundedRectangle(cornerSize: CGSize(width: 12, height: 12))
                                    .background(.ultraThinMaterial)
                                    .frame(width: 48, height: 48)
                                VStack {
                                    RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                        .background(.ultraThinMaterial)
                                        .frame(width: 80, height: 20)
                                    RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                        .background(.ultraThinMaterial)
                                        .frame(width: 80, height: 20)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(.headline))
                                    .multilineTextAlignment(.center )
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .padding([.trailing], 10)
                            }
                            .foregroundColor(Color(UIColor.label))
                            
                            .padding(8)
                            .padding([.vertical], 6)
                        }
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
                    }
                }
                .frame(width: .infinity, height: 64)
                //.padding([.horizontal], 20)
                //.background(GradientView())
                .padding()
                .cornerRadius(16)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
            }
            .listRowBackground(GradientView())
                
            Section {
                RadioButtonGroup(items: options, selectedId: String(options[selected])) { tempselected in
                    selected = options.firstIndex(of: tempselected) ?? 0
                    print("selected \(options.firstIndex(of: tempselected) ?? 0)")
                    print("setting \(selected == 1)")
                    UserDefaults.standard.set(selected == 1, forKey: "compactEnabled")
                    print("querying returns \(UserDefaults.standard.bool(forKey: "compactEnabled"))")
                    UIApplication.shared.confirmAlert(title: "View Mode Changed", body: "The app needs to restart to apply the change.", onOK: {
                        exitGracefully()
                    }, noCancel: true)
                }
            }
            
            Section {
                Toggle(isOn: $vibrantTheming, label: {
                    HStack {
                        Text("Vibrant App View Theming")
                        Button(action: {UIApplication.shared.alert(title: "Info", body: "This makes the app view's accent color match that of the app's icon.")}, label: {Image(systemName: "questionmark.circle")})
                            .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                    }
                })
                .tint(.accentColor)
                .toggleStyle(.switch)
            }
            .listRowBackground(
                Rectangle()
                    .background(Color(uiColor: UIColor.systemGray6))
                    .opacity(0.05)
            )
            
        }
        .onAppear {
            print("userdefaults query returns \(compactEnabled)")
        }
        .navigationTitle("View Options")
    }
}
