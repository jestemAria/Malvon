//
//  MAWebView.swift
//  MAWebView
//
//  Created by Ashwin Paudel on 2021-11-29.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa
import WebKit

@objc public protocol MAWebViewDelegate: NSObjectProtocol {
    /// When the webview URL changes
    @objc optional func mubWebView(_ webView: MAWebView, urlDidChange url: URL?)
    
    /// When the webview is loading
    @objc optional func mubWebView(_ webView: MAWebView, estimatedProgress progress: Double)
    
    /// When the webview's title changes
    @objc optional func mubWebView(_ webView: MAWebView, titleChanged title: String)
    
    /// When the webview is done loading
    @objc optional func mubWebView(_ webView: MAWebView, didFinishLoading url: URL?)
    
    /// When the webview is done loading
    @objc optional func mubWebView(_ webView: MAWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures)
    
    @objc func mubWebView(_ webView: MAWebView, createWebViewWith configuration: WKWebViewConfiguration, navigationAction: WKNavigationAction) -> MAWebView
    
    @objc func mubWebViewWillCloseTab()
    
    @objc optional func mubWebView(_ webView: MAWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void)
    
    @objc optional func mubWebView(_ webView: MAWebView, failedLoadingWebpage error: Error)
}

/// The MAWebView, subclass of WKWebView
public class MAWebView: WKWebView, WKUIDelegate, WKNavigationDelegate {
    public weak var delegate: MAWebViewDelegate?
    
    private var frameworkBundle: Bundle? {
        let bundleId = "com.ashwin.MAWebView"
        return Bundle(identifier: bundleId)
    }
    
    private lazy var downloader = FilesDownloader()
    
    public func initializeWebView() {
        self.uiDelegate = self
        self.navigationDelegate = self
        
        self.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        self.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }
    
    public func removeWebview() {
        self.removeObserver(self, forKeyPath: "estimatedProgress")
        self.removeObserver(self, forKeyPath: "URL")
        self.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        
        self.removeFromSuperview()
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.delegate?.mubWebView?(self, estimatedProgress: self.estimatedProgress)
        } else if keyPath == "URL" {
            self.delegate?.mubWebView?(self, urlDidChange: self.url)
        } else if keyPath == "title" {
            self.delegate?.mubWebView?(self, titleChanged: self.title ?? "Unknown Title")
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.mubWebView?(webView as! MAWebView, didFinishLoading: webView.url)
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return self.delegate?.mubWebView(webView as! MAWebView, createWebViewWith: configuration, navigationAction: navigationAction)
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        self.delegate?.mubWebViewWillCloseTab()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.delegate?.mubWebView?(webView as! MAWebView, failedLoadingWebpage: error)
    }
    
    public func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        self.delegate?.mubWebView?(webView as! MAWebView, runOpenPanelWith: parameters, initiatedByFrame: frame, completionHandler: completionHandler)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            if !navigationResponse.canShowMIMEType {
                let panel = NSSavePanel()
                panel.nameFieldStringValue = response.suggestedFilename!
                DownloaderProgress.shardInstance.isFinished = false
                panel.canCreateDirectories = true
                panel.beginSheetModal(for: self.window!) { [self] res in
                    if res == .OK {
                        DownloaderProgress.shardInstance.fileName = panel.nameFieldStringValue
                            
                        let filePath = panel.url
                        let ProgView = MAWebViewDownloadingViewController(nibName: "MAWebViewDownloadingViewController", bundle: frameworkBundle)
                            
                        let mainWindow = NSWindow(contentViewController: ProgView)
                            
                        self.window?.beginSheet(mainWindow, completionHandler: { _ in
                        })
                            
                        mainWindow.close()
                            
                        downloader.download(from: response.url!, tourl: filePath!)
                    }
                }
            }
        }
        
        decisionHandler(.allow)
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
        self.configuration.preferences.setValue(true, forKey: "fullScreenEnabled")
        self.configuration.preferences.setValue(true, forKey: "allowsPictureInPictureMediaPlayback")
        self.configuration.preferences.setValue(true, forKey: "simpleLineLayoutEnabled")
        self.configuration.preferences.setValue(true, forKey: "acceleratedDrawingEnabled")
        self.configuration.preferences.setValue(true, forKey: "largeImageAsyncDecodingEnabled")
        self.configuration.preferences.setValue(true, forKey: "animatedImageAsyncDecodingEnabled")
        self.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        self.configuration.preferences.setValue(true, forKey: "loadsImagesAutomatically")
        self.configuration.preferences.setValue(true, forKey: "screenCaptureEnabled")
        self.configuration.preferences.setValue(true, forKey: "acceleratedCompositingEnabled")
        self.configuration.preferences.setValue(true, forKey: "canvasUsesAcceleratedDrawing")
        self.configuration.preferences.setValue(true, forKey: "localFileContentSniffingEnabled")
        self.configuration.preferences.setValue(true, forKey: "usesPageCache")
        self.configuration.preferences.setValue(false, forKey: "backspaceKeyNavigationEnabled")
        self.configuration.preferences.setValue(true, forKey: "aggressiveTileRetentionEnabled")
        self.configuration.preferences.setValue(true, forKey: "appNapEnabled")
        self.configuration.preferences.setValue(true, forKey: "aggressiveTileRetentionEnabled")
        self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        self.configuration.preferences.setValue(true, forKey: "videoQualityIncludesDisplayCompositingEnabled")
        
        self.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
    }
}
