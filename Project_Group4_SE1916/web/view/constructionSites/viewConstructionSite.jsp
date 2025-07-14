<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Construction Site Details</title>
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
        .edit-button {
            background-color: #ffc107;
            color: white;
        }
        .edit-button:hover {
            background-color: #e0a800;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <%
        String role = (String) session.getAttribute("role");
        if (role == null) {
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
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Construction Site Details</h2>
                </div>
                <c:if test="${not empty sessionScope.error}">
                    <div class="error-message">${sessionScope.error}</div>
                    <c:remove var="error" scope="session"/>
                </c:if>
                <c:if test="${constructionSite != null}">
                    <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow border border-gray-200 dark:border-gray-700">
                        <div class="grid grid-cols-1 gap-4">
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">ID:</label>
                                <span class="text-gray-900 dark:text-gray-100">${constructionSite.siteId}</span>
                            </div>
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">Site Name:</label>
                                <span class="text-gray-900 dark:text-gray-100">${constructionSite.siteName}</span>
                            </div>
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">Address:</label>
                                <span class="text-gray-900 dark:text-gray-100">${constructionSite.address}</span>
                            </div>
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">Manager:</label>
                                <span class="text-gray-900 dark:text-gray-100">${managerName}</span>
                            </div>
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">Start Date:</label>
                                <span class="text-gray-900 dark:text-gray-100">${constructionSite.startDate}</span>
                            </div>
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">End Date:</label>
                                <span class="text-gray-900 dark:text-gray-100">${constructionSite.endDate != null ? constructionSite.endDate : 'Not specified'}</span>
                            </div>
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">Status:</label>
                                <span class="text-gray-900 dark:text-gray-100">${constructionSite.status}</span>
                            </div>
                            <div class="flex items-center">
                                <label class="font-medium text-gray-700 dark:text-gray-300 w-32">Note:</label>
                                <span class="text-gray-900 dark:text-gray-100">${constructionSite.note != null ? constructionSite.note : 'No note'}</span>
                            </div>
                        </div>
                        <div class="flex justify-center gap-4 mt-6">
                            <a href="ListConstructionSites" id="backButton" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                                <i class="fas fa-arrow-left mr-2"></i> Back to List
                            </a>
                            <c:if test="${sessionScope.role == 'admin' || sessionScope.role == 'direction'}">
                                <a href="EditConstructionSiteServlet?siteId=${constructionSite.siteId}" class="action-button edit-button">
                                    <i class="fas fa-edit mr-1"></i> Edit
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
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
            const backButton = document.getElementById('backButton');
            if (backButton && sidebar) {
                backButton.addEventListener('click', (e) => {
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