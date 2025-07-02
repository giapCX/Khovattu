<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <title>Material Import History</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
        <style>
            body {
                background-color: #f9fafb;
                color: #1f2937;
                font-family: 'Inter', sans-serif;
            }
            .max-w-6xl {
                max-width: 72rem;
                margin: 0 auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background-color: #fff;
                border-radius: 0.5rem;
                overflow: hidden;
                box-shadow: 0 1px 3px rgb(0 0 0 / 0.1);
            }
            thead tr {
                background-color: #2563eb;
                color: white;
            }
            th, td {
                padding: 0.75rem 1rem;
                text-align: left;
                border-bottom: 1px solid #e5e7eb;
            }
            tbody tr:hover {
                background-color: #f3f4f6;
            }
            .p-4 {
                padding: 1rem;
            }
            /* Form styles */
            .form-control {
                padding: 0.5rem;
                border: 1px solid #d1d5db;
                border-radius: 0.375rem;
                margin-right: 0.5rem;
                font-size: 0.875rem;
            }
            .form-control:focus {
                outline: none;
                border-color: #2563eb;
                box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
            }
            .btn {
                padding: 0.5rem 1rem;
                background-color: #2563eb;
                color: white;
                border: none;
                border-radius: 0.375rem;
                cursor: pointer;
                font-size: 0.875rem;
            }
            .btn:hover {
                background-color: #1d4ed8;
            }
            .btn-back {
                background-color: #6b7280;
            }
            .btn-back:hover {
                background-color: #4b5563;
            }
            /* Pagination styles */
            .pagination {
                display: flex;
                justify-content: center; /* Center the pagination */
                gap: 0.5rem;
            }
            .pagination a {
                padding: 0.5rem 0.75rem;
                border: 1px solid #d1d5db;
                border-radius: 0.375rem;
                text-decoration: none;
                color: #2563eb;
                font-size: 0.875rem;
            }
            .pagination a:hover {
                background-color: #f3f4f6;
            }
            .pagination a.active {
                background-color: #2563eb;
                color: white;
                border-color: #2563eb;
            }
            /* Flex container for form */
            .filter-form {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                flex-wrap: wrap;
                margin-bottom: 1rem;
            }
        </style>
    </head>
    <body>
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
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Material Import History</h2>
                </div>

                <!-- Filter -->
                <form method="get" action="importhistory" class="filter-form">
                    <input type="date" name="fromDate" value="${fromDate}" class="form-control" />
                    <input type="date" name="toDate" value="${toDate}" class="form-control" />
                    <input type="text" name="importer" value="${importer}" placeholder="Importer" class="form-control" />
                    <button type="submit" class="btn">Search</button>
                </form>
                <br><br>
                <div class="table-container bg-white dark:bg-gray-800">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr>
                                    <th class="p-4">Voucher ID</th>
                                    <th class="p-4">Total</th>
                                    <th class="p-4">Import Date</th>
                                    <th class="p-4">Importer</th>
                                    <th class="p-4">Note</th>
                                    <th class="p-4">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${historyData}">
                                    <tr class="border-b border-gray-200 dark:border-gray-700">
                                        <td class="p-4">${item.voucherId}</td>
                                        <td class="p-4">${item.total}</td>
                                        <td class="p-4">${item.importDate}</td>
                                        <td class="p-4">${item.importerName}</td>
                                        <td class="p-4">${item.note}</td>
                                        <td class="p-4">
                                            <a href="importhistorydetail?importId=${item.importId}&keyword=${param.keyword}&sort=${param.sort}&page=1">View</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
                <!-- Pagination -->
                <div class="pagination mt-4">
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <a href="importhistory?page=${i}&fromDate=${param.fromDate}&toDate=${param.toDate}&importer=${param.importer}"
                           class="${i == currentPage ? 'active' : ''}">${i}</a>
                    </c:forEach>
                </div>
                <button onclick="history.back()" class="btn btn-back">Back</button>
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>