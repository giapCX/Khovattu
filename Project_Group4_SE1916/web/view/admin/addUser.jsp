<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Người dùng Mới - Hệ thống Quản lý Vật tư</title>
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
            background-color: rgba(255, 255, 255, 0.1);
            transform: translateX(5px);
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

        .btn-secondary {
            background: linear-gradient(to right, #6b7280, #9ca3af);
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            transform: scale(1.05);
            box-shadow: 0 10px 15px -3px rgba(107, 114, 128, 0.3), 0 4px 6px -2px rgba(107, 114, 128, 0.1);
        }

        .dark-mode {
            background-color: #1a202c;
            color: #e2e8f0;
        }

        .dark-mode .card {
            background-color: #2d3748;
            color: #e2e8f0;
            border-color: #4a5568;
        }

        .dark-mode .sidebar {
            background: linear-gradient(195deg, #111827, #1f2937);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14), 0 7px 10px -5px rgba(31, 41, 55, 0.4);
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
    <!-- Session Check -->
    <%
        String username = (String) session.getAttribute("username");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <!-- Sidebar -->
    <aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50">
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
            <a href="${pageContext.request.contextPath}/home.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-tachometer-alt mr-3 w-6 text-center"></i>
                <span class="text-lg">Tổng quan</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/inventory.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-warehouse mr-3 w-6 text-center"></i>
                <span class="text-lg">Quản lý kho</span>
                <span class="ml-auto bg-white bg-opacity-20 text-sm px-2 py-1 rounded-full">5</span>
            </a>
            <a href="${pageContext.request.contextPath}/items.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-box-open mr-3 w-6 text-center"></i>
                <span class="text-lg">Danh mục vật tư</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/orders.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-clipboard-list mr-3 w-6 text-center"></i>
                <span class="text-lg">Đơn hàng</span>
                <span class="ml-auto bg-red-500 text-white text-sm px-2 py-1 rounded-full">3</span>
            </a>
            <a href="${pageContext.request.contextPath}/reports.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-chart-bar mr-3 w-6 text-center"></i>
                <span class="text-lg">Báo cáo</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/listuser" class="nav-item active flex items-center p-3">
                <i class="fas fa-users mr-3 w-6 text-center"></i>
                <span class="text-lg">Danh sách người dùng</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/userProfile.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-user mr-3 w-6 text-center"></i>
                <span class="text-lg">Thông tin cá nhân</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
        </nav>
        <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
            <a href="logout" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                <i class="fas fa-sign-out-alt mr-3"></i>
                <span class="text-lg">Đăng xuất</span>
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-8 transition-all duration-300">
        <div class="max-w-md mx-auto card bg-white dark:bg-gray-800 p-6">
            <div class="flex items-center gap-4 mb-6">
                <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                    <i class="fas fa-bars text-2xl"></i>
                </button>
                <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Thêm Người dùng Mới</h2>
            </div>

            <form action="adduser" method="post" class="space-y-4">
                <div class="space-y-2">
                    <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Tên người dùng</label>
                    <input type="text" id="username" name="username" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Mật khẩu</label>
                    <input type="password" id="password" name="password" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="fullName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Họ và tên</label>
                    <input type="text" id="fullName" name="fullName" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="address" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Địa chỉ</label>
                    <input type="text" id="address" name="address" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
                    <input type="email" id="email" name="email" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="phone" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Số điện thoại</label>
                    <input type="text" id="phone" name="phone" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="dob" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Ngày sinh</label>
                    <input type="date" id="dob" name="dob" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Trạng thái</label>
                    <select id="status" name="status" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                </div>

                <div class="space-y-2">
                    <label for="roleId" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Vai trò</label>
                    <select id="roleId" name="roleId" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <c:forEach var="role" items="${roles}">
                            <option value="${role.roleId}">${role.roleName}</option>
                        </c:forEach>
                    </select>
                </div>

                <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full flex items-center justify-center">
                    <i class="fas fa-plus-circle mr-2"></i> Thêm Người dùng
                </button>
            </form>

            <div class="mt-4 flex justify-center">
                <a href="listuser" class="btn-secondary text-white px-6 py-3 rounded-lg">Quay lại Danh sách</a>
            </div>
        </div>
    </main>

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

        // Client-side validation
        const form = document.querySelector('form');
        form.addEventListener('submit', (e) => {
            const email = document.getElementById('email').value;
            const phone = document.getElementById('phone').value;
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const phoneRegex = /^\d{10}$/;

            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('Vui lòng nhập email hợp lệ!');
                return;
            }

            if (phone && !phoneRegex.test(phone)) {
                e.preventDefault();
                alert('Số điện thoại phải có đúng 10 chữ số!');
                return;
            }
        });
    </script>
</body>
</html>