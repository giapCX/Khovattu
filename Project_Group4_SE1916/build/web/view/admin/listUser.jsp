<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách Người dùng - Hệ thống Quản lý Vật tư</title>
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

        .btn-danger {
            background: linear-gradient(to right, #ef4444, #f87171);
            transition: all 0.3s ease;
        }

        .btn-danger:hover {
            transform: scale(1.05);
            box-shadow: 0 10px 15px -3px rgba(239, 68, 68, 0.3), 0 4px 6px -2px rgba(239, 68, 68, 0.1);
        }

        .dark-mode {
            background-color: #1a202c;
            color: #e2e8f0;
        }

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

        th.asc::after {
            content: ' ↑';
            font-size: 0.75rem;
        }

        th.desc::after {
            content: ' ↓';
            font-size: 0.75rem;
        }

        .pagination a, .pagination span {
            padding: 0.5rem 1rem;
            margin: 0 0.25rem;
            border-radius: 0.5rem;
            transition: all 0.3s ease;
        }

        .pagination a {
            background-color: #e5e7eb;
            color: #374151;
        }

        .pagination a:hover {
            background-color: #d1d5db;
            transform: scale(1.05);
        }

        .pagination span {
            background-color: #3b82f6;
            color: white;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                max-width: 280px;
                z-index: 50;
            }

            .table-container {
                overflow-x: auto;
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
        if (request.getAttribute("data") == null && request.getParameter("fromServlet") == null) {
            response.sendRedirect("listuser?fromServlet=true");
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
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                <i class="fas fa-sign-out-alt mr-3"></i>
                <span class="text-lg">Đăng xuất</span>
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-8 transition-all duration-300">
        <div class="max-w-6xl mx-auto">
            <div class="flex justify-between items-center mb-6">
                <div class="flex items-center gap-4">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Danh sách Người dùng</h2>
                </div>
                <a href="adduser" class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                    <i class="fas fa-plus-circle mr-2"></i> Thêm Người dùng Mới
                </a>
            </div>

            <!-- Search and Filter Form -->
            <form action="listuser" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                <div class="flex-1 min-w-[200px]">
                    <input type="text" name="search" placeholder="Tìm kiếm theo tên người dùng hoặc họ tên" value="${param.search}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>
                <div class="flex-1 min-w-[150px]">
                    <select name="roleId" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <option value="">Tất cả Vai trò</option>
                        <c:forEach var="role" items="${roles}">
                            <option value="${role.roleId}" ${param.roleId == role.roleId ? "selected" : ""}>${role.roleName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="flex-1 min-w-[150px]">
                    <select name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <option value="">Tất cả Trạng thái</option>
                        <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
                <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                    <i class="fas fa-search mr-2"></i> Tìm kiếm
                </button>
            </form>

            <!-- Table -->
            <div class="table-container bg-white dark:bg-gray-800">
                <div class="overflow-x-auto">
                    <table class="w-full table-auto">
                        <thead>
                            <tr class="bg-primary-600 text-white">
                                <th class="p-4 text-left">Tên người dùng</th>
                                <th class="p-4 text-left">Họ và tên</th>
                                <th class="p-4 text-left">Mã người dùng</th>
                                <th class="p-4 text-left">Địa chỉ</th>
                                <th class="p-4 text-left">Email</th>
                                <th class="p-4 text-left">Số điện thoại</th>
                                <th class="p-4 text-left">Vai trò</th>
                                <th class="p-4 text-left">Trạng thái</th>
                                <th class="p-4 text-left">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${data}">
                                <tr class="border-b border-gray-200 dark:border-gray-700">
                                    <td class="p-4 font-medium">${item.username}</td>
                                    <td class="p-4">${item.fullName}</td>
                                    <td class="p-4">${item.code}</td>
                                    <td class="p-4">${item.address}</td>
                                    <td class="p-4">${item.email}</td>
                                    <td class="p-4">${item.phone}</td>
                                    <td class="p-4">${item.role.roleName}</td>
                                    <td class="p-4">${item.status}</td>
                                    <td class="p-4 flex gap-2">
                                        <a href="edituser?userId=${item.userId}" class="text-primary-600 dark:text-primary-400 hover:underline">Chỉnh sửa</a>
                                       
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="mt-6 flex justify-center pagination">
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span>[${i}]</span>
                            </c:when>
                            <c:otherwise>
                                <a href="listuser?page=${i}&search=${param.search}&roleId=${param.roleId}&status=${param.status}">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
            </c:if>

            <div class="mt-6 flex justify-center">
                <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Quay lại Trang chủ</a>
            </div>
        </div>
    </main>

</body>
</html>