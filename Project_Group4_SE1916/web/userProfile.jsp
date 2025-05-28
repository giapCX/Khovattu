<%-- 
    Document   : user_profile
    Created on : 26 May 2025, 02:00 PM
    Author     : YourName
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="Dal.DBContext" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ Người dùng - Hệ thống Quản lý Vật tư</title>

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

        .dark-mode {
            background-color: #1a202c;
            color: #e2e8f0;
        }

        .dark-mode .card {
            background-color: #2d3748;
            color: #e2e8f0;
            border-color: #4a5568;
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

    <!-- Main Content -->
    <main class="flex-1 p-8">
        <div class="max-w-md mx-auto card bg-white dark:bg-gray-800 p-6">
            <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">Hồ sơ Người dùng</h2>

            <%
                String fullName = "", email = "", phone = "", address = "", status = "", roleName = "";
                java.sql.Date dob = null;

                Connection conn = null;
                try {
                    conn = new DBContext().getConnection();
                    if (conn == null) {
                        throw new SQLException("Database connection failed.");
                    }

                    String sql = "SELECT u.full_name, u.email, u.phone_number, u.address, u.date_of_birth, u.status, r.role_name " +
                                 "FROM Users u " +
                                 "JOIN UserRoles ur ON u.user_id = ur.user_id " +
                                 "JOIN Roles r ON ur.role_id = r.role_id " +
                                 "WHERE u.username = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setString(1, username);
                        ResultSet rs = stmt.executeQuery();
                        if (rs.next()) {
                            fullName = rs.getString("full_name");
                            email = rs.getString("email");
                            phone = rs.getString("phone_number");
                            address = rs.getString("address");
                            dob = rs.getDate("date_of_birth");
                            status = rs.getString("status");
                            roleName = rs.getString("role_name");
                        } else {
                            throw new SQLException("User not found.");
                        }
                    }
                } catch (SQLException e) {
                    request.setAttribute("error", "Error fetching profile: " + e.getMessage());
                } finally {
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                            System.err.println("Error closing connection: " + e.getMessage());
                        }
                    }
                }
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

                // Determine the homepage based on role
                String homePage = "${pageContext.request.contextPath}/home.jsp"; // Default fallback
                if ("Direction".equalsIgnoreCase(roleName)) {
                    homePage = "${pageContext.request.contextPath}/view/direction/directionDashboard.jsp";
                } else if ("Employee".equalsIgnoreCase(roleName)) {
                    homePage = "${pageContext.request.contextPath}/view/employee/employeeDashboard.jsp";
                } else if ("Warehouse".equalsIgnoreCase(roleName)) {
                    homePage = "${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp";
                }
            %>

            <% if (request.getAttribute("error") != null) { %>
                <div class="text-red-500 mb-4 text-center"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("message") != null) { %>
                <div class="text-green-500 mb-4 text-center"><%= request.getAttribute("message") %></div>
            <% } %>

            <form action="Update_profile_servlet" method="post" class="space-y-4">
                <div class="space-y-2">
                    <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Tên người dùng</label>
                    <input type="text" id="username" name="username" value="<%= username %>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white" readonly>
                </div>

                <div class="space-y-2">
                    <label for="fullName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Họ và tên</label>
                    <input type="text" id="fullName" name="fullName" value="<%= fullName != null ? fullName : "" %>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" required>
                </div>

                <div class="space-y-2">
                    <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
                    <input type="email" id="email" name="email" value="<%= email != null ? email : "" %>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" required>
                </div>

                <div class="space-y-2">
                    <label for="phone" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Số điện thoại</label>
                    <input type="text" id="phone" name="phone" value="<%= phone != null ? phone : "" %>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="address" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Địa chỉ</label>
                    <input type="text" id="address" name="address" value="<%= address != null ? address : "" %>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" required>
                </div>

                <div class="space-y-2">
                    <label for="dob" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Ngày sinh</label>
                    <input type="date" id="dob" name="dob" value="<%= dob != null ? sdf.format(dob) : "" %>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>

                <div class="space-y-2">
                    <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Trạng thái</label>
                    <select id="status" name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <option value="active" <%= "active".equals(status) ? "selected" : "" %>>Active</option>
                        <option value="inactive" <%= "inactive".equals(status) ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>

                <div class="space-y-2">
                    <label for="role" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Vai trò</label>
                    <input type="text" id="role" name="role" value="<%= roleName != null ? roleName : "" %>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white" readonly>
                </div>

                <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full">Lưu thay đổi</button>
            </form>

            <div class="mt-4 flex justify-center space-x-4">
                <a href="<%= homePage %>" class="text-primary-600 dark:text-primary-400 hover:underline">Quay lại Trang chủ</a>
                <a href="logout" class="text-red-500 hover:underline">Đăng xuất</a>
            </div>
        </div>
    </main>

    <!-- JavaScript for Dark Mode -->
    <script>
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
    </script>
</body>
</html>