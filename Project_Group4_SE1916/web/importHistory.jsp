<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Import History</title>

        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- Custom CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            /* Paste the updated style block here */
            .badge {
                padding: 0.25rem 0.75rem;
                border-radius: 0.375rem;
                font-size: 0.75rem;
                font-weight: 600;
                background-color: #d1e7dd;
                color: #0f5132;
                display: inline-block;
            }

            .table-container {
                border-radius: 0.5rem;
                overflow: hidden;
            }

            table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
            }

            thead {
                background-color: #4dabf7;
                color: white;
            }

            th {
                padding: 0.75rem;
                text-align: left;
                font-size: 0.75rem;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            td {
                padding: 0.75rem;
                font-size: 0.875rem;
                font-weight: 500;
            }

            tr {
                border-bottom: 1px solid #e5e7eb;
            }

            tr:last-child {
                border-bottom: none;
            }

            .pagination a, .pagination span {
                padding: 0.5rem 0.75rem;
                border-radius: 0.375rem;
                background-color: blue !important;
                color: white !important;
                margin: 0 0.25rem;
            }

            .pagination span {
                background-color: #e5e7eb;
                color: #6b7280;
                cursor: not-allowed;
            }

            .btn-secondary {
                background-color: #6b7280;
                color: white;
                padding: 0.75rem 1.5rem;
                border-radius: 0.375rem;
            }

            .btn-primary {
                background-color: #3b82f6;
                color: white;
                padding: 0.5rem 1rem;
                border-radius: 0.375rem;
            }

            input, select {
                border: 1px solid #d1d5db;
                border-radius: 0.375rem;
                padding: 0.5rem;
            }

            /* Ensure dark mode compatibility (optional tweak) */
            @media (prefers-color-scheme: dark) {
                body {
                    background-color: #1f2937;
                }
                .table-container {
                    background-color: #374151;
                }
                thead {
                    background-color: #1e40af;
                }
                td, th {
                    color: #d1d5db;
                }
                input, select {
                    background-color: #4b5563;
                    color: #d1d5db;
                    border-color: #4b5563;
                }
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

        <!-- Main content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Import History</h2>
                    </div>
                </div>

                <!-- Filter form -->
                <form action="importhistory" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <label class="block text-sm font-medium text-gray-700">Proposal Type</label>
                        <select name="type" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">All</option>
                            <option value="import_from_supplier" ${param.type == 'import_from_supplier' ? 'selected' : ''}>From Supplier</option>
                            <option value="import_returned" ${param.type == 'import_returned' ? 'selected' : ''}>Returned</option>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <label class="block text-sm font-medium text-gray-700">Executor</label>
                        <input type="text" name="executor" value="${param.executor}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" />
                    </div>
                    <div class="flex-1 min-w-[150px]">
                        <label class="block text-sm font-medium text-gray-700">From Date</label>
                        <input type="date" name="fromDate" value="${param.fromDate}" max="<%= java.time.LocalDate.now()%>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" />
                    </div>
                    <div class="flex-1 min-w-[150px]">
                        <label class="block text-sm font-medium text-gray-700">To Date</label>
                        <input type="date" name="toDate" value="${param.toDate}" max="<%= java.time.LocalDate.now()%>" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" />
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                    <a href="${pageContext.request.contextPath}/importhistory" onclick="event.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;" class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
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
                                    <th class="p-4 text-left">Proposal Type</th>
                                    <th class="p-4 text-left">Executor</th>
                                    <th class="p-4 text-left">Import Date</th>
                                    <th class="p-4 text-left">Note</th>
                                    <th class="p-4 text-left">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty importList}">
                                        <c:forEach var="imp" items="${importList}">
                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="p-4 font-medium">${imp.importId}</td>
                                                <td class="p-4 font-medium">
                                                    <c:choose>
                                                        <c:when test="${imp.importType == 'import_from_supplier'}">
                                                            <span class="badge badge-success">From Supplier</span>
                                                        </c:when>
                                                        <c:when test="${imp.importType == 'import_returned'}">
                                                            <span class="badge badge-success-bg-subtle">Returned</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td class="p-4 font-medium">${imp.executor.fullName}</td>
                                                <td class="p-4 font-medium"><fmt:formatDate value="${imp.importDate}" pattern="HH:mm, dd MMM yyyy"/></td>
                                                <td class="p-4 font-medium">${imp.note}</td>
                                                <td class="p-4 font-medium">
                                                    <a href="ViewImportDetailServlet?importId=${imp.importId}" class="text-primary-600 dark:text-primary-400 hover:underline">View</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="p-4 text-center text-gray-500 dark:text-gray-400">
                                                No import history found
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
                    <!-- Previous page -->
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="importhistory?page=${currentPage - 1}&type=${param.type}&executor=${param.executor}&fromDate=${param.fromDate}&toDate=${param.toDate}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400"><</a>
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
                            <a href="importhistory?page=1&type=${param.type}&executor=${param.executor}&fromDate=${param.fromDate}&toDate=${param.toDate}" class="px-3 py-1 rounded border hover:border-blue-500">1</a>
                        </c:otherwise>
                    </c:choose>
                    <!-- Ellipsis if needed -->
                    <c:if test="${currentPage > 4}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <!-- Middle pages -->
                    <c:forEach var="i" begin="${currentPage - 1 > 1 ? currentPage - 1 : 2}" end="${currentPage + 1 < totalPages ? currentPage + 1 : totalPages - 1}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="importhistory?page=${i}&type=${param.type}&executor=${param.executor}&fromDate=${param.fromDate}&toDate=${param.toDate}" class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <!-- Ellipsis if needed -->
                    <c:if test="${currentPage < totalPages - 3}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <!-- Last page -->
                    <c:if test="${totalPages > 1}">
                        <c:choose>
                            <c:when test="${currentPage == totalPages}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${totalPages}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="importhistory?page=${totalPages}&type=${param.type}&executor=${param.executor}&fromDate=${param.fromDate}&toDate=${param.toDate}" class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <!-- Next page -->
                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="importhistory?page=${currentPage + 1}&type=${param.type}&executor=${param.executor}&fromDate=${param.fromDate}&toDate=${param.toDate}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">></a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">></span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Back to home -->
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

        <!-- Scripts -->
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                const form = document.querySelector('form');
                const fromDateInput = document.querySelector('input[name="fromDate"]');
                const toDateInput = document.querySelector('input[name="toDate"]');

                if (!form || !fromDateInput || !toDateInput) {
                    console.warn('Form or date inputs not found!');
                    return;
                }

                form.addEventListener('submit', function (e) {
                    const today = new Date().toISOString().split('T')[0];
                    const fromDate = fromDateInput.value;
                    const toDate = toDateInput.value;

                    if (fromDate && isNaN(Date.parse(fromDate))) {
                        alert("From date is invalid.");
                        e.preventDefault();
                        return;
                    }

                    if (toDate && isNaN(Date.parse(toDate))) {
                        alert("To date is invalid.");
                        e.preventDefault();
                        return;
                    }

                    if (fromDate && toDate && toDate < fromDate) {
                        alert("To date cannot be earlier than from date.");
                        e.preventDefault();
                    }
                });
            });
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>