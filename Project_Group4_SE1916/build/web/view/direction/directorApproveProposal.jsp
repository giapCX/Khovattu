<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Director Approve Proposal</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Style CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
    
    <style>
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
        .success {
            color: #059669;
            font-weight: 600;
        }
        .error {
            color: #dc2626;
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
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white flex items-center gap-2">
                        <i class="fas fa-file-alt"></i>
                         Director Approve Request
                    </h2>
                </div>
                <a href="${pageContext.request.contextPath}/proposals" 
                   class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                    <i class="fas fa-arrow-left mr-2"></i>Back to Proposals History
                </a>
            </div>

            <!-- Information Proposal Card -->
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 mb-6">
                <div class="bg-primary-600 text-white px-6 py-4 rounded-t-lg">
                    <h3 class="text-lg font-semibold flex items-center gap-2">
                        <i class="fas fa-info-circle"></i>
                        Information Request
                    </h3>
                </div>
                <div class="p-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Proposal ID</label>
                            <input class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                   value="${proposal.proposalId}" readonly>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Proposer</label>
                            <input class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                   value="${proposal.senderName}" readonly>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Proposal Type</label>
                            <div class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100">
                                    <c:choose>
                                        <c:when test='${proposal.proposalType == "import_from_supplier"}'>Purchase</c:when>
                                        <c:when test='${proposal.proposalType == "import_returned"}'>Retrieve</c:when>
                                        <c:otherwise>${proposal.proposalType}</c:otherwise>
                                    </c:choose>
                                </div>
                        </div>
                        <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Supplier</label>
                                <input class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                       value="${proposal.supplierName}" readonly>
                            </div>
                        </c:if>
                        <c:if test="${proposal.proposalType == 'import_returned' || proposal.proposalType == 'export'}">
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Construction Site</label>
                                <input class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                       value="${proposal.siteName}" readonly>
                            </div>
                        </c:if>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Submission Date</label>
                            <input class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                   value="<fmt:formatDate value='${proposal.proposalSentDate}' pattern='yyyy-MM-dd'/>" readonly>
                        </div>
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Note</label>
                            <textarea class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                      rows="3" readonly>${proposal.note}</textarea>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Admin Status</label>
                            <div class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700">
                                <c:choose>
                                    <c:when test="${proposal.approval.adminStatus == 'pending'}">
                                        <span class="badge badge-warning">Pending</span>
                                    </c:when>
                                    <c:when test="${proposal.approval.adminStatus == 'approved'}">
                                        <span class="badge badge-success">Approved</span>
                                    </c:when>
                                    <c:when test="${proposal.approval.adminStatus == 'rejected'}">
                                        <span class="badge badge-danger">Rejected</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">${proposal.approval.adminStatus}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Director Status</label>
                            <div class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700">
                                <c:choose>
                                    <c:when test="${proposal.approval.directorStatus == 'pending'}">
                                        <span class="badge badge-warning">Pending</span>
                                    </c:when>
                                    <c:when test="${proposal.approval.directorStatus == 'approved'}">
                                        <span class="badge badge-success">Approved</span>
                                    </c:when>
                                    <c:when test="${proposal.approval.directorStatus == 'rejected'}">
                                        <span class="badge badge-danger">Rejected</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">${proposal.approval.directorStatus}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                       
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Admin Note</label>
                            <textarea class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                      rows="2" readonly>${proposal.approval.adminNote}</textarea>
                        </div>
                        <c:if test="${proposal.approval.directorStatus != 'pending'}">
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Director Note</label>
                                <textarea class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100" 
                                          rows="3" readonly>${proposal.approval.directorNote}</textarea>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- List of Proposed Materials Card -->
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 mb-6">
                <div class="bg-primary-600 text-white px-6 py-4 rounded-t-lg">
                    <h3 class="text-lg font-semibold flex items-center gap-2">
                        <i class="fas fa-list-alt"></i>
                       List of Request Materials
                    </h3>
                </div>
                <div class="p-6">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-gray-100 dark:bg-gray-700">
                                    <th class="px-4 py-3 text-left text-sm font-medium text-gray-700 dark:text-gray-300">
                                        <i class="fas fa-box mr-1"></i>Name of Material
                                    </th>
                                    <th class="px-4 py-3 text-left text-sm font-medium text-gray-700 dark:text-gray-300">
                                        <i class="fas fa-ruler mr-1"></i>Unit
                                    </th>
                                    <th class="px-4 py-3 text-left text-sm font-medium text-gray-700 dark:text-gray-300">
                                        <i class="fas fa-sort-numeric-up mr-1"></i>Quantity
                                    </th>
                                    <th class="px-4 py-3 text-left text-sm font-medium text-gray-700 dark:text-gray-300">
                                        <i class="fas fa-info-circle mr-1"></i>Material Condition
                                    </th>
                                    <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                        <th class="px-4 py-3 text-left text-sm font-medium text-gray-700 dark:text-gray-300">
                                            <i class="fas fa-money-bill-wave mr-1"></i>Price (VNĐ)
                                        </th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                                <c:forEach var="detail" items="${proposal.proposalDetails}">
                                    <tr class="hover:bg-gray-50 dark:hover:bg-gray-700">
                                        <td class="px-4 py-3 text-gray-900 dark:text-gray-100">${detail.materialName}</td>
                                        <td class="px-4 py-3 text-gray-900 dark:text-gray-100">${detail.unit}</td>
                                        <td class="px-4 py-3 text-gray-900 dark:text-gray-100">${detail.quantity}</td>
                                        <td class="px-4 py-3 text-gray-900 dark:text-gray-100">${detail.materialCondition}</td>
                                        <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                            <td class="px-4 py-3 text-gray-900 dark:text-gray-100">
                                                <fmt:formatNumber value="${detail.price}" type="number" minFractionDigits="0" maxFractionDigits="2" />
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty proposal.proposalDetails}">
                                    <tr>
                                        <td colspan="5" class="px-4 py-8 text-center text-gray-500 dark:text-gray-400">
                                            <i class="fas fa-inbox text-3xl mb-2"></i>
                                            <p>No materials proposed.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Director Approval Form -->
            <c:if test="${proposal.approval.directorStatus == 'pending'}">
                <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 mb-6">
                    <div class="bg-primary-600 text-white px-6 py-4 rounded-t-lg">
                        <h3 class="text-lg font-semibold flex items-center gap-2">
                            <i class="fas fa-check-circle"></i>
                            Director Approval
                        </h3>
                    </div>
                    <div class="p-6">
                        <form action="${pageContext.request.contextPath}/DirectorApproveProposal" method="post" onsubmit="return validateForm()">
                            <input type="hidden" name="proposalId" value="${proposal.proposalId}">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Director Status</label>
                                    <select name="directorStatus" id="directorStatus" 
                                            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                                            required>
                                        <option value="approved">Approved</option>
                                        <option value="rejected">Rejected</option>
                                    </select>
                                </div>
                                <div class="md:col-span-2">
                                    <label for="directorNote" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Director Note</label>
                                    <textarea class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                                              name="directorNote" id="directorNote" rows="3" 
                                              placeholder="Enter your notes (required if rejected)"></textarea>
                                    <small id="noteError" class="text-red-500 mt-1 hidden">Note is required when rejecting</small>
                                </div>
                            </div>
                            <div class="flex justify-end gap-3 mt-6">
                                <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                                    <i class="fas fa-save mr-2"></i>Submit Decision
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <script>
                    function validateForm() {
                        const status = document.getElementById('directorStatus').value;
                        const note = document.getElementById('directorNote').value.trim();
                        const noteError = document.getElementById('noteError');
                        
                        if (status === 'rejected' && note === '') {
                            noteError.classList.remove('hidden');
                            return false;
                        }
                        noteError.classList.add('hidden');
                        return true;
                    }
                    
                    // Show/hide note requirement based on status selection
                    document.getElementById('directorStatus').addEventListener('change', function() {
                        const noteLabel = document.querySelector('label[for="directorNote"]');
                        if (this.value === 'rejected') {
                            noteLabel.innerHTML = 'Director Note <span class="text-red-500">*</span>';
                        } else {
                            noteLabel.innerHTML = 'Director Note';
                        }
                    });
                </script>
            </c:if>

            <!-- Messages -->
            <c:if test="${not empty message}">
                <div class="bg-green-50 border border-green-200 rounded-lg p-4 mb-6">
                    <div class="flex items-center">
                        <i class="fas fa-check-circle text-green-500 mr-2"></i>
                        <p class="success">${message}</p>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle text-red-500 mr-2"></i>
                        <p class="error">${error}</p>
                    </div>
                </div>
            </c:if>

            <!-- Back to Dashboard Button -->
            <div class="flex justify-center">
                <jsp:include page="/view/backToDashboardButton.jsp" />
            </div>
        </div>
    </main>

    <!-- JavaScript -->
    <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
</body>
</html>