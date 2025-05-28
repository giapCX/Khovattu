<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng quan Nhân viên Công ty - Hệ thống Quản lý Vật tư</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: {
                            50: '#f0f9ff', 100: '#e0f2fe', 200: '#bae6fd', 300: '#7dd3fc',
                            400: '#38bdf8', 500: '#0ea5e9', 600: '#0284c7', 700: '#0369a1',
                            800: '#075985', 900: '#0c4a6e'
                        },
                        secondary: {
                            50: '#f5f3ff', 100: '#ede9fe', 200: '#ddd6fe', 300: '#c4b5fd',
                            400: '#a78bfa', 500: '#8b5cf6', 600: '#7c3aed', 700: '#6d28d9',
                            800: '#5b21b6', 900: '#4c1d95'
                        }
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif']
                    }
                }
            }
        }
    </script>
    <!-- Toastify -->
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
        }

        .sidebar {
            background: linear-gradient(195deg, #1e3a8a, #3b82f6);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14), 0 7px 10px -5px rgba(59, 130, 246, 0.4);
            transition: all 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);
            transform: translateX(-100%);
        }

        .sidebar.active {
            transform: translateX(0);
        }

        main, footer {
            transition: all 0.3s ease;
        }

        .sidebar.active ~ main,
        .sidebar.active ~ footer {
            margin-left: 18rem;
        }

        .nav-item {
            transition: all 0.2s ease;
            border-radius: 0.5rem;
        }

        .nav-item:hover {
            background: linear-gradient(to right, #3b82f6, #8b5cf6);
            transform: translateX(5px) scale(1.02);
        }

        .nav-item.active {
            background-color: rgba(255, 255, 255, 0.2);
            font-weight: 600;
        }

        .card {
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border-radius: 1rem;
            border: 1px solid #e5e7eb;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }

        .btn-primary {
            background: linear-gradient(to right, #3b82f6, #6366f1);
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            transform: scale(1.05);
            box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.3), 0 4px 6px -2px rgba(59, 130, 246, 0.1);
        }

        .table-container {
            border-radius: 1rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border: 1px solid #e5e7eb;
        }

        .table th {
            background-color: #3b82f6;
            color: white;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
            padding: 1rem;
        }

        .table td {
            padding: 1rem;
        }

        .table tr:nth-child(even) {
            background-color: #f8fafc;
        }

        .badge {
            padding: 0.25rem 0.75rem;
            border-radius: 0.5rem;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .badge-success {
            background-color: #d1fae5;
            color: #065f46;
        }

        .badge-warning {
            background-color: #fef3c7;
            color: #92400e;
        }

        .badge-danger {
            background-color: #fee2e2;
            color: #991b1b;
        }

        .dark-mode {
            background-color: #1a202c;
            color: #e2e8f0;
        }

        .dark-mode .card,
        .dark-mode .table-container {
            background-color: #2d3748;
            color: #e2e8f0;
            border-color: #4a5568;
        }

        .dark-mode .table tr:nth-child(even) {
            background-color: #2d3748;
        }

        .dark-mode .table tr {
            border-color: #4a5568;
        }

        .dark-mode .sidebar {
            background: linear-gradient(195deg, #111827, #1f2937);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14), 0 7px 10px -5px rgba(31, 41, 55, 0.4);
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animate-fadeInUp {
            animation: fadeInUp 0.5s ease-out forwards;
        }

        .delay-100 { animation-delay: 0.1s; }
        .delay-200 { animation-delay: 0.2s; }
        .delay-300 { animation-delay: 0.3s; }

        th.asc::after {
            content: ' ↑';
            font-size: 0.75rem;
        }

        th.desc::after {
            content: ' ↓';
            font-size: 0.75rem;
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                max-width: 280px;
                z-index: 50;
            }
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <!-- Sidebar -->
    <aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50 hidden">
        <div class="flex items-center mb-8">
            <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
                <i class="fas fa-boxes text-primary-600 text-2xl"></i>
            </div>
            <h2 class="text-2xl font-bold">QL Vật Tư</h2>
            <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <nav class="space-y-2">
            <a href="${pageContext.request.contextPath}/userProfile.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-user mr-3 w-6 text-center"></i>
                <span class="text-lg">Thông tin cá nhân</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/createRequest.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-file-alt mr-3 w-6 text-center"></i>
                <span class="text-lg">Tạo yêu cầu</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/requestHistory.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-history mr-3 w-6 text-center"></i>
                <span class="text-lg">Lịch sử yêu cầu</span>
                <span class="ml-auto bg-red-500 text-white text-sm px-2 py-1 rounded-full">2</span>
            </a>
        </nav>
        <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
            <a href="${pageContext.request.contextPath}/forgetPassword/changePassword.jsp" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                <i class="fas fa-key mr-3"></i>
                <span class="text-lg">Đổi mật khẩu</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                <i class="fas fa-sign-out-alt mr-3"></i>
                <span class="text-lg">Đăng xuất</span>
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-8 transition-all duration-300">
        <!-- Header -->
        <header class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
            <div class="flex items-center gap-4">
                <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                    <i class="fas fa-bars text-2xl"></i>
                </button>
                <div>
                    <h1 class="text-3xl font-bold text-gray-800 dark:text-white">Tổng quan Nhân viên</h1>
                    <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">Quản lý yêu cầu vật tư</p>
                </div>
            </div>
            <div class="flex items-center space-x-6">
                <div class="relative">
                    <i class="fas fa-bell text-gray-500 hover:text-primary-600 cursor-pointer text-xl"></i>
                    <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">2</span>
                </div>
                <div class="flex items-center">
                    <img src="https://ui-avatars.com/api/?name=Nhân+viên&background=3b82f6&color=fff" 
                         alt="Nhân viên" class="w-10 h-10 rounded-full mr-3">
                    <span class="font-medium text-gray-700 dark:text-white text-lg">Nhân viên</span>
                </div>
                <button id="toggleDarkMode" class="bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600">
                    <i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-xl"></i>
                </button>
            </div>
        </header>

        <!-- Dashboard Stats -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8 mb-8">
            <div class="card bg-white dark:bg-gray-800 animate-fadeInUp">
                <div class="p-6 flex items-start justify-between">
                    <div>
                        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Yêu cầu đã gửi</p>
                        <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">10</h3>
                        <p class="text-sm text-green-500 mt-3"><i class="fas fa-arrow-up mr-1"></i>2 yêu cầu mới</p>
                    </div>
                    <div class="p-4 rounded-full bg-primary-100 dark:bg-primary-900 text-primary-600 dark:text-primary-300">
                        <i class="fas fa-file-alt text-2xl"></i>
                    </div>
                </div>
                <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                    <a href="${pageContext.request.contextPath}/requestHistory.jsp" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Xem lịch sử</a>
                </div>
            </div>
            <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-100">
                <div class="p-6 flex items-start justify-between">
                    <div>
                        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Yêu cầu chờ duyệt</p>
                        <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">3</h3>
                        <p class="text-sm text-yellow-500 mt-3"><i class="fas fa-clock mr-1"></i>Đang chờ xử lý</p>
                    </div>
                    <div class="p-4 rounded-full bg-yellow-100 dark:bg-yellow-900 text-yellow-600 dark:text-yellow-300">
                        <i class="fas fa-clipboard-list text-2xl"></i>
                    </div>
                </div>
                <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                    <a href="${pageContext.request.contextPath}/requestHistory.jsp" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Xem chi tiết</a>
                </div>
            </div>
            <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-200">
                <div class="p-6 flex items-start justify-between">
                    <div>
                        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Yêu cầu được duyệt</p>
                        <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">7</h3>
                        <p class="text-sm text-blue-500 mt-3"><i class="fas fa-check-circle mr-1"></i>Đã hoàn thành</p>
                    </div>
                    <div class="p-4 rounded-full bg-blue-100 dark:bg-blue-900 text-blue-600 dark:text-blue-300">
                        <i class="fas fa-check text-2xl"></i>
                    </div>
                </div>
                <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                    <a href="${pageContext.request.contextPath}/requestHistory.jsp" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Xem tất cả</a>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="mb-8 grid grid-cols-1 sm:grid-cols-2 gap-6">
            <button onclick="window.location.href='${pageContext.request.contextPath}/createRequest.jsp'" 
                    class="btn-primary text-white px-6 py-4 rounded-lg flex flex-col items-center justify-center hover:shadow-lg transition-all">
                <i class="fas fa-file-alt text-3xl mb-3"></i>
                <span class="text-lg">Tạo yêu cầu mới</span>
            </button>
            <button onclick="window.location.href='${pageContext.request.contextPath}/requestRistory.jsp'" 
                    class="btn-primary text-white px-6 py-4 rounded-lg flex flex-col items-center justify-center hover:shadow-lg transition-all">
                <i class="fas fa-history text-3xl mb-3"></i>
                <span class="text-lg">Xem lịch sử yêu cầu</span>
            </button>
        </div>

        <!-- Request History Table -->
        <div class="table-container bg-white dark:bg-gray-800">
            <div class="p-6 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
                <div>
                    <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Lịch sử yêu cầu</h2>
                    <p class="text-sm text-gray-600 dark:text-gray-300">Danh sách các yêu cầu đã gửi</p>
                </div>
                <a href="${pageContext.request.contextPath}/requestHistory.jsp" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">Xem tất cả</a>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full table-auto">
                    <thead>
                        <tr class="bg-primary-600 text-white">
                            <th class="p-4 text-left">Thời gian</th>
                            <th class="p-4 text-left">Loại yêu cầu</th>
                            <th class="p-4 text-left">Nội dung</th>
                            <th class="p-4 text-left">Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="border-b border-gray-200 dark:border-gray-700">
                            <td class="p-4">10:30 23/05/2025</td>
                            <td class="p-4">Yêu cầu xuất kho</td>
                            <td class="p-4">10 bàn gỗ cao cấp</td>
                            <td class="p-4"><span class="badge badge-warning">Chờ duyệt</span></td>
                        </tr>
                        <tr class="border-b border-gray-200 dark:border-gray-700">
                            <td class="p-4">09:15 23/05/2025</td>
                            <td class="p-4">Đề nghị mua vật tư</td>
                            <td class="p-4">5 màn hình LCD 24"</td>
                            <td class="p-4"><span class="badge badge-success">Đã duyệt</span></td>
                        </tr>
                        <tr class="border-b border-gray-200 dark:border-gray-700">
                            <td class="p-4">08:45 23/05/2025</td>
                            <td class="p-4">Đề nghị sửa chữa</td>
                            <td class="p-4">3 bàn phím cơ hỏng</td>
                            <td class="p-4"><span class="badge badge-danger">Bị từ chối</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-100 dark:bg-gray-800 text-center p-6 mt-8 border-t border-gray-200 dark:border-gray-700 transition-all duration-300">
        <p class="text-gray-600 dark:text-gray-300 text-sm">Hệ thống Quản lý Vật tư - Phiên bản 2.0 © 2025 | <a href="mailto:support@company.com" class="text-primary-600 dark:text-primary-400 hover:underline text-base">Liên hệ hỗ trợ</a></p>
    </footer>

    <!-- JavaScript -->
    <script>
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
        const toggleDarkMode = document.getElementById('toggleDarkMode');
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

        // Toast Notification
        function showToast(message, bgColor = "#3b82f6") {
            Toastify({
                text: message,
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: bgColor,
                stopOnFocus: true,
                className: "rounded-lg shadow-lg",
                style: {borderRadius: "0.5rem"}
            }).showToast();
        }

        // Table Sorting
        document.querySelectorAll('th').forEach(th => {
            th.addEventListener('click', () => {
                const table = th.closest('table');
                const tbody = table.querySelector('tbody');
                const rows = Array.from(tbody.querySelectorAll('tr'));
                const columnIndex = th.cellIndex;
                const isNumeric = columnIndex === 0; // Only "Thời gian" is sortable as text for simplicity
                const isAsc = th.classList.toggle('asc');
                th.classList.toggle('desc', !isAsc);
                table.querySelectorAll('th').forEach(header => {
                    if (header !== th)
                        header.classList.remove('asc', 'desc');
                });
                rows.sort((a, b) => {
                    let aValue = a.cells[columnIndex].textContent;
                    let bValue = b.cells[columnIndex].textContent;
                    if (isNumeric) {
                        aValue = new Date(aValue).getTime();
                        bValue = new Date(bValue).getTime();
                        return isAsc ? aValue - bValue : bValue - aValue;
                    }
                    return isAsc ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue);
                });
                tbody.innerHTML = '';
                rows.forEach(row => tbody.appendChild(row));
            });
        });
    </script>
</body>
</html>