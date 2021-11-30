//
//  MubWebView.swift
//  MubWebView
//
//  Created by Ashwin Paudel on 29/11/2021.
//

import Cocoa
import WebKit

/// The MubWebView, subclass of WKWebView
public class MubWebView: WKWebView {
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
        self.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15 Unique/1"
    }
}
