#  MAWebView

A `WKWebView` subclass that displays interactive web content, enables content blocking, uses private features and more



## Declaration

```Swift
public  class  MAWebView: WKWebView, WKUIDelegate, WKNavigationDelegate {
```
  
## Overview

`MAWebView` is a subclass of `WKWebview`. It is becasically a `WKWebView`, but with more features. It has Content Blocking; which can block ads and trackers. It uses private API’s, which can increase the speed of loading and much more. 

## Functions

  
#### initializeWebView

This will setup the webView. It will add the nessary observers, and handlers. And configure the will webView.
```Swift
public func initializeWebView() { ... }
```

#### removeWebview


This will remove all the observers and handlers on the webView, it will also de-configure the webview and remove it from the superview. 
```Swift
public  func  removeWebview() { ... }
```

#### enableAdblock


This will add the content blocking JSON script into the webView. The content blocking script is provided by [Brave](https://raw.githubusercontent.com/brave/brave-ios/development/Client/WebFilters/ContentBlocker/Lists/block-ads.json)

```Swift
public  func  enableAdblock() { ... }
```

#### enableConfigurations


This will enable the private API’s of `WKWebView`. This will make the loading faster and enable more features.

```Swift
public  func  enableConfigurations() { ... }
```

  

## Delegate

