# Bookmark Saver Browser Extension

A Chrome/Firefox browser extension that saves bookmarks directly to your personal knowledge base at iagocavalcante.com, similar to Pocket functionality.

## Features

- 🔖 **One-click saving** - Save the current page with a single click
- 🏷️ **Smart tagging** - Auto-suggests tags based on website domain and URL
- 📝 **Rich metadata** - Extracts page title, description, and reading time
- ✅ **Duplicate detection** - Shows if a page is already bookmarked
- 🎨 **Clean UI** - Modern, responsive popup interface
- 🌙 **Dark mode** - Automatic dark/light theme support
- 🔍 **Context menu** - Right-click to save bookmarks
- 📊 **Visual indicators** - Badge shows bookmark status

## Installation

### Development (Chrome)

1. Open Chrome and go to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select the `browser-extension` folder
4. The extension will appear in your toolbar

### Development (Firefox)

1. Open Firefox and go to `about:debugging`
2. Click "This Firefox" in the sidebar
3. Click "Load Temporary Add-on"
4. Select any file in the `browser-extension` folder

## Usage

### First Time Setup

1. Install the extension
2. Click the extension icon in your toolbar
3. If not logged in, click "Open Login Page" to authenticate
4. Once logged in, you can start saving bookmarks!

### Saving Bookmarks

1. Navigate to any webpage you want to save
2. Click the extension icon
3. The popup will auto-fill the title and URL
4. Optionally add:
   - Description/notes
   - Tags (comma-separated)
   - Mark as favorite
5. Click "Save Bookmark"

### Smart Features

- **Auto-tagging**: The extension suggests tags based on the website:
  - GitHub → `github, code`
  - Stack Overflow → `stackoverflow, programming`
  - Medium → `article, blog`
  - YouTube → `video, tutorial`

- **Bookmark Status**: The extension badge shows:
  - ✓ Green badge = Page is already bookmarked
  - No badge = Page not bookmarked

- **Metadata Extraction**: Automatically extracts:
  - Page description from meta tags
  - Estimated reading time
  - Suggested keywords

## API Integration

The extension uses the bookmark API at `/api/bookmarks` with these endpoints:

- `GET /api/bookmarks` - List bookmarks
- `POST /api/bookmarks` - Create bookmark
- `GET /api/bookmarks-stats` - Get user stats
- `GET /api/health` - Check API status

### Authentication

Uses session-based authentication. Users must be logged in to iagocavalcante.com for the extension to work.

## Files Structure

```
browser-extension/
├── manifest.json          # Extension configuration
├── popup.html             # Main popup interface
├── popup.css              # Popup styling
├── popup.js               # Popup logic and API calls
├── content.js             # Content script for metadata extraction
├── background.js          # Service worker for background tasks
├── icons/                 # Extension icons (add your icons here)
└── README.md              # This file
```

## Development

### Adding Features

1. **New API endpoints**: Update `popup.js` with new API calls
2. **UI changes**: Modify `popup.html` and `popup.css`
3. **Background tasks**: Add functionality to `background.js`
4. **Page interaction**: Extend `content.js` for page analysis

### Testing

1. Make changes to the code
2. Go to `chrome://extensions/`
3. Click the refresh button on your extension
4. Test the functionality

### Publishing

1. Create icons (16x16, 48x48, 128x128 PNG files) in the `icons/` folder
2. Update `manifest.json` with final details
3. Zip the entire folder
4. Submit to Chrome Web Store or Firefox Add-ons

## Permissions Explained

- `activeTab`: Access current tab information
- `storage`: Store extension settings
- `host_permissions`: Make API calls to iagocavalcante.com

## Browser Compatibility

- ✅ Chrome (Manifest V3)
- ✅ Firefox (with minor modifications)
- ✅ Edge (Chromium-based)
- ⚠️ Safari (requires conversion to Safari Web Extension format)

## Troubleshooting

### Extension not working
- Check if you're logged in to iagocavalcante.com
- Open browser developer tools and check for console errors
- Verify the API is accessible

### Bookmarks not saving
- Ensure you have a stable internet connection
- Check if the API is responding (test `/api/health`)
- Verify authentication status

### Missing metadata
- Some websites block content scripts
- Metadata extraction may fail on certain sites
- Manual entry is always available

This extension provides a seamless way to build your personal knowledge base directly from your browser, making it easy to save and organize the content that matters to you!
