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
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
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
                    LazyVGrid(columns: gridItemLayout, alignment: .center) {
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
                        
                        
                        Button(action: { remvoeIconCache() }, label: {
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                                        .imageScale(.large)
                                        .font(.title2)
                                    Text("Rebuild Icon Cache")
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

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}
