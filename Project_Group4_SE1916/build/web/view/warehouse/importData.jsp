<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Import Material</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">
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
        .form-control[readonly] {
            background-color: #e9ecef;
            cursor: not-allowed;
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
    </style>
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
        String success = request.getParameter("success");
    %>

    <div class="flex flex-col md:flex-row">
        <jsp:include page="/view/sidebar/sidebarWarehouse.jsp" />
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="container">
                <header class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h1 class="text-3xl font-bold text-gray-800">Import Material</h1>
                </header>

                <c:if test="${not empty error}">
                    <div class="error-message">${error}</div>
                </c:if>

                <form id="importForm" action="${pageContext.request.contextPath}/ImportServlet" method="post" class="form-section">
                    <input type="hidden" name="proposalId" value="${proposalId}" />
                    <input type="hidden" name="executorId" value="<%= userId %>" />
                    <div class="form-group">
                        <label for="executor">Executor</label>
                        <input type="text" class="form-control" id="executor" value="<%= userFullName %>" readonly>
                    </div>
                    <div class="form-group">
                        <label for="importDate">Import Date</label>
                        <input type="datetime-local" class="form-control" id="importDate" name="importDate" value="<%= currentDateTime %>" required>
                    </div>
                    <div class="form-group">
                        <label for="proposalType">Proposal Type</label>
                        <input type="text" class="form-control" id="proposalType" name="proposalType" value="${proposalType}" readonly>
                        <input type="hidden" name="proposalType" value="${proposalType}">
                    </div>
                    <div class="form-group" id="responsibleIdDiv" style="display: ${proposalType == 'import_returned' ? 'block' : 'none'}">
                        <label for="responsibleId">Responsible ID</label>
                        <input type="number" class="form-control" id="responsibleId" name="responsibleId" <c:if test="${proposalType == 'import_returned'}">required</c:if>>
                        <div id="userInfoDisplay" class="hidden mt-2 p-2 bg-gray-100 rounded">
                            <p><strong>Full Name:</strong> <span id="userFullName"></span></p>
                            <p><strong>Phone:</strong> <span id="userPhone"></span></p>
                        </div>
                    </div>
                    <div class="form-group" id="deliverySupplierNameDiv" style="display: ${proposalType == 'import_from_supplier' ? 'block' : 'none'}">
                        <label for="deliverySupplierName">Delivery Supplier Name</label>
                        <input type="text" class="form-control" id="deliverySupplierName" name="deliverySupplierName" <c:if test="${proposalType == 'import_from_supplier'}">required</c:if>>
                    </div>
                    <div class="form-group" id="deliverySupplierPhoneDiv" style="display: ${proposalType == 'import_from_supplier' ? 'block' : 'none'}">
                        <label for="deliverySupplierPhone">Delivery Supplier Phone</label>
                        <input type="text" class="form-control" id="deliverySupplierPhone" name="deliverySupplierPhone" <c:if test="${proposalType == 'import_from_supplier'}">required</c:if>>
                        <p id="phoneError" class="hidden mt-1 text-sm text-red-600"></p>
                    </div>
                    <div class="form-group">
                        <label for="note">Note</label>
                        <textarea class="form-control" id="note" name="note" rows="3" required></textarea>
                    </div>
                    <div class="button-group mt-3">
                        <button type="submit" class="btn btn-primary">Submit Import</button>
                        <a href="${pageContext.request.contextPath}/WarehouseDashboard" class="btn btn-secondary">Back to Dashboard</a>
                    </div>
                </form>

                <div class="mt-6 text-center">
                    <a href="${pageContext.request.contextPath}/ListProposalExecute?filter=import_only" class="btn btn-primary">Go to Execute List</a>
                </div>

                <c:if test="${not empty proposal}">
                    <div class="table-container mt-6">
                        <table class="w-full text-sm text-left text-gray-500 table">
                            <thead>
                                <tr>
                                    <th class="px-6 py-3">No</th>
                                    <th class="px-6 py-3">Material</th>
                                    <th class="px-6 py-3">Unit</th>
                                    <th class="px-6 py-3">Quantity</th>
                                    <th class="px-6 py-3">Condition</th>
                                    <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                        <th class="px-6 py-3">Supplier</th>
                                        <th class="px-6 py-3">Price (VND)</th>
                                    </c:if>
                                    <c:if test="${proposal.proposalType == 'import_returned'}">
                                        <th class="px-6 py-3">Construction Site</th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty proposal.proposalDetails}">
                                        <tr><td colspan="7" class="px-6 py-4 text-center">No details available.</td></tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="detail" items="${proposal.proposalDetails}" varStatus="status">
                                            <tr class="border-b border-gray-200">
                                                <td class="px-6 py-4">${status.index + 1}</td>
                                                <td class="px-6 py-4">${not empty detail.materialName ? detail.materialName : 'N/A'}</td>
                                                <td class="px-6 py-4">${not empty detail.unit ? detail.unit : 'N/A'}</td>
                                                <td class="px-6 py-4">
                                                    <fmt:formatNumber value="${not empty detail.quantity ? detail.quantity : 0}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                                </td>
                                                <td class="px-6 py-4">${not empty detail.materialCondition ? detail.materialCondition : 'N/A'}</td>
                                                <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                                    <td class="px-6 py-4">${not empty proposal.supplierName ? proposal.supplierName : 'N/A'}</td>
                                                    <td class="px-6 py-4">
                                                        <fmt:formatNumber value="${not empty detail.price ? detail.price : 0}" type="number" minFractionDigits="0" maxFractionDigits="2" />
                                                    </td>
                                                </c:if>
                                                <c:if test="${proposal.proposalType == 'import_returned'}">
                                                    <td class="px-6 py-4">${not empty proposal.siteName ? proposal.siteName : 'N/A'}</td>
                                                </c:if>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </div>
        </main>
    </div>

    <script>
        const activeUsers = [
            <c:forEach var="u" items="${activeUsers}" varStatus="loop">
                { id: ${u.userId}, fullName: "${fn:escapeXml(u.fullName)}", phone: "${fn:escapeXml(u.phone)}" }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        document.addEventListener("DOMContentLoaded", function () {
            const toggleSidebar = document.getElementById("toggleSidebarMobile");
            const closeButton = document.getElementById("toggleSidebar");
            const sidebar = document.querySelector(".sidebar");

            if (toggleSidebar && sidebar) {
                toggleSidebar.addEventListener("click", () => {
                    sidebar.classList.toggle("active");
                });
            }
            if (closeButton && sidebar) {
                closeButton.addEventListener("click", () => {
                    sidebar.classList.toggle("active");
                });
            }

            document.addEventListener("click", (event) => {
                if (window.innerWidth <= 768 && sidebar.classList.contains("active") && 
                    !sidebar.contains(event.target) && !toggleSidebar.contains(event.target)) {
                    sidebar.classList.remove("active");
                }
            });

            const responsibleInput = document.getElementById("responsibleId");
            const displayBox = document.getElementById("userInfoDisplay");
            const fullNameSpan = document.getElementById("userFullName");
            const phoneSpan = document.getElementById("userPhone");

            if (responsibleInput) {
                responsibleInput.addEventListener("input", function () {
                    const trimmed = this.value.trim();
                    const inputId = parseInt(trimmed);
                    if (!isNaN(inputId)) {
                        const user = activeUsers.find(u => u.id === inputId);
                        if (user) {
                            fullNameSpan.textContent = user.fullName;
                            phoneSpan.textContent = user.phone;
                            displayBox.classList.remove("hidden");
                        } else {
                            displayBox.classList.add("hidden");
                        }
                    } else {
                        displayBox.classList.add("hidden");
                    }
                });
            }

            const proposalType = "${proposalType}";
            const responsibleDiv = document.getElementById("responsibleIdDiv");
            const supplierNameDiv = document.getElementById("deliverySupplierNameDiv");
            const supplierPhoneDiv = document.getElementById("deliverySupplierPhoneDiv");
            responsibleDiv.style.display = proposalType === 'import_returned' ? 'block' : 'none';
            supplierNameDiv.style.display = proposalType === 'import_from_supplier' ? 'block' : 'none';
            supplierPhoneDiv.style.display = proposalType === 'import_from_supplier' ? 'block' : 'none';
            responsibleDiv.querySelector("input").required = proposalType === 'import_returned';
            supplierNameDiv.querySelector("input").required = proposalType === 'import_from_supplier';
            supplierPhoneDiv.querySelector("input").required = proposalType === 'import_from_supplier';

            const phoneInput = document.getElementById("deliverySupplierPhone");
            const phoneError = document.getElementById("phoneError");
            const phoneRegex = /^(0|\+84)(3|5|7|8|9)[0-9]{8}$/;

            if (phoneInput) {
                phoneInput.addEventListener("input", function () {
                    const phoneValue = this.value.trim();
                    if (phoneValue === "") {
                        phoneError.textContent = "Phone number is required.";
                        phoneError.classList.remove("hidden");
                        this.classList.add("border-red-500");
                    } else if (!phoneRegex.test(phoneValue)) {
                        phoneError.textContent = "Invalid phone number. Must be a valid Vietnamese number (e.g., 09xxxxxxxx or +84xxxxxxxxx).";
                        phoneError.classList.remove("hidden");
                        this.classList.add("border-red-500");
                    } else {
                        phoneError.textContent = "";
                        phoneError.classList.add("hidden");
                        this.classList.remove("border-red-500");
                    }
                });
            }

            const form = document.getElementById("importForm");
            form.addEventListener("submit", function (event) {
                const phoneValue = phoneInput ? phoneInput.value.trim() : "";
                if (proposalType === "import_from_supplier" && phoneValue !== "" && !phoneRegex.test(phoneValue)) {
                    event.preventDefault();
                    phoneError.textContent = "Invalid phone number. Must be a valid Vietnamese number.";
                    phoneError.classList.remove("hidden");
                    phoneInput.classList.add("border-red-500");
                }
            });

            const success = "<%= success != null ? success : "" %>";
            if (success === "Save successfully") {
                alert("Save successfully");
                window.location.href = "${pageContext.request.contextPath}/importhistory";
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/sidebar_darkmode.js"></script>
</body>
</html>