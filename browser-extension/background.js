// Background service worker for the bookmark extension

// Handle extension installation
chrome.runtime.onInstalled.addListener(() => {
    console.log('Bookmark Saver extension installed');

    // Create context menu
    chrome.contextMenus.create({
        id: 'saveBookmark',
        title: 'Save to Bookmarks',
        contexts: ['page', 'link']
    });
});

// Handle context menu clicks
chrome.contextMenus.onClicked.addListener((info, tab) => {
    if (info.menuItemId === 'saveBookmark') {
        // Open popup or save bookmark directly
        chrome.action.openPopup();
    }
});

// Handle tab updates to check bookmark status
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.status === 'complete' && tab.url) {
        checkBookmarkStatus(tab.url, tabId);
    }
});

// Check if current page is bookmarked and update badge
async function checkBookmarkStatus(url, tabId) {
    try {
        // Skip checking for non-web URLs
        if (!url.startsWith('http')) return;

        const API_URL = 'https://iagocavalcante.com/api';
        const response = await fetch(`${API_URL}/bookmarks?search=${encodeURIComponent(url)}`, {
            method: 'GET',
            credentials: 'include'
        });

        if (response.ok) {
            const data = await response.json();
            const isBookmarked = data.data.some(bookmark => bookmark.url === url);

            if (isBookmarked) {
                // Show bookmarked indicator
                chrome.action.setBadgeText({ text: '✓', tabId: tabId });
                chrome.action.setBadgeBackgroundColor({ color: '#28a745', tabId: tabId });
                chrome.action.setTitle({
                    title: 'This page is bookmarked - Click to manage',
                    tabId: tabId
                });
            } else {
                // Clear badge
                chrome.action.setBadgeText({ text: '', tabId: tabId });
                chrome.action.setTitle({
                    title: 'Save bookmark to your knowledge base',
                    tabId: tabId
                });
            }
        }
    } catch (error) {
        console.log('Could not check bookmark status:', error);
        // Clear badge on error
        chrome.action.setBadgeText({ text: '', tabId: tabId });
    }
}

// Handle keyboard shortcuts (if any are defined in manifest)
chrome.commands?.onCommand.addListener((command) => {
    if (command === 'save-bookmark') {
        chrome.action.openPopup();
    }
});

// Handle browser action click (when popup fails to open)
chrome.action.onClicked.addListener((tab) => {
    // Fallback: create a new tab with the bookmark form
    chrome.tabs.create({
        url: chrome.runtime.getURL('popup.html')
    });
});
