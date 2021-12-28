//
//  MubViewController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-11-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import APSuggestions
import Cocoa
import MubWebView
import WebKit

class MubViewController: NSViewController, MubWebViewDelegate, NSSearchFieldDelegate {
    // MARK: - Elements
    
    
    // webView! Element
    @IBOutlet weak var webContentView: NSView!
    var webView: MubWebView?
    
    // Search Field and Progress Indicator Elements
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var searchField: MubSearchField!
    
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
    private var suggestionsController: APSuggestionsWindowController?
    private var skipNextSuggestion = false
    private var window = NSWindow()
    
    // Show the tabs
    @IBOutlet var showTabsButton: NSButton!
    let tabsPopover = NSPopover()
    var tabsPopoverPositioningView: NSView?
    @IBOutlet var createNewTabButton: NSButton!
    public var website: URL?
    
    public var webConfigurations: WKWebViewConfiguration
    
    private var loadURL = true
    // MARK: - Setup Functions
    
    init(config: WKWebViewConfiguration = WKWebViewConfiguration(), loadURL: Bool = true) {
        self.webConfigurations = config
        self.loadURL = loadURL
        super.init(nibName: "MubViewController", bundle: nil)
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
        
        self.webView = MubWebView(frame: self.webContentView.frame, configuration: self.webConfigurations)
        
        self.webContentView.addSubview(self.webView!)
        
        self.webView?.autoresizingMask = [.width, .height]
        
        (searchField.cell as? NSSearchFieldCell)?.searchButtonCell?.isTransparent = true
        (searchField.cell as? NSSearchFieldCell)?.cancelButtonCell?.isTransparent = true
        configureElements()
        refreshButton.cornerRadius = 10
        webView!.initializeWebView()
        webView!.delegate = self
        
        if loadURL == true {
            webView!.load(URLRequest(url: URL(string: "https://www.google.com")!))
            updateWebsiteURL()
        }
        self.website = URL(string: "https://www.google.com")!
        tabsPopover.behavior = .transient
        tabsPopover.animates = false
    }
    
    // Style the elements ( buttons, searchfields )
    func styleElements() {
        progressIndicator.alphaValue = 0.7
        backButtonOutlet.changeTint = true
        forwardButtonOutlet.changeTint = true
    }
    
    // Configure the elements ( buttons, searchfields )
    func configureElements() {
        APsuggestionCellNib = "SearchCell"
        searchField.delegate = self
        webView!.enableAdblock()
        webView!.enableConfigurations()
    }
    
    // MARK: - Buttons
    
    @IBAction func tabsPopoverButton(_ sender: NSButton) {
        tabsPopoverPositioningView = NSView()
        tabsPopoverPositioningView?.frame = sender.frame
        view.addSubview(tabsPopoverPositioningView!, positioned: .below, relativeTo: sender)
        
        if tabsPopover.isShown {
            tabsPopover.close()
        } else {
            tabsPopover.contentViewController = MubTabViewController(windowController: ((self.view.window?.windowController as? MubWindowController)!))
            tabsPopover.show(relativeTo: .zero, of: tabsPopoverPositioningView!, preferredEdge: .maxY)
            tabsPopoverPositioningView?.frame = NSMakeRect(0, -200, 10, 10)
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        print("Back Button Pressed")
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
        let tab = (self.view.window?.windowController as? MubWindowController)?.tabViewController
        tab?.addTabViewItem(NSTabViewItem(viewController: MubViewController()))
        
        tab?.selectedTabViewItemIndex = tab!.tabViewItems.count-1
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
    
    func parseHistoryJSON() -> [MubHistoryElement]? {
        let fileContents = MubFile.read(path: MubHistoryViewController.path!)
        let decodedJSON = try? JSONDecoder().decode([MubHistoryElement].self, from: fileContents.data(using: .utf8)!)
        
        return decodedJSON
    }
    
    func addItem(website: String, address: String) {
        createHistoryFileIfNotExists()
        var historyJSON = parseHistoryJSON()
        var newHistoryJSON: [MubHistoryElement] = historyJSON!
        let newItem = MubHistoryElement(website: website, address: address)
        newHistoryJSON.append(newItem)
        historyJSON = newHistoryJSON
        do {
            let data = try JSONEncoder().encode(newHistoryJSON)
            try data.write(to: MubHistoryViewController.path!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addHistoryEntry() {
        addItem(website: webView!.title!, address: webView!.url!.absoluteString)
    }
    
    // If the history.json file doesn't exist, create it
    func createHistoryFileIfNotExists() {
        if let pathComponent = MubHistoryViewController.path {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
            } else {
                let str = "[]"
                do {
                    try str.write(to: MubHistoryViewController.path!, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print("orejiawo: \(error.localizedDescription)")
                }
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    
    // MARK: - webView Functions
    
    func mubWebView(_ webView: MubWebView, urlDidChange url: URL?) {
        updateWebsiteURL()
        self.website = url
        GlobalVariables.currentWebsite = self.webView!.url!.absoluteString
        GlobalVariables.currentWebsiteRemovedHTTP = self.webView!.url!.absoluteString.removeHTTP
        checkButtons()
    }
    
    func mubWebView(_ webView: MubWebView, createWebViewWith configuration: WKWebViewConfiguration, navigationAction: WKNavigationAction) -> MubWebView {
        let tab = (self.view.window?.windowController as? MubWindowController)?.tabViewController
        let VC = MubViewController(config: configuration, loadURL: false)
        
        
        tab?.addTabViewItem(NSTabViewItem(viewController: VC))
        
        tab?.selectedTabViewItemIndex = tab!.tabViewItems.count-1
        
        return VC.webView!
    }
    
    func mubWebView(_ webView: MubWebView, estimatedProgress progress: Double) {
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
    
    func mubWebView(_ webView: MubWebView, titleChanged title: String) {
        websiteTitle.stringValue = title
        self.title = title
        
        guard let webViewURL = webView.url?.absoluteString else { return }
        let url = URL(string: "https://www.google.com/s2/favicons?sz=30&domain_url=" + webViewURL)
        let data = try? Data(contentsOf: url!)
        faviconImageView.image = NSImage(data: data!)
    }
    
    func mubWebViewWillCloseTab() {
        let tab = (self.view.window?.windowController as? MubWindowController)?.tabViewController
        
        tab?.tabViewItems.remove(at: tab!.selectedTabViewItemIndex)
    }
    
    func updateWebsiteURL() {
        let scheme = (self.webView!.url?.scheme ?? "http(s)") + "://"
        let host = self.webView!.url?.host ?? "www.unknown.com"
        let path = self.webView!.url?.path ?? "/unknown"
        
        let attribute = [ NSAttributedString.Key.foregroundColor: NSColor.gray ]
        
        let attrPath = NSAttributedString(string: path, attributes: attribute)
        let attrHost = NSAttributedString(string: host)
        let attrScheme = NSMutableAttributedString(string: scheme, attributes: attribute)
        
        attrScheme.append(attrHost)
        attrScheme.append(attrPath)
        
        searchField.attributedStringValue = attrScheme
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateWebsiteURL()
        
        GlobalVariables.currentWebsite = self.webView!.url!.absoluteString
        GlobalVariables.currentWebsiteRemovedHTTP = self.webView!.url!.absoluteString.removeHTTP
        checkButtons()
    }
    
    
    
    func mubWebView(_ webView: MubWebView, didFinishLoading url: URL?) {
        addHistoryEntry()
        checkButtons()
        print("oweifjaweofij")
    }
    
    // MARK: - Search Field
    @IBAction func searchFieldAction(_ sender: Any) {
        if searchField.stringValue.isValidURL{
            webView!.load(URLRequest(url: URL(string: searchField.stringValue)!))
        } else {
            webView!.load(URLRequest(url: URL(string: "https://www.google.com/search?client=mubser&q=\(searchField.stringValue.encodeToURL)")!))
        }
    }
    
    @IBAction func searchFieldValueDidUpdate(_ sender: Any) {
        let entry = (sender as? APSuggestionsWindowController)?.selectedSuggestion()
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
                suggestionsController = APSuggestionsWindowController()
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
}
