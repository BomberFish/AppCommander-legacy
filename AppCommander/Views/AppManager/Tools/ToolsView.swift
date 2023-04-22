//
//  ToolsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-01.
//

import SwiftUI
import FluidGradient

struct ToolsView: View {
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    var body: some View {
        NavigationView {
            ZStack {
                FluidGradient(blobs: [.accentColor, .accentColor, .accentColor, .accentColor, .accentColor],
                              highlights: [.blue, .purple, .blue, .purple],
                              speed: 0.25,
                              blur: 0)
                    .background(.ultraThickMaterial)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 16) {
                        ZStack {
                            Card(tool: "Whitelist", image: "app.badge.checkmark")
                                .frame(width: 180, height: 150)
                                .cornerRadius(16)
                                .background(.ultraThinMaterial)
                        }
                        .cornerRadius(16)
                        NavigationLink(destination: { WhitelistView() }, label: {
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "app.badge.checkmark")
                                        .imageScale(.large)
                                        .font(.title2)
                                    Text("Whitelist")
                                        .multilineTextAlignment(.leading)
                                }
                                
                                .font(.title3)
                                .foregroundColor(Color(UIColor.label))
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .padding()
                            .frame(width: 180, height: 150)
                            .cornerRadius(16)
                            .background(.ultraThinMaterial)
                        })
                        .cornerRadius(16)
                        NavigationLink(destination: { FreeloadView() }, label: {
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "apps.iphone.badge.plus")
                                        .imageScale(.large)
                                        .font(.title2)
                                    Text("Remove three-app limit")
                                        .multilineTextAlignment(.leading)
                                }
                                
                                .font(.title3)
                                .foregroundColor(Color(UIColor.label))
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .padding()
                            .frame(width: 180, height: 150)
                            .cornerRadius(16)
                            .background(.ultraThinMaterial)
                        })
                        .cornerRadius(16)
                        if debugEnabled {
                            NavigationLink(destination: { ReplaceTestingView() }, label: {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading) {
                                        Image(systemName: "hexagon")
                                            .imageScale(.large)
                                            .font(.title2)
                                        Text("AbsoluteSolver Testing")
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    .font(.title3)
                                    .foregroundColor(Color(UIColor.label))
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                .padding()
                                .frame(width: 180, height: 150)
                                .cornerRadius(16)
                                .background(.ultraThinMaterial)
                            })
                            .cornerRadius(16)
                            NavigationLink(destination: { AppleLoopsMixView() }, label: {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading) {
                                        Image(systemName: "apple.logo")
                                            .imageScale(.large)
                                            .font(.title2)
                                        Text("Apple Loops Mix")
                                            .multilineTextAlignment(.leading)
                                    }
                                    .font(.title3)
                                    .foregroundColor(Color(UIColor.label))
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                
                                .padding()
                                .frame(width: 180, height: 150)
                                .cornerRadius(16)
                                .background(.ultraThinMaterial)
                            })
                            .cornerRadius(16)
                        }
                    }
                    .padding(6)
                }
                .background(.thinMaterial)
                .navigationTitle("Tools")
            }
        }
        .onAppear{
            debugEnabled = UserDefaults.standard.bool(forKey: "DebugEnabled")
        }
    }
}

struct Card: View {
    var tool: String
    var image: String
    @State var opened = false
    @State var rotation = 0.0
    // THESE SHOULD ALWAYS BE THE SAME!!!
    let defaultAnimDuration = 0.3
    @State var animDuration = 0.3
    
    private var timeCurveAnimation: Animation {
        return Animation.timingCurve(0.5, 0.8, 0.8, 0.3, duration: 0.3)
        }
    
    var body: some View {
        if opened {
            ZStack {
                CardBack(toolname: tool)
                    .cornerRadius(10)
                    .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                    .animation(self.timeCurveAnimation, value: rotation)
                    .padding()
                    .onAppear {
                        rotation = 0
                    }
                    .edgesIgnoringSafeArea(.all)
                
                Button(action: {
                    print("Switching to album")
                    rotation = -90.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + animDuration) {
                        animDuration = 0.0
                        rotation = 90.0
                        animDuration = defaultAnimDuration
                        opened.toggle()
                    }
                }, label: {Label("", systemImage: "chevron.left")})
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    .onTapGesture {
                        rotation = -90.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + animDuration) {
                            animDuration = 0.0
                            rotation = 90.0
                            animDuration = defaultAnimDuration
                            opened.toggle()
                        }
                    }
            }
        } else {
            CardFront(tool: tool, image: image)
                .cornerRadius(10)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                .animation(self.timeCurveAnimation, value: rotation)
                .onTapGesture {
                    print("Switching to list")
                    rotation = 90.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + animDuration) {
                        animDuration = 0.0
                        rotation = -90.0
                        animDuration = defaultAnimDuration
                        opened.toggle()
                    }
                }
                .onAppear {
                    rotation = 0
                }
        }
    }
}

struct CardFront: View {
    var tool: String
    var image: String
    var body: some View {
        return HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Image(systemName: image)
                    .imageScale(.large)
                    .font(.title2)
                Text(tool)
                    .multilineTextAlignment(.leading)
            }
            
            .font(.title3)
            .foregroundColor(Color(UIColor.label))
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding()
        .frame(width: 180, height: 150)
        .cornerRadius(16)
        .background(.ultraThinMaterial)
    }
}

struct CardBack: View {
    var toolname: String
    var body: some View {
        return ZStack {
            // i will never see the gates of heaven
            if toolname == "Whitelist" {
                WhitelistView()
            } else if toolname == "Apple Loops Mix" {
                AppleLoopsMixView()
            } else if toolname == "Remove three-app limit" {
                FreeloadView()
            } else if toolname == "AbsoluteSolver Testing" {
                ReplaceTestingView()
            } else {
                Text("WTF?! Tool does not exist?!")
            }
        }
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}
