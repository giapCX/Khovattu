<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>List Construction Sites</title>

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
            .badge-success-border-subtle {
                background-color: #ecfdf5;
                color: #047857;
                border: 1px solid #34d399;
            }
            .badge-success-bg-subtle {
                background-color: #bbf7d0;
                color: #065f46;
            }
            .action-button {
                padding: 0.25rem 0.75rem;
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
            .error-message {
                background-color: #fee2e2;
                color: #991b1b;
                padding: 0.75rem;
                border-radius: 0.375rem;
                margin-bottom: 1rem;
                text-align: center;
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">

        <%
            String role = (String) session.getAttribute("role");
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
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <!-- Error Message Display -->
                <c:if test="${not empty sessionScope.error}">
                    <div class="error-message">${sessionScope.error}</div>
                    <c:remove var="error" scope="session"/>
                </c:if>

                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">List Construction Site</h2>
                    </div>
                    <c:if test="${sessionScope.role == 'admin' || sessionScope.role == 'direction'}">
                        <a href="${pageContext.request.contextPath}/EditConstructionSiteServlet" class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                            <i class="fas fa-plus-circle mr-2"></i> Create new construction site
                        </a>
                    </c:if>
                </div>

                <!-- Search and Filter Form -->
                <form action="ListConstructionSites" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <input type="text" name="searchName" placeholder="Search name" value="${param.searchName}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <input type="text" name="searchAddress" placeholder="Search address" value="${param.searchAddress}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <select name="searchStatus" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">All Status</option>
                            <option value="paused" ${param.searchStatus == 'paused' ? 'selected' : ''}>Paused</option>
                            <option value="ongoing" ${param.searchStatus == 'ongoing' ? 'selected' : ''}>Ongoing</option>
                            <option value="completed" ${param.searchStatus == 'completed' ? 'selected' : ''}>Completed</option>
                            <option value="cancel" ${param.searchStatus == 'cancel' ? 'selected' : ''}>Cancel</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                    <a href="${pageContext.request.contextPath}/ListConstructionSites" onclick="event.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;" class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-undo mr-2"></i> Reset form
                    </a>
                </form>

                <!-- Table -->
                <div class="table-container bg-white dark:bg-gray-800">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-primary-600 text-white">
                                    <th class="p-4 text-left">ID</th>
                                    <th class="p-4 text-left">Site Name</th>
                                    <th class="p-4 text-left">Address</th>
                                    <th class="p-4 text-left">Status</th>
                                    <th class="p-4 text-left">Detail</th>
                                    <th class="p-4 text-left">Edit</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty constructionSites}">
                                        <c:forEach var="item" items="${constructionSites}">
                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="p-4 font-medium">${item.siteId}</td>
                                                <td class="p-4 font-medium">${item.siteName}</td>
                                                <td class="p-4 font-medium">${item.address}</td>
                                                <td class="p-4 font-medium">
                                                    <c:choose>
                                                        <c:when test="${item.status == 'cancel'}">
                                                            <span class="badge badge-danger">Cancel</span>
                                                        </c:when>
                                                        <c:when test="${item.status == 'paused'}">
                                                            <span class="badge badge-warning">Paused</span>
                                                        </c:when>
                                                        <c:when test="${item.status == 'ongoing'}">
                                                            <span class="badge badge-success-border-subtle">Ongoing</span>
                                                        </c:when>
                                                        <c:when test="${item.status == 'completed'}">
                                                            <span class="badge badge-success-bg-subtle">Completed</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <a href="ViewConstructionSiteServlet?siteId=${item.siteId}" class="text-primary-600 dark:text-primary-400 hover:underline">Detail</a>
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <c:if test="${sessionScope.role == 'admin' || sessionScope.role == 'direction'}">
                                                        <button onclick="window.location.href='EditConstructionSiteServlet?siteId=${item.siteId}'" class="action-button edit-button">
                                                            <i class="fas fa-edit mr-1"></i> Edit
                                                        </button>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="p-4 text-center text-gray-500 dark:text-gray-400">
                                                No construction site found
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div><br/>

                <!-- Pagination -->
                <div class="pagination flex items-center justify-center space-x-1">
                    <!-- Previous Page -->
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="ListConstructionSites?page=${currentPage - 1}&searchName=${param.searchName}&searchAddress=${param.searchAddress}&searchStatus=${param.searchStatus}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400"><</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed"><</span>
                        </c:otherwise>
                    </c:choose>
                    <!-- Page 1 -->
                    <c:choose>
                        <c:when test="${currentPage == 1}">
                            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
                        </c:when>
                        <c:otherwise>
                            <a href="ListConstructionSites?page=1&searchName=${param.searchName}&searchAddress=${param.searchAddress}&searchStatus=${param.searchStatus}" class="px-3 py-1 rounded border hover:border-blue-500">1</a>
                        </c:otherwise>
                    </c:choose>
                    <!-- Ellipsis if currentPage > 4 -->
                    <c:if test="${currentPage > 4}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <!-- Middle Pages -->
                    <c:forEach var="i" begin="${currentPage - 1 > 1 ? currentPage - 1 : 2}" end="${currentPage + 1 < totalPages ? currentPage + 1 : totalPages - 1}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="ListConstructionSites?page=${i}&searchName=${param.searchName}&searchAddress=${param.searchAddress}&searchStatus=${param.searchStatus}" class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <!-- Ellipsis if currentPage < totalPages - 3 -->
                    <c:if test="${currentPage < totalPages - 3}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <!-- Last Page -->
                    <c:if test="${totalPages > 1}">
                        <c:choose>
                            <c:when test="${currentPage == totalPages}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${totalPages}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="ListConstructionSites?page=${totalPages}&searchName=${param.searchName}&searchAddress=${param.searchAddress}&searchStatus=${param.searchStatus}" class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <!-- Next Page -->
                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="ListConstructionSites?page=${currentPage + 1}&searchName=${param.searchName}&searchAddress=${param.searchAddress}&searchStatus=${param.searchStatus}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">></a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">></span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="mt-6 flex justify-center">
                    <c:choose>
                        <c:when test="${role == 'admin'}">
                            <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                        </c:when>
                        <c:when test="${role == 'direction'}">
                            <a href="${pageContext.request.contextPath}/view/direction/directionDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                        </c:when>
                        <c:when test="${role == 'warehouse'}">
                            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                        </c:when>
                        <c:when test="${role == 'employee'}">
                            <a href="${pageContext.request.contextPath}/view/employee/employeeDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                        </c:when>
                    </c:choose>
                </div>
            </div>
        </main>

        <!-- JavaScript -->
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                const form = document.querySelector('form');
                form.addEventListener('submit', function (e) {
                    // No date validation needed as startDate and endDate are not in the form
                });
            });
        </script>

        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>