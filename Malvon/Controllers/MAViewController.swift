//
//  MAViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-11-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import MASearchSuggestions
import Cocoa
import MAWebView
import WebKit
import MATools

class MAViewController: NSViewController, MAWebViewDelegate, NSSearchFieldDelegate {
    // MARK: - Elements
    
    
    // webView! Element
    @IBOutlet weak var webContentView: NSView!
    var webView: MAWebView?
    
    // Search Field and Progress Indicator Elements
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var searchField: MASearchField!
    
    // Website Title Favicon Image, And tab Elements
    @IBOutlet var websiteTitle: NSTextField!
    @IBOutlet var faviconImageView: NSImageView!
    @IBOutlet var tabStackView: NSStackView!
    
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
    @IBOutlet var showTabsButton: NSButton!
    let tabsPopover = NSPopover()
    var tabsPopoverPositioningView: NSView?
    @IBOutlet var createNewTabButton: HoverButton!
    
    
    public var website: URL?
    public var favicon: NSImage?
    
    public var webConfigurations: WKWebViewConfiguration
    
    private var loadURL = true
    
    @IBOutlet weak var blackView: NSBox!
    public var tabViewItem: NSTabViewItem?
    // MARK: - Setup Functions
    
    init(config: WKWebViewConfiguration = WKWebViewConfiguration(), loadURL: Bool = true) {
        self.webConfigurations = config
        self.loadURL = loadURL
        super.init(nibName: "MAViewController", bundle: nil)
    }
    
    init(config: WKWebViewConfiguration = WKWebViewConfiguration(), loadURL: Bool = true, _ tabView: NSTabViewItem) {
        self.webConfigurations = config
        self.loadURL = loadURL
        self.tabViewItem = tabView
        super.init(nibName: "MAViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        window = view.window!
        styleElements()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.setFrameSize(NSSize(width: 100, height: searchField.frame.height))
        self.webView = MAWebView(frame: self.webContentView.frame, configuration: self.webConfigurations)
        
        self.webContentView.addSubview(self.webView!)
        
        self.webView?.autoresizingMask = [.width, .height]
        
        (searchField.cell as? NSSearchFieldCell)?.searchButtonCell?.isTransparent = true
        (searchField.cell as? NSSearchFieldCell)?.cancelButtonCell?.isTransparent = true
        refreshButton.cornerRadius = 10
        configureElements()
        
        if loadURL == true {
            let newtabURL = Bundle.main.url(forResource: "newtab", withExtension: "html")
            webView!.loadFileURL(newtabURL!, allowingReadAccessTo: newtabURL!)
            updateWebsiteURL()
        } else {
            mubWebView(self.webView!, titleChanged: self.webView!.title!)
        }
        
        self.website = URL(string: "https://www.google.com")!
        tabsPopover.behavior = .semitransient
        tabsPopover.animates = false
        
    }
    
    // Style the elements ( buttons, searchfields )
    func styleElements() {
        progressIndicator.alphaValue = 0.7
        backButtonOutlet.changeTint = true
        forwardButtonOutlet.changeTint = true
        refreshButton.changeTint = true
        createNewTabButton.changeTint = true
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
    
    @IBAction func tabsPopoverButton(_ sender: NSButton) {
        //        tabsPopoverPositioningView = NSView()
        //        tabsPopoverPositioningView?.frame = sender.frame
        //        view.addSubview(tabsPopoverPositioningView!, positioned: .below, relativeTo: sender)
        
        if tabsPopover.isShown {
            tabsPopover.close()
        } else {
            tabsPopover.contentViewController = MATabViewController(windowController: ((self.view.window?.windowController as? MAWindowController)!))
            
            tabsPopover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            //            tabsPopover.show(relativeTo: .zero, of: tabsPopoverPositioningView!, preferredEdge: .maxY)
            //            tabsPopoverPositioningView?.frame = sender.frame
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        if webView!.canGoBack { webView!.goBack() }
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        if webView!.canGoForward { webView!.goForward() }
    }
    
    @IBAction func refreshButton(_ sender: NSButton) {
        if sender.image == NSImage(named: NSImage.refreshTemplateName) {
            webView!.reload()
            sender.image = NSImage(named: NSImage.stopProgressTemplateName)
        } else {
            webView!.stopLoading()
            sender.image = NSImage(named: NSImage.refreshTemplateName)
        }
    }
    
    @IBAction func createNewTab(_ sender: Any) {
        self.blackView.isHidden = false
        let tab = (self.view.window?.windowController as? MAWindowController)?.tabViewController
        
        var tabItem = NSTabViewItem(viewController: MAViewController())
        tabItem.viewController = MAViewController(tabItem)
        
        tab?.addTabViewItem(tabItem)
        
        tab?.selectedTabViewItemIndex = tab!.tabViewItems.count-1
        
        self.blackView.isHidden = true
    }
    
    func checkButtons() {
        if webView!.canGoBack {
            backButtonOutlet.isEnabled = true
        } else {
            backButtonOutlet.isEnabled = false
        }
        
        if webView!.canGoForward {
            forwardButtonOutlet.isEnabled = true
        } else {
            forwardButtonOutlet.isEnabled = false
        }
    }
    
    // MARK: - History Functions
    
    func parseHistoryJSON() -> [MAHistoryElement]? {
        let fileContents = MAFile(path: MAHistoryViewController.path!).read()
        let decodedJSON = try? JSONDecoder().decode([MAHistoryElement].self, from: fileContents.data(using: .utf8)!)
        
        return decodedJSON
    }
    
    func addItem(website: String, address: String) {
        createHistoryFileIfNotExists()
        var historyJSON = parseHistoryJSON()
        var newHistoryJSON: [MAHistoryElement] = historyJSON!
        let newItem = MAHistoryElement(website: website, address: address)
        newHistoryJSON.append(newItem)
        historyJSON = newHistoryJSON
        do {
            let data = try JSONEncoder().encode(newHistoryJSON)
            try data.write(to: MAHistoryViewController.path!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addHistoryEntry() {
        addItem(website: webView!.title!, address: webView!.url!.absoluteString)
    }
    
    // If the history.json file doesn't exist, create it
    func createHistoryFileIfNotExists() {
        if let pathComponent = MAHistoryViewController.path {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
            } else {
                let str = "[]"
                do {
                    try str.write(to: MAHistoryViewController.path!, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        } else {
        }
    }
    
    // MARK: - webView Functions
    
    func mubWebView(_ webView: MAWebView, urlDidChange url: URL?) {
        guard let url = url else { return }
        
        updateWebsiteURL()
        self.website = url
        checkButtons()
    }
    
    func mubWebView(_ webView: MAWebView, createWebViewWith configuration: WKWebViewConfiguration, navigationAction: WKNavigationAction) -> MAWebView {
        let tab = (self.view.window?.windowController as? MAWindowController)?.tabViewController
        
        let VC = MAViewController(config: configuration, loadURL: false)
        
        let tabItem = NSTabViewItem(viewController: VC)
        tabItem.viewController = MAViewController(config: configuration, loadURL: false, tabItem)
        
        tab?.addTabViewItem(tabItem)
        
        tab?.selectedTabViewItemIndex = tab!.tabViewItems.count-1
        
        return (tabItem.viewController as? MAViewController)!.webView!
    }
    
    func mubWebView(_ webView: MAWebView, estimatedProgress progress: Double) {
        progressIndicator.isHidden = false
        refreshButton.image = NSImage(named: NSImage.stopProgressTemplateName)
        progressIndicator.doubleValue = (progress * 100) + 10
        progressIndicator.increment(by: 50)
        
        progressIndicator.usesThreadedAnimation = true
        if progressIndicator.doubleValue == 100 {
            progressIndicator.doubleValue = 0
            progressIndicator.isHidden = true
            refreshButton.image = NSImage(named: NSImage.refreshTemplateName)
            checkButtons()
        }
    }
    
    func mubWebView(_ webView: MAWebView, titleChanged title: String) {
        websiteTitle.stringValue = title
        self.title = title
        tabViewItem?.label = title
        
        guard let webViewURL = webView.url?.absoluteString else { return }
        let url = URL(string: "https://www.google.com/s2/favicons?sz=30&domain_url=" + webViewURL)
        
        let data: Data
        
        do {
            data = try Data(contentsOf: url!)
            favicon = NSImage(data: data)
            
            faviconImageView.image = favicon
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func vcclosetabm(_ sender: Any?) {
        let tabViewController = (self.view.window?.windowController as? MAWindowController)?.tabViewController
        
        self.webView?.load(URLRequest(url: URL(string: "about:blank")!))
        
        self.webView?.removeWebview()
        self.webView?.removeFromSuperview()
        self.webView = nil
        
        tabViewController!.removeChild(at: tabViewController!.selectedTabViewItemIndex)
    }
    
    func mubWebViewWillCloseTab() {
        let tab = (self.view.window?.windowController as? MAWindowController)?.tabViewController
        
        tab?.tabViewItems.remove(at: tab!.selectedTabViewItemIndex)
    }
    
    func updateWebsiteURL() {
        guard let url = self.webView!.url else { return }
        
        let attribute = [ NSAttributedString.Key.foregroundColor: NSColor.gray ]
        
        if url.scheme == "file" {
            
            if url.absoluteString.starts(with: Bundle.main.bundleURL.absoluteString) == true {
                
                let attrScheme = NSMutableAttributedString(string: "malvon?", attributes: attribute)
                let attrHost = NSAttributedString(string: url.absoluteString.fileName)
                
                attrScheme.append(attrHost)
                print(attrScheme)
                searchField.attributedStringValue = attrScheme
            } else {
                searchField.stringValue = url.absoluteString
            }
        } else {
            let scheme = (url.scheme ?? "") + "://"
            let host = url.host ?? ""
            let path = url.path
            
            let attrPath = NSAttributedString(string: path, attributes: attribute)
            let attrHost = NSAttributedString(string: host)
            let attrScheme = NSMutableAttributedString(string: scheme, attributes: attribute)
            
            attrScheme.append(attrHost)
            attrScheme.append(attrPath)
            
            searchField.attributedStringValue = attrScheme
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateWebsiteURL()
        checkButtons()
    }
    
    
    
    func mubWebView(_ webView: MAWebView, didFinishLoading url: URL?) {
        addHistoryEntry()
        checkButtons()
    }
    
    // MARK: - Search Field
    @IBAction func searchFieldAction(_ sender: Any) {
        if searchField.stringValue.starts(with: "malvon?") {
            let URL = Bundle.main.url(forResource: searchField.stringValue.string("malvon?"), withExtension: "html")!
            webView!.loadFileURL(URL, allowingReadAccessTo: URL)
        } else if URL(string: searchField.stringValue)?.scheme == "file" {
            webView!.loadFileURL(URL(string: searchField.stringValue)!, allowingReadAccessTo: URL(string: searchField.stringValue)!)
        } else if searchField.stringValue.isValidURL {
            webView!.load(URLRequest(url: MAURL(URL(string: searchField.stringValue)!).fix()))
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
    
    func switchTo(tab number: Int, _ pauses: Bool = false) {
        let properties = AppProperties()
        if properties.showsBlackScreen { self.blackView.isHidden = false }
        if pauses {
            let stopVideoScript = "var videos = document.getElementsByTagName('video'); for( var i = 0; i < videos.length; i++ ){videos.item(i).pause()}"
            self.webView!.evaluateJavaScript(stopVideoScript, completionHandler:nil)
        }
        let tab = (self.view.window?.windowController as? MAWindowController)?.tabViewController
        
        tab?.selectedTabViewItemIndex = 0
        if properties.showsBlackScreen { self.blackView.isHidden = true }
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
}
