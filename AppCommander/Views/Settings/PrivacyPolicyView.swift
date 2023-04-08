//
//  PrivacyPolicyView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-18.
//

import SwiftUI
import WebKit

// MARK: - Copied this from the first search result. Am I going to change it? No!

struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .scaleEffect(CGSize(width: 1.5, height: 1.5))
            WebView(url: URL(string: "https://bomberfish.ca/misc/kouyou-privacy-policy.html")!)
                .deferredRendering(for: 0.4)
        }
            //.padding()
            .navigationTitle("Kouyou Privacy Policy")
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
