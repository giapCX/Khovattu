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
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                background-color: #f0f2f5;
                color: #1a1a1a;
                min-height: 100vh;
                display: flex;
            }
            .container {
                margin: 0 auto;
                background-color: #fff;
                padding: 20px;
                border-radius: 0 0 0.5rem 0.5rem;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                width: 100%;
                max-width: 1200px;
            }
            h1 {
                text-align: center;
                color: #1f2937;
                margin-bottom: 20px;
            }
            form {
                display: flex;
                flex-direction: column;
                gap: 15px;
            }
            input[type="text"],
            input[type="number"],
            input[type="datetime-local"],
            select,
            textarea {
                padding: 8px;
                border: 1px solid #d1d5db;
                border-radius: 0.5rem;
                font-size: 14px;
                width: 100%;
                background-color: #fff;
                transition: border-color 0.2s, box-shadow 0.2s;
            }
            input[type="text"]:focus,
            input[type="number"]:focus,
            input[type="datetime-local"]:focus,
            select:focus,
            textarea:focus {
                outline: none;
                border-color: #2563eb;
                box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
            }
            input[readonly] {
                background-color: #e5e7eb;
                cursor: not-allowed;
            }
            textarea {
                resize: vertical;
                min-height: 80px;
            }
            button[type="submit"] {
                padding: 8px 16px;
                background-color: #2563eb;
                color: #fff;
                border: none;
                border-radius: 0.5rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            button[type="submit"]:hover {
                background-color: #1d4ed8;
            }
            .table-container {
                background-color: #fff;
                border-radius: 0 0 0.5rem 0.5rem;
                overflow: hidden;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 12px;
                text-align: left;
                border-bottom: 1px solid #e5e7eb;
            }
            th {
                background-color: #0284C7;
                color: #fff;
                font-weight: bold;
            }
            tr:nth-child(even) {
                background-color: #f9fafb;
            }
            tr:hover {
                background-color: #f3f4f6;
            }
            .no-data {
                text-align: center;
                color: #6b7280;
                padding: 20px;
            }
            .error-message, .success-message {
                padding: 12px;
                border-radius: 0.5rem;
                margin-bottom: 15px;
                text-align: center;
            }
            .error-message {
                background-color: #fee2e2;
                border: 1px solid #f87171;
                color: #991b1b;
            }
            .success-message {
                background-color: #dcfce7;
                border: 1px solid #86efac;
                color: #15803d;
            }
            .link-execute {
                display: inline-block;
                margin-top: 20px;
                text-align: center;
                background-color: #2563eb;
                color: #fff;
                text-decoration: none;
                font-weight: bold;
                padding: 8px 16px;
                border-radius: 0.5rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            .link-execute:hover {
                background-color: #1d4ed8;
            }
            @media (max-width: 768px) {
                .container {
                    padding: 15px;
                }
                .grid-cols-1.md\:grid-cols-2 {
                    grid-template-columns: 1fr;
                }
                input[type="text"],
                input[type="number"],
                input[type="datetime-local"],
                select,
                textarea {
                    margin-bottom: 10px;
                }
                button[type="submit"],
                .link-execute {
                    width: 100%;
                    text-align: center;
                }
                table {
                    font-size: 14px;
                }
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");
            String userFullName = (String) session.getAttribute("fullName");
            String success = request.getParameter("success");
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
            <div class="error-message max-w-6xl mx-auto">
                <span>${error}</span>
            </div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="success-message max-w-6xl mx-auto">
                <span>${success}</span>
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
            <div class="container">
                <form id="exportForm" action="${pageContext.request.contextPath}/exportMaterial" method="post" class="space-y-6">
                    <input type="hidden" name="exporterId" value="<%= userId%>" />
                    <input type="hidden" name="proposalId" value="${proposalId}" />

                    <!-- Header -->
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-4">
                            <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                                <i class="fas fa-bars text-2xl"></i>
                            </button>
                            <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Export Material</h2>
                        </div>
                    </div>

                    <!-- Exporter -->
                    <div class="bg-white shadow-md rounded-lg p-4">
                        <label class="block text-sm font-medium">Exporter</label>
                        <p class="mt-1"><%= userFullName%></p>
                    </div>

                    <!-- Form Inputs -->
                    <div class="bg-white shadow-md rounded-lg p-6">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium">Proposal ID</label>
                                <input type="number" name="proposalId" value="${proposalId}" class="mt-1 block w-full" readonly>
                            </div>
                            <div>
                                <label class="block text-sm font-medium">Receiver</label>
                                <select name="receiverId" id="receiverId" class="mt-1 block w-full p-2" required>
                                    <option value="">Select Receiver</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-medium">Construction Site</label>
                                <p class="mt-1">${not empty proposal.siteName ? fn:escapeXml(proposal.siteName) : 'N/A'}</p>
                            </div>
                            <div>
                                <label class="block text-sm font-medium">Export Date</label>
                                <input type="datetime-local" name="exportDate" value="<%= currentDateTime%>" class="mt-1 block w-full" required>
                            </div>
                            <div>
                                <label class="block text-sm font-medium">Proposal Type</label>
                                <input type="text" name="proposalType" value="${proposal.proposalType}" class="mt-1 block w-full" readonly>
                                <input type="hidden" name="proposalType" value="${proposal.proposalType}">
                            </div>
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium">Note</label>
                                <textarea name="note" class="mt-1 block w-full" rows="3" required></textarea>
                            </div>
                        </div>
                        <button type="submit" class="mt-4">Submit Export</button>
                    </div>

                    <!-- Proposal Details -->
                    <c:if test="${not empty proposal}">
                        <div class="table-container mt-6">
                            <h3 class="text-lg font-medium text-gray-700 p-4">Proposal Details</h3>
                            <table>
                                <thead>
                                    <tr>
                                        <th>No</th>
                                        <th>Material</th>
                                        <th>Unit</th>
                                        <th>Quantity</th>
                                        <th>Condition</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty proposal.proposalDetails}">
                                            <tr><td colspan="5" class="no-data">No details available.</td></tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="detail" items="${proposal.proposalDetails}" varStatus="status">
                                                <tr>
                                                    <td>${status.index + 1}</td>
                                                    <td>${not empty detail.materialName ? fn:escapeXml(detail.materialName) : 'N/A'}</td>
                                                    <td>${not empty detail.unit ? fn:escapeXml(detail.unit) : 'N/A'}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${not empty detail.quantity ? detail.quantity : 0}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                                    </td>
                                                    <td>${not empty detail.materialCondition ? fn:escapeXml(detail.materialCondition) : 'N/A'}</td>
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
                    <a href="${pageContext.request.contextPath}/ListProposalExecute?filter=export_only" class="link-execute">Go to Execute List</a>
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

                // Check for success message and redirect
                const success = "<%= success != null ? success : "" %>";
                if (success === "Save successfully") {
                    alert("Save successfully");
                    window.location.href = "${pageContext.request.contextPath}/exportHistory";
                }
            });
        </script>

        <script src="${pageContext.request.contextPath}/assets/js/sidebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>