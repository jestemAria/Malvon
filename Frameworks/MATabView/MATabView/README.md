# MATabView

## How to use this?

- In your main.storyboard, create 2 new views. One view for the tab bar and one view for the tab view
- In your `ViewController.swift`, add this code
```swift
tabView.create(tab: MATab(NSView()))
```

## Delegate Methods
The delegate methods are easy to understand, so no need to explain :)
```swift
@objc optional func tabView(_ tabView: MATabView, willSelect tab: MATab)
@objc optional func tabView(_ tabView: MATabView, didSelect tab: MATab)


@objc optional func tabView(_ tabView: MATabView, willClose tab: MATab)
@objc optional func tabView(_ tabView: MATabView, didClose tab: MATab)


@objc optional func tabView(_ tabView: MATabView, willCreateTab tab: MATab)
@objc optional func tabView(_ tabView: MATabView, didCreateTab tab: MATab)


@objc optional func tabView(noMoreTabsLeft tabView: MATabView)
```
