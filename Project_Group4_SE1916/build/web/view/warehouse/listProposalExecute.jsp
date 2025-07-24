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
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Inter', sans-serif;
            color: #333;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 25px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border: 1px solid #e5e7eb;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            display: block;
        }
        .form-control {
            border-radius: 6px;
            border: 1px solid #ced4da;
            padding: 8px 12px;
            width: 100%;
            box-sizing: border-box;
            transition: all 0.3s ease;
        }
        .form-control:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
        }
        .btn-primary {
            background-color: #3b82f6;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            transition: background-color 0.3s ease;
            color: white;
        }
        .btn-primary:hover {
            background-color: #1d4ed8;
        }
        .btn-secondary {
            background-color: #6c757d;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            transition: background-color 0.3s ease;
            color: white;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
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
            background: #ffffff;
            overflow: hidden;
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
            color: #212529;
        }
        .table tr:nth-child(even) {
            background-color: #f8fafc;
        }
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
        .badge-success-bg-subtle {
            background-color: #bbf7d0;
            color: #065f46;
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
            .container {
                margin: 20px;
                padding: 15px;
            }
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

    <div class="flex flex-col md:flex-row">
        <jsp:include page="/view/sidebar/sidebarWarehouse.jsp" />
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="container">
                <header class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h1 class="text-3xl font-bold text-gray-800">List Requests Awaiting Execution</h1>
                </header>

                <c:if test="${not empty sessionScope.error}">
                    <div class="error-message">${sessionScope.error}</div>
                    <c:remove var="error" scope="session"/>
                </c:if>

                <form action="${pageContext.request.contextPath}/ListProposalExecute" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <select name="searchType" class="form-control">
                            <option value="">All Types</option>
                            <option value="import_from_supplier" ${param.searchType == 'import_from_supplier' ? 'selected' : ''}>Purchase</option>
                            <option value="import_returned" ${param.searchType == 'import_returned' ? 'selected' : ''}>Retrieve</option>
                            <option value="export" ${param.searchType == 'export' ? 'selected' : ''}>Export</option>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <input type="date" name="searchStartDate" id="searchStartDate" value="${param.searchStartDate}" max="<%= java.time.LocalDate.now() %>" class="form-control">
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <input type="date" name="searchEndDate" id="searchEndDate" value="${param.searchEndDate}" max="<%= java.time.LocalDate.now() %>" class="form-control">
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                    <a href="${pageContext.request.contextPath}/ListProposalExecute" onclick="event.preventDefault(); this.closest('form').reset(); window.location.href = this.href;" class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-undo mr-2"></i> Reset
                    </a>
                    <div class="w-full flex items-center gap-2">
                        <span class="text-gray-700">Items per page:</span>
                        <select name="recordsPerPage" onchange="this.form.submit()" class="form-control">
                            <option value="5" ${recordsPerPage == 5 ? 'selected' : ''}>5 requests/page</option>
                            <option value="10" ${recordsPerPage == 10 ? 'selected' : ''}>10 requests/page</option>
                            <option value="15" ${recordsPerPage == 15 ? 'selected' : ''}>15 requests/page</option>
                        </select>
                    </div>
                </form>

                <div class="table-container">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto text-sm text-left text-gray-500 table">
                            <thead>
                                <tr>
                                    <th class="p-4 text-left cursor-pointer" data-sort="proposalId">ID</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="proposalType">Type</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="senderName">Proposer</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="proposalSentDate">Time Sent</th>
                                    <th class="p-4 text-left cursor-pointer" data-sort="finalStatus">Status</th>
                                    <th class="p-4 text-left">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty proposals}">
                                        <c:forEach var="item" items="${proposals}">
                                            <tr class="border-b border-gray-200">
                                                <td class="p-4">${item.proposalId}</td>
                                                <td class="p-4">
                                                    <c:choose>
                                                        <c:when test="${item.proposalType == 'import_from_supplier'}">Purchase</c:when>
                                                        <c:when test="${item.proposalType == 'import_returned'}">Retrieve</c:when>
                                                        <c:when test="${item.proposalType == 'export'}">Export</c:when>
                                                        <c:otherwise>${item.proposalType}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="p-4">${not empty item.senderName ? item.senderName : 'N/A'}</td>
                                                <td class="p-4">
                                                    <fmt:formatDate value="${item.proposalSentDate}" pattern="HH:mm, dd MMM yyyy" />
                                                </td>
                                                <td class="p-4">
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
                                                <td class="p-4">
                                                    <c:choose>
                                                        <c:when test="${item.finalStatus == 'approved_but_not_executed' && item.proposalType == 'export'}">
                                                            <a href="${pageContext.request.contextPath}/ExportServlet?proposalId=${item.proposalId}" class="btn-primary text-white px-4 py-2 rounded-lg flex items-center">
                                                                <i class="fas fa-play mr-2"></i> Execute
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${item.finalStatus == 'approved_but_not_executed' && (item.proposalType == 'import_from_supplier' || item.proposalType == 'import_returned')}">
                                                            <a href="${pageContext.request.contextPath}/ImportServlet?proposalId=${item.proposalId}" class="btn-primary text-white px-4 py-2 rounded-lg flex items-center">
                                                                <i class="fas fa-play mr-2"></i> Execute
                                                            </a>
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

                <c:if test="${totalPages > 1}">
                    <div class="pagination flex items-center justify-center space-x-1 mt-6">
                        <c:choose>
                            <c:when test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/ListProposalExecute?page=${currentPage - 1}&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&lt;</a>
                            </c:when>
                            <c:otherwise>
                                <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&lt;</span>
                            </c:otherwise>
                        </c:choose>
                        <c:choose>
                            <c:when test="${currentPage == 1}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/ListProposalExecute?page=1&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded border hover:border-blue-500">1</a>
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
                                    <a href="${pageContext.request.contextPath}/ListProposalExecute?page=${i}&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
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
                                    <a href="${pageContext.request.contextPath}/ListProposalExecute?page=${totalPages}&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                        <c:choose>
                            <c:when test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/ListProposalExecute?page=${currentPage + 1}&recordsPerPage=${recordsPerPage}&searchType=${param.searchType}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}&filter=${param.filter}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&gt;</a>
                            </c:when>
                            <c:otherwise>
                                <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&gt;</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <div class="mt-6 flex justify-center">
                    <a href="${pageContext.request.contextPath}/WarehouseDashboard" class="btn-secondary text-white px-6 py-3 rounded-lg">
                        <i class="fas fa-arrow-left mr-2"></i> Back to Dashboard
                    </a>
                </div>
            </div>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const form = document.querySelector('form');
            const startDateInput = document.getElementById('searchStartDate');
            const endDateInput = document.getElementById('searchEndDate');
            const searchTypeSelect = document.querySelector('select[name="searchType"]');
            const filter = new URLSearchParams(window.location.search).get('filter');

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
            const closeButton = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.sidebar');

            if (toggleSidebar && sidebar) {
                toggleSidebar.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });
            }
            if (closeButton && sidebar) {
                closeButton.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });
            }

            document.addEventListener('click', (event) => {
                if (window.innerWidth <= 768 && sidebar.classList.contains('active') && 
                    !sidebar.contains(event.target) && !toggleSidebar.contains(event.target)) {
                    sidebar.classList.remove('active');
                }
            });

            document.querySelectorAll('.table th[data-sort]').forEach(th => {
                th.addEventListener('click', () => {
                    const table = th.closest('table');
                    const tbody = table.querySelector('tbody');
                    const rows = Array.from(tbody.querySelectorAll('tr'));
                    const columnIndex = th.cellIndex;
                    const sortKey = th.getAttribute('data-sort');
                    const isNumeric = sortKey === 'proposalId';
                    const isDate = sortKey === 'proposalSentDate';
                    const isAsc = th.classList.toggle('asc');
                    th.classList.toggle('desc', !isAsc);

                    table.querySelectorAll('th').forEach(header => {
                        if (header !== th) header.classList.remove('asc', 'desc');
                    });

                    rows.sort((a, b) => {
                        let aValue = a.cells[columnIndex].textContent.trim();
                        let bValue = b.cells[columnIndex].textContent.trim();

                        if (isNumeric) {
                            aValue = parseFloat(aValue) || 0;
                            bValue = parseFloat(bValue) || 0;
                            return isAsc ? aValue - bValue : bValue - aValue;
                        } else if (isDate) {
                            aValue = aValue ? new Date(aValue.split(', ')[1].split(' ').reverse().join('-') + ' ' + aValue.split(', ')[0]) : '';
                            bValue = bValue ? new Date(bValue.split(', ')[1].split(' ').reverse().join('-') + ' ' + bValue.split(', ')[0]) : '';
                            if (aValue === '' && bValue === '') return 0;
                            if (aValue === '') return isAsc ? 1 : -1;
                            if (bValue === '') return isAsc ? -1 : 1;
                            return isAsc ? aValue - bValue : bValue - aValue;
                        } else {
                            return isAsc ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue);
                        }
                    });

                    rows.forEach(row => tbody.appendChild(row));
                });
            });

            function showToast(message) {
                Toastify({
                    text: message,
                    duration: 3000,
                    gravity: "top",
                    position: "right",
                    backgroundColor: "#3b82f6",
                    stopOnFocus: true,
                    className: "rounded-lg shadow-lg",
                    style: { borderRadius: "0.5rem" }
                }).showToast();
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/sidebar_darkmode.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
</body>
</html>