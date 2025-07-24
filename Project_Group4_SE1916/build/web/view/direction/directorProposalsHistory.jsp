<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Construction Material Request History</title>
  
  <!-- Tailwind CSS -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
  
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  
  <!-- Style CSS -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
  
  <style>
    .view-details-cell {
      min-width: 120px;
      word-break: break-word;
    }
    .view-details-cell a {
      display: inline-block;
      white-space: nowrap;
      background-color: #3b82f6;
      color: white;
      padding: 0.5rem 1rem;
      border-radius: 0.5rem;
      text-decoration: none;
      transition: background-color 0.2s;
    }
    .view-details-cell a:hover {
      background-color: #2563eb;
    }
    .error-message {
      color: red;
      font-size: 0.875rem;
      margin-top: 0.25rem;
    }
    .badge {
      padding: 0.25rem 0.75rem;
      border-radius: 0.5rem;
      font-size: 0.875rem;
      font-weight: 600;
    }
    .badge-warning {
      background-color: #fef3c7;
      color: #92400e;
    }
    .badge-success {
      background-color: #d1fae5;
      color: #065f46;
    }
    .badge-danger {
      background-color: #fee2e2;
      color: #991b1b;
    }
    .badge-secondary {
      background-color: #f3f4f6;
      color: #374151;
    }
    /* Smaller header text */
    .table-header {
      font-size: 0.875rem;
      font-weight: 600;
    }
  </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
  <%
      String role = (String) session.getAttribute("role");
      if (role == null) {
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
      <!-- Title and Back Button -->
      <div class="flex justify-between items-center mb-6">
        <div class="flex items-center gap-4">
          <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
            <i class="fas fa-bars text-2xl"></i>
          </button>
          <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Construction Material Request History</h2>
        </div>
        <a href="${pageContext.request.contextPath}/view/direction/directionDashboard.jsp" 
           class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
          <i class="fas fa-arrow-left mr-2"></i>Previous page 
        </a>
      </div>

      <!-- Search and Filter Form -->
      <form id="searchForm" action="${pageContext.request.contextPath}/proposals" method="get" onsubmit="return validateForm()" class="mb-6">
        <div class="flex flex-wrap gap-4 items-center mb-4">
          <div class="flex-1 min-w-[200px]">
            <input type="text" id="searchInput" name="search" value="${param.search}" 
                   placeholder="Search by Proposal ID or Sender..." 
                   class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
          </div>
          <div class="flex-1 min-w-[150px]">
            <select id="statusFilter" name="status" 
                    class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
              <option value="">All Statuses</option>
              <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Pending</option>
              <option value="approved" ${param.status == 'approved' ? 'selected' : ''}>Approved</option>
              <option value="rejected" ${param.status == 'rejected' ? 'selected' : ''}>Rejected</option>
            </select>
          </div>
          <div class="flex-1 min-w-[150px]">
            <input type="date" id="startDate" name="startDate" value="${param.startDate}" 
                   class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
            <div id="startDateError" class="error-message"></div>
          </div>
          <div class="flex-1 min-w-[150px]">
            <input type="date" id="endDate" name="endDate" value="${param.endDate}" 
                   class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
            <div id="endDateError" class="error-message"></div>
          </div>
          <button type="submit" id="searchButton" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
            <i class="fas fa-search mr-2"></i>Search
          </button>
          <a href="${pageContext.request.contextPath}/proposals" 
             onclick="event.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;" 
             class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
            <i class="fas fa-undo mr-2"></i>Reset form
          </a>
        </div>
        
        <!-- Items per Page Selector -->
        <div class="flex items-center gap-4">
          <span class="text-gray-700 dark:text-gray-300">Items per page:</span>
          <select id="itemsPerPage" name="itemsPerPage" onchange="this.form.submit()" 
                  class="border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
            <option value="10" ${param.itemsPerPage == '10' ? 'selected' : ''}>10 items/page</option>
            <option value="20" ${param.itemsPerPage == '20' ? 'selected' : ''}>20 items/page</option>
            <option value="30" ${param.itemsPerPage == '30' ? 'selected' : ''}>30 items/page</option>
          </select>
        </div>
      </form>

      <!-- Table -->
      <div class="table-container bg-white dark:bg-gray-800">
        <div class="overflow-x-auto">
          <table class="w-full table-auto">
            <thead>
              <tr class="bg-primary-600 text-white">
               
                <th class="p-3 text-left sortable table-header" data-sort="proposalId">
                  <i class="fas fa-hashtag mr-1"></i>Proposal ID
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-left sortable table-header" data-sort="proposalType">
                  <i class="fas fa-box mr-1"></i>Proposal Type
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-left sortable table-header" data-sort="senderName">
                  <i class="fas fa-user mr-1"></i>Sender
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-left sortable table-header" data-sort="proposalSentDate">
                  <i class="fas fa-calendar-alt mr-1"></i>Submission Date
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-left sortable table-header" data-sort="note">
                  <i class="fas fa-sticky-note mr-1"></i>Note Sender
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-left sortable table-header" data-sort="approvalDate">
                  <i class="fas fa-calendar-check mr-1"></i>Approval Date Admin
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-left sortable table-header" data-sort="directorApprovalDate">
                  <i class="fas fa-calendar-check mr-1"></i>Approval Date Director
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-left sortable table-header" data-sort="directorStatus">
                  <i class="fas fa-user-tie mr-1"></i>Director Status
                  <i class="fas fa-sort ml-1"></i>
                </th>
                <th class="p-3 text-center view-details-cell table-header">
                  <i class="fas fa-eye mr-1"></i>View Details
                </th>
              </tr>
            </thead>
            <tbody id="requestTableBody" class="divide-y divide-gray-200">
              <c:choose>
                <c:when test="${not empty requests}">
                  <c:forEach var="proposal" items="${requests}" varStatus="loop">
                    <tr class="border-b border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700">
                      <td class="p-4 font-bold">${proposal.proposalId}</td>
                      <td class="p-4">${proposal.proposalType}</td>
                      <td class="p-4">${proposal.senderName}</td>
                      <td class="p-4"><fmt:formatDate value="${proposal.proposalSentDate}" pattern="yyyy-MM-dd"/></td>
                      <td class="p-4">${proposal.note}</td>
                      <td class="p-4">
                        <fmt:formatDate value="${proposal.approvalDate}" pattern="yyyy-MM-dd" var="formattedDate"/>
                        ${empty formattedDate ? 'Not Approved' : formattedDate}
                      </td>
                      <td class="p-4">
                        <fmt:formatDate value="${proposal.approval.directorApprovalDate}" pattern="yyyy-MM-dd" var="directorFormattedDate"/>
                        ${empty directorFormattedDate ? 'Not Approved' : directorFormattedDate}
                      </td>
                      <td class="p-4">
                        <c:choose>
                          <c:when test="${proposal.approval != null and proposal.approval.directorStatus == 'pending'}">
                            <span class="badge badge-warning">Pending</span>
                          </c:when>
                          <c:when test="${proposal.approval != null and proposal.approval.directorStatus == 'approved'}">
                            <span class="badge badge-success">Approved</span>
                          </c:when>
                          <c:when test="${proposal.approval != null and proposal.approval.directorStatus == 'rejected'}">
                            <span class="badge badge-danger">Rejected</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-secondary">Unknown</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="p-4 text-center view-details-cell">
                        <a href="${pageContext.request.contextPath}/DirectorApproveProposal?id=${proposal.proposalId}">
                          <i class="fas fa-eye mr-1"></i>View Details
                        </a>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="10" class="p-4 text-center text-gray-500 dark:text-gray-400">
                      No proposals found
                    </td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Pagination -->
      <div class="pagination flex items-center justify-center space-x-1 mt-6">
        <c:set var="currentPage" value="${param.page == null ? 1 : param.page}"/>
        <c:set var="totalPages" value="${totalPages}"/>
        
        <!-- Previous Button -->
        <c:choose>
          <c:when test="${currentPage > 1}">
            <a href="${pageContext.request.contextPath}/proposals?page=${currentPage - 1}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
               class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&lt;</a>
          </c:when>
          <c:otherwise>
            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&lt;</span>
          </c:otherwise>
        </c:choose>
        
        <!-- Page 1 -->
        <c:choose>
          <c:when test="${currentPage == 1}">
            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
          </c:when>
          <c:otherwise>
            <a href="${pageContext.request.contextPath}/proposals?page=1&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
               class="px-3 py-1 rounded border hover:border-blue-500">1</a>
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
              <a href="${pageContext.request.contextPath}/proposals?page=${i}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
                 class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
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
              <a href="${pageContext.request.contextPath}/proposals?page=${totalPages}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
                 class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
            </c:otherwise>
          </c:choose>
        </c:if>
        
        <!-- Next Button -->
        <c:choose>
          <c:when test="${currentPage < totalPages}">
            <a href="${pageContext.request.contextPath}/proposals?page=${currentPage + 1}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
               class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&gt;</a>
          </c:when>
          <c:otherwise>
            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&gt;</span>
          </c:otherwise>
        </c:choose>
      </div>
      
      <!-- Back to Dashboard Button -->
      <div class="mt-6 flex justify-center">
        <jsp:include page="/view/backToDashboardButton.jsp" />
      </div>
    </div>
  </main>

  <!-- JavaScript -->
  <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
  <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
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