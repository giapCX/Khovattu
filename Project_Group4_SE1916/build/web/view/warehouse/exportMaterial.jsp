<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Export Material</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">      
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");
            String userFullName = (String) session.getAttribute("fullName");
            if (userFullName == null && userId != null) {
                UserDAO userDAO = new UserDAO();
                User user = userDAO.getUserById(userId);
                userFullName = user != null ? user.getFullName() : "Unknown User";
            } else if (userFullName == null) {
                userFullName = "Unknown User";
            }
            if (role == null || !role.equals("warehouse")) {
                response.getWriter().write("Access denied. Please log in as warehouse.");
                return;
            }

            LocalDateTime now = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            String currentDateTime = now.format(formatter);
        %>

        <!-- Error/Success Messages -->
        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4 mx-auto max-w-6xl">
                <span class="block sm:inline">${error}</span>
            </div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4 mx-auto max-w-6xl">
                <span class="block sm:inline">${success}</span>
            </div>
        </c:if>

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
                <form action="${pageContext.request.contextPath}/exportMaterial" method="post" class="space-y-6">
                    <input type="hidden" name="exporterId" value="<%= userId%>" />
                    <input type="hidden" name="proposalId" value="${proposalId}" />

                    <!-- Header -->
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-4">
                            <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                                <i class="fas fa-bars text-2xl"></i>
                            </button>
                            <h2 class="text-2xl font-bold text-gray-800">Export Material</h2>
                        </div>
                    </div>

                    <!-- Exporter -->
                    <div class="bg-white shadow-md rounded-lg p-4">
                        <label class="block text-sm font-medium text-gray-700">Exporter</label>
                        <p class="mt-1 text-gray-900"><%= userFullName%></p>
                    </div>

                    <!-- Form Inputs -->
                    <div class="bg-white shadow-md rounded-lg p-6">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Proposal ID</label>
                                <input type="number" name="proposalId" value="${proposalId}" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" readonly>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Receiver</label>
                                <select name="receiverId" id="receiverId" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" required>
                                    <option value="">Select Receiver</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Construction Site</label>
                                <p class="mt-1 text-gray-900">${not empty proposal.siteName ? fn:escapeXml(proposal.siteName) : 'N/A'}</p>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Export Date</label>
                                <input type="datetime-local" name="exportDate" value="<%= currentDateTime%>" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" required>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Proposal Type</label>
                                <input type="text" name="proposalType" value="${proposal.proposalType}" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" readonly>
                                <input type="hidden" name="proposalType" value="${proposal.proposalType}">
                            </div>



                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700">Note</label>
                                <textarea name="note" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" rows="3" required></textarea>
                            </div>
                        </div>
                        <button type="submit" class="mt-4 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">Submit Export</button>
                    </div>

                    <!-- Proposal Details -->
                    <c:if test="${not empty proposal}">
                        <div class="bg-white shadow-md rounded-lg overflow-hidden mt-6">
                            <h3 class="text-lg font-medium text-gray-700 p-4">Proposal Details</h3>
                            <table class="w-full text-sm text-left text-gray-500">
                                <thead class="text-xs text-gray-700 uppercase bg-gray-50">
                                    <tr>
                                        <th class="px-6 py-3">No</th>
                                        <th class="px-6 py-3">Material</th>
                                        <th class="px-6 py-3">Unit</th>
                                        <th class="px-6 py-3">Quantity</th>
                                        <th class="px-6 py-3">Condition</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty proposal.proposalDetails}">
                                            <tr><td colspan="5" class="px-6 py-4 text-center">No details available.</td></tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="detail" items="${proposal.proposalDetails}" varStatus="status">
                                                <tr class="border-b border-gray-200">
                                                    <td class="px-6 py-4">${status.index + 1}</td>
                                                    <td class="px-6 py-4">${not empty detail.materialName ? fn:escapeXml(detail.materialName) : 'N/A'}</td>
                                                    <td class="px-6 py-4">${not empty detail.unit ? fn:escapeXml(detail.unit) : 'N/A'}</td>
                                                    <td class="px-6 py-4">
                                                        <fmt:formatNumber value="${not empty detail.quantity ? detail.quantity : 0}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                                    </td>
                                                    <td class="px-6 py-4">${not empty detail.materialCondition ? fn:escapeXml(detail.materialCondition) : 'N/A'}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </c:if>
                </form>

                <!-- Link to List Execute -->
                <div class="mt-6 text-center">
                    <a href="${pageContext.request.contextPath}/ListProposalExecute?filter=export_only" class="inline-block bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">Go to Execute List</a>
                </div>
            </div>
        </main>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
               

                // Fetch employees and populate receiver dropdown
                fetch('${pageContext.request.contextPath}/exportMaterial?action=getEmployees')
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Network response was not ok');
                            }
                            return response.json();
                        })
                        .then(data => {
                            console.log('Fetched employees:', data);
                            const receiverSelect = document.getElementById('receiverId');
                            data.forEach(employee => {
                                const option = document.createElement('option');
                                option.value = employee.userId;
                                option.textContent = employee.fullName || 'Unknown User';
                                receiverSelect.appendChild(option);
                            });
                            console.log('Final receiver select:', receiverSelect.outerHTML);
                        })
                        .catch(error => {
                            console.error('Error fetching employees:', error);
                            const receiverSelect = document.getElementById('receiverId');
                            const option = document.createElement('option');
                            option.textContent = 'Error loading employees';
                            receiverSelect.appendChild(option);
                        });
            });
        </script>
        
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>