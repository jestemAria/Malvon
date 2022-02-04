#  Changes

## v1.2
- Updated the constaint layouts
- Fixed bug where closing the first tab will crash the application
- Added an example application
- Made the code more simple
- Added configurations
- Fixed the scrolling issue
- Re-wrote the entire tabing system
- Changed the color of the tab bar items based on appearance
- Used a shared process pool instead of using seperate process pools
- Updated the Unique Web Engine to Parse and Lex Text and Element Nodes
- Fixed the bug where closing the tab may cause the application to crash
- Updated the newtab.html file
- Updated the load time
- Fixed the reopen tab
- Started working on a web browser engine :)
- Added support for re-opening closed tabs
- Fixed the minimize problem
- Made a slight delay when opening new tab and popups to make it load in the background
- Used more tactics to energy saving
- Fixed problem where url from spotlight search wont open 
- Fixed Problem where webview wont autoresize
- Fixed Problem where webview wont get first responder
- Created Scroll View for tab scrolling
- Fixed problems with the cursor
- More improvements with energy usage
- Uses less energy
- Fixed when creating a new tab, it will use 135% of CPU
- Added favicon to the tab bar
- Close button automatically hides and opens
- Added a close button
- Made the tabs look better
- Created a tab bar
- Added retry button to the error page
- Added Error Page for when the webView fails loading a web page
- Fixed problem where video will keep on playing even when closed
- Fixed Window State Problem
- Fixed the search field
- Fixed the bug when closing the first tab, it will close the window
- Created run script to make life easier :)
- Fixed the bug where if you close the first tab it will crash

## v1.0.2 ( **Released** )
- Re-wrote the tabbing system, that will use less power!!!!!
- Pressing `CMD + CNTR + n` will close the tab in the background
- Finished re-writing the downloads history view controller
- Fixed a few errors
- Thinking of changing the way of tabbing
- Fixed a few mistakes
- Formatted Code
- Started re-writing the download history view controller
- Added NSOpenFile for file uploading
- Commented the code
- Fixed a small mistake in the auto updater
- Improved tab switching
- Fixed a few bugs and crashes
- Improvments in CPU power and battery life
- Dark mode for the start page
- More optimization for lower energy usage
- Added exit button for the history view controller
- Started working on preference
- Changed the color of `HoverButton`
- Pressing `CMD + OPT + n` will pause all videos that are playing in current tab and switch to the next tab
- When switching and creating a new tab, a black screen will appear (Only works when using keyboard shortcuts) ( You can disable this feature via preferences)

## v1.0.1 ( **Released** )
- Double Click ( Maximize Window )
- Added startpage instead of using google.com
- Close tab button on the tab popover
- Open the tabs by pressing `CMD+Y`
- Removed the `format` menu bar item
- Removed the `Hide Toolbar` and `Customize Toolbar` menu bar item
- Changed the hover style of the refresh button to the ones on the back/forward buttons
- CreateTab button is now a `HoverButton`
- Search Suggestions list will have a different style
- Created a close button beside the search field
- Fixed the contraints and layout of the search field
- Shows a window instead of alert for the updater
- Re-wrote all the files in the `Utilities` Folder
- Created an `MATools` Framework and moved all the file in the `Utilities` folder there
- Created a Malvon Updater Application


## v1.0.0 ( **Released** )
- Back/Forward/Refresh Buttons
- Tab **Popover** (we have used a `NSPopover` instead of `TabBar` for more web content)
- Search Suggestions (the search bar can show suggestions)
- Automatic URL formatting (eg. `youtube.com` -> `https://www.youtube.com`)
- Automatic Updater ( Without relaunching!! )
- Anything a normal web browser does basically ( back, forward, refresh, search suggestions etc.)
