<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Proposals List</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        .table-hover tbody tr:hover {
            background-color: #e0f7fa;
            transition: all 0.3s ease;
        }
    </style>
</head>
<body class="bg-gradient-to-br from-sky-100 via-cyan-100 to-blue-100 font-sans min-h-screen">
    <div class="container mx-auto p-6">
        <!-- Title -->
        <h1 class="text-4xl font-extrabold text-center mb-8 bg-clip-text text-transparent bg-gradient-to-r from-sky-600 to-blue-600 animate-pulse">
            Pending Proposals List
        </h1>

        <!-- Search and Filter Bar -->
        <form action="${pageContext.request.contextPath}/AdminApproveServlet" method="get" id="filterForm">
            <div class="flex flex-col md:flex-row justify-between mb-6 gap-4">
                <div class="flex w-full md:w-1/3 gap-2">
                    <div class="relative flex-1">
                        <input type="text" id="searchInput" name="search" value="${search}" placeholder="Search by sender name..."
                               class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
                        <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
                    </div>
                    <button type="submit" id="searchButton" class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
                        <i class="fas fa-search mr-2"></i>Search
                    </button>
                </div>
                <div class="flex flex-col md:flex-row gap-4 w-full md:w-2/3">
                    <div class="relative w-full md:w-1/3">
                        <input type="date" id="dateFrom" name="dateFrom" value="${dateFrom}"
                               class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
                        <i class="fas fa-calendar-alt absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
                    </div>
                    <div class="relative w-full md:w-1/3">
                        <input type="date" id="dateTo" name="dateTo" value="${dateTo}"
                               class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
                        <i class="fas fa-calendar-alt absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
                    </div>
                    <div class="relative w-full md:w-1/3">
                        <select id="status" name="status" class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white"
                                onchange="document.getElementById('filterForm').submit()">
                            <option value="" ${empty status ? 'selected' : ''}>All Status</option>
                            <option value="pending" ${status == 'pending' ? 'selected' : ''}>Pending</option>
                            <option value="approved_by_admin" ${status == 'approved_by_admin' ? 'selected' : ''}>Approved by Admin</option>
                            <option value="approved_by_director" ${status == 'approved_by_director' ? 'selected' : ''}>Approved by Director</option>
                            <option value="rejected" ${status == 'rejected' ? 'selected' : ''}>Rejected</option>
                        </select>
                        <i class="fas fa-filter absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
                    </div>
                </div>
            </div>

            <!-- Items per Page Selector -->
            <div class="flex justify-end mb-4">
                <select id="itemsPerPage" name="itemsPerPage" class="p-3 border-2 border-sky-300 rounded-xl w-full md:w-1/5 focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white"
                        onchange="document.getElementById('filterForm').submit()">
                    <option value="10" ${itemsPerPage == '10' ? 'selected' : ''}>10 proposals/page</option>
                    <option value="20" ${itemsPerPage == '20' ? 'selected' : ''}>20 proposals/page</option>
                    <option value="30" ${itemsPerPage == '30' ? 'selected' : ''}>30 proposals/page</option>
                </select>
            </div>
        </form>

        <!-- Proposals Table -->
        <div class="overflow-x-auto rounded-2xl shadow-xl">
            <table class="min-w-full bg-white table-hover">
                <thead class="bg-gradient-to-r from-sky-600 to-blue-600 text-white">
                    <tr>
                        <th class="py-4 px-6 text-left rounded-tl-2xl"><i class="fas fa-list-ol mr-2"></i>#</th>
                        <th class="py-4 px-6 text-left"><i class="fas fa-id-badge mr-2"></i>Proposal ID</th>
                        <th class="py-4 px-6 text-left"><i class="fas fa-box mr-2"></i>Proposal Type</th>
                        <th class="py-4 px-6 text-left"><i class="fas fa-user mr-2"></i>Sender</th>
                        <th class="py-4 px-6 text-left"><i class="fas fa-calendar-alt mr-2"></i>Send Date</th>
                        <th class="py-4 px-6 text-left"><i class="fas fa-calendar-check mr-2"></i>Approval Date</th>
                        <th class="py-4 px-6 text-left"><i class="fas fa-check-circle mr-2"></i>Admin Status</th>
                        <th class="py-4 px-6 text-left"><i class="fas fa-check-circle mr-2"></i>Director Status</th>
                        <th class="py-4 px-6 text-left rounded-tr-2xl"><i class="fas fa-eye mr-2"></i>Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    <c:forEach var="proposal" items="${pendingProposals}" varStatus="loop">
                        <tr class="hover:bg-gradient-to-r hover:from-sky-50 hover:to-cyan-50 transition-all duration-300">
                            <td class="py-4 px-6 font-medium">${(currentPage - 1) * itemsPerPage + loop.count}</td>
                            <td class="py-4 px-6">${proposal.proposalId}</td>
                            <td class="py-4 px-6">${proposal.proposalType}</td>
                            <td class="py-4 px-6">${proposal.senderName}</td>
                            <td class="py-4 px-6"><fmt:formatDate value="${proposal.proposalSentDate}" pattern="yyyy-MM-dd" /></td>
                            <td class="py-4 px-6">${proposal.approvalDate == null ? 'Not Approved' : ''}<fmt:formatDate value="${proposal.approvalDate}" pattern="yyyy-MM-dd" /></td>
                            <td class="py-4 px-6">
                                <span class="px-3 py-1 rounded-full font-semibold <c:choose>
                                    <c:when test="${proposal.finalStatus == 'pending'}">bg-yellow-300 text-yellow-900 animate-bounce</c:when>
                                    <c:when test="${proposal.finalStatus == 'approved_by_admin'}">bg-green-300 text-green-900</c:when>
                                    <c:when test="${proposal.finalStatus == 'rejected'}">bg-red-300 text-red-900</c:when>
                                    <c:otherwise>bg-gray-300 text-gray-900</c:otherwise>
                                </c:choose>">
                                    <c:choose>
                                        <c:when test="${proposal.finalStatus == 'pending'}">Pending</c:when>
                                        <c:when test="${proposal.finalStatus == 'approved_by_admin'}">Approved</c:when>
                                        <c:when test="${proposal.finalStatus == 'rejected'}">Rejected</c:when>
                                        <c:otherwise>Unknown</c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="px-3 py-1 rounded-full font-semibold <c:choose>
                                    <c:when test="${proposal.directorStatus == 'pending'}">bg-yellow-300 text-yellow-900 animate-bounce</c:when>
                                    <c:when test="${proposal.directorStatus == 'approved_by_director'}">bg-blue-300 text-blue-900</c:when>
                                    <c:otherwise>bg-gray-300 text-gray-900</c:otherwise>
                                </c:choose>">
                                    <c:choose>
                                        <c:when test="${proposal.directorStatus == 'pending'}">Pending</c:when>
                                        <c:when test="${proposal.directorStatus == 'approved_by_director'}">Approved</c:when>
                                        <c:otherwise>Unknown</c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td class="py-4 px-6">
                                <a href="${pageContext.request.contextPath}/AdminProposalDetailServlet?id=${proposal.proposalId}"
                                   class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
                                    <i class="fas fa-eye mr-2"></i>View & Edit
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <div class="flex justify-center mt-6 gap-2">
            <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${currentPage - 1}&search=${search}&dateFrom=${dateFrom}&dateTo=${dateTo}&status=${status}&itemsPerPage=${itemsPerPage}"
               class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == 1 ? 'opacity-50 pointer-events-none' : ''}">
                <i class="fas fa-chevron-left mr-2"></i>Previous
            </a>
            <div class="flex gap-2">
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${i}&search=${search}&dateFrom=${dateFrom}&dateTo=${dateTo}&status=${status}&itemsPerPage=${itemsPerPage}"
                       class="px-4 py-2 rounded-lg shadow-md transition-all duration-300 ${i == currentPage ? 'bg-blue-600 text-white' : 'bg-sky-200 text-sky-800 hover:bg-sky-300'}">${i}</a>
                </c:forEach>
            </div>
            <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${currentPage + 1}&search=${search}&dateFrom=${dateFrom}&dateTo=${dateTo}&status=${status}&itemsPerPage=${itemsPerPage}"
               class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == totalPages ? 'opacity-50 pointer-events-none' : ''}">
                Next<i class="fas fa-chevron-right ml-2"></i>
            </a>
        </div>

        <!-- Back Button -->
        <div class="flex justify-end mt-6">
            <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp"
               class="px-4 py-2 bg-gradient-to-r from-gray-500 to-gray-600 text-white rounded-lg hover:from-gray-600 hover:to-gray-700 transition-all duration-300 shadow-md">
                <i class="fas fa-arrow-left mr-2"></i>Back to Dashboard
            </a>
        </div>
    </div>
</body>
</html>