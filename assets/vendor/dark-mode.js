const localStorageKey = 'theme';

const isDark = () => {
	if (localStorage.getItem(localStorageKey) === 'dark') return true;
	if (localStorage.getItem(localStorageKey) === 'light') return false;
	return window.matchMedia('(prefers-color-scheme: dark)').matches;
}

const toggleVisibility = (dark) => {
	const themeToggleDarkIcon = document.getElementById('theme-toggle-dark-icon');
	const themeToggleLightIcon = document.getElementById('theme-toggle-light-icon');
	if (themeToggleDarkIcon == null || themeToggleLightIcon == null) return;

	if (dark) {
		themeToggleDarkIcon.classList.remove('hidden');
		themeToggleLightIcon.classList.add('hidden');
		document.documentElement.classList.add('dark');
	} else {
		themeToggleDarkIcon.classList.add('hidden');
		themeToggleLightIcon.classList.remove('hidden');
		document.documentElement.classList.remove('dark');
	}

	try { localStorage.setItem(localStorageKey, dark ? 'dark' : 'light') } catch (_err) { }
}

const handleThemeToggle = () => {
	const newDark = !isDark();
	toggleVisibility(newDark);
}

const darkModeHook = {
	mounted() {
		// Set initial state
		toggleVisibility(isDark());

		// Add click listener to this element
		this.el.addEventListener('click', handleThemeToggle);
	},
	destroyed() {
		// Clean up listener
		this.el.removeEventListener('click', handleThemeToggle);
	}
}

export default darkModeHook;
