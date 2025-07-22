//Inven.jsp

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Inventory List</title>
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
            .date {
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
            .filter-form input[type="date"],
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
            .filter-form input[type="date"]:focus,
            .filter-form input[type="text"]:focus,
            .filter-form select:focus {
                outline: none;
                border-color: #2563eb; /* Matches focus:ring-primary-500 */
                box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
            }
            .filter-form input[type="submit"] {
                padding: 8px 16px;
                background-color: #2563eb; /* Matches btn-primary / bg-primary-600 */
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
                background-color: #1d4ed8; /* Darker shade of primary-600 */
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
            }
            th.sortable:hover {
                background-color: #1d4ed8; /* Darker shade on hover */
                cursor: pointer;
            }
            tr:nth-child(even) {
                background-color: #f9fafb; /* Matches bg-gray-50 */
            }
            tr:hover {
                background-color: #f3f4f6; /* Matches hover:bg-gray-100 */
            }
            td a {
                color: #2563eb; /* Matches text-primary-600 */
                text-decoration: none;
                font-weight: bold;
            }
            td a:hover {
                color: #1d4ed8; /* Darker shade of primary-600 */
                text-decoration: underline;
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
                .btn-secondary {
                    margin-left: 0;
                    width: 100%;
                    text-align: center;
                }
            }
            .button-back {
                justify-self: center;
            }
        </style>
        <script>
            function clearFormAndSubmit() {
                const form = document.querySelector('.filter-form');
                document.getElementById('materialId').value = '';
                document.getElementById('materialName').value = '';
                document.getElementById('condition').value = '';
                document.getElementById('fromDate').value = '';
                document.getElementById('toDate').value = '';
                form.submit();
            }
        </script>
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
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Inventory List</h2>
                    </div>
                </div>

                <!-- Search Form -->
                <form action="inventory" method="get" class="filter-form">
                    <label for="materialName">Material Name:</label>
                    <input type="text" id="materialName" name="materialName" value="${fn:escapeXml(materialName)}" placeholder="Material Name">
                    <label for="condition">Condition:</label>
<!--                    <input type="text" id="condition" name="condition" value="${fn:escapeXml(condition)}" placeholder="Condition">-->
                    <select name="condition" value="${fn:escapeXml(condition)}" class="form-control">
                        <option value=""> All condition</option>
                        <option value="New" ${fn:escapeXml(condition) == 'New' ? 'selected' : ''}>New</option>
                        <option value="Used" ${fn:escapeXml(condition) == 'Used' ? 'selected' : ''}>Used</option>
                        <option value="Damaged" ${fn:escapeXml(condition) == 'Damaged' ? 'selected' : ''}>Damaged</option>

                    </select>
                    <label for="sortOrder">Sort Quantity:</label>
                    <select id="sortOrder" name="sortOrder" onchange="this.form.submit()" class="bg-white">
                        <option value="" ${empty sortOrder ? 'selected' : ''}>Default</option>
                        <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Sort Ascending</option>
                        <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Sort Descending</option>
                    </select>
                    <div style="display: flex; align-items: center; gap: 10px;">                        
                        <input type="date" id="fromDate" name="fromDate" value="${fn:escapeXml(fromDate)}">                        
                    </div>
                    <input type="submit" value="Search">
                    <input type="button" value="Reset" onclick="window.location.href = 'inventory';">
                </form>

                <!-- Error Message -->
                <c:if test="${not empty errorMessage}">
                    <p class="error-message">${fn:escapeXml(errorMessage)}</p>
                </c:if>

                <!-- Inventory Table -->
                <div class="table-container">
                    <table>
                        <tr>
                            <th>No.</th>
                            <th>Material ID</th>
                            <th>Material Name</th>
                            <th>Condition</th>
                            <th>Quantity in Stock</th>
                            <th>Last Updated</th>
                        </tr>
                        <c:choose>
                            <c:when test="${not empty inventoryData}">
                                <c:forEach items="${inventoryData}" var="item" varStatus="loop">
                                    <tr>
                                        <td>${(currentPage - 1) * 10 + loop.index + 1}</td>
                                        <td>${fn:escapeXml(item.materialId)}</td>
                                        <td>${fn:escapeXml(item.materialName)}</td>
                                        <td>${fn:escapeXml(item.materialCondition)}</td>
                                        <td>${item.quantityInStock}</td>
                                        <td><fmt:formatDate value="${item.lastUpdated}" pattern="yyyy-MM-dd"/></td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="no-data">No data found.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 0}">
                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="inventory?page=${i}&materialId=${fn:escapeXml(materialId)}&materialName=${fn:escapeXml(materialName)}&condition=${fn:escapeXml(condition)}&fromDate=${fn:escapeXml(fromDate)}&toDate=${fn:escapeXml(toDate)}&sortOrder=${fn:escapeXml(sortOrder)}"
                               class="${i == currentPage ? 'active' : ''}">${i}</a>
                        </c:forEach>
                    </div>
                </c:if>

                <div class="mt-6 d-flex button-back">
                    <jsp:include page="/view/backToDashboardButton.jsp" />
                </div>
                <!-- Back to Home -->
                <!--                <button onclick="window.location.href = ''" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to Home</button>-->
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>