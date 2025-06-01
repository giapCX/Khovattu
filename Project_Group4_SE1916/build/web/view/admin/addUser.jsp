```jsp
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New User</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap');
        body { font-family: 'Inter', sans-serif; background-color: #f8fafc; }
        .sidebar {
            background: linear-gradient(195deg, #1e3a8a, #3b82f6);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14);
            transition: transform 0.3s ease;
            transform: translateX(-100%);
            width: 18rem;
        }
        .sidebar.active { transform: translateX(0); }
        .sidebar.active ~ main { margin-left: 18rem; }
        .nav-item { transition: all 0.2s ease; border-radius: 0.5rem; }
        .nav-item:hover { background-color: rgba(255, 255, 255, 0.1); transform: translateX(5px); }
        .nav-item.active { background-color: rgba(255, 255, 255, 0.2); font-weight: 600; }
        .card { transition: all 0.3s ease; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border-radius: 1rem; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }
        .btn-primary { background: linear-gradient(to right, #3b82f6, #6366f1); transition: all 0.3s ease; }
        .btn-primary:hover { transform: scale(1.05); box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.3); }
        .btn-secondary { background: linear-gradient(to right, #6b7280, #9ca3af); }
        .btn-secondary:hover { transform: scale(1.05); }
        @media (max-width: 768px) { .sidebar { width: 100%; max-width: 280px; z-index: 50; } }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">
    <% 
        String username = (String) session.getAttribute("username");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <aside id="sidebar" class="sidebar text-white p-6 fixed h-full z-50">
        <div class="flex items-center mb-6">
            <div class="w-10 h-10 rounded-full bg-white flex items-center justify-center mr-3">
                <i class="fas fa-boxes text-blue-600 text-xl"></i>
            </div>
            <h2 class="text-xl font-bold">Material Management</h2>
            <button id="toggleSidebar" class="ml-auto text-white"><i class="fas fa-times"></i></button>
        </div>
        <nav class="space-y-2">
            <a href="${pageContext.request.contextPath}/home.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-tachometer-alt mr-3"></i> Overview
            </a>
            <a href="${pageContext.request.contextPath}/inventory.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-warehouse mr-3"></i> Warehouse <span class="ml-auto bg-white bg-opacity-20 text-sm px-2 py-1 rounded-full">5</span>
            </a>
            <a href="${pageContext.request.contextPath}/items.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-box-open mr-3"></i> Materials
            </a>
            <a href="${pageContext.request.contextPath}/orders.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-clipboard-list mr-3"></i> Order <span class="ml-auto bg-red-500 text-white text-sm px-2 py-1 rounded-full">3</span>
            </a>
            <a href="${pageContext.request.contextPath}/reports.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-chart-bar mr-3"></i> Report
            </a>
            <a href="${pageContext.request.contextPath}/listuser" class="nav-item active flex items-center p-3">
                <i class="fas fa-users mr-3"></i> List User
            </a>
            <a href="${pageContext.request.contextPath}/userProfile.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-user mr-3"></i> Information
            </a>
        </nav>
        <div class="absolute bottom-0 left-0 right-0 p-6">
            <a href="logout" class="flex items-center p-3 hover:bg-white hover:bg-opacity-20"><i class="fas fa-sign-out-alt mr-3"></i> Logout</a>
        </div>
    </aside>
    <main class="p-8 transition-all">
        <div class="max-w-3xl mx-auto card bg-white p-6">
            <div class="flex items-center gap-4 mb-6">
                <button id="toggleSidebarMobile" class="text-gray-700"><i class="fas fa-bars text-2xl"></i></button>
                <h2 class="text-2xl font-bold">Add New User</h2>
            </div>
            <form action="adduser" method="post" class="space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
                        <input type="text" id="username" name="username" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
                        <input type="password" id="password" name="password" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="code" class="block text-sm font-medium text-gray-700">Code</label>
                        <input type="text" id="code" name="code" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div>
                        <label for="fullName" class="block text-sm font-medium text-gray-700">Full Name</label>
                        <input type="text" id="fullName" name="fullName" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
                <div>
                    <label for="address" class="block text-sm font-medium text-gray-700">Address</label>
                    <input type="text" id="address" name="address" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
                        <input type="email" id="email" name="email" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div>
                        <label for="phone" class="block text-sm font-medium text-gray-700">Phone</label>
                        <input type="text" id="phone" name="phone" class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="dob" class="block text-sm font-medium text-gray-700">Date of Birth</label>
                        <input type="date" id="dob" name="dob" class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div>
                        <label for="status" class="block text-sm font-medium text-gray-700">Status</label>
                        <select id="status" name="status" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                </div>
                <div>
                    <label for="roleId" class="block text-sm font-medium text-gray-700">Role</label>
                    <select id="roleId" name="roleId" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                        <c:forEach var="role" items="${roles}">
                            <option value="${role.roleId}">${role.roleName}</option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full"><i class="fas fa-plus-circle mr-2"></i> Add User</button>
            </form>
            <div class="mt-4 text-center">
                <a href="listuser" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to List</a>
            </div>
        </div>
    </main>
</body>
</html>
```