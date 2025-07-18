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
        // Lấy ngày giờ hiện tại và định dạng cho input datetime-local
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        String currentDateTime = now.format(formatter);
    %>

    <!-- Hiển thị thông báo lỗi hoặc thành công -->
    <c:if test="${not empty error}">
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            <span class="block sm:inline">${error}</span>
        </div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            <span class="block sm:inline">${success}</span>
        </div>
    </c:if>

    <div class="flex">
        <!-- Sidebar -->
        <aside id="sidebar" class="sidebar w-72 text-white p-4 fixed h-full z-50">
            <div class="sidebar-header flex items-center mb-4">
                <div class="w-10 h-10 rounded-full bg-white flex items-center justify-center mr-2">
                    <i class="fas fa-boxes text-primary-600 text-xl"></i>
                </div>
                <h2 class="text-xl font-bold">Materials Management</h2>
                <button id="toggleSidebar" class="ml-auto text-white opacity-75 hover:opacity-100">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <nav class="space-y-1">
                <a href="${pageContext.request.contextPath}/userprofile" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-user mr-2 w-5 text-center"></i>
                        <span class="text-base">My Information</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/ListMaterialController" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-box-open mr-2 w-5 text-center"></i>
                        <span class="text-base">Materials List</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/inventory" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-boxes mr-2 w-5 text-center"></i>
                        <span class="text-base">Inventory List</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/unit" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-clipboard-list mr-2 w-5 text-center"></i>
                        <span class="text-base">Unit List</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <!-- Supplier - Menu cha -->
                <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fa-truck mr-2 w-5 text-center"></i>
                            <span class="text-base">Suppliers</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href="${pageContext.request.contextPath}/ListSupplierServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">Suppliers List</span>
                        </a>
                    </div>
                </div>
                <!-- Proposal - Menu cha -->
                <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fa-file-alt mr-2 w-5 text-center"></i>
                            <span class="text-base">Proposals</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href="${pageContext.request.contextPath}/ListProposalServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">My Submitted Proposals</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/ListProposalExecute" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">Proposal Execute</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/ProposalServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-circle-plus mr-2 w-4 text-center"></i>
                            <span class="text-sm">Create New Proposal</span>
                        </a>
                    </div>
                </div>
                <div class="border-t border-white border-opacity-20 my-2"></div>
                <a href="${pageContext.request.contextPath}/view/warehouse/importData.jsp" class="nav-item flex items-center p-2 justify-between bg-white bg-opacity-10 rounded-lg">
                    <div class="flex items-center">
                        <i class="fas fa-arrow-down mr-2 w-5 text-center"></i>
                        <span class="text-base">Import Materials</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/importhistory" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-history mr-2 w-5 text-center"></i>
                        <span class="text-base">Import History</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/exportMaterial.jsp" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-arrow-up mr-2 w-5 text-center"></i>
                        <span class="text-base">Export Materials</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/exportHistory" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-history mr-2 w-5 text-center"></i>
                        <span class="text-base">Export History</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
            </nav>
            <div class="absolute bottom-0 left-0 right-0 p-4 bg-white bg-opacity-10">
                <a href="${pageContext.request.contextPath}/forgetPassword/changePassword.jsp" class="flex items-center p-2 rounded-lg hover:bg-white hover:bg-opacity-20">
                    <i class="fas fa-key mr-2 w-5 text-center"></i>
                    <span class="text-base">Change password</span>
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="flex items-center p-2 rounded-lg hover:bg-white hover:bg-opacity-20">
                    <i class="fas fa-sign-out-alt mr-2 w-5 text-center"></i>
                    <span class="text-base">Logout</span>
                </a>
            </div>
        </aside>

        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <form action="${pageContext.request.contextPath}/ImportServlet" method="post" class="space-y-6">
                    <input type="hidden" name="proposalId" value="${proposalId}" />
                    <input type="hidden" name="executorId" value="<%= userId %>" />

                    <!-- Tiêu đề -->
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-4">
                            <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                                <i class="fas fa-bars text-2xl"></i>
                            </button>
                            <h2 class="text-2xl font-bold text-gray-800">Import Material</h2>
                        </div>
                    </div>

                    <!-- Mục Executor -->
                    <div class="bg-white shadow-md rounded-lg p-4">
                        <label class="block text-sm font-medium text-gray-700">Executor</label>
                        <p class="mt-1 text-gray-900"><%= userFullName %></p>
                    </div>

                    <!-- Form nhập liệu -->
                    <div class="bg-white shadow-md rounded-lg p-6">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Import Date</label>
                                <input type="datetime-local" name="importDate" value="<%= currentDateTime %>" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" required>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Proposal Type</label>
                                <input type="text" name="proposalType" value="${proposalType}" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" readonly>
                                <input type="hidden" name="proposalType" value="${proposalType}">
                            </div>
                            <div id="responsibleIdDiv" style="display: ${proposalType == 'import_returned' ? 'block' : 'none'}">
                                <label class="block text-sm font-medium text-gray-700">Responsible ID</label>
                                <input type="number" id="responsibleId" name="responsibleId" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" <c:if test="${proposalType == 'import_returned'}">required</c:if>>
                                <div id="userInfoDisplay" class="hidden mt-2 p-2 bg-gray-100 rounded">
                                    <p><strong>Full Name:</strong> <span id="userFullName"></span></p>
                                    <p><strong>Phone:</strong> <span id="userPhone"></span></p>
                                </div>
                            </div>
                            <div id="deliverySupplierNameDiv" style="display: ${proposalType == 'import_from_supplier' ? 'block' : 'none'}">
                                <label class="block text-sm font-medium text-gray-700">Delivery Supplier Name</label>
                                <input type="text" name="deliverySupplierName" value="" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" <c:if test="${proposalType == 'import_from_supplier'}">required</c:if>>
                            </div>
                            <div id="deliverySupplierPhoneDiv" style="display: ${proposalType == 'import_from_supplier' ? 'block' : 'none'}">
                                <label class="block text-sm font-medium text-gray-700">Delivery Supplier Phone</label>
                                <input type="text" name="deliverySupplierPhone" value="" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" <c:if test="${proposalType == 'import_from_supplier'}">required</c:if>>
                            </div>
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700">Note</label>
                                <textarea name="note" id="note" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" rows="3" required></textarea>
                            </div>
                        </div>
                        <button type="submit" class="mt-4 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">Submit Import</button>
                    </div>
                </form>

                <!-- Link sang List Execute -->
                <div class="mt-6 text-center">
                    <a href="${pageContext.request.contextPath}/ListProposalExecute?filter=import_only" class="inline-block bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">Go to Execute List</a>
                </div>

                <c:if test="${not empty proposal}">
                    <!-- Bảng chi tiết (nếu có proposal) -->
                    <div class="bg-white shadow-md rounded-lg overflow-hidden mt-6">
                        <table class="w-full text-sm text-left text-gray-500">
                            <thead class="text-xs text-gray-700 uppercase bg-gray-50">
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
            if (toggleSidebar) {
                toggleSidebar.addEventListener("click", function () {
                    const sidebar = document.querySelector(".sidebar");
                    sidebar.classList.toggle("hidden");
                });
            }

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

            // Cập nhật hiển thị các trường dựa trên proposalType
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
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
</body>
</html>