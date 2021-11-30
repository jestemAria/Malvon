//
//  MubViewController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 29/11/2021.
//

// https://www.google.com/s2/favicons?domain=

import Cocoa
import MubWebView
import WebKit
import APSuggestions

class MubViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, NSSearchFieldDelegate {
    
    @IBOutlet weak var webView: MubWebView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var websiteTitle: NSTextField!
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var faviconImageView: NSImageView!
    
    @IBOutlet weak var tabStackView: NSStackView!
    @IBOutlet weak var sideView: NSView!
    
    var suggestions = [String]()
    private var suggestionsController: APSuggestionsWindowController?
    private var skipNextSuggestion = false
    private var window: NSWindow = NSWindow()
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        window = self.view.window!
        tabStackView.layer?.backgroundColor = NSColor.black.cgColor
        sideView.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APsuggestionCellNib = "SearchCell"
        
        searchField.delegate = self
        (searchField.cell as? NSSearchFieldCell)?.searchButtonCell?.isTransparent = true
        (searchField.cell as? NSSearchFieldCell)?.cancelButtonCell?.isTransparent = true
        progressIndicator.alphaValue = 0.7
        
        // Enable stuff
        webView.enableAdblock()
        webView.enableConfigurations()
        
        webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        if webView.canGoBack { webView.goBack() }
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func refreshButton(_ sender: NSButton) {
        if sender.image == NSImage(named: NSImage.refreshTemplateName) {
            webView.reload()
            sender.image = NSImage(named: NSImage.stopProgressTemplateName)
        } else {
            webView.stopLoading()
            sender.image = NSImage(named: NSImage.refreshTemplateName)
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressIndicator.isHidden = false
            refreshButton.image = NSImage(named: NSImage.stopProgressTemplateName)
            
            print(self.webView.estimatedProgress)
            self.progressIndicator.doubleValue = (self.webView.estimatedProgress * 100) + 10
            progressIndicator.increment(by: 50)
            progressIndicator.usesThreadedAnimation = true
            if progressIndicator.doubleValue == 100 {
                progressIndicator.doubleValue = 0
                progressIndicator.isHidden = true
                refreshButton.image = NSImage(named: NSImage.refreshTemplateName)
            }
        } else if keyPath == "title" {
            websiteTitle.stringValue = webView.title!
            guard let webViewURL = webView.url?.absoluteString else { return }
            let url = URL(string: "https://www.google.com/s2/favicons?sz=30&domain_url=" + webViewURL)
            let data = try? Data(contentsOf: url!)
            faviconImageView.image = NSImage(data: data!)
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        searchField.stringValue = self.webView.url!.absoluteString
    }
    
    @IBAction func searchFieldAction(_ sender: Any) {
        webView.load(URLRequest(url: URL(string: self.searchField.stringValue)!))
    }
    
    @IBAction func searchFieldValueDidUpdate(_ sender: Any) {
        let entry = (sender as? APSuggestionsWindowController)?.selectedSuggestion()
        if entry != nil && !entry!.isEmpty {
            let fieldEditor: NSText? = window.fieldEditor(false, for: searchField)
            if fieldEditor != nil {
                updateFieldEditor(fieldEditor, withSuggestion: entry![kSuggestionLabel] as? String)
            }
        }
    }
    
    func suggestions(forText text: String?) -> [[String: Any]]? {
        var testVals = [String]()
        
        SearchSuggestions.getQuerySuggestions(text!) { [unowned self] (suggestions, error) in
            if let suggestions = suggestions, suggestions.count > 0 {
                self.suggestions = suggestions
            } else {
                print(error?.localizedDescription)
            }
        }
        
        
        // Search the known image URLs array for matches.
        var suggestions = [[String: Any]]()
        suggestions.reserveCapacity(1)
        
        for val in self.suggestions {
            if text != nil && text != "" && (val.hasPrefix(text ?? "") || val.uppercased().hasPrefix(text?.uppercased() ?? "")) {
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
            if suggestions != nil && suggestions!.count > 0 {
                // We have at least 1 suggestion. Update the field editor to the first suggestion and show the suggestions window.
                let suggestion = suggestions![0]
                
                updateFieldEditor(fieldEditor, withSuggestion: suggestion[kSuggestionLabel] as? String)
                suggestionsController?.setSuggestions(suggestions!)
                if !(suggestionsController?.window?.isVisible ?? false) {
                    suggestionsController?.begin(for: (control as? NSSearchField))
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
                suggestionsController?.action = #selector(self.searchFieldValueDidUpdate(_:))
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
            if suggestionsController != nil && suggestionsController!.window != nil && suggestionsController!.window!.isVisible {
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

