<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>List requests</title>

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
        </style>

    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">

        <%
            String role = (String) session.getAttribute("role");

            if (role == null || (!role.equals("employee"))) {
                response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
                return;
            }
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
            <div class="max-w-7xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">My submitted requests</h2>
                    </div>
                    <a href="${pageContext.request.contextPath}/ProposalServlet" class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                        <i class="fas fa-plus-circle mr-2"></i> Create new request
                    </a>
                </div>

                <!-- Search and Filter Form -->
                <form action="ListProposalServlet" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <select name="searchType" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">                         
                            <option value="">All Type</option>
                            <option value="import_from_supplier" ${param.searchType == 'import_from_supplier' ? 'selected' : ''}>Purchase</option>
                            <option value="import_returned" ${param.searchType == 'import_returned' ? 'selected' : ''}>Retrieve</option>
                            <option value="export" ${param.searchType == 'export' ? 'selected' : ''}>Export</option>
                        </select>                   
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <select name="searchStatus" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">                         
                            <option value="">All Status</option>
                            <option value="pending" ${param.searchStatus == 'pending' ? 'selected' : ''}>Pending</option>
                            <option value="approved_by_admin" ${param.searchStatus == 'approved_by_admin' ? 'selected' : ''}>Mgr Approved</option>
                            <option value="approved_but_not_executed" ${param.searchStatus == 'approved_but_not_executed' ? 'selected' : ''}>To Execute</option>
                            <option value="executed" ${param.searchStatus == 'executed' ? 'selected' : ''}>Executed</option>
                            <option value="rejected" ${param.searchStatus == 'rejected' ? 'selected' : ''}>Rejected</option>
                        </select>                 
                    </div>
                     From :
                    <div class="flex-1 min-w-[200px]">
            
                        <input type="date" name="searchStartDate" id="searchStartDate"
                               value="${param.searchStartDate}"
                               max="<%= java.time.LocalDate.now()%>"
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg
                               focus:outline-none focus:ring-2 focus:ring-primary-500
                               dark:bg-gray-700 dark:text-white" />       
                    </div>
                     To :
                    <div class="flex-1 min-w-[150px]">
                        <input type="date" name="searchEndDate" id="searchEndDate"
                               value="${param.searchEndDate}"
                               max="<%= java.time.LocalDate.now()%>"
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg
                               focus:outline-none focus:ring-2 focus:ring-primary-500
                               dark:bg-gray-700 dark:text-white" />
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                    <a href="${pageContext.request.contextPath}/ListProposalServlet" onclick="Listevent.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;" class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-undo mr-2"></i> Reset form
                    </a>
                    <div class="w-full flex items-center gap-2 mt-2">
                        <span class="text-gray-700 dark:text-gray-300">Items per page:</span>
                        <select name="recordsPerPage" onchange="this.form.submit()" 
                                class="border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                            <option value="5" ${recordsPerPage == '5' ? 'selected' : ''}>5 requests/page</option>
                            <option value="10" ${recordsPerPage == '10' ? 'selected' : ''}>10 requests/page</option>
                            <option value="15" ${recordsPerPage == '15' ? 'selected' : ''}>15 requests/page</option>
                        </select>
                    </div>

                </form>

                <!-- Table -->
                <div class="table-container bg-white dark:bg-gray-800">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-primary-600 text-white">
                                    <th class="p-4 text-left">ID</th>
                                    <th class="p-4 text-left">Type</th>
                                    <th class="p-4 text-left">Time Sent</th>
                                    <th class="p-4 text-left">Status</th>
                                    <th class="p-4 text-left">Note</th>
                                    <th class="p-4 text-left">Detail</th>
                                    <th class="p-4 text-left">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty proposals}">
                                        <c:forEach var="item" items="${proposals}">
                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="p-4 font-medium">${item.proposalId}</td>
                                                <td class="p-4 font-medium">
                                                    <c:choose>
                                                        <c:when test="${item.proposalType == 'import_from_supplier'}">Purchase</c:when>
                                                        <c:when test="${item.proposalType == 'import_returned'}">Retrieve</c:when>
                                                        <c:when test="${item.proposalType == 'export'}">Export</c:when>
                                                    </c:choose>
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <fmt:formatDate value="${item.proposalSentDate}" pattern="HH:mm, dd MMM yyyy"/>
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <c:choose>
                                                        <c:when test="${item.finalStatus == 'rejected'}">
                                                            <span class="badge badge-danger">Rejected</span> 
                                                        </c:when>
                                                        <c:when test="${item.finalStatus == 'pending'}">
                                                            <span class="badge badge-warning">Pending</span> 
                                                        </c:when>
                                                        <c:when test="${item.finalStatus == 'approved_by_admin'}">
                                                            <span class="badge badge-success-border-subtle">Mgr Approved</span> 
                                                        </c:when>
                                                        <c:when test="${item.finalStatus == 'approved_but_not_executed'}">
                                                            <span class="badge badge-success-bg-subtle">To Execute</span> 
                                                        </c:when>
                                                        <c:when test="${item.finalStatus == 'executed'}">
                                                            <span class="badge badge-success">Executed</span> 
                                                        </c:when>
                                                    </c:choose>
                                                </td>

                                                <td class="p-4 font-medium">${item.note}</td>
                                                <td class="p-4 font-medium">
                                                    <a href="DetailProposalServlet?proposalId=${item.proposalId}" class="text-primary-600 dark:text-primary-400 hover:underline">Detail </a>
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <c:choose>
                                                        <c:when test="${item.finalStatus == 'rejected'}">
                                                            <a href="EditProposalServlet?proposalId=${item.proposalId}" class="text-primary-600 dark:text-primary-400 hover:underline">
                                                                Edit
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-gray-400 italic">Cannot edit</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="p-4 text-center text-gray-500 dark:text-gray-400">
                                                No proposal found
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
                    <!-- Nút trang trước -->
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="ListProposalServlet?page=${currentPage - 1}&recordsPerPage=${param.recordsPerPage}&searchType=${param.searchType}&searchStatus=${param.searchStatus}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&lt;</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&lt;</span>
                        </c:otherwise>
                    </c:choose>
                    <!-- Trang 1 luôn hiện -->
                    <c:choose>
                        <c:when test="${currentPage == 1}">
                            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
                        </c:when>
                        <c:otherwise>
                            <a href="ListProposalServlet?page=1&recordsPerPage=${param.recordsPerPage}&searchType=${param.searchType}&searchStatus=${param.searchStatus}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}" class="px-3 py-1 rounded border hover:border-blue-500">1</a>
                        </c:otherwise>
                    </c:choose>
                    <!-- Dấu ... nếu khoảng cách trang hiện tại > 3 với trang 1 -->
                    <c:if test="${currentPage > 4}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <!-- Hiển thị các trang giữa: từ max(2, currentPage-1) đến min(totalPages-1, currentPage+1) -->
                    <c:forEach var="i" begin="${currentPage - 1 > 1 ? currentPage - 1 : 2}" end="${currentPage + 1 < totalPages ? currentPage + 1 : totalPages - 1}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="ListProposalServlet?page=${i}&recordsPerPage=${param.recordsPerPage}&searchType=${param.searchType}&searchStatus=${param.searchStatus}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}" class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <!-- Dấu ... nếu khoảng cách trang hiện tại < totalPages - 3 -->
                    <c:if test="${currentPage < totalPages - 3}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    <!-- Trang cuối (nếu > 1) -->
                    <c:if test="${totalPages > 1}">
                        <c:choose>
                            <c:when test="${currentPage == totalPages}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${totalPages}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="ListProposalServlet?page=${totalPages}&recordsPerPage=${param.recordsPerPage}&searchType=${param.searchType}&searchStatus=${param.searchStatus}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}" class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <!-- Nút trang sau -->
                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="ListProposalServlet?page=${currentPage + 1}&recordsPerPage=${param.recordsPerPage}&searchType=${param.searchType}&searchStatus=${param.searchStatus}&searchStartDate=${param.searchStartDate}&searchEndDate=${param.searchEndDate}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&gt;</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&gt;</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="mt-6 flex justify-center">
                    <jsp:include page="/view/backToDashboardButton.jsp" />
                </div>
            </div>
        </main>

        <!--JavaScript -->
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                const form = document.querySelector('form');
                const startDateInput = document.getElementById('searchStartDate');
                const endDateInput = document.getElementById('searchEndDate');

                form.addEventListener('submit', function (e) {
                    const today = new Date().toISOString().split('T')[0];
                    const startDate = startDateInput.value;
                    const endDate = endDateInput.value;
                    // Kiểm tra startDate định dạng hợp lệ
                    if (startDate && isNaN(Date.parse(startDate))) {
                        alert("Start date is invalid.");
                        e.preventDefault();
                        return;
                    }

                    // Kiểm tra endDate định dạng hợp lệ
                    if (endDate && isNaN(Date.parse(endDate))) {
                        alert("End date is invalid.");
                        e.preventDefault();
                        return;
                    }


                    if (startDate && endDate && endDate < startDate) {
                        alert("End date cannot be earlier than start date.");
                        e.preventDefault();
                    }
                });
            });
        </script>

        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>
