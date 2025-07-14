<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${constructionSite == null ? 'Add Construction Site' : 'Edit Construction Site'}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
    <style>
        .error-message {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 0.75rem;
            border-radius: 0.375rem;
            margin-bottom: 1rem;
            text-align: center;
        }
        .action-button {
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            font-size: 0.875rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
            display: inline-flex;
            align-items: center;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <%
        String role = (String) session.getAttribute("role");
        if (role == null || (!role.equals("admin") && !role.equals("direction"))) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
    %>
    <div class="flex">
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
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">${constructionSite == null ? 'Add New Construction Site' : 'Edit Construction Site'}</h2>
                </div>
                <c:if test="${not empty sessionScope.error}">
                    <div class="error-message">${sessionScope.error}</div>
                    <c:remove var="error" scope="session"/>
                </c:if>
                <form action="EditConstructionSiteServlet" method="post" class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow border border-gray-200 dark:border-gray-700">
                    <c:if test="${constructionSite != null}">
                        <input type="hidden" name="siteId" value="${constructionSite.siteId}"/>
                    </c:if>
                    <div class="grid grid-cols-1 gap-4">
                        <div>
                            <label for="siteName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Site Name</label>
                            <input type="text" id="siteName" name="siteName" value="${constructionSite.siteName}" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"/>
                        </div>
                        <div>
                            <label for="address" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Address</label>
                            <textarea id="address" name="address" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">${constructionSite.address}</textarea>
                        </div>
                        <div>
                            <label for="managerId" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Manager</label>
                            <select id="managerId" name="managerId" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                                <option value="">Select Manager</option>
                                <c:forEach var="manager" items="${managers}">
                                    <option value="${manager[0]}" ${constructionSite.managerId == manager[0] ? 'selected' : ''}>${manager[1]}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label for="startDate" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Start Date</label>
                            <input type="date" id="startDate" name="startDate" value="${constructionSite.startDate}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"/>
                        </div>
                        <div>
                            <label for="endDate" class="block text-sm font-medium text-gray-700 dark:text-gray-300">End Date</label>
                            <input type="date" id="endDate" name="endDate" value="${constructionSite.endDate}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"/>
                        </div>
                        <div>
                            <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                            <select id="status" name="status" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                                <option value="ongoing" ${constructionSite.status == 'ongoing' ? 'selected' : ''}>Ongoing</option>
                                <option value="completed" ${constructionSite.status == 'completed' ? 'selected' : ''}>Completed</option>
                                <option value="paused" ${constructionSite.status == 'paused' ? 'selected' : ''}>Paused</option>
                                <option value="cancel" ${constructionSite.status == 'cancel' ? 'selected' : ''}>Cancel</option>
                            </select>
                        </div>
                        <div>
                            <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Note</label>
                            <textarea id="note" name="note" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">${constructionSite.note}</textarea>
                        </div>
                    </div>
                    <div class="flex justify-center gap-4 mt-6">
                        <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                            <i class="fas fa-save mr-2"></i> Save
                        </button>
                        <a href="ListConstructionSites" id="cancelButton" class="action-button bg-gray-500 text-white">
                            <i class="fas fa-times mr-2"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </main>
    </div>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const toggleButton = document.getElementById('toggleSidebarMobile');
            const sidebar = document.querySelector('.sidebar');
            if (toggleButton && sidebar) {
                toggleButton.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });
            }
            const cancelButton = document.getElementById('cancelButton');
            if (cancelButton && sidebar) {
                cancelButton.addEventListener('click', (e) => {
                    if (window.innerWidth <= 768 && sidebar.classList.contains('active')) {
                        sidebar.classList.remove('active');
                    }
                });
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/sidebar_darkmode.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
</body>
</html>