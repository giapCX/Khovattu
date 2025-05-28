<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tổng quan Giám đốc - Hệ thống Quản lý Vật tư</title>
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
        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
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
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .animate-fadeInUp {
                animation: fadeInUp 0.5s ease-out forwards;
            }

            .delay-100 {
                animation-delay: 0.1s;
            }
            .delay-200 {
                animation-delay: 0.2s;
            }
            .delay-300 {
                animation-delay: 0.3s;
            }

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
                <a href="${pageContext.request.contextPath}/categories.jsp" class="nav-item flex items-center p-3">
                    <i class="fas fa-box-open mr-3 w-6 text-center"></i>
                    <span class="text-lg">Danh mục vật tư</span>
                    <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/suppliers.jsp" class="nav-item flex items-center p-3">
                    <i class="fas fa-truck mr-3 w-6 text-center"></i>
                    <span class="text-lg">Danh sách nhà cung cấp</span>
                    <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/pendingRequests.jsp" class="nav-item active flex items-center p-3">
                    <i class="fas fa-clipboard-list mr-3 w-6 text-center"></i>
                    <span class="text-lg">Phê duyệt yêu cầu</span>
                    <span class="ml-auto bg-red-500 text-white text-sm px-2 py-1 rounded-full">3</span>
                </a>
                <a href="${pageContext.request.contextPath}/listUser.jsp" class="nav-item flex items-center p-3">
                    <i class="fas fa-users mr-3 w-6 text-center"></i>
                    <span class="text-lg">Danh sách nhân viên</span>
                    <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
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
                        <h1 class="text-3xl font-bold text-gray-800 dark:text-white">Tổng quan Giám đốc</h1>
                        <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">Thống kê và phê duyệt yêu cầu vật tư</p>
                    </div>
                </div>
                <div class="flex items-center space-x-6">
                    <div class="relative">
                        <i class="fas fa-bell text-gray-500 hover:text-primary-600 cursor-pointer text-xl"></i>
                        <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">3</span>
                    </div>
                    <div class="flex items-center">
                        <img src="https://ui-avatars.com/api/?name=Giám đốc&background=3b82f6&color=fff" 
                             alt="Giám đốc" class="w-10 h-10 rounded-full mr-3">
                        <span class="font-medium text-gray-700 dark:text-white text-lg">Giám đốc</span>
                    </div>
                    <button id="toggleDarkMode" class="bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600">
                        <i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-xl"></i>
                    </button>
                </div>
            </header>

            <!-- Dashboard Stats -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-8">
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Tổng vật tư</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">1,284</h3>
                            <p class="text-sm text-green-500 mt-3"><i class="fas fa-arrow-up mr-1"></i>12% tháng trước</p>
                        </div>
                        <div class="p-4 rounded-full bg-primary-100 dark:bg-primary-900 text-primary-600 dark:text-primary-300">
                            <i class="fas fa-boxes text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/inventoryReport.jsp" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Xem báo cáo</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-100">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Yêu cầu chờ duyệt</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">5</h3>
                            <p class="text-sm text-yellow-500 mt-3"><i class="fas fa-clock mr-1"></i>Đang chờ xử lý</p>
                        </div>
                        <div class="p-4 rounded-full bg-yellow-100 dark:bg-yellow-900 text-yellow-600 dark:text-yellow-300">
                            <i class="fas fa-clipboard-list text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/pendingRequests.jsp" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Duyệt yêu cầu</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-200">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Chi phí kỳ gần nhất</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">500M VND</h3>
                            <p class="text-sm text-blue-500 mt-3"><i class="fas fa-dollar-sign mr-1"></i>Mua & Sửa chữa</p>
                        </div>
                        <div class="p-4 rounded-full bg-blue-100 dark:bg-blue-900 text-blue-600 dark:text-blue-300">
                            <i class="fas fa-money-bill-wave text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/costReport.jsp" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Xem báo cáo</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-300">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Tồn kho thấp</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">8</h3>
                            <p class="text-sm text-red-500 mt-3"><i class="fas fa-exclamation-circle mr-1"></i>Cần bổ sung</p>
                        </div>
                        <div class="p-4 rounded-full bg-red-100 dark:bg-red-900 text-red-600 dark:text-red-red-300">
                            <i class="fas fa-exclamation text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/lowInventoryReport.jsp" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Xem chi tiết</a>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
                <div class="lg:col-span-2 card bg-white dark:bg-gray-800 p-6">
                    <div class="flex justify-between items-center mb-4">
                        <div>
                            <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Xu hướng Xuất - Nhập - Tồn</h2>
                            <p class="text-sm text-gray-600 dark:text-gray-300">Theo dõi nhập/xuất kho theo thời gian</p>
                        </div>
                        <div class="flex space-x-2">
                            <button class="chart-filter px-4 py-2 text-sm bg-primary-100 dark:bg-primary-900 text-primary-600 dark:text-primary-300 rounded-full active">Tuần</button>
                            <button class="chart-filter px-4 py-2 text-sm bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-full">Tháng</button>
                            <button class="chart-filter px-4 py-2 text-sm bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-full">Năm</button>
                        </div>
                    </div>
                    <canvas id="inventoryChart" class="border rounded-lg"></canvas>
                    <button onclick="exportToExcel('inventoryChart')" class="mt-4 px-4 py-2 bg-primary-600 text-white rounded-lg">Xuất Excel</button>
                </div>
                <div class="card bg-white dark:bg-gray-800 p-6">
                    <div class="mb-4">
                        <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Phân bố chi phí</h2>
                        <p class="text-sm text-gray-600 dark:text-gray-300">Chi phí mua và sửa chữa vật tư</p>
                    </div>
                    <canvas id="costChart" class="border rounded-lg"></canvas>
                    <button onclick="exportToExcel('costChart')" class="mt-4 px-4 py-2 bg-primary-600 text-white rounded-lg">Xuất Excel</button>
                </div>
            </div>

            <!-- Request Management Table -->
            <div class="table-container bg-white dark:bg-gray-800 mb-8">
                <div class="p-6 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
                    <div>
                        <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Yêu cầu chờ duyệt</h2>
                        <p class="text-sm text-gray-600 dark:text-gray-300">Danh sách yêu cầu xuất/mua/sửa vật tư</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/pendingRequests.jsp" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">Xem tất cả</a>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full table-auto">
                        <thead>
                            <tr class="bg-primary-600 text-white">
                                <th class="p-4 text-left">Thời gian</th>
                                <th class="p-4 text-left">Loại yêu cầu</th>
                                <th class="p-4 text-left">Người yêu cầu</th>
                                <th class="p-4 text-left">Nội dung</th>
                                <th class="p-4 text-left">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <td class="p-4">10:30 23/05/2025</td>
                                <td class="p-4">Yêu cầu xuất kho</td>
                                <td class="p-4">Nguyễn Văn A</td>
                                <td class="p-4">10 bàn gỗ cao cấp</td>
                                <td class="p-4">
                                    <button onclick="approveRequest(1)" class="btn-primary text-white px-3 py-1 rounded">Phê duyệt</button>
                                    <button onclick="rejectRequest(1)" class="bg-red-500 text-white px-3 py-1 rounded ml-2">Từ chối</button>
                                </td>
                            </tr>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <td class="p-4">09:15 23/05/2025</td>
                                <td class="p-4">Đề nghị mua vật tư</td>
                                <td class="p-4">Phòng IT</td>
                                <td class="p-4">5 màn hình LCD 24"</td>
                                <td class="p-4">
                                    <button onclick="approveRequest(2)" class="btn-primary text-white px-3 py-1 rounded">Phê duyệt</button>
                                    <button onclick="rejectRequest(2)" class="bg-red-500 text-white px-3 py-1 rounded ml-2">Từ chối</button>
                                </td>
                            </tr>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <td class="p-4">08:45 23/05/2025</td>
                                <td class="p-4">Đề nghị sửa chữa</td>
                                <td class="p-4">Nguyễn Thị B</td>
                                <td class="p-4">3 bàn phím cơ hỏng</td>
                                <td class="p-4">
                                    <button onclick="approveRequest(3)" class="btn-primary text-white px-3 py-1 rounded">Phê duyệt</button>
                                    <button onclick="rejectRequest(3)" class="bg-red-500 text-white px-3 py-1 rounded ml-2">Từ chối</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Request History Table -->
            <div class="table-container bg-white dark:bg-gray-800">
                <div class="p-6 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
                    <div>
                        <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Lịch sử yêu cầu</h2>
                        <p class="text-sm text-gray-600 dark:text-gray-300">Lịch sử yêu cầu xuất/mua/sửa vật tư</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/requestHistory.jsp" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">Xem tất cả</a>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full table-auto">
                        <thead>
                            <tr class="bg-primary-600 text-white">
                                <th class="p-4 text-left">Thời gian</th>
                                <th class="p-4 text-left">Loại yêu cầu</th>
                                <th class="p-4 text-left">Phòng ban</th>
                                <th class="p-4 text-left">Nội dung</th>
                                <th class="p-4 text-left">Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <td class="p-4">15:20 22/05/2025</td>
                                <td class="p-4">Yêu cầu xuất kho</td>
                                <td class="p-4">Phòng Kỹ thuật</td>
                                <td class="p-4">20 ghế xoay</td>
                                <td class="p-4"><span class="badge badge-success">Đã phê duyệt</span></td>
                            </tr>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <td class="p-4">14:00 22/05/2025</td>
                                <td class="p-4">Đề nghị mua vật tư</td>
                                <td class="p-4">Phòng Hành chính</td>
                                <td class="p-4">10 bàn họp</td>
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

            // Approve/Reject Request
            function approveRequest(id) {
                showToast(`Yêu cầu #${id} đã được phê duyệt`, "#10b981");
                // Backend API call to update request status
            }

            function rejectRequest(id) {
                const reason = prompt('Lý do từ chối:');
                if (reason) {
                    showToast(`Yêu cầu #${id} đã bị từ chối: ${reason}`, "#ef4444");
                    // Backend API call to update request status
                }
            }

            // Export to Excel
            function exportToExcel(chartId) {
                showToast(`Đang xuất báo cáo ra Excel...`);
                // Backend call to generate Excel file
            }

            // Inventory Chart
            const inventoryCtx = document.getElementById('inventoryChart').getContext('2d');
            const inventoryChart = new Chart(inventoryCtx, {
                type: 'line',
                data: {
                    labels: ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'],
                    datasets: [
                        {
                            label: 'Tồn kho',
                            data: [1200, 1150, 1100, 1050, 1000, 950, 900],
                            borderColor: '#3b82f6',
                            backgroundColor: 'rgba(59, 130, 246, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: 'Nhập kho',
                            data: [200, 150, 100, 80, 50, 30, 10],
                            borderColor: '#10b981',
                            backgroundColor: 'rgba(16, 185, 129, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: 'Xuất kho',
                            data: [50, 70, 90, 120, 150, 100, 80],
                            borderColor: '#ef4444',
                            backgroundColor: 'rgba(239, 68, 68, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {position: 'top', labels: {usePointStyle: true, padding: 20}},
                        tooltip: {enabled: true, mode: 'index', intersect: false}
                    },
                    scales: {
                        y: {beginAtZero: false, grid: {drawBorder: false}},
                        x: {grid: {display: false}}
                    }
                }
            });

            // Cost Chart
            const costCtx = document.getElementById('costChart').getContext('2d');
            new Chart(costCtx, {
                type: 'pie',
                data: {
                    labels: ['Mua mới', 'Sửa chữa', 'Khác'],
                    datasets: [{
                            data: [60, 30, 10],
                            backgroundColor: ['#3b82f6', '#10b981', '#f87171'],
                            borderWidth: 0
                        }]
                },
                options: {
                    responsive: true,
                    plugins: {legend: {position: 'bottom', labels: {usePointStyle: true}}}
                }
            });

            // Chart Filter
            document.querySelectorAll('.chart-filter').forEach(button => {
                button.addEventListener('click', () => {
                    document.querySelectorAll('.chart-filter').forEach(btn => btn.classList.remove('active'));
                    button.classList.add('active');
                    const period = button.textContent;
                    // Update inventory chart data based on period (Week/Month/Year)
                    let newData;
                    if (period === 'Tuần') {
                        newData = {
                            labels: ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'],
                            datasets: inventoryChart.data.datasets
                        };
                    } else if (period === 'Tháng') {
                        newData = {
                            labels: ['T1', 'T2', 'T3', 'T4'],
                            datasets: [
                                {...inventoryChart.data.datasets[0], data: [1200, 1100, 1000, 900]},
                                {...inventoryChart.data.datasets[1], data: [200, 150, 100, 50]},
                                {...inventoryChart.data.datasets[2], data: [50, 70, 90, 120]}
                            ]
                        };
                    } else {
                        newData = {
                            labels: ['2023', '2024', '2025'],
                            datasets: [
                                {...inventoryChart.data.datasets[0], data: [1300, 1250, 1200]},
                                {...inventoryChart.data.datasets[1], data: [300, 250, 200]},
                                {...inventoryChart.data.datasets[2], data: [100, 80, 60]}
                            ]
                        };
                    }
                    inventoryChart.data = newData;
                    inventoryChart.update();
                    showToast(`Đã cập nhật biểu đồ cho ${period}`);
                });
            });

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