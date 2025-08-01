<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>List User</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome: icon -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- style CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            .badge {
                padding: 0.25rem 0.75rem;
                border-radius: 0.5rem;
                font-size: 1rem;
                font-weight: 600;
            }

            .badge-success {
                background-color: #d1fae5;
                color: #065f46;
            }

            .badge-danger {
                background-color: #fee2e2;
                color: #991b1b;
            }

            .table-container {
                background: #fff;
                border-radius: 0.5rem;
                overflow: hidden;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            thead {
                background-color: #2563eb !important;
                color: white !important;
            }

            thead th {
                background-color: #2563eb !important;
                color: white !important;
            }

            th {
                padding: 1rem;
                text-align: left;
                font-size: 0.875rem;
                font-weight: 600;
            }

            td {
                padding: 1rem;
                font-size: 0.875rem;
                font-weight: 500;
            }

            tr {
                border-bottom: 1px solid #e5e7eb;
            }

            tr:hover {
                background-color: #f9fafb;
            }

            .pagination {
                display: flex;
                justify-content: center;
                gap: 0.5rem;
                margin-top: 1.5rem;
            }

            .pagination a, .pagination span {
                padding: 0.75rem 1rem;
                border-radius: 0.375rem;
                text-decoration: none;
                color: #ffffff !important;
            }

            .pagination a {
                border: 1px solid #d1d5db;
                background-color: #2563eb;
            }

            .pagination a:hover {
                border-color: #1d4ed8;
                background-color: #1d4ed8;
                color: #ffffff !important;
            }

            .pagination span {
                border: 1px solid #2563eb;
                background-color: #2563eb;
                font-weight: 600;
            }

            .user-info {
                position: absolute;
                top: 1rem;
                right: 3rem;
                /*                color: #ffffff;*/
                font-size: 1rem;
                font-weight: 500;
                /*                background-color: #2563eb;*/
                padding: 0.5rem 1rem;
                border-radius: 0.375rem;
                z-index: 10;
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
            String role = (String) session.getAttribute("role");
            if (role == null || !role.equals("admin")) {
                response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
                return;
            }
            if (request.getAttribute("data") == null && request.getParameter("fromServlet") == null) {
                response.sendRedirect("${pageContext.request.contextPath}/user?fromServlet=true");
                return;
            }
        %>
        <!-- Sidebar -->
        <c:choose>
            <c:when test="${role == 'admin'}">
                <jsp:include page="/view/sidebar/sidebarAdmin.jsp" />
            </c:when>
            <c:when test="${role == 'direction'}">
                <jsp:include page="/view/sidebar/sidebarDirection.jsp" />
            </c:when>
            <c:when test="${role == 'warehouse'}">
                <jsp:include page="/view/sidebar/sidebarWarehouse.jsp" />
            </c:when>
            <c:when test="${role == 'employee'}">
                <jsp:include page="/view/sidebar/sidebarEmployee.jsp" />
            </c:when>
        </c:choose>

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300 relative">
            <!-- User Info at Top Right -->
            <%
                String usernameDisplay = (String) session.getAttribute("username");

                if (usernameDisplay == null) {
                    out.println("<div class='user-info'>Username not found</div>");
                } else {
            %>
            <div class="user-info">
                Welcome, <%= usernameDisplay%>
            </div>
            <% }%>

            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">List User</h2>
                    </div>
                    <a href="adduser" class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                        <i class="fas fa-plus-circle mr-2"></i> Add User
                    </a>
                </div>

                <!-- Search and Filter Form -->
                <form action="${pageContext.request.contextPath}/user" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <input type="text" name="search" placeholder="Enter user name" value="${param.search}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                    </div>
                    <div class="flex-1 min-w-[150px]">
                        <select name="roleId" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">All roles</option>
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}" ${param.roleId == r.roleId ? "selected" : ""}>${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[150px]">
                        <select name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">All status</option>
                            <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                </form>

                <!-- Table -->
                <div class="table-container bg-white dark:bg-gray-800 rounded-lg overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead class="sticky top-0 bg-primary-600 text-white z-10">
                                <tr class="bg-primary-600 text-white">
                                    <th class="p-4 text-left">Username</th>
                                    <th class="p-4 text-left">Full Name</th>
                                    <th class="p-4 text-left">Code</th>
                                    <th class="p-4 text-left">Address</th>
                                    <th class="p-4 text-left">Email</th>
                                    <th class="p-4 text-left">Phone number</th>
                                    <th class="p-4 text-left">Role</th>
                                    <th class="p-4 text-left">Status</th>
                                    <th class="p-4 text-left">Action</th>
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
                                        <td class="p-4">
                                            <c:choose>
                                                <c:when test="${item.status == 'active'}">
                                                    <span class="badge badge-success">Active</span>
                                                </c:when>
                                                <c:when test="${item.status == 'inactive'}">
                                                    <span class="badge badge-danger">Inactive</span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td class="p-4 flex gap-2">
                                            <a href="edituser?userId=${item.userId}" class="text-primary-600 dark:text-primary-400 hover:underline">Edit</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Pagination -->
                <div class="mt-6 flex justify-center pagination">
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-white font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/user?page=${i}&search=${param.search}&roleId=${param.roleId}&status=${param.status}" class="px-3 py-1 rounded border hover:border-blue-500 text-white">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>

                <div class="mt-6 flex justify-center">
                    <a href="${pageContext.request.contextPath}/AdminDashboard" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                </div>
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>