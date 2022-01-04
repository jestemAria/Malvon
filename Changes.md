#  Changes

## v1.0.2
**Commit 4:**
    - Fixed a few mistakes
    - Formatted Code
    - Started re-writing the download history view controller
**Commit 3:**
    - Added NSOpenFile for file uploading
    - Commented the code
**Commit 2:**
    - Fixed a small mistake in the auto updater
    - Improved tab switching
    - Fixed a few bugs and crashes
    - Improvments in CPU power and battery life
**Commit 1:**
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
