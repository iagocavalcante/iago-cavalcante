// Background script for the bookmark extension (compatible with both Chrome and Firefox)
const isFirefox = typeof browser !== "undefined";
const extensionAPI = isFirefox ? browser : chrome;

// Handle extension installation
extensionAPI.runtime.onInstalled.addListener(() => {
  console.log("Bookmark Saver extension installed");

  // Create context menu (only if supported)
  if (extensionAPI.contextMenus) {
    extensionAPI.contextMenus.create({
      id: "saveBookmark",
      title: "Save to Bookmarks",
      contexts: ["page", "link"],
    });
  }
});

// Handle context menu clicks (only if supported)
if (extensionAPI.contextMenus) {
  extensionAPI.contextMenus.onClicked.addListener((info, tab) => {
    if (info.menuItemId === "saveBookmark") {
      // Open popup or save bookmark directly
      if (extensionAPI.action) {
        extensionAPI.action.openPopup();
      } else if (extensionAPI.browserAction) {
        // Firefox fallback
        extensionAPI.tabs.create({
          url: extensionAPI.runtime.getURL("popup.html"),
        });
      }
    }
  });
}

// Handle tab updates to check bookmark status
extensionAPI.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === "complete" && tab.url) {
    checkBookmarkStatus(tab.url, tabId);
  }
});

// Check if current page is bookmarked and update badge
async function checkBookmarkStatus(url, tabId) {
  try {
    // Skip checking for non-web URLs
    if (!url.startsWith("http")) return;

    const API_URL = "https://iagocavalcante.com/api";
    const response = await fetch(
      `${API_URL}/bookmarks?search=${encodeURIComponent(url)}`,
      {
        method: "GET",
        credentials: "include",
      },
    );

    if (response.ok) {
      const data = await response.json();
      const isBookmarked = data.data.some((bookmark) => bookmark.url === url);

      if (isBookmarked) {
        // Show bookmarked indicator
        const actionAPI = extensionAPI.action || extensionAPI.browserAction;
        if (actionAPI) {
          actionAPI.setBadgeText({ text: "✓", tabId: tabId });
          actionAPI.setBadgeBackgroundColor({ color: "#28a745", tabId: tabId });
          actionAPI.setTitle({
            title: "This page is bookmarked - Click to manage",
            tabId: tabId,
          });
        }
      } else {
        // Clear badge
        const actionAPI = extensionAPI.action || extensionAPI.browserAction;
        if (actionAPI) {
          actionAPI.setBadgeText({ text: "", tabId: tabId });
          actionAPI.setTitle({
            title: "Save bookmark to your knowledge base",
            tabId: tabId,
          });
        }
      }
    }
  } catch (error) {
    console.log("Could not check bookmark status:", error);
    // Clear badge on error
    const actionAPI = extensionAPI.action || extensionAPI.browserAction;
    if (actionAPI) {
      actionAPI.setBadgeText({ text: "", tabId: tabId });
    }
  }
}

// Handle keyboard shortcuts (if any are defined in manifest)
if (extensionAPI.commands) {
  extensionAPI.commands.onCommand.addListener((command) => {
    if (command === "save-bookmark") {
      const actionAPI = extensionAPI.action || extensionAPI.browserAction;
      if (actionAPI && actionAPI.openPopup) {
        actionAPI.openPopup();
      } else {
        extensionAPI.tabs.create({
          url: extensionAPI.runtime.getURL("popup.html"),
        });
      }
    }
  });
}

// Handle browser action click (when popup fails to open)
const actionAPI = extensionAPI.action || extensionAPI.browserAction;
if (actionAPI && actionAPI.onClicked) {
  actionAPI.onClicked.addListener((tab) => {
    // Fallback: create a new tab with the bookmark form
    extensionAPI.tabs.create({
      url: extensionAPI.runtime.getURL("popup.html"),
    });
  });
}
