//
//  MubWebView.swift
//  MubWebView
//
//  Created by Ashwin Paudel on 29/11/2021.
//

import Cocoa
import WebKit

@objc public protocol MubWebViewDelegate: NSObjectProtocol {
    /// When the webview URL changes
    @objc optional func mubWebView(_ webView: MubWebView, urlDidChange url: URL?)

    /// When the webview is loading
    @objc optional func mubWebView(_ webView: MubWebView, estimatedProgress progress: Double)

    /// When the webview's title changes
    @objc optional func mubWebView(_ webView: MubWebView, titleChanged title: String)

    /// When the webview is done loading
    @objc optional func mubWebView(_ webView: MubWebView, didFinishLoading url: URL?)
}

/// The MubWebView, subclass of WKWebView
public class MubWebView: WKWebView, WKUIDelegate, WKNavigationDelegate {
    public weak var delegate: MubWebViewDelegate?

    // Observers
    var urlObservation: NSKeyValueObservation?
    var titleObservation: NSKeyValueObservation?
    var estimatedProgressObservation: NSKeyValueObservation?

    public func initializeWebView() {
        self.uiDelegate = self
        self.navigationDelegate = self

        self.titleObservation = self.observe(\.title, changeHandler: { webView, _ in
            print("[ MubWebView ]: Title changed to: \(webView.title ?? "Unknown Title")")
            self.delegate?.mubWebView?(webView, titleChanged: webView.title ?? "Unknown Title")
        })

        self.estimatedProgressObservation = self.observe(\.estimatedProgress) { webView, _ in
            print("[ MubWebView ]: Estimated loading time: \(webView.estimatedProgress)")

            self.delegate?.mubWebView?(webView, estimatedProgress: webView.estimatedProgress)
        }

        self.urlObservation = self.observe(\.url, changeHandler: { webView, _ in
            print("[ MubWebView ]: URL changed to \(webView.url?.absoluteString ?? "NIL")")

            self.delegate?.mubWebView?(webView, urlDidChange: webView.url)
        })
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("[ MubWebView ]: Finished Loading Website")
        self.delegate?.mubWebView?(webView as! MubWebView, didFinishLoading: webView.url)
    }

    /// Add the adblock script into the webview
    public func enableAdblock() {
        if let url1 = URL(string: "https://raw.githubusercontent.com/brave/brave-ios/development/Client/WebFilters/ContentBlocker/Lists/block-ads.json") {
            do {
                let contents = try String(contentsOf: url1)
                WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: contents) { contentRuleList, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.configuration.userContentController.add(contentRuleList!)
                }
            } catch {}
        }
    }

    /// Add the configurations to the webview to make it faster and enable more features
    public func enableConfigurations() {
        self.configuration.preferences.setValue(true, forKey: "offlineApplicationCacheIsEnabled")
        self.configuration.preferences.setValue(true, forKey: "aggressiveTileRetentionEnabled")
        self.configuration.preferences.setValue(true, forKey: "screenCaptureEnabled")
        self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        self.configuration.preferences.setValue(true, forKey: "allowsPictureInPictureMediaPlayback")
        self.configuration.preferences.setValue(true, forKey: "fullScreenEnabled")
        self.configuration.preferences.setValue(true, forKey: "largeImageAsyncDecodingEnabled")
        self.configuration.preferences.setValue(false, forKey: "animatedImageAsyncDecodingEnabled")
        self.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        self.configuration.preferences.setValue(true, forKey: "usesPageCache")
        self.configuration.preferences.setValue(true, forKey: "mediaSourceEnabled")
        self.configuration.preferences.setValue(true, forKey: "acceleratedDrawingEnabled")
        self.configuration.preferences.setValue(false, forKey: "backspaceKeyNavigationEnabled")
        self.configuration.preferences.setValue(true, forKey: "mediaDevicesEnabled")
        self.configuration.preferences.setValue(true, forKey: "mockCaptureDevicesPromptEnabled")
        self.configuration.preferences.setValue(true, forKey: "canvasUsesAcceleratedDrawing")
        self.configuration.preferences.setValue(true, forKey: "aggressiveTileRetentionEnabled")
        self.configuration.preferences.setValue(true, forKey: "videoQualityIncludesDisplayCompositingEnabled")
        self.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        self.configuration.preferences.setValue(true, forKey: "appNapEnabled")

        self.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
    }
}
