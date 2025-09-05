// Configuration
const API_BASE_URL = 'https://iagocavalcante.com/api';
const DEV_API_URL = 'http://localhost:4000/api';

// Use dev URL in development
const API_URL = location.hostname === 'localhost' ? DEV_API_URL : API_BASE_URL;

// DOM elements
const elements = {
    form: document.getElementById('bookmarkForm'),
    loginRequired: document.getElementById('loginRequired'),
    titleInput: document.getElementById('title'),
    urlInput: document.getElementById('url'),
    descriptionInput: document.getElementById('description'),
    tagsInput: document.getElementById('tags'),
    favoriteCheckbox: document.getElementById('favorite'),
    saveBtn: document.getElementById('saveBtn'),
    cancelBtn: document.getElementById('cancelBtn'),
    loginBtn: document.getElementById('loginBtn'),
    successMessage: document.getElementById('successMessage'),
    errorMessage: document.getElementById('errorMessage'),
    errorText: document.getElementById('errorText'),
    btnText: elements.saveBtn?.querySelector('.btn-text'),
    spinner: elements.saveBtn?.querySelector('.spinner')
};

// Initialize popup
document.addEventListener('DOMContentLoaded', async () => {
    await initializePopup();
    setupEventListeners();
});

async function initializePopup() {
    try {
        // Get current tab info
        const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

        if (tab) {
            elements.titleInput.value = tab.title || '';
            elements.urlInput.value = tab.url || '';

            // Try to get page description from content script
            try {
                const response = await chrome.tabs.sendMessage(tab.id, { action: 'getPageMeta' });
                if (response?.description) {
                    elements.descriptionInput.value = response.description;
                }
            } catch (err) {
                console.log('Could not get page metadata:', err);
            }
        }

        // Check if user is authenticated
        const isAuthenticated = await checkAuthentication();

        if (isAuthenticated) {
            showBookmarkForm();

            // Check if this URL is already bookmarked
            await checkIfBookmarked(elements.urlInput.value);
        } else {
            showLoginRequired();
        }

    } catch (error) {
        console.error('Error initializing popup:', error);
        showError('Failed to initialize extension');
    }
}

function setupEventListeners() {
    elements.form?.addEventListener('submit', handleSaveBookmark);
    elements.cancelBtn?.addEventListener('click', () => window.close());
    elements.loginBtn?.addEventListener('click', handleLogin);

    // Auto-suggest tags based on URL domain
    elements.urlInput?.addEventListener('input', suggestTags);
}

async function checkAuthentication() {
    try {
        const response = await fetch(`${API_URL}/bookmarks-stats`, {
            method: 'GET',
            credentials: 'include'
        });

        return response.ok;
    } catch (error) {
        console.error('Auth check failed:', error);
        return false;
    }
}

async function checkIfBookmarked(url) {
    try {
        const response = await fetch(`${API_URL}/bookmarks?search=${encodeURIComponent(url)}`, {
            method: 'GET',
            credentials: 'include'
        });

        if (response.ok) {
            const data = await response.json();
            const isBookmarked = data.data.some(bookmark => bookmark.url === url);

            if (isBookmarked) {
                elements.saveBtn.innerHTML = '✓ Already Saved';
                elements.saveBtn.disabled = true;
                elements.saveBtn.classList.add('btn-success');
            }
        }
    } catch (error) {
        console.log('Could not check bookmark status:', error);
    }
}

async function handleSaveBookmark(event) {
    event.preventDefault();

    setBtnLoading(true);

    try {
        const formData = new FormData(elements.form);
        const tags = formData.get('tags') ? formData.get('tags').split(',').map(tag => tag.trim()) : [];

        const bookmarkData = {
            title: formData.get('title'),
            url: formData.get('url'),
            description: formData.get('description') || '',
            tags: tags,
            favorite: formData.get('favorite') === 'on',
            source: 'extension'
        };

        const response = await fetch(`${API_URL}/bookmarks`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ bookmark: bookmarkData }),
            credentials: 'include'
        });

        if (response.ok) {
            showSuccess();

            // Update badge or icon to show saved state
            chrome.action.setBadgeText({ text: '✓' });
            chrome.action.setBadgeBackgroundColor({ color: '#28a745' });

            // Close popup after delay
            setTimeout(() => window.close(), 1500);
        } else {
            const errorData = await response.json();
            throw new Error(errorData.error || 'Failed to save bookmark');
        }

    } catch (error) {
        console.error('Save failed:', error);
        showError(error.message);
    } finally {
        setBtnLoading(false);
    }
}

function handleLogin() {
    chrome.tabs.create({
        url: `${API_URL.replace('/api', '')}/admin/login`,
        active: true
    });
    window.close();
}

function suggestTags() {
    const url = elements.urlInput.value;
    if (!url) return;

    try {
        const domain = new URL(url).hostname.toLowerCase();
        const suggestions = [];

        // Domain-based suggestions
        if (domain.includes('github.com')) suggestions.push('github', 'code');
        else if (domain.includes('stackoverflow.com')) suggestions.push('stackoverflow', 'programming');
        else if (domain.includes('medium.com')) suggestions.push('article', 'blog');
        else if (domain.includes('youtube.com')) suggestions.push('video', 'tutorial');
        else if (domain.includes('dev.to')) suggestions.push('dev', 'programming');
        else if (domain.includes('elixir-lang.org')) suggestions.push('elixir', 'docs');
        else if (domain.includes('phoenixframework.org')) suggestions.push('phoenix', 'elixir');

        // URL path-based suggestions
        if (url.includes('/tutorial')) suggestions.push('tutorial');
        if (url.includes('/docs')) suggestions.push('documentation');
        if (url.includes('/blog')) suggestions.push('blog');
        if (url.includes('/api')) suggestions.push('api');

        if (suggestions.length > 0 && !elements.tagsInput.value) {
            elements.tagsInput.placeholder = `Suggested: ${suggestions.join(', ')}`;
        }

    } catch (error) {
        console.log('Could not parse URL for suggestions:', error);
    }
}

function setBtnLoading(loading) {
    if (loading) {
        elements.btnText.style.display = 'none';
        elements.spinner.style.display = 'inline';
        elements.saveBtn.disabled = true;
    } else {
        elements.btnText.style.display = 'inline';
        elements.spinner.style.display = 'none';
        elements.saveBtn.disabled = false;
    }
}

function showBookmarkForm() {
    elements.form.style.display = 'block';
    elements.loginRequired.style.display = 'none';
    elements.successMessage.style.display = 'none';
    elements.errorMessage.style.display = 'none';
}

function showLoginRequired() {
    elements.form.style.display = 'none';
    elements.loginRequired.style.display = 'block';
    elements.successMessage.style.display = 'none';
    elements.errorMessage.style.display = 'none';
}

function showSuccess() {
    elements.form.style.display = 'none';
    elements.loginRequired.style.display = 'none';
    elements.successMessage.style.display = 'block';
    elements.errorMessage.style.display = 'none';
}

function showError(message) {
    elements.errorText.textContent = `❌ ${message}`;
    elements.errorMessage.style.display = 'block';

    // Hide error after 5 seconds
    setTimeout(() => {
        elements.errorMessage.style.display = 'none';
    }, 5000);
}
