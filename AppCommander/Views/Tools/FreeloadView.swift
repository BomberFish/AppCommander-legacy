//
//  ContentView.swift
//  Freeload
//
//  Created by Hariz Shirazi on 2023-02-04.
//

import SwiftUI
import MacDirtyCow

struct FreeloadView: View {
    @State var inProgress = false
    @State var success = false
    var body: some View {
        ZStack {
            GradientView()
            VStack {
                Button(action: {
                    inProgress = true
                    Haptic.shared.play(.medium)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        success = MacDirtyCow.patch_installd()

                        if success {
                            UIApplication.shared.alert(title: "Success", body: "Successfully patched installd!", withButton: true)
                            Haptic.shared.notify(.success)
                            inProgress = false
                        } else {
                            UIApplication.shared.alert(title: "Failure", body: "Failed to patch installd!", withButton: true)
                            Haptic.shared.notify(.error)
                            inProgress = false
                        }
                    }
                }, label: {
                    Label("Apply", systemImage: "checkmark.seal")
                        .padding(10)
                })
                .buttonStyle(.borderedProminent)
            }
            //.background(.thinMaterial, ignoresSafeAreaEdges: .all)
        }
        .disabled(inProgress)
        .navigationTitle("Remove three-app limit")
    }
}

struct FreeloadView_Previews: PreviewProvider {
    static var previews: some View {
        FreeloadView()
    }
}
