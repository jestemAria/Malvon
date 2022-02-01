# MATabView

## How to use this?

- In your main.storyboard, create 2 new views. One view for the tab bar and one view for the tab view
- In your `ViewController.swift`, add this code
```swift
tabView.tabBar = tabBarView
// Optional
tabView.delegate = self
```

### Creating a new tab
```swift
let myView = NSView()
tabView.addTabViewItem(tabViewItem: MATabViewItem(view: myView))
```

## Delegate Methods
The delegate methods are easy to understand, so no need to explain :)
```swift
@objc optional func tabView(_ tabView: MATabView, willSelect tabViewItemIndex: Int)
@objc optional func tabView(_ tabView: MATabView, didSelect tabViewItemIndex: Int)


@objc optional func tabView(_ tabView: MATabView, willClose tabViewItemIndex: Int)
@objc optional func tabView(_ tabView: MATabView, didClose tabViewItemIndex: Int)


@objc optional func tabView(_ tabView: MATabView, willCreateTab tabViewItemIndex: Int)
@objc optional func tabView(_ tabView: MATabView, didCreateTab tabViewItemIndex: Int)


@objc optional func tabView(noMoreTabsLeft tabView: MATabView)
```
