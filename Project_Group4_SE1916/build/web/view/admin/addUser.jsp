<%@page contentType="text/html; charset=UTF-8" language="java"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New User</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
</head>
<body class="bg-gray-50 min-h-screen antialiased">
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
%>

<c:choose>
    <c:when test="${role == 'admin'}">
        <jsp:include page="/view/sidebar/sidebarAdmin.jsp"/>
    </c:when>
    <c:when test="${role == 'direction'}">
        <jsp:include page="/view/sidebar/sidebarDirection.jsp"/>
    </c:when>
    <c:when test="${role == 'warehouse'}">
        <jsp:include page="/view/sidebar/sidebarWarehouse.jsp"/>
    </c:when>
    <c:when test="${role == 'employee'}">
        <jsp:include page="/view/sidebar/sidebarEmployee.jsp"/>
    </c:when>
</c:choose>

<main class="p-8 lg:ml-72 transition-all duration-300">
    <div class="max-w-3xl mx-auto card bg-white p-6">
        <div class="flex items-center gap-4 mb-6">
            <button id="toggleSidebarMobile" class="text-gray-700"><i class="fas fa-bars text-2xl"></i></button>
            <h2 class="text-2xl font-bold">Add New User</h2>
        </div>

        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                <strong>Error:</strong> ${error}
            </div>
        </c:if>

        <form action="adduser" method="post" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
                    <input type="text" id="username" name="username" required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
                    <input type="password" id="password" name="password" readonly class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
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
                    <c:forEach var="roleObj" items="${roles}">
                        <option value="${roleObj.roleId}">${roleObj.roleName}</option>
                    </c:forEach>
                </select>
            </div>

            <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full">
                <i class="fas fa-plus-circle mr-2"></i> Add User
            </button>
        </form>

        <div class="mt-4 text-center">
            <a href="listuser" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to List</a>
        </div>
    </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const sidebar  = document.getElementById('sidebar');
    const openBtn  = document.getElementById('toggleSidebarMobile');
    const closeBtn = document.getElementById('toggleSidebar');
    if (openBtn)  openBtn.addEventListener('click', () => sidebar.classList.toggle('-translate-x-full'));
    if (closeBtn) closeBtn.addEventListener('click', () => sidebar.classList.add('-translate-x-full'));
});
</script>
<script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
</body>
</html>
