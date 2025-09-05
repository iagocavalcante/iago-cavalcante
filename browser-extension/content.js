// Content script to extract page metadata

// Listen for messages from popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.action === 'getPageMeta') {
        const metadata = extractPageMetadata();
        sendResponse(metadata);
        return true; // Keep message channel open for async response
    }
});

function extractPageMetadata() {
    // Get page description from meta tags
    const description = getMetaContent('description') ||
                       getMetaContent('og:description') ||
                       getMetaContent('twitter:description') ||
                       extractFirstParagraph();

    // Get reading time estimate
    const readingTime = estimateReadingTime();

    // Extract keywords/tags
    const keywords = getMetaContent('keywords');
    const suggestedTags = keywords ? keywords.split(',').map(k => k.trim()) : [];

    return {
        description: description?.substring(0, 500) || '', // Limit description length
        readingTime: readingTime,
        suggestedTags: suggestedTags.slice(0, 5) // Limit to 5 suggested tags
    };
}

function getMetaContent(name) {
    const meta = document.querySelector(`meta[name="${name}"], meta[property="${name}"]`);
    return meta ? meta.getAttribute('content') : null;
}

function extractFirstParagraph() {
    // Try to find the first meaningful paragraph
    const paragraphs = document.querySelectorAll('p');

    for (const p of paragraphs) {
        const text = p.textContent.trim();
        if (text.length > 50 && text.length < 500) {
            return text;
        }
    }

    return '';
}

function estimateReadingTime() {
    // Estimate reading time based on word count
    // Average reading speed: 200 words per minute
    const text = document.body.textContent || '';
    const wordCount = text.split(/\s+/).length;
    const readingTime = Math.ceil(wordCount / 200);

    return Math.max(1, readingTime); // Minimum 1 minute
}

// Optional: Add visual indicator when page is bookmarked
function addBookmarkIndicator() {
    // This could add a small visual indicator to show the page is bookmarked
    // Implementation depends on the design requirements
}
