<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>List of Pending Proposals - Material Management System</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Toastify -->
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <!-- Style CSS -->
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
        .error-message {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 0.75rem;
            border-radius: 0.375rem;
            margin-bottom: 1rem;
            text-align: center;
        }
        .table-container {
            border-radius: 1rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border: 1px solid #e5e7eb;
        }
        .table th {
            background-color: #3b82f6;
            color: white;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
            padding: 1rem;
        }
        .table td {
            padding: 1rem;
        }
        .table tr:nth-child(even) {
            background-color: #f8fafc;
        }
        .search-input {
            transition: all 0.3s ease;
            border-radius: 0.75rem;
        }
        .search-input:focus {
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
        }
        .dark-mode .table-container {
            background-color: #2d3748;
            color: #e2e8f0;
            border-color: #4a5568;
        }
        .dark-mode .table tr:nth-child(even) {
            background-color: #2d3748;
        }
        .dark-mode .table tr {
            border-color: #4a5568;
        }
        th.asc::after {
            content: ' ↑';
            font-size: 0.75rem;
        }
        th.desc::after {
            content: ' ↓';
            font-size: 0.75rem;
        }
        .sidebar {
            width: 18rem;
            background: linear-gradient(to bottom, #1e40af, #3b82f6);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14);
            transition: transform 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);
            transform: translateX(-100%);
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            z-index: 50;
        }
        .sidebar.active {
            transform: translateX(0);
        }
        .nav-item {
            transition: all 0.2s ease;
            border-radius: 0.5rem;
        }
        .nav-item:hover {
            background: linear-gradient(to right, #3b82f6, #8b5cf6);
            transform: translateX(5px) scale(1.02);
        }
        .nav-item.active {
            background-color: rgba(255, 255, 255, 0.2);
            font-weight: 600;
        }
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                max-width: 280px;
            }
            .sidebar.active ~ main {
                margin-left: 0;
            }
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <!-- Session Check -->
    <%
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equals("admin")) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
    %>
    <div class="flex">
        <!-- Sidebar -->
        <jsp:include page="/view/sidebar/sidebarAdmin.jsp" />

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <!-- Header -->
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">List of Pending Proposals</h2>
                </div>

                <!-- Error Message Display -->
                <c:if test="${not empty sessionScope.error}">
                    <div class="error-message">${sessionScope.error}</div>
                    <c:remove var="error" scope="session"/>
                </c:if>

                <!-- Search and Filter Form -->
                <form action="${pageContext.request.contextPath}/AdminApproveServlet" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <input type="text" name="search" value="${param.search}" placeholder="Search by sender name" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white search-input">
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <input type="date" name="dateFrom" value="${param.dateFrom}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white search-input">
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <input type="date" name="dateTo" value="${param.dateTo}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white search-input">
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <select name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white search-input">
                            <option value="" ${empty param.status ? 'selected' : ''}>All Statuses</option>
                            <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Pending</option>
                            <option value="approved_by_admin" ${param.status == 'approved_by_admin' ? 'selected' : ''}>Approved by Admin</option>
                            <option value="approved_but_not_executed" ${param.status == 'approved_but_not_executed' ? 'selected' : ''}>Approved by Director</option>
                            <option value="rejected" ${param.status == 'rejected' ? 'selected' : ''}>Rejected</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                    <a href="${pageContext.request.contextPath}/AdminApproveServlet" 
                       onclick="event.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;" 
                       class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-undo mr-2"></i> Reset
                    </a>
                </form>

                <!-- Items Per Page -->
                <form action="${pageContext.request.contextPath}/AdminApproveServlet" method="get" class="mb-6 flex items-center gap-2">
                    <span class="text-gray-700 dark:text-gray-300">Items per page:</span>
                    <select name="itemsPerPage" onchange="this.form.submit()" 
                            class="border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white search-input">
                        <option value="10" ${itemsPerPage == '10' ? 'selected' : ''}>10 proposals/page</option>
                        <option value="20" ${itemsPerPage == '20' ? 'selected' : ''}>20 proposals/page</option>
                        <option value="30" ${itemsPerPage == '30' ? 'selected' : ''}>30 proposals/page</option>
                    </select>
                    <input type="hidden" name="search" value="${param.search}">
                    <input type="hidden" name="dateFrom" value="${param.dateFrom}">
                    <input type="hidden" name="dateTo" value="${param.dateTo}">
                    <input type="hidden" name="status" value="${param.status}">
                    <input type="hidden" name="page" value="${currentPage}">
                </form>

                <!-- Proposals Table -->
                <div class="table-container bg-white dark:bg-gray-800">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-primary-600 text-white">
                                    <th class="p-4 text-left cursor-pointer" data-sort="#">No.</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="proposalId">Proposal ID</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="proposalType">Proposal Type</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="sender">Sender</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="sendDate">Send Date</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="approvalDate">Approval Date</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="adminStatus">Admin Status</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="directorStatus">Director Status</th>
                                    <th class="p-4 text-left">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="proposal" items="${pendingProposals}" varStatus="loop">
                                    <tr class="border-b border-gray-200 dark:border-gray-700">
                                        <td class="p-4">${(currentPage - 1) * itemsPerPage + loop.count}</td>
                                        <td class="p-4">${not empty proposal.proposalId ? proposal.proposalId : 'N/A'}</td>
                                        <td class="p-4">${not empty proposal.proposalType ? proposal.proposalType : 'N/A'}</td>
                                        <td class="p-4">${not empty proposal.senderName ? proposal.senderName : 'N/A'}</td>
                                        <td class="p-4">
                                            <fmt:formatDate value="${proposal.proposalSentDate}" pattern="dd/MM/yyyy HH:mm" var="sendDateFormatted"/>
                                            ${not empty sendDateFormatted ? sendDateFormatted : 'N/A'}
                                        </td>
                                        <td class="p-4">
                                            <fmt:formatDate value="${proposal.approvalDate}" pattern="dd/MM/yyyy HH:mm" var="approvalDateFormatted"/>
                                            ${not empty approvalDateFormatted ? approvalDateFormatted : 'Not Approved'}
                                        </td>
                                        <td class="p-4">
                                            <span class="badge
                                                  ${proposal.approval.adminStatus == 'pending' ? 'badge-warning' : 
                                                    proposal.approval.adminStatus == 'approved' ? 'badge-success' : 
                                                    proposal.approval.adminStatus == 'rejected' ? 'badge-danger' : 
                                                    'bg-gray-300 text-gray-900'}">
                                                ${not empty proposal.approval.adminStatus ? proposal.approval.adminStatus : 'N/A'}
                                            </span>
                                        </td>
                                        <td class="p-4">
                                            <span class="badge
                                                  ${proposal.approval.directorStatus == 'pending' ? 'badge-warning' : 
                                                    proposal.approval.directorStatus == 'approved' ? 'badge-success' : 
                                                    proposal.approval.directorStatus == 'rejected' ? 'badge-danger' : 
                                                    'bg-gray-300 text-gray-900'}">
                                                ${not empty proposal.approval.directorStatus ? proposal.approval.directorStatus : 'N/A'}
                                            </span>
                                        </td>
                                        <td class="p-4">
                                            <a href="${pageContext.request.contextPath}/AdminProposalDetailServlet?proposalId=${proposal.proposalId}" 
                                               class="btn-primary text-white px-4 py-2 rounded-lg flex items-center">
                                                <i class="fas fa-eye mr-2"></i> View & Edit
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Pagination -->
                <div class="pagination flex items-center justify-center space-x-1 mt-6">
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${currentPage - 1}&search=${param.search}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}&status=${param.status}&itemsPerPage=${itemsPerPage}" 
                               class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400"><</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed"><</span>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${currentPage == 1}">
                            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=1&search=${param.search}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}&status=${param.status}&itemsPerPage=${itemsPerPage}" 
                               class="px-3 py-1 rounded border hover:border-blue-500">1</a>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${currentPage > 4}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <c:forEach var="i" begin="${currentPage - 1 > 1 ? currentPage - 1 : 2}" end="${currentPage + 1 < totalPages ? currentPage + 1 : totalPages - 1}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${i}&search=${param.search}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}&status=${param.status}&itemsPerPage=${itemsPerPage}" 
                                   class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages - 3}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <c:if test="${totalPages > 1}">
                        <c:choose>
                            <c:when test="${currentPage == totalPages}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${totalPages}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${totalPages}&search=${param.search}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}&status=${param.status}&itemsPerPage=${itemsPerPage}" 
                                   class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${currentPage + 1}&search=${param.search}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}&status=${param.status}&itemsPerPage=${itemsPerPage}" 
                               class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">></a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">></span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Back to Dashboard -->
                <div class="mt-6 flex justify-center">
                    <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" 
                       class="btn-secondary text-white px-6 py-3 rounded-lg">Back to Dashboard</a>
                </div>
            </div>
        </main>
    </div>

    <!-- JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const toggleButton = document.getElementById('toggleSidebarMobile');
            const closeButton = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.sidebar');

            // Toggle sidebar visibility
            if (toggleButton && sidebar) {
                toggleButton.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });
            } else {
                console.error('Toggle button or sidebar not found');
            }
            if (closeButton && sidebar) {
                closeButton.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });
            } else {
                console.error('Close button or sidebar not found');
            }

            // Close sidebar when clicking outside on mobile
            document.addEventListener('click', (event) => {
                if (window.innerWidth <= 768 && sidebar.classList.contains('active') && 
                    !sidebar.contains(event.target) && !toggleButton.contains(event.target)) {
                    sidebar.classList.remove('active');
                }
            });

            // Table Sorting
            document.querySelectorAll('.table th[data-sort]').forEach(th => {
                th.addEventListener('click', () => {
                    const table = th.closest('table');
                    const tbody = table.querySelector('tbody');
                    const rows = Array.from(tbody.querySelectorAll('tr'));
                    const columnIndex = th.cellIndex;
                    const sortKey = th.getAttribute('data-sort');
                    const isNumeric = sortKey === '#' || sortKey === 'proposalId';
                    const isDate = sortKey === 'sendDate' || sortKey === 'approvalDate';
                    const isAsc = th.classList.toggle('asc');
                    th.classList.toggle('desc', !isAsc);

                    // Remove sort indicators from other headers
                    table.querySelectorAll('th').forEach(header => {
                        if (header !== th)
                            header.classList.remove('asc', 'desc');
                    });

                    rows.sort((a, b) => {
                        let aValue = a.cells[columnIndex].textContent.trim();
                        let bValue = b.cells[columnIndex].textContent.trim();

                        if (isNumeric) {
                            aValue = parseFloat(aValue) || 0;
                            bValue = parseFloat(bValue) || 0;
                            return isAsc ? aValue - bValue : bValue - aValue;
                        } else if (isDate) {
                            aValue = aValue === 'Not Approved' ? '' : new Date(aValue.split(' ').reverse().join(' ').replace(/(\d+)\/(\d+)\/(\d+)/, '$3-$2-$1'));
                            bValue = bValue === 'Not Approved' ? '' : new Date(bValue.split(' ').reverse().join(' ').replace(/(\d+)\/(\d+)\/(\d+)/, '$3-$2-$1'));
                            if (aValue === '' && bValue === '')
                                return 0;
                            if (aValue === '')
                                return isAsc ? 1 : -1;
                            if (bValue === '')
                                return isAsc ? -1 : 1;
                            return isAsc ? aValue - bValue : bValue - aValue;
                        } else {
                            return isAsc ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue);
                        }
                    });

                    // Re-append sorted rows
                    rows.forEach(row => tbody.appendChild(row));
                });
            });

            // Toast Notification
            function showToast(message) {
                Toastify({
                    text: message,
                    duration: 3000,
                    gravity: "top",
                    position: "right",
                    backgroundColor: "#3b82f6",
                    stopOnFocus: true,
                    className: "rounded-lg shadow-lg",
                    style: {borderRadius: "0.5rem"}
                }).showToast();
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/sidebar_darkmode.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
</body>
</html>