//
//  View++.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-03.
//

import Foundation
import SwiftUI

/// A ViewModifier that defers its rendering until after the provided threshold surpasses
private struct DeferredViewModifier: ViewModifier {

    // MARK: API

    let threshold: Double

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        _content(content)
            .onAppear {
               DispatchQueue.main.asyncAfter(deadline: .now() + threshold) {
                   self.shouldRender = true
               }
            }
    }

    // MARK: - Private

    @ViewBuilder
    private func _content(_ content: Content) -> some View {
        if shouldRender {
            content
        } else {
            content
                .hidden()
        }
    }

    @State
    private var shouldRender = false
}

extension View {
    func deferredRendering(for seconds: Double) -> some View {
        modifier(DeferredViewModifier(threshold: seconds))
    }
}
