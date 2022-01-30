//
//  MAViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-11-29.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa
import MASearchSuggestions
import MATabView
import MATools
import MAWebView
import WebKit

class MAViewController: NSViewController, MAWebViewDelegate, NSSearchFieldDelegate, MATabViewDelegate {
    // MARK: - Elements
    
    // webView! Element
    @IBOutlet var webTabView: MATabView!
    @IBOutlet var webTabBarView: MATabBarView!
    var webView: MAWebView?
    
    // Search Field and Progress Indicator Elements
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var searchField: MASearchField!
    
    // Refresh, Back, Forward outlets
    @IBOutlet var refreshButton: HoverButton!
    @IBOutlet var backButtonOutlet: HoverButton!
    @IBOutlet var forwardButtonOutlet: HoverButton!
    
    // Search Suggestions field
    var suggestions = [String]()
    private var suggestionsController: MASuggestionsWindowController?
    private var skipNextSuggestion = false
    private var window = NSWindow()
    
    // Show the tabs
    @IBOutlet var createNewTabButton: HoverButton!
    
    // For popups
    public var webConfigurations: WKWebViewConfiguration
    private var loadURL = true
    
    // The window properties
    public var windowController: MAWindowController
    
    // Just to improve proformance
    private var startPageHTML = String()
    let newtabURL = Bundle.main.url(forResource: "newtab", withExtension: "html")

    // MARK: - Setup Functions
    
    init(config: WKWebViewConfiguration = WKWebViewConfiguration(), loadURL: Bool = true, windowCNTRL: MAWindowController) {
        self.webConfigurations = config
        self.loadURL = loadURL
        self.windowController = windowCNTRL
        super.init(nibName: "MAViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        window = view.window!
        
        // Setup the buttons
        styleElements()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async { [self] in
            if let string = UserDefaults.standard.string(forKey: "startPageHTML") {
                startPageHTML = string
            } else {
                startPageHTML = MAURL(newtabURL!).contents()
                UserDefaults.standard.set(startPageHTML, forKey: "startPageHTML")
            }
        }
        // Add the `webView` to the `webTabView`

        webView = MAWebView(frame: webTabView.frame, configuration: webConfigurations)
        webView = getNewWebViewInstance(config: webConfigurations)
        webTabView.tabBar = webTabBarView
        webTabView.`init`()
        webTabView.addTabViewItem(tabViewItem: MATabViewItem(view: webView!))
        webTabView.delegate = self

        // Remove the cancle and search buttons from the searchfield
        if let cell = searchField.cell as? NSSearchFieldCell {
            cell.searchButtonCell?.isTransparent = true
            cell.cancelButtonCell?.isTransparent = true
        }
        
        // Configure the elements
        configureElements()
        
        if AppProperties().hidesScreenElementsWhenNotActive {
            // When the app enters the background
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(willEnterBackground), name: NSApplication.willResignActiveNotification, object: nil)
            nc.addObserver(self, selector: #selector(willBecomeActive), name: NSApplication.willBecomeActiveNotification, object: nil)
        }
        
        // Check if the view controller is a popup or a normal view controller
        // If it's a normal view controller, we will load the startpage
        // If it's not, the webview will automatically load the URL, so we don't have to worry
        if loadURL {
            webView?.loadHTMLString(startPageHTML, baseURL: newtabURL!)
        }
    }
    
    @objc func willEnterBackground() {
        webTabView.isHidden = true
        webView?.isHidden = true
        searchField.isHidden = true
        refreshButton.isHidden = true
        backButtonOutlet.isHidden = true
        forwardButtonOutlet.isHidden = true
        createNewTabButton.isHidden = true
    }
    
    @objc func willBecomeActive() {
        webTabView.isHidden = false
        webView?.isHidden = false
        searchField.isHidden = false
        refreshButton.isHidden = false
        backButtonOutlet.isHidden = false
        forwardButtonOutlet.isHidden = false
        createNewTabButton.isHidden = false
    }
    
    // Style the elements ( buttons, searchfields )
    func styleElements() {
        progressIndicator.alphaValue = 0.7
        backButtonOutlet.changeTint = true
        forwardButtonOutlet.changeTint = true
        refreshButton.changeTint = true
        createNewTabButton.changeTint = true
        refreshButton.cornerRadius = 10
    }
    
    // Configure the elements ( buttons, searchfields )
    func configureElements() {
        searchField.delegate = self
        webView!.delegate = self
        webView!.initializeWebView()
        webView!.enableConfigurations()
        webView!.enableAdblock()
    }
    
    // MARK: - Buttons
    
    @IBAction func backButton(_ sender: Any) {
        // If the webView can go back, go back
        if webView!.canGoBack { webView!.goBack() }
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        // If the webView can go forward, go forward
        if webView!.canGoForward { webView!.goForward() }
    }
    
    @IBAction func refreshButton(_ sender: NSButton) {
        // If there is a reload icon, reload the page and display the X icon
        if sender.image == NSImage(named: NSImage.refreshTemplateName) {
            webView!.reload()
            sender.image = NSImage(named: NSImage.stopProgressTemplateName)
        
            // If there is a X icon, stop the webpage from loading
        } else if sender.image == NSImage(named: NSImage.stopProgressTemplateName) {
            webView!.stopLoading()
            sender.image = NSImage(named: NSImage.refreshTemplateName)
        }
    }
    
    func createNewTab(url: URL) {
        // Create a new tab
        webView = getNewWebViewInstance(url: url)
        webTabView.addTabViewItem(tabViewItem: MATabViewItem(view: webView!))
    }
    
    @IBAction func createNewTab(_ sender: Any) {
        // Create a new tab
        webView = getNewWebViewInstance()
        webTabView.addTabViewItem(tabViewItem: MATabViewItem(view: webView!))
    }
    
    @IBAction func closeTab(_ sender: Any) {
        // Close the current tab
        webTabView.removeTabViewItem(at: webTabView.selectedTabViewItemIndex)
    }
    
    func checkButtons() {
        if let webView = webView {
            // If the webView can go back, enable the back button
            webView.canGoBack ? (backButtonOutlet.isEnabled = true) : (backButtonOutlet.isEnabled = false)
            
            // If the webView can go forward, enable the back forward
            webView.canGoForward ? (forwardButtonOutlet.isEnabled = true) : (forwardButtonOutlet.isEnabled = false)
            
            webView.isLoading ? (refreshButton.image = NSImage(named: NSImage.stopProgressTemplateName)) : (refreshButton.image = NSImage(named: NSImage.refreshTemplateName))
        }
    }
    
    // MARK: - History Functions
    
    func parseHistoryJSON() -> [MAHistoryElement]? {
        // Read the file
        let fileContents = MAFile(path: MAHistoryViewController.path!).read()

        // Decode the file
        let decodedJSON = try? JSONDecoder().decode([MAHistoryElement].self, from: fileContents.data(using: .utf8)!)

        // Return the decoded JSON
        return decodedJSON
    }
    
    func addItem(website: String, address: String) {
        // If the history.json file doesn't exist, create an empty file
        createHistoryFileIfNotExists()

        // Create a new JSON Property
        var newHistoryJSON: [MAHistoryElement] = parseHistoryJSON()!

        // Add a new item to the new JSON property
        newHistoryJSON.append(MAHistoryElement(website: website, address: address))

        // Write the new JSON property
        do {
            let data = try JSONEncoder().encode(newHistoryJSON)
            try data.write(to: MAHistoryViewController.path!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // If the history.json file doesn't exist, create it
    func createHistoryFileIfNotExists() {
        let pathComponent = MAFile(path: MAHistoryViewController.path!)
        if !pathComponent.exists() {
            pathComponent.write("[]")
        }
    }
    
    // MARK: - webView Functions
    
    func mubWebView(_ webView: MAWebView, failedLoadingWebpage error: Error) {
        let newtabURL = Bundle.main.url(forResource: "error_page", withExtension: "html")
        self.webView!.loadFileURL(newtabURL!, allowingReadAccessTo: newtabURL!)
        
        if let info = error._userInfo as? [String: Any] {
            if let url = info["NSErrorFailingURLKey"] as? URL {
                let errorMessageScript = WKUserScript(source: "errorMessage(\"\(error.localizedDescription)\")\nlet retryLoadingURL = \"\(url.absoluteString)\"", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                webView.configuration.userContentController.addUserScript(errorMessageScript)
            }
        }
    }
    
    func mubWebView(_ webView: MAWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        // Create the file panel
        let dialog = NSOpenPanel()
        
        // Configure the NSOpenPanel
        dialog.allowsMultipleSelection = parameters.allowsMultipleSelection
        dialog.canChooseDirectories = parameters.allowsDirectories
        
        // Show the file panel
        dialog.beginSheetModal(for: view.window!) { result in
            // If the user uploads a file complete
            if result == .OK {
                if let url = dialog.url {
                    // Upload the file url to the webpage
                    completionHandler([url])
                }
            } else {
                // If the user clicks cancle
                self.complete(nil)
            }
        }
    }
    
    func mubWebView(_ webView: MAWebView, urlDidChange url: URL?) {
        // Update the search field URL
        updateWebsiteURL()
        // Check if we should enable one of the buttons
        checkButtons()
    }
    
    func getFavicon(url: String) -> NSImage? {
        let url = URL(string: "https://www.google.com/s2/favicons?sz=30&domain_url=" + url)

        do {
            return NSImage(data: try Data(contentsOf: url!))
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func mubWebView(_ webView: MAWebView, titleChanged title: String) {
        if let webView = (webTabView.tabViewItems[webTabView.selectedTabViewItemIndex].view as? MAWebView) {
            // Set the new title
            (webTabView.tabBar?.tabStackView.subviews[webTabView.selectedTabViewItemIndex] as? MATabBarViewItem)?.label = webView.title ?? "Untitled Tab"

            // Get the favicon of the website
            guard let webViewURL = webView.url?.absoluteString else { return }
            
            (webTabBarView.tabStackView.subviews[webTabView.selectedTabViewItemIndex] as? MATabBarViewItem)?.favicon = getFavicon(url: webViewURL)
        }
    }
    
    func mubWebView(_ webView: MAWebView, createWebViewWith configuration: WKWebViewConfiguration, navigationAction: WKNavigationAction) -> MAWebView {
        // Create a new tab and open it
        
        let newWebView = getNewWebViewInstance(config: configuration)
        self.webView = newWebView
        webTabView.addTabViewItem(tabViewItem: MATabViewItem(view: newWebView))
        
        // Return the new tab's webView
        return newWebView
    }
    
    func mubWebView(_ webView: MAWebView, estimatedProgress progress: Double) {
        // Make the progress indicator visible
        progressIndicator.isHidden = false
        
        // Change the refresh button's icon to X mark
        refreshButton.image = NSImage(named: NSImage.stopProgressTemplateName)
        
        // Set the value of the progress indicator
        progressIndicator.doubleValue = (progress * 100)
        
        // Increase the value by 50
        progressIndicator.increment(by: 50)
        
        // Set it to use threaded animations
        progressIndicator.usesThreadedAnimation = true
        
        if progressIndicator.doubleValue == 100 {
            // Set the value to 0
            progressIndicator.doubleValue = 0
            // Hide the progress indicator
            progressIndicator.isHidden = true
            // Change the icon of the refresh button to the refresh icon
            refreshButton.image = NSImage(named: NSImage.refreshTemplateName)
            // Check if we should disable or enable any buttons
            checkButtons()
        }
    }
    
    func mubWebViewWillCloseTab() {
        webTabView.removeTabViewItem(at: webTabView.selectedTabViewItemIndex)
    }
    
    func updateWebsiteURL() {
        // Highlight the searchfield value
        guard let url = webView!.url else { return }
        
        let attribute = [NSAttributedString.Key.foregroundColor: NSColor.gray]
        
        if url.scheme == "file" {
            if url.absoluteString.starts(with: Bundle.main.bundleURL.absoluteString) == true {
                let attrScheme = NSMutableAttributedString(string: "malvon?", attributes: attribute)
                let attrHost = NSAttributedString(string: url.absoluteString.fileName)
                
                attrScheme.append(attrHost)
                searchField.attributedStringValue = attrScheme
            } else {
                searchField.stringValue = url.absoluteString
            }
        } else {
            let scheme = (url.scheme ?? "") + "://"
            let host = url.host ?? ""
            var path = url.path
            let query = url.query ?? ""
            
            query.isEmpty ? () : (path += "?" + query)
            
            let attrPath = NSAttributedString(string: path, attributes: attribute)
            let attrHost = NSAttributedString(string: host)
            let attrScheme = NSMutableAttributedString(string: scheme, attributes: attribute)
            
            attrScheme.append(attrHost)
            attrScheme.append(attrPath)
            
            searchField.attributedStringValue = attrScheme
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Update the URL of the search field
        updateWebsiteURL()
        // Update the state of the back and forward buttons
        checkButtons()
    }
    
    func mubWebView(_ webView: MAWebView, didFinishLoading url: URL?) {
        // Add a new item into the history
        addItem(website: webView.title!, address: webView.url!.absoluteString)
        // Update the state of the back and forward buttons
        checkButtons()
    }
    
    // MARK: - Search Field

    @IBAction func searchFieldAction(_ sender: Any) {
        if searchField.stringValue.isEmpty {
            // Do nothing
            return
        } else if searchField.stringValue.starts(with: "malvon?") {
            let URL = Bundle.main.url(forResource: searchField.stringValue.string("malvon?"), withExtension: "html")!
            webView!.loadFileURL(URL, allowingReadAccessTo: URL)
        
            // If the URL starts with 'file'
        } else if URL(string: searchField.stringValue)?.scheme == "file" {
            webView!.loadFileURL(URL(string: searchField.stringValue)!, allowingReadAccessTo: URL(string: searchField.stringValue)!)
        
            // If the URL is a valid URL
        } else if searchField.stringValue.isValidURL {
            webView!.load(URLRequest(url: MAURL(URL(string: searchField.stringValue)!).fix()))
            
            // If it's none of the above
        } else {
            webView!.load(URLRequest(url: URL(string: "https://www.google.com/search?client=Malvon&q=\(searchField.stringValue.encodeToURL)")!))
        }
    }
    
    @IBAction func searchFieldValueDidUpdate(_ sender: Any) {
        let entry = (sender as? MASuggestionsWindowController)?.selectedSuggestion()
        if entry != nil, !entry!.isEmpty {
            let fieldEditor: NSText? = window.fieldEditor(false, for: searchField)
            if fieldEditor != nil {
                updateFieldEditor(fieldEditor, withSuggestion: entry![kSuggestionLabel] as? String)
            }
        }
    }
    
    func suggestions(forText text: String?) -> [[String: Any]]? {
        SearchSuggestions.getQuerySuggestions(text!) { [unowned self] suggestions, error in
            if let suggestions = suggestions, suggestions.count > 0 {
                self.suggestions = suggestions
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        var suggestions = [[String: Any]]()
        suggestions.reserveCapacity(1)
        
        for val in self.suggestions {
            if text != nil, text != "", val.hasPrefix(text ?? "") || val.uppercased().hasPrefix(text?.uppercased() ?? "") {
                let entry: [String: Any] = [
                    kSuggestionLabel: val
                ]
                suggestions.append(entry)
            }
        }
        return suggestions
    }
    
    private func updateFieldEditor(_ fieldEditor: NSText?, withSuggestion suggestion: String?) {
        let selection = NSRange(location: fieldEditor?.selectedRange.location ?? 0, length: suggestion?.count ?? 0)
        fieldEditor?.string = suggestion ?? ""
        fieldEditor?.selectedRange = selection
    }
    
    /* Determines the current list of suggestions, display the suggestions and update the field editor.
     */
    func updateSuggestions(from control: NSControl?) {
        let fieldEditor: NSText? = window.fieldEditor(false, for: control)
        if fieldEditor != nil {
            // Only use the text up to the caret position
            let selection: NSRange? = fieldEditor?.selectedRange
            let text = (selection != nil) ? (fieldEditor?.string as NSString?)?.substring(to: selection!.location) : nil
            let suggestions = self.suggestions(forText: text)
            if suggestions != nil, suggestions!.count > 0 {
                // We have at least 1 suggestion. Update the field editor to the first suggestion and show the suggestions window.
                let suggestion = suggestions![0]
                
                updateFieldEditor(fieldEditor, withSuggestion: suggestion[kSuggestionLabel] as? String)
                suggestionsController?.setSuggestions(suggestions!)
                if !(suggestionsController?.window?.isVisible ?? false) {
                    suggestionsController?.begin(for: control as? NSSearchField)
                }
            } else {
                suggestionsController?.cancelSuggestions()
            }
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if !skipNextSuggestion {
            updateSuggestions(from: obj.object as? NSControl)
        } else {
            // If the suggestionController is already in a cancelled state, this call does nothing and is therefore always safe to call.
            suggestionsController?.cancelSuggestions()
            // This suggestion has been skipped, don"t skip the next one.
            skipNextSuggestion = false
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        suggestionsController?.cancelSuggestions()
    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        if !skipNextSuggestion {
            // We keep the suggestionsController around, but lazely allocate it the first time it is needed.
            if suggestionsController == nil {
                suggestionsController = MASuggestionsWindowController()
                suggestionsController?.target = self
                suggestionsController?.action = #selector(searchFieldValueDidUpdate(_:))
            }
            updateSuggestions(from: obj.object as? NSControl)
        }
    }
    
    /* As the delegate for the NSTextField, this class is given a chance to respond to the key binding commands interpreted by the input manager when the field editor calls -interpretKeyEvents:. This is where we forward some of the keyboard commands to the suggestion window to facilitate keyboard navigation. Also, this is where we can determine when the user deletes and where we can prevent AppKit"s auto completion.
     */
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.moveUp(_:)) {
            // Move up in the suggested selections list
            suggestionsController?.moveUp(textView)
            return true
        }
        if commandSelector == #selector(NSResponder.moveDown(_:)) {
            // Move down in the suggested selections list
            suggestionsController?.moveDown(textView)
            return true
        }
        if commandSelector == #selector(NSResponder.deleteForward(_:)) || commandSelector == #selector(NSResponder.deleteBackward(_:)) {
            /* The user is deleting the highlighted portion of the suggestion or more. Return NO so that the field editor performs the deletion. The field editor will then call -controlTextDidChange:. We don"t want to provide a new set of suggestions as that will put back the characters the user just deleted. Instead, set skipNextSuggestion to YES which will cause -controlTextDidChange: to cancel the suggestions window. (see -controlTextDidChange: above)
             */
            let insertionRange = textView.selectedRanges[0].rangeValue
            if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
                skipNextSuggestion = (insertionRange.location != 0 || insertionRange.length > 0)
            } else {
                skipNextSuggestion = (insertionRange.location != textView.string.count || insertionRange.length > 0)
            }
            return false
        }
        if commandSelector == #selector(NSResponder.complete(_:)) {
            // The user has pressed the key combination for auto completion. AppKit has a built in auto completion. By overriding this command we prevent AppKit"s auto completion and can respond to the user"s intention by showing or cancelling our custom suggestions window.
            if suggestionsController != nil, suggestionsController!.window != nil, suggestionsController!.window!.isVisible {
                suggestionsController?.cancelSuggestions()
            } else {
                updateSuggestions(from: control)
            }
            return true
        }
        // This is a command that we don't specifically handle, let the field editor do the appropriate thing.
        return false
    }
    
    // MARK: - Tab Menu Items
    
    func switchTo(tab number: Int, _ pauses: Bool = false, closes: Bool = false) {
        if !closes {
            if number <= webTabView.tabViewItems.count - 1 {
                if pauses {
                    // Run the Javascript that will pause the video
                    let stopVideoScript = "var videos = document.getElementsByTagName('video'); for( var i = 0; i < videos.length; i++ ){videos.item(i).pause()}"

                    // Tell the webview to run that javascript
                    webView!.evaluateJavaScript(stopVideoScript, completionHandler: nil)
                }

                // Change the current tab to the new number
                webTabView.selectTabViewItem(at: number)
            }
        } else {
            webTabView.removeTabViewItem(at: number)
        }
    }
    
    @IBAction func tab1(_ sender: Any?) {
        switchTo(tab: 0)
    }
    
    @IBAction func tab2(_ sender: Any?) {
        switchTo(tab: 1)
    }
    
    @IBAction func tab3(_ sender: Any?) {
        switchTo(tab: 2)
    }
    
    @IBAction func tab4(_ sender: Any?) {
        switchTo(tab: 3)
    }
    
    @IBAction func tab5(_ sender: Any?) {
        switchTo(tab: 4)
    }
    
    @IBAction func tab6(_ sender: Any?) {
        switchTo(tab: 5)
    }
    
    @IBAction func tab7(_ sender: Any?) {
        switchTo(tab: 6)
    }
    
    @IBAction func tab8(_ sender: Any?) {
        switchTo(tab: 7)
    }
    
    @IBAction func tab9(_ sender: Any?) {
        switchTo(tab: 8)
    }
    
    @IBAction func tab1PAUSE(_ sender: Any?) {
        switchTo(tab: 0, true)
    }
    
    @IBAction func tab2PAUSE(_ sender: Any?) {
        switchTo(tab: 1, true)
    }
    
    @IBAction func tab3PAUSE(_ sender: Any?) {
        switchTo(tab: 2, true)
    }
    
    @IBAction func tab4PAUSE(_ sender: Any?) {
        switchTo(tab: 3, true)
    }
    
    @IBAction func tab5PAUSE(_ sender: Any?) {
        switchTo(tab: 4, true)
    }
    
    @IBAction func tab6PAUSE(_ sender: Any?) {
        switchTo(tab: 5, true)
    }
    
    @IBAction func tab7PAUSE(_ sender: Any?) {
        switchTo(tab: 6, true)
    }
    
    @IBAction func tab8PAUSE(_ sender: Any?) {
        switchTo(tab: 7, true)
    }
    
    @IBAction func tab9PAUSE(_ sender: Any?) {
        switchTo(tab: 8, true)
    }
    
    @IBAction func tab1CLOSE(_ sender: Any?) {
        switchTo(tab: 0, closes: true)
    }
    
    @IBAction func tab2CLOSE(_ sender: Any?) {
        switchTo(tab: 1, closes: true)
    }
    
    @IBAction func tab3CLOSE(_ sender: Any?) {
        switchTo(tab: 2, closes: true)
    }
    
    @IBAction func tab4CLOSE(_ sender: Any?) {
        switchTo(tab: 3, closes: true)
    }
    
    @IBAction func tab5CLOSE(_ sender: Any?) {
        switchTo(tab: 4, closes: true)
    }
    
    @IBAction func tab6CLOSE(_ sender: Any?) {
        switchTo(tab: 5, closes: true)
    }
    
    @IBAction func tab7CLOSE(_ sender: Any?) {
        switchTo(tab: 6, closes: true)
    }
    
    @IBAction func tab8CLOSE(_ sender: Any?) {
        switchTo(tab: 7, closes: true)
    }
    
    @IBAction func tab9CLOSE(_ sender: Any?) {
        switchTo(tab: 8, closes: true)
    }
    
    // MARK: - Tab Functions
    
    func tabView(_ tabView: MATabView, didSelect tabViewItemIndex: Int) {
        webView = webTabView.tabViewItems[tabViewItemIndex].view as? MAWebView
        
        checkButtons()
        updateWebsiteURL()
        
        // Hide the progress indicator
        progressIndicator.isHidden = true
    }

    func tabViewEmpty() {
        view.window?.close()
    }
    
    func tabView(_ tabView: MATabView, willRemove tabViewItemIndex: Int) {
        var tabsWebView = webTabView.tabViewItems[tabViewItemIndex].view as? MAWebView
        // Make the webView load "about:blank"
        tabsWebView?.load(URLRequest(url: URL(string: "about:blank")!))
        // Remove all the observers on the webview
        tabsWebView?.removeWebview()
        // Remove from the superview
        tabsWebView?.removeFromSuperview()
        // Make it nil
        tabsWebView = nil
        
        progressIndicator.isHidden = true
    }
    
    private func getNewWebViewInstance(config: WKWebViewConfiguration? = nil, url: URL? = nil) -> MAWebView {
        let newWebView = MAWebView(frame: webTabView.frame, configuration: config ?? WKWebViewConfiguration())
        
        newWebView.initializeWebView()
        newWebView.enableConfigurations()
        
        DispatchQueue.global(qos: .background).async {
            newWebView.enableAdblock()
            newWebView.delegate = self
        }

        if config == nil {
            _ = url != nil ? newWebView.load(.init(url: url!)) : newWebView.loadHTMLString(startPageHTML, baseURL: newtabURL!)
        }
        
        return newWebView
    }
}
