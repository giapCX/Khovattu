
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Export History</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- Liên kết đến file CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                background-color: #f0f2f5;
                color: #1a1a1a;
            }
            .container {
                margin: 0 auto;
                background-color: #fff;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }
            h1 {
                text-align: center;
                color: #2c3e50;
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
                color: #34495e;
            }
            .filter-form input[type="date"],
            .filter-form input[type="text"] {
                padding: 8px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 14px;
            }
            .filter-form input[type="submit"] {
                padding: 8px 16px;
                background-color: #3498db;
                color: #fff;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            .filter-form input[type="reset"] {
                padding: 8px 16px;
                background-color: #1abc9c;
                color: #fff;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            .filter-form input[type="submit"]:hover {
                background-color: #2980b9;
            }
            .filter-form input[type="reset"]:hover {
                background-color: #16a085;
            }
            .error-message {
                color: #e74c3c;
                text-align: center;
                margin-bottom: 15px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 20px;
            }
            th, td {
                padding: 12px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #3498db;
                color: #fff;
                font-weight: bold;
            }
            tr:nth-child(even) {
                background-color: #f9f9f9;
            }
            tr:hover {
                background-color: #f1f1f1;
            }
            td a {
                color: #3498db;
                text-decoration: none;
                font-weight: bold;
            }
            td a:hover {
                color: #2980b9;
                text-decoration: underline;
            }
            .no-data {
                text-align: center;
                color: #7f8c8d;
                padding: 20px;
            }
            .pagination {
                text-align: center;
                margin-top: 20px;
            }
            .pagination a {
                display: inline-block;
                padding: 8px 12px;
                margin: 0 5px;
                text-decoration: none;
                color: #3498db;
                border: 1px solid #ddd;
                border-radius: 4px;
                transition: background-color 0.3s;
            }
            .pagination a.active {
                background-color: #3498db;
                color: #fff;
                border-color: #3498db;
            }
            .pagination a:hover {
                background-color: #ecf0f1;
            }
            .home-link {
                display: inline-block;
                margin-top: 20px;
                text-align: center;
                color: #3498db;
                text-decoration: none;
                font-weight: bold;
            }
            .home-link:hover {
                color: #2980b9;
                text-decoration: underline;
            }
            @media (max-width: 768px) {
                .filter-form {
                    flex-direction: column;
                    align-items: stretch;
                }
                .filter-form input {
                    width: 100%;
                    margin-bottom: 10px;
                }
                table {
                    font-size: 14px;
                }
            }
        </style>
        <script>
            function clearFormAndSubmit() {
                const form = document.querySelector('.filter-form');
                document.getElementById('fromDate').value = '';
                document.getElementById('toDate').value = '';
                document.getElementById('exporter').value = '';
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
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Export History</h2>
                    </div>
                </div>

                <form action="exportHistory" method="get" class="filter-form">
                    <label for="fromDate">From: </label>
                    <input type="date" id="fromDate" name="fromDate" value="${fromDate}">
                    <label for="toDate">To: </label>
                    <input type="date" id="toDate" name="toDate" value="${toDate}">
                    <label for="exporter">Exporter Name: </label>
                    <input type="text" id="exporter" name="exporter" value="${exporter}" placeholder="Exporter Name">
                    <input type="submit" value="Search">
                    <input type="reset" value="Reset" onclick="clearFormAndSubmit();">
                </form>

                <c:if test="${not empty errorMessage}">
                    <p class="error-message">${errorMessage}</p>
                </c:if>

                <table>
                    <tr>
                        <th>No.</th>
                        <th>Code</th>
                        <th>Date</th>
                        <th>Exporter</th>
                        <th>Note</th>
                        <th>Action</th>
                    </tr>
                    <c:choose>
                        <c:when test="${not empty historyData}">
                            <c:forEach items="${historyData}" var="item" varStatus="loop">
                                <tr>
                                    <td>${(currentPage - 1) * 10 + loop.index + 1}</td>
                                    <td>${item.voucherId}</td>
                                    <td>${item.exportDate}</td>
                                    <td>${item.exporterName}</td>
                                    <td>${item.note}</td>
                                    <td><button onclick="window.location.href='./viewExportHistoryDetail.jsp'" class="text-primary-600 font-medium hover:underline">View</button></td>
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

                <c:if test="${totalPages > 0}">
                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="exportHistory?page=${i}&fromDate=${fromDate}&toDate=${toDate}&exporter=${exporter}"
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
                <button onclick="window.location.href='<%= redirectUrl%>'" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to Home</button>
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>