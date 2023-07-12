//
//  PrivacyPolicyView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-18.
//

import SwiftUI
import WebKit
import Combine

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

class WebViewModel: ObservableObject {
    let webView: WKWebView

    private let navigationDelegate: WebViewNavigationDelegate

    init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: configuration)
        navigationDelegate = WebViewNavigationDelegate()

        webView.navigationDelegate = navigationDelegate
        setupBindings()
    }

    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false

    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)

        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)

        webView.publisher(for: \.isLoading)
            .assign(to: &$isLoading)

    }

    func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        webView.load(URLRequest(url: url))
    }

    func goForward() {
        webView.goForward()
    }

    func goBack() {
        webView.goBack()
    }
}

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // TODO
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // TODO
        decisionHandler(.allow)
    }
}

struct PrivacyPolicyView: View {
    @StateObject var model = WebViewModel()
    
    @State var bgColor: Color = Color(uiColor: UIColor.systemBackground)
    
    var body: some View {
        ZStack {
            Rectangle()
                .background(bgColor)
                .ignoresSafeArea(.all)
            WebView(webView: model.webView)
                //.deferredRendering(for: 0.4)
                .onAppear {
                    model.loadURL("https://telemetrydeck.com/privacy/")
                }
                .cornerRadius(8)
            ProgressView()
                //.scaleEffect(CGSize(size: 1.5))
                .foregroundColor(.black)
                .colorMultiply(.black)
                .tint(.black)
                .opacity(model.isLoading ? 1 : 0)
        }
            //.padding()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                bgColor = .white
            }
            .animation(.easeInOut(duration: 0.25), value: bgColor)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
