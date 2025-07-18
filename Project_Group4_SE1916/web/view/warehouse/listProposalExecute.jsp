<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>List Requests Awaiting Execution</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
    <style>
        .badge {
            padding: 0.25rem 0.75rem;
            border-radius: 0.5rem;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-success { background-color: #d1fae5; color: #065f46; }
        .badge-success-bg-subtle { background-color: #bbf7d0; color: #065f46; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
     <%
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        if (username == null || role == null) {
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
    <main class="flex-1 p-8 transition-all duration-300">
        <div class="max-w-6xl mx-auto">
            <div class="flex justify-between items-center mb-6">
                <div class="flex items-center gap-4">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800">List Requests Awaiting Execution</h2>
                </div>
            </div>

            <!-- Search and Filter Form -->
            <form action="${pageContext.request.contextPath}/ListProposalExecute" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                <div class="flex-1 min-w-[200px]">
                    <select name="searchType" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500">
                        <option value="">All Types</option>
                        <option value="import_from_supplier" ${param.searchType == 'import_from_supplier' ? 'selected' : ''}>Purchase</option>
                        <option value="import_returned" ${param.searchType == 'import_returned' ? 'selected' : ''}>Retrieve</option>
                        <option value="export" ${param.searchType == 'export' ? 'selected' : ''}>Export</option>
                    </select>
                </div>
                <div class="flex-1 min-w-[200px]">
                    <input type="date" name="searchStartDate" id="searchStartDate" value="${param.searchStartDate}"
                           max="<%= java.time.LocalDate.now() %>" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500">
                </div>
                <div class="flex-1 min-w-[200px]">
                    <input type="date" name="searchEndDate" id="searchEndDate" value="${param.searchEndDate}"
                           max="<%= java.time.LocalDate.now() %>" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500">
                </div>
                <button type="submit" class="bg-blue-500 text-white px-6 py-2 rounded-lg flex items-center hover:bg-blue-600">
                    <i class="fas fa-search mr-2"></i> Search
                </button>
                <a href="${pageContext.request.contextPath}/ListProposalExecute" onclick="event.preventDefault(); this.closest('form').reset(); window.location.href = this.href;" class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center hover:bg-yellow-600">
                    <i class="fas fa-undo mr-2"></i> Reset
                </a>
                <div class="w-full flex items-center gap-2 mt-2">
                    <span class="text-gray-700">Items per page:</span>
                    <select name="recordsPerPage" onchange="this.form.submit()" class="border border-gray-300 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500">
                        <option value="5" ${recordsPerPage == 5 ? 'selected' : ''}>5 requests/page</option>
                        <option value="10" ${recordsPerPage == 10 ? 'selected' : ''}>10 requests/page</option>
                        <option value="15" ${recordsPerPage == 15 ? 'selected' : ''}>15 requests/page</option>
                    </select>
                </div>
            </form>

            <!-- Table -->
            <div class="bg-white shadow-md rounded-lg overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full table-auto text-sm text-left text-gray-500">
                        <thead class="bg-gray-50 text-xs text-gray-700 uppercase">
                            <tr>
                                <th class="p-4 text-left">ID</th>
                                <th class="p-4 text-left">Type</th>
                                <th class="p-4 text-left">Proposer</th>
                                <th class="p-4 text-left">Time Sent</th>
                                <th class="p-4 text-left">Status</th>
                                <th class="p-4 text-left">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty proposals}">
                                    <c:forEach var="item" items="${proposals}">
                                        <tr class="border-b border-gray-200">
                                            <td class="p-4 font-medium">${item.proposalId}</td>
                                            <td class="p-4 font-medium">
                                                <c:choose>
                                                    <c:when test="${item.proposalType == 'import_from_supplier'}">Purchase</c:when>
                                                    <c:when test="${item.proposalType == 'import_returned'}">Retrieve</c:when>
                                                    <c:when test="${item.proposalType == 'export'}">Export</c:when>
                                                    <c:otherwise>${item.proposalType}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="p-4 font-medium">${not empty item.senderName ? item.senderName : 'N/A'}</td>
                                            <td class="p-4 font-medium">
                                                <fmt:formatDate value="${item.proposalSentDate}" pattern="HH:mm, dd MMM yyyy" />
                                            </td>
                                            <td class="p-4 font-medium">
                                                <c:choose>
                                                    <c:when test="${item.finalStatus == 'approved_but_not_executed'}">
                                                        <span class="badge badge-success-bg-subtle">To Be Executed</span>
                                                    </c:when>
                                                    <c:when test="${item.finalStatus == 'executed'}">
                                                        <span class="badge badge-success">Executed</span>
                                                    </c:when>
                                                    <c:otherwise>${item.finalStatus}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="p-4 font-medium">
                                                <c:choose>
                                                    <c:when test="${item.finalStatus == 'approved_but_not_executed' && item.proposalType == 'export'}">
                                                        <a href="${pageContext.request.contextPath}/ExportServlet?proposalId=${item.proposalId}" class="text-blue-600 hover:underline">Execute</a>
                                                    </c:when>
                                                    <c:when test="${item.finalStatus == 'approved_but_not_executed' && (item.proposalType == 'import_from_supplier' || item.proposalType == 'import_returned')}">
                                                        <a href="${pageContext.request.contextPath}/ImportServlet?proposalId=${item.proposalId}" class="text-blue-600 hover:underline">Execute</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-gray-500">N/A</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="p-4 text-center text-gray-500">No proposals found</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="pagination flex items-center justify-center space-x-2 mt-4">
                    <c:if test="${currentPage > 1}">
                        <a href="${pageContext.request.contextPath}/ListProposalExecute?page=${currentPage - 1}&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&lt;</a>
                    </c:if>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/ListProposalExecute?page=${i}&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <a href="${pageContext.request.contextPath}/ListProposalExecute?page=${currentPage + 1}&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&gt;</a>
                    </c:if>
                </div>
            </c:if>

            <!-- Nút quay lại -->
            <div class="mt-6 flex justify-center">
                <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="bg-gray-500 text-white px-6 py-3 rounded-lg hover:bg-gray-600">Back to Dashboard</a>
            </div>
        </div>
    </main>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const form = document.querySelector('form');
            const startDateInput = document.getElementById('searchStartDate');
            const endDateInput = document.getElementById('searchEndDate');
            const searchTypeSelect = document.querySelector('select[name="searchType"]');
            const filter = new URLSearchParams(window.location.search).get('filter');

            // Disable "Export" option if filter=import_only
            if (filter === 'import_only') {
                const exportOption = searchTypeSelect.querySelector('option[value="export"]');
                if (exportOption) exportOption.disabled = true;
            }

            form.addEventListener('submit', (e) => {
                const today = new Date().toISOString().split('T')[0];
                const startDate = startDateInput.value;
                const endDate = endDateInput.value;

                if (startDate && isNaN(Date.parse(startDate))) {
                    alert("Start date is invalid.");
                    e.preventDefault();
                    return;
                }
                if (endDate && isNaN(Date.parse(endDate))) {
                    alert("End date is invalid.");
                    e.preventDefault();
                    return;
                }
                if (startDate && endDate && new Date(endDate) < new Date(startDate)) {
                    alert("End date cannot be earlier than start date.");
                    e.preventDefault();
                }
            });

            const toggleSidebar = document.getElementById('toggleSidebarMobile');
            if (toggleSidebar) {
                toggleSidebar.addEventListener('click', () => {
                    const sidebar = document.querySelector('.sidebar');
                    sidebar.classList.toggle('hidden');
                });
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
</body>
</html>