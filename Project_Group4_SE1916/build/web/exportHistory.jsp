//exHis
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Export History</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
                border-radius: 0 0 0.5rem 0.5rem;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }
            h1 {
                text-align: center;
                color: #1f2937;
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
                color: #374151;
            }
            .filter-form input[type="date"],
            .filter-form input[type="text"],
            .filter-form select {
                padding: 8px;
                border: 1px solid #d1d5db;
                border-radius: 0.5rem;
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
                border-color: #2563eb;
                box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
            }
            .filter-form input[type="submit"] {
                padding: 8px 16px;
                background-color: #2563eb;
                color: #fff;
                border: none;
                border-radius: 0.5rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            .filter-form input[type="button"] {
                padding: 8px 16px;
                background-color: #eab308;
                color: #fff;
                border: none;
                border-radius: 0.5rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            .filter-form input[type="submit"]:hover {
                background-color: #1d4ed8;
            }
            .filter-form input[type="button"]:hover {
                background-color: #ca8a04;
            }
            .error-message {
                color: #991b1b;
                text-align: center;
                margin-bottom: 15px;
            }
            .table-container {
                background-color: #fff;
                border-radius: 0 0 0.5rem 0.5rem;
                overflow: hidden;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 20px;
            }
            th, td {
                padding: 12px;
                text-align: left;
                border-bottom: 1px solid #e5e7eb;
            }
            th {
                background-color: #0284C7;
                color: #fff;
                font-weight: bold;
            }
            tr:nth-child(even) {
                background-color: #f9fafb;
            }
            tr:hover {
                background-color: #f3f4f6;
            }
            td a {
                color: #2563eb;
                text-decoration: none;
                font-weight: bold;
            }
            td a:hover {
                color: #1d4ed8;
                text-decoration: underline;
            }
            .no-data {
                text-align: center;
                color: #6b7280;
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
                color: #2563eb;
                border: 1px solid #d1d5db;
                border-radius: 0.5rem;
                transition: background-color 0.3s, border-color 0.3s;
            }
            .pagination a.active, .pagination span.active {
                background-color: #2563eb;
                color: #fff;
                border-color: #2563eb;
                font-weight: bold;
            }
            .pagination a:hover {
                background-color: #e5e7eb;
                border-color: #2563eb;
            }
            .pagination span.disabled {
                color: #6b7280;
                background-color: #e5e7eb;
                cursor: not-allowed;
            }
            .home-link {
                display: inline-block;
                margin-top: 20px;
                text-align: center;
                color: #2563eb;
                text-decoration: none;
                font-weight: bold;
            }
            .home-link:hover {
                color: #1d4ed8;
                text-decoration: underline;
            }
            .btn-secondary {
                background-color: #eab308;
                color: #fff;
                border-radius: 0.5rem;
                padding: 12px 24px;
                transition: background-color 0.3s;
                
                margin-top: 20px;
            }
            .btn-secondary:hover {
                background-color: #ca8a04;
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
            }
            
            .button-back {
                justify-self: center;
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
                    <input type="date" id="fromDate" name="fromDate" value="${fn:escapeXml(fromDate)}">
                    <label for="toDate">To: </label>
                    <input type="date" id="toDate" name="toDate" value="${fn:escapeXml(toDate)}">
                    <label for="exporter">Search key: </label>
                    <input type="text" id="exporter" name="exporter" value="${fn:escapeXml(exporter)}" placeholder="Exporter Name, Material name">
                    <input type="submit" value="Search">
                    <input type="button" value="Reset" onclick="window.location.href = 'exportHistory';">
                </form>

                <c:if test="${not empty errorMessage}">
                    <p class="error-message">${fn:escapeXml(errorMessage)}</p>
                </c:if>

                <table class="table-container">
                    <tr>
                        <th>No.</th>
                        <th>Code</th>
                        <th>Date</th>
                        <th>Exporter</th>
                        <th>Receiver</th>
                        <th>Construction Name</th>
                        <th>Note</th>
                        <th>Action</th>
                    </tr>
                    <c:choose>
                        <c:when test="${not empty historyData}">
                            <c:forEach items="${historyData}" var="item" varStatus="loop">
                                <tr>
                                    <td>${(currentPage - 1) * 10 + loop.index + 1}</td>
                                    <td>${fn:escapeXml(item.receiptId)}</td>
                                    <td>${fn:escapeXml(item.exportDate)}</td>
                                    <td>${fn:escapeXml(item.exporterName)}</td>
                                    <td>${fn:escapeXml(item.receiverName)}</td>
                                    <td>${fn:escapeXml(item.siteName)}</td>
                                    <td>${fn:escapeXml(item.note)}</td>
                                    <td><a href="exportHistoryDetail?exportId=${item.exportId}&keyword=${param.keyword}&sort=${param.sort}&page=1">View</a></td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="8" class="no-data">No data found.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </table>

                <c:if test="${totalPages > 0}">
                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="exportHistory?page=${i}&fromDate=${fn:escapeXml(fromDate)}&toDate=${fn:escapeXml(toDate)}&exporter=${fn:escapeXml(exporter)}"
                               class="${i == currentPage ? 'active' : ''}">${i}</a>
                        </c:forEach>
                    </div>
                </c:if>


                <div class="mt-6 d-flex button-back">
                    <jsp:include page="/view/backToDashboardButton.jsp" />
                </div>


            </div>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>