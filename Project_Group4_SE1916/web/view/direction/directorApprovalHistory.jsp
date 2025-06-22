<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Construction Material Request History</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <style>
    .view-details-cell {
      min-width: 120px;
      word-break: break-word;
    }
    .view-details-cell a {
      display: inline-block;
      white-space: nowrap;
    }
    .error-message {
      color: red;
      font-size: 0.875rem;
      margin-top: 0.25rem;
    }
  </style>
</head>
<body class="bg-gradient-to-br from-sky-100 via-cyan-100 to-blue-100 font-sans min-h-screen">
  <div class="container mx-auto p-6">
    <!-- Title -->
    <h1 class="text-4xl font-extrabold text-center mb-8 bg-clip-text text-transparent bg-gradient-to-r from-sky-600 to-blue-600 animate-pulse">
      Construction Material Request History
    </h1>

    <!-- Search and Filter Bar -->
    <form id="searchForm" action="${pageContext.request.contextPath}/proposals" method="get" onsubmit="return validateForm()">
      <div class="flex flex-col md:flex-row justify-between mb-6 gap-4">
        <div class="flex w-full md:w-1/3 gap-2">
          <div class="relative flex-1">
            <input type="text" id="searchInput" name="search" value="${param.search}" placeholder="Search by Proposal ID or Sender..." 
                   class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
            <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
          </div>
          <button type="submit" id="searchButton" class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
            <i class="fas fa-search mr-2"></i>Search
          </button>
        </div>
        <div class="flex flex-col md:flex-row gap-4 w-full md:w-2/3">
          <div class="relative w-full md:w-1/2">
            <input type="date" id="startDate" name="startDate" value="${param.startDate}" 
                   class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
            <i class="fas fa-calendar-alt absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
            <div id="startDateError" class="error-message"></div>
          </div>
          <div class="relative w-full md:w-1/2">
            <input type="date" id="endDate" name="endDate" value="${param.endDate}" 
                   class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
            <i class="fas fa-calendar-alt absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
            <div id="endDateError" class="error-message"></div>
          </div>
        </div>
        <select id="statusFilter" name="status" class="p-3 border-2 border-sky-300 rounded-xl w-full md:w-1/4 focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
          <option value="">All Statuses</option>
          <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Pending</option>
          <option value="approved" ${param.status == 'approved' ? 'selected' : ''}>Approved</option>
          <option value="rejected" ${param.status == 'rejected' ? 'selected' : ''}>Rejected</option>
        </select>
      </div>

      <!-- Items per Page Selector -->
      <div class="flex justify-end mb-4">
        <select id="itemsPerPage" name="itemsPerPage" class="p-3 border-2 border-sky-300 rounded-xl w-full md:w-1/5 focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
          <option value="10" ${param.itemsPerPage == '10' ? 'selected' : ''}>10 items/page</option>
          <option value="20" ${param.itemsPerPage == '20' ? 'selected' : ''}>20 items/page</option>
          <option value="30" ${param.itemsPerPage == '30' ? 'selected' : ''}>30 items/page</option>
        </select>
      </div>
    </form>

    <!-- Proposals Table -->
    <div class="overflow-x-auto rounded-2xl shadow-xl">
      <table class="min-w-full bg-white">
        <thead class="bg-gradient-to-r from-sky-600 to-blue-600 text-white">
          <tr>
            <th class="py-4 px-6 text-left rounded-tl-2xl"><i class="fas fa-list-ol mr-2"></i>No.</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-box mr-2"></i>Proposal Type</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-user mr-2"></i>Sender</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-calendar-alt mr-2"></i>Submission Date</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-user-check mr-2"></i>Last Approver</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-calendar-check mr-2"></i>Approval Date Admin</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-calendar-check mr-2"></i>Approval Date Director</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-user-tie mr-2"></i>Director Status</th>
            <th class="py-4 px-6 text-center view-details-cell rounded-tr-2xl"><i class="fas fa-eye mr-2"></i>View Details</th>
          </tr>
        </thead>
        <tbody id="requestTableBody" class="divide-y divide-gray-200">
          <c:forEach var="proposal" items="${requests}" varStatus="loop">
            <tr class="hover:bg-gradient-to-r hover:from-sky-50 hover:to-cyan-50 transition-all duration-300">
              <td class="py-4 px-6 font-medium">${(param.page == null ? 1 : param.page - 1) * (param.itemsPerPage == null ? 10 : param.itemsPerPage) + loop.count}</td>
              <td class="py-4 px-6">${proposal.proposalType}</td>
              <td class="py-4 px-6">${proposal.senderName}</td>
              <td class="py-4 px-6"><fmt:formatDate value="${proposal.proposalSentDate}" pattern="yyyy-MM-dd"/></td>
              <td class="py-4 px-6">${proposal.finalApprover == null ? 'Not Available' : proposal.finalApprover}</td>
              <td class="py-4 px-6"><fmt:formatDate value="${proposal.approvalDate}" pattern="yyyy-MM-dd" var="formattedDate"/>${empty formattedDate ? 'Not Approved' : formattedDate}</td>
              <td class="py-4 px-6">
                <fmt:formatDate value="${proposal.approval.directorApprovalDate}" pattern="yyyy-MM-dd" var="directorFormattedDate"/>
                ${empty directorFormattedDate ? 'Not Approved' : directorFormattedDate}
              </td>
              <td class="py-4 px-6">
                <span class="px-3 py-1 rounded-full font-semibold <c:choose>
                  <c:when test="${proposal.directorStatus == 'pending'}">bg-yellow-300 text-yellow-900 animate-bounce</c:when>
                  <c:when test="${proposal.directorStatus == 'approved_by_director'}">bg-green-300 text-green-900</c:when>
                  <c:otherwise>bg-red-300 text-red-900</c:otherwise>
                </c:choose>">
                  <c:choose>
                    <c:when test="${proposal.directorStatus == 'pending'}">Pending</c:when>
                    <c:when test="${proposal.directorStatus == 'approved_by_director'}">Approved by Director</c:when>
                    <c:otherwise>Rejected</c:otherwise>
                  </c:choose>
                </span>
              </td>
              <td class="py-4 px-6 text-center view-details-cell">
                <a href="${pageContext.request.contextPath}/proposal-detail?id=${proposal.proposalId}" 
                   class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
                  <i class="fas fa-eye mr-2"></i>View Details
                </a>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="flex justify-center mt-6 gap-2">
      <c:set var="currentPage" value="${param.page == null ? 1 : param.page}"/>
      <c:set var="totalPages" value="${totalPages}"/>
      <a href="${pageContext.request.contextPath}/proposals?page=${currentPage - 1}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
         class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == 1 ? 'opacity-50 pointer-events-none' : ''}">
        <i class="fas fa-chevron-left mr-2"></i>Previous Page
      </a>
      <div class="flex gap-2">
        <c:forEach begin="1" end="${totalPages}" var="i">
          <a href="${pageContext.request.contextPath}/proposals?page=${i}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
             class="px-4 py-2 rounded-lg shadow-md transition-all duration-300 ${i == currentPage ? 'bg-blue-600 text-white' : 'bg-sky-200 text-sky-800 hover:bg-sky-300'}">${i}</a>
        </c:forEach>
      </div>
      <a href="${pageContext.request.contextPath}/proposals?page=${currentPage + 1}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
         class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == totalPages ? 'opacity-50 pointer-events-none' : ''}">
        Next Page<i class="fas fa-chevron-right ml-2"></i>
      </a>
    </div>
  </div>

  <script>
    function validateForm() {
      const startDateInput = document.getElementById('startDate').value;
      const endDateInput = document.getElementById('endDate').value;
      const startDateError = document.getElementById('startDateError');
      const endDateError = document.getElementById('endDateError');

      // Reset error messages
      startDateError.textContent = '';
      endDateError.textContent = '';

      // Check if dates are provided and valid
      if (startDateInput && !isValidDate(startDateInput)) {
        startDateError.textContent = 'Please enter a valid start date.';
        return false;
      }
      if (endDateInput && !isValidDate(endDateInput)) {
        endDateError.textContent = 'Please enter a valid end date.';
        return false;
      }

      // Check if end date is not before start date
      if (startDateInput && endDateInput && new Date(endDateInput) < new Date(startDateInput)) {
        endDateError.textContent = 'End date must be on or after start date.';
        return false;
      }

      return true;
    }

    function isValidDate(dateString) {
      const date = new Date(dateString);
      return !isNaN(date.getTime());
    }
  </script>
</body>
</html>