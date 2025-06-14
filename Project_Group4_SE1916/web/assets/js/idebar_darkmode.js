// Toggle Sidebar
const sidebar = document.getElementById('sidebar');
const toggleSidebar = document.getElementById('toggleSidebar');
const toggleSidebarMobile = document.getElementById('toggleSidebarMobile');

function toggleSidebarVisibility() {
    sidebar.classList.toggle('active');
    sidebar.classList.toggle('hidden');
}

toggleSidebar.addEventListener('click', toggleSidebarVisibility);
toggleSidebarMobile.addEventListener('click', toggleSidebarVisibility);

// Initialize sidebar as hidden
sidebar.classList.add('hidden');

// Dark Mode Toggle
const toggleDarkMode = document.createElement('button');
toggleDarkMode.id = 'toggleDarkMode';
toggleDarkMode.className = 'bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600 fixed top-4 right-4 z-50';
toggleDarkMode.innerHTML = '<i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-xl"></i>';
document.body.appendChild(toggleDarkMode);

toggleDarkMode.addEventListener('click', () => {
    document.body.classList.toggle('dark-mode');
    const icon = toggleDarkMode.querySelector('i');
    icon.classList.toggle('fa-moon');
    icon.classList.toggle('fa-sun');
    localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
});

// Load Dark Mode Preference
if (localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    toggleDarkMode.querySelector('i').classList.replace('fa-moon', 'fa-sun');
}



