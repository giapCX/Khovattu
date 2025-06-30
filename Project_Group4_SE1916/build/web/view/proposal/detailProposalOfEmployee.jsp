<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Proposal</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");
            String userFullName = (String) session.getAttribute("userFullName");
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
        <main class="flex-1 p-8 transition-all duration-300 min-h-screen">
            <div class="max-w-5xl mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Detail Proposal Material ID:${proposalId}</h2>
                </div>
                <div class="space-y-4">
                    <input type="hidden" name="proposalId" value="${proposalId}">
                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Proposer</label>
                        <input type="text" value="${sessionScope.userFullName}" readonly class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>
                    <div class="space-y-2">
                        <label for="proposalType" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Type of proposal</label>
                        <input type="text" value="${proposal.proposalType}" readonly class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>
                    <div class="space-y-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">My note </label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  rows="3" readonly>${proposal.note}</textarea>
                    </div> 
                    <div class="space-y-2">
                        <label for="proposalStatus" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Type of proposal</label>
                        <input type="text" value="${proposal.finalStatus}" readonly class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>
                    <div class="space-y-2">
                        <label for="reasonAdmin" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Reason of admin</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" rows="3" readonly>${proApp.adminReason}</textarea>
                    </div> 
                    <div class="space-y-2">
                        <label for="noteAdmin" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Note of admin</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" rows="3" readonly>${proApp.adminNote}</textarea>
                    </div> 
                    <div class="space-y-2">
                        <label for="reasonDirection" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Reason of direction</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" rows="3" readonly>${proApp.directorReason}</textarea>
                    </div> 
                    <div class="space-y-2">
                        <label for="noteDirection" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Note of direction</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" rows="3" readonly>${proApp.directorNote}</textarea>
                    </div> 
                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">List of Proposed Materials</label>
                        <br/>
                        <div class="table-container bg-white dark:bg-gray-800">
                            <div class="overflow-x-auto">
                                <table class="w-full table-auto">
                                    <thead>
                                        <tr class="bg-primary-600 text-white">
                                            <th class="p-4 text-left">Name of Material</th>
                                            <th class="p-4 text-left">Unit</th>
                                            <th class="p-4 text-left">Quantity</th>
                                            <th class="p-4 text-left">Material Condition </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="detail" items="${proposal.proposalDetails}">
                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="p-4 font-medium">${detail.materialName}</td>
                                                <td class="p-4 font-medium">${detail.unit}</td>
                                                <td class="p-4 font-medium">${detail.quantity}</td>
                                                <td class="p-4 font-medium">${detail.materialCondition}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <br/>
                <c:choose>
                    <c:when test="${proposal.finalStatus == 'rejected'}">
                        <a href="EditProposalServlet?proposalId=${proposal.proposalId}" class="btn-secondary text-white px-6 py-3 rounded-lg">
                            Edit
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="btn-secondary text-white px-6 py-3 rounded-lg">Cannot edit</span>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${role == 'warehouse'}">
                        <div class="mt-4 flex justify-center">
                            <a href="${pageContext.request.contextPath}/ListProposalServlet" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to list proposal</a>
                        </div>
                    </c:when>
                    <c:when test="${role == 'employee'}">
                        <div class="mt-4 flex justify-center">
                            <a href="${pageContext.request.contextPath}/ListProposalServlet" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to list proposal</a>
                        </div>
                    </c:when>
                </c:choose>
            </div>
        </main>
        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    </body>
</html>