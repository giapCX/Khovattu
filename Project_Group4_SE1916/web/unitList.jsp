
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Unit List</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Custom CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                background-color: #f0f2f5; /* Matches bg-gray-50 */
                color: #1a1a1a;
            }
            .container {
                margin: 0 auto;
                background-color: #fff;
                padding: 20px;
                border-radius: 0 0 0.5rem 0.5rem; /* Rounded corners at the bottom */
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }
            h1 {
                text-align: center;
                color: #1f2937; /* Matches text-gray-800 */
                margin-bottom: 20px;
            }
            .filter-form {
                display: flex;
                gap: 15px;
                margin-bottom: 20px;
                flex-wrap: wrap;
                align-items: center;
            }
            .filter-form label {
                font-weight: bold;
                color: #374151; /* Matches text-gray-700 */
            }
            .filter-form input[type="text"],
            .filter-form select {
                padding: 8px;
                border: 1px solid #d1d5db; /* Matches border-gray-300 */
                border-radius: 0.5rem; /* Rounded corners */
                font-size: 14px;
                width: 100%;
                max-width: 200px;
                background-color: #fff;
                transition: border-color 0.2s, box-shadow 0.2s;
            }
            .filter-form input[type="text"]:focus,
            .filter-form select:focus {
                outline: none;
                border-color: #2563eb; /* Matches focus:ring-primary-500 */
                box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
            }
            .filter-form input[type="submit"] {
                padding: 8px 16px;
                background-color: #4f46e5; /* Matches bg-indigo-600 */
                color: #fff;
                border: none;
                border-radius: 0.5rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            .filter-form input[type="button"] {
                padding: 8px 16px;
                background-color: #eab308; /* Matches bg-yellow-500 for reset button */
                color: #fff;
                border: none;
                border-radius: 0.5rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            .filter-form input[type="submit"]:hover {
                background-color: #4338ca; /* Darker shade of indigo-600 */
            }
            .filter-form input[type="button"]:hover {
                background-color: #ca8a04; /* Darker shade of yellow-500 */
            }
            .error-message {
                color: #991b1b; /* Matches badge-danger color */
                text-align: center;
                margin-bottom: 15px;
            }
            .table-container {
                background-color: #fff;
                border-radius: 0 0 0.5rem 0.5rem; /* Rounded corners at the bottom */
                overflow: hidden;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 12px;
                text-align: left;
                border-bottom: 1px solid #e5e7eb; /* Matches border-gray-200 */
            }
            th {
                background-color: #0284C7; /* Matches bg-primary-600 */
                color: #fff;
                font-weight: bold;
                cursor: pointer;
            }
            th.sortable:hover {
                background-color: #0267a0; /* Darker shade for hover */
            }
            tr:nth-child(even) {
                background-color: #f9fafb; /* Matches bg-gray-50 */
            }
            tr:hover {
                background-color: #f3f4f6; /* Matches hover:bg-gray-100 */
            }
            .no-data {
                text-align: center;
                color: #6b7280; /* Matches text-gray-500 */
                padding: 20px;
            }
            .pagination {
                text-align: center;
                margin-top: 20px;
                display: flex;
                justify-content: center;
                gap: 4px;
            }
            .pagination a, .pagination span {
                display: inline-block;
                padding: 8px 12px;
                text-decoration: none;
                color: #2563eb; /* Matches text-primary-600 */
                border: 1px solid #d1d5db; /* Matches border-gray-300 */
                border-radius: 0.5rem;
                transition: background-color 0.3s, border-color 0.3s;
            }
            .pagination a.active, .pagination span.active {
                background-color: #2563eb; /* Matches bg-primary-600 */
                color: #fff;
                border-color: #2563eb;
                font-weight: bold;
            }
            .pagination a:hover {
                background-color: #e5e7eb; /* Matches hover:bg-gray-200 */
                border-color: #2563eb;
            }
            .pagination span.disabled {
                color: #6b7280; /* Matches text-gray-500 */
                background-color: #e5e7eb; /* Matches bg-gray-200 */
                cursor: not-allowed;
            }
            .home-link {
                display: inline-block;
                margin-top: 20px;
                text-align: center;
                color: #2563eb; /* Matches text-primary-600 */
                text-decoration: none;
                font-weight: bold;
            }
            .home-link:hover {
                color: #1d4ed8; /* Darker shade of primary-600 */
                text-decoration: underline;
            }
            .btn-secondary {
                background-color: #eab308; /* Matches bg-yellow-500 */
                color: #fff;
                border-radius: 0.5rem;
                padding: 12px 24px;
                transition: background-color 0.3s;
                margin-top: 20px;
            }
            .btn-add-unit, .btn-edit-unit {
                background-color: #10b981; /* Matches bg-green-500 */
                color: #fff;
                border-radius: 0.5rem;
                padding: 8px 16px;
                transition: background-color 0.3s;
                text-decoration: none;
                font-weight: bold;
                margin-right: 8px;
            }
            .btn-disable-unit, .btn-enable-unit {
                background-color: #f97316; /* Matches bg-orange-500 for Disable */
                color: #fff;
                border-radius: 0.5rem;
                padding: 8px 16px;
                transition: background-color 0.3s;
                text-decoration: none;
                font-weight: bold;
            }
            .btn-enable-unit {
                background-color: #3b82f6; /* Matches bg-blue-500 for Enable */
            }
            .btn-add-unit:hover, .btn-edit-unit:hover {
                background-color: #059669; /* Matches bg-green-600 */
            }
            .btn-disable-unit:hover {
                background-color: #ea580c; /* Darker shade of orange-500 */
            }
            .btn-enable-unit:hover {
                background-color: #2563eb; /* Darker shade of blue-500 */
            }
            .btn-secondary:hover {
                background-color: #ca8a04; /* Darker shade of yellow-500 */
            }
            @media (max-width: 768px) {
                .filter-form {
                    flex-direction: column;
                    align-items: stretch;
                }
                .filter-form input,
                .filter-form select {
                    max-width: none;
                    margin-bottom: 10px;
                }
                table {
                    font-size: 14px;
                }
                .btn-secondary, .btn-add-unit, .btn-edit-unit, .btn-disable-unit, .btn-enable-unit {
                    margin-left: 0;
                    width: 100%;
                    text-align: center;
                    margin-bottom: 8px;
                }
            }
            .button-back {
                justify-self: center;
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String role = (String) session.getAttribute("role");
            String sortByStatus = request.getParameter("sortByStatus");
            if (sortByStatus == null) sortByStatus = "";
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
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Unit List</h2>
                    </div>
                </div>

                <!-- Search Form with Sort -->
                <form action="unit" method="get" class="filter-form">
                    <label for="name">Unit Name:</label>
                    <input type="text" id="name" name="name" value="${fn:escapeXml(name)}" placeholder="Unit Name">
                    <label for="sortByStatus">Sort by Status:</label>
                    <select id="sortByStatus" name="sortByStatus">
                        <option value="">All Status</option>
                        <option value="active" ${sortByStatus == 'active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${sortByStatus == 'inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                    <input type="submit" value="Search">
                    <input type="button" value="Reset" onclick="clearFormAndSubmit();">
                </form>

                <!-- Add Unit Button (Restricted to Admin and Warehouse Roles) -->
                <c:if test="${role == 'admin' || role == 'warehouse'}">
                    <div class="mb-4 add-btn">
                        <a href="${pageContext.request.contextPath}/addUnit" class="btn-add-unit">
                            <i class="fas fa-plus mr-2"></i>Add Unit
                        </a>
                    </div>
                </c:if>

                <!-- Error Message -->
                <c:if test="${not empty errorMessage}">
                    <p class="error-message">${fn:escapeXml(errorMessage)}</p>
                </c:if>

                <!-- Units Table -->
                <div class="table-container">
                    <table>
                        <tr>
                            <th>No.</th>
                            <th>Unit ID</th>
                            <th>Unit Name</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                        <c:choose>
                            <c:when test="${not empty unitData}">
                                <c:forEach items="${unitData}" var="unit" varStatus="loop">
                                    <tr>
                                        <td>${(currentPage - 1) * 10 + loop.index + 1}</td>
                                        <td>${fn:escapeXml(unit.unitId)}</td>
                                        <td>${fn:escapeXml(unit.name)}</td>
                                        <td>${fn:escapeXml(unit.status)}</td>
                                        <td>
                                            <c:if test="${role == 'admin' || role == 'warehouse'}">
                                                <a href="${pageContext.request.contextPath}/editUnit?unitId=${fn:escapeXml(unit.unitId)}" class="btn-edit-unit">
                                                    <i class="fas fa-edit mr-2"></i>Edit
                                                </a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="5" class="no-data">No data found.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 0}">
                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="unit?page=${i}&name=${fn:escapeXml(name)}&sortByStatus=${fn:escapeXml(sortByStatus)}"
                               class="${i == currentPage ? 'active' : ''}">${i}</a>
                        </c:forEach>
                    </div>
                </c:if>

                <%
                    String redirectUrl = "./login.jsp";
                    if (role != null) {
                        switch (role.toLowerCase()) {
                            case "direction":
                                redirectUrl = request.getContextPath() + "/view/direction/directionDashboard.jsp";
                                break;
                            case "employee":
                                redirectUrl = request.getContextPath() + "/view/employee/employeeDashboard.jsp";
                                break;
                            case "warehouse":
                                redirectUrl = request.getContextPath() + "/view/warehouse/warehouseDashboard.jsp";
                                break;
                            case "admin":
                                redirectUrl = request.getContextPath() + "/view/admin/adminDashboard.jsp";
                                break;
                        }
                    }
                %>
                <!-- Back to Home -->
                <div class="button-back">
                    <button onclick="window.location.href = '<%= redirectUrl%>'" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to Home</button>
                </div>
            </div>
        </main>
        <script>
            function clearFormAndSubmit() {
                const form = document.querySelector('.filter-form');
                document.getElementId('name').value = '';
                document.getElementById('sortByStatus').value = '';
                form.submit();
            }
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>