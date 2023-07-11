//
//  ToolsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-01.
//

import SwiftUI
import TelemetryClient

struct ToolsView: View {
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    var body: some View {
        NavigationView {
            ZStack {
                GradientView()
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, alignment: .center) {
                        NavigationLink(destination: { WhitelistView() }, label: {
                            HStack(alignment: .bottom) {
                                VStack/*(alignment: .leading)*/ {
                                    Image(systemName: "app.badge.checkmark")
                                        .imageScale(.large)
                                        .font(.title2)
                                    Text("\nWhitelist")
                                        .multilineTextAlignment(.center)
                                }
                                
                                .font(.headline)
                                .foregroundColor(Color(UIColor.label))
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .padding()
                            .frame(width: 180, height: 150)
                            .cornerRadius(16)
                            .background(.ultraThinMaterial)
                        })
                        .cornerRadius(16)
                        NavigationLink(destination: { FreeloadView() }, label: {
                            HStack(alignment: .bottom) {
                                VStack/*(alignment: .leading)*/ {
                                    Image(systemName: "apps.iphone.badge.plus")
                                        .imageScale(.large)
                                        .font(.title2)
                                    Text("\nRemove three-app limit")
                                        .multilineTextAlignment(.center)
                                }
                                
                                .font(.headline)
                                .foregroundColor(Color(UIColor.label))
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .padding()
                            .frame(width: 180, height: 150)
                            .cornerRadius(16)
                            .background(.ultraThinMaterial)
                        })
                        .cornerRadius(16)
                        
                        
                        Button(action: {
                            Haptic.shared.play(.heavy)
                            UIApplication.shared.alert(title: "Scheduling Icon Cache rebuild...", body: "", withButton: false)
                            remvoeIconCache()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                UIApplication.shared.changeTitle("Respringing...")
                                Haptic.shared.notify(.success)
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                                respring()
                            })
                        }, label: {
                            HStack(alignment: .bottom) {
                                VStack/*(alignment: .leading)*/ {
                                    if #available(iOS 16, *) {
                                        Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                                            .imageScale(.large)
                                            .font(.title2)
                                    } else {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .imageScale(.large)
                                            .font(.title2)
                                    }
                                    Text("\nRebuild Icon Cache")
                                        .multilineTextAlignment(.center)
                                }
                                .font(.headline)
                                .foregroundColor(Color(UIColor.label))
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(Color(UIColor.secondaryLabel))
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
                                    VStack/*(alignment: .leading)*/ {
                                        Image(systemName: "move.3d")
                                            .imageScale(.large)
                                            .font(.title2)
                                        Text("\nAbsoluteSolver Testing")
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.label))
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                .padding()
                                .frame(width: 180, height: 150)
                                .cornerRadius(16)
                                .background(.ultraThinMaterial)
                            })
                            .cornerRadius(16)
                            NavigationLink(destination: { AppleLoopsMixView() }, label: {
                                HStack(alignment: .bottom) {
                                    VStack/*(alignment: .leading)*/ {
                                        Image(systemName: "applelogo")
                                            .imageScale(.large)
                                            .font(.title2)
                                        Text("\nApple Loops Mix")
                                            .multilineTextAlignment(.center)
                                    }
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.label))
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                
                                .padding()
                                .frame(width: 180, height: 150)
                                .cornerRadius(16)
                                .background(.ultraThinMaterial)
                            })
                            .cornerRadius(16)
                        }
                    }
                    .padding(16)
                }
                //.background(.thinMaterial)
                .navigationTitle("Tools")
            }
        }
        .onAppear {
            debugEnabled = UserDefaults.standard.bool(forKey: "sex")
            TelemetryManager.send("toolsOpened")
        }
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}
