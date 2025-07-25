<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa Người dùng - Hệ thống Quản lý Vật tư</title>
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
    </style>
    <%
            String username = (String) session.getAttribute("username");
            if (username == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            String role = (String) session.getAttribute("role");
            if (role == null || !role.equals("admin")) {
                response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
                return;
            }
        %>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    
    <!-- Main Content -->
    <main class="flex-1 p-8">
        <%
                String usernameDisplay = (String) session.getAttribute("username");

                if (usernameDisplay == null) {
                    out.println("<div class='user-info'>Username not found</div>");
                } else {
            %>
            <div class="flex justify-end mb-4">
                <div class="text-gray-700 dark:text-white font-semibold">
                    Welcome, <%= usernameDisplay%>
                </div>
            </div>
            <% }%>
        <div class="max-w-md mx-auto card bg-white dark:bg-gray-800 p-6">
            <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">Edit user</h2>

            <form action="edituser" method="post" class="space-y-4">
                <input type="hidden" name="userId" value="${user.userId}" />

                <div class="space-y-2">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Username</label>
                    <p class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white">${user.username}</p>
                </div>

                <div class="space-y-2">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Full Name</label>
                    <p class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white">${user.fullName}</p>
                </div>

                <div class="space-y-2">
                    <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                    <select id="status" name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <option value="active" ${user.status == 'active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${user.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>

                <div class="space-y-2">
                    <label for="roleId" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Role</label>
                    <select id="roleId" name="roleId" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <c:forEach var="role" items="${roles}">
                            <option value="${role.roleId}" ${user.role.roleId == role.roleId ? 'selected' : ''}>${role.roleName}</option>
                        </c:forEach>
                    </select>
                </div>

                <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full">Update</button>
            </form>

            <div class="mt-4 flex justify-center">
                <a href="${pageContext.request.contextPath}/listuser" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to List</a>
            </div>
        </div>
    </main>

</body>
</html>