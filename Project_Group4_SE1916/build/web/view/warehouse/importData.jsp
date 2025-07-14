<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Import Warehouse Data - Inventory Management System</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <link href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" rel="stylesheet">
    <style>
        body {
            @apply bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-100 transition-all duration-300;
        }
        .sidebar {
            @apply bg-gradient-to-b from-blue-600 to-blue-800 shadow-xl transform transition-transform duration-300;
        }
        .sidebar.hidden {
            transform: translateX(-100%);
        }
        .nav-item {
            @apply rounded-lg hover:bg-blue-700 transition-colors duration-200;
        }
        .nav-item.active {
            @apply bg-blue-700;
        }
        .submenu {
            @apply bg-blue-800 bg-opacity-50 rounded-lg;
        }
        .table-container {
            @apply rounded-xl shadow-md overflow-hidden;
        }
        .table-container table {
            @apply w-full border-collapse;
        }
        .table-container th, .table-container td {
            @apply p-4 border-b border-gray-200 dark:border-gray-700;
        }
        .table-container th {
            @apply bg-blue-600 text-white font-semibold;
        }
        .table-container tr:hover {
            @apply bg-gray-50 dark:bg-gray-700;
        }
        .error {
            @apply text-red-500 text-sm mt-1;
        }
        .error-row {
            @apply border-l-4 border-red-500 bg-red-50 dark:bg-red-900;
        }
        .btn-sm {
            @apply text-sm py-1 px-3;
        }
        .btn-disabled {
            @apply opacity-50 cursor-not-allowed;
        }
        .search-input:focus {
            @apply ring-2 ring-blue-500;
        }
        #printReceiptPreview {
            @apply hidden mt-6;
        }
        .ui-autocomplete {
            @apply bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg shadow-lg max-h-60 overflow-y-auto;
        }
        .ui-autocomplete .ui-menu-item {
            @apply px-4 py-2 hover:bg-blue-100 dark:hover:bg-blue-700 cursor-pointer;
        }
    </style>
</head>
<body class="min-h-screen font-sans antialiased">
    <%
        String username = (String) session.getAttribute("username");
        if (username == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        String encodedUsername = java.net.URLEncoder.encode(username, "UTF-8").replace("+", "%20");
        // Generate Receipt ID automatically
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMdd");
        String dateStr = sdf.format(new java.util.Date());
        String receiptId = "IMP-" + dateStr + "-" + String.format("%03d", (int)(Math.random() * 1000));
    %>

    <aside id="sidebar" class="sidebar w-64 text-white p-6 fixed h-full z-50 lg:translate-x-0">
        <div class="flex items-center mb-8">
            <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
                <i class="fas fa-boxes text-blue-600 text-2xl"></i>
            </div>
            <h2 class="text-2xl font-bold">Inventory Management</h2>
            <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100 lg:hidden">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="mb-6 px-2">
            <div class="relative">
                <input type="text" placeholder="Search..." 
                       class="w-full bg-white bg-opacity-20 text-white placeholder-white placeholder-opacity-70 rounded-lg py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-white focus:ring-opacity-50 search-input">
                <i class="fas fa-search absolute left-3 top-2.5 text-white opacity-70"></i>
            </div>
        </div>
        <nav class="space-y-2">
            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="nav-item flex items-center p-3">
                <i class="fas fa-home mr-3 w-6 text-center"></i>
                <span class="text-lg">Dashboard</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="nav-item flex items-center p-3">
                <i class="fas fa-box-open mr-3 w-6 text-center"></i>
                <span class="text-lg">Materials List</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
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
                    <a href="${pageContext.request.contextPath}/AddSupplierServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                        <i class="fas fa-circle-plus mr-2 w-4 text-center"></i>
                        <span class="text-sm">Create New Supplier</span>
                    </a>
                </div>
            </div>
            <div class="nav-item flex flex-col">
                <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                    <div class="flex items-center">
                        <i class="fas fa-file-alt mr-2 w-5 text-center"></i>
                        <span class="text-base">Proposals</span>
                    </div>
                    <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                </button>
                <div class="submenu hidden pl-6 space-y-1 mt-1">
                    <a href="${pageContext.request.contextPath}/myProposals" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                        <i class="fas fa-list mr-2 w-4 text-center"></i>
                        <span class="text-sm">My Submitted Proposals</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/proposalExecute" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                        <i class="fas fa-check-circle mr-2 w-4 text-center"></i>
                        <span class="text-sm">Proposal Execute</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/createProposal" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                        <i class="fas fa-circle-plus mr-2 w-4 text-center"></i>
                        <span class="text-sm">Create New Proposal</span>
                    </a>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/importMaterials" class="nav-item flex items-center p-3 active">
                <i class="fas fa-arrow-down mr-3 w-6 text-center"></i>
                <span class="text-lg">Import Materials</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/importhistory" class="nav-item flex items-center p-3">
                <i class="fas fa-history mr-3 w-6 text-center"></i>
                <span class="text-lg">Import History</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/exportMaterials" class="nav-item flex items-center p-3">
                <i class="fas fa-arrow-up mr-3 w-6 text-center"></i>
                <span class="text-lg">Export Materials</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
            <a href="${pageContext.request.contextPath}/exportHistory" class="nav-item flex items-center p-3">
                <i class="fas fa-history mr-3 w-6 text-center"></i>
                <span class="text-lg">Export History</span>
                <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
            </a>
        </nav>
        <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
            <a href="${pageContext.request.contextPath}/userprofile" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                <i class="fas fa-user mr-3"></i>
                <span class="text-lg">My Information</span>
            </a>
            <a href="${pageContext.request.contextPath}/forgetPassword/changePassword.jsp" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                <i class="fas fa-key mr-3"></i>
                <span class="text-lg">Change Password</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                <i class="fas fa-sign-out-alt mr-3"></i>
                <span class="text-lg">Logout</span>
            </a>
        </div>
    </aside>

    <main class="flex-1 p-6 lg:ml-64 transition-all duration-300">
        <header class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
            <div class="flex items-center gap-4">
                <button id="toggleSidebarMobile" class="text-gray-700 hover:text-blue-600 lg:hidden">
                    <i class="fas fa-bars text-2xl"></i>
                </button>
                <div>
                    <h1 class="text-2xl font-bold text-gray-800 dark:text-white">Add Import Receipt</h1>
                    <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">Create a new import receipt for warehouse materials</p>
                </div>
            </div>
            <div class="flex items-center space-x-4">
                <div class="relative">
                    <i class="fas fa-bell text-gray-500 hover:text-blue-600 cursor-pointer text-lg"></i>
                    <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">3</span>
                </div>
                <div class="flex items-center">
                    <img src="https://ui-avatars.com/api/?name=<%= encodedUsername %>&background=3b82f6&color=fff" 
                         alt="User Avatar" 
                         class="w-8 h-8 rounded-full mr-2" 
                         onerror="this.src='https://via.placeholder.com/40?text=User';">
                    <span class="font-medium text-gray-700 dark:text-white text-base"><%= username %></span>
                </div>
                <button id="toggleDarkMode" class="bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600">
                    <i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-lg"></i>
                </button>
            </div>
        </header>

        <div class="table-container bg-white dark:bg-gray-800 p-6 rounded-xl">
            <div id="successAlert" class="hidden bg-green-100 text-green-700 rounded-lg p-4 mb-4" role="alert"></div>
            <div id="errorAlert" class="hidden bg-red-100 text-red-700 rounded-lg p-4 mb-4" role="alert"></div>
            <form id="importForm" method="post" action="${pageContext.request.contextPath}/ImportMaterialServlet">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <div>
                        <label for="importType" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Import Type</label>
                        <select id="importType" name="importType" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <option value="import_from_supplier">From Supplier</option>
                            <option value="import_returned_from_site">Return from Construction Site</option>
                        </select>
                    </div>
                    <div id="siteField" style="display: none;">
                        <label for="siteId" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Construction Site</label>
                        <select name="siteId" id="siteId" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500" onchange="loadSiteMaterials()">
                            <option value="">Select Construction Site</option>
                            <c:forEach items="${sites}" var="site">
                                <option value="${site.siteId}">${site.siteName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div id="executorField" style="display: none;">
                        <label for="executorId" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Responsible Person ID</label>
                        <input type="number" name="executorId" id="executorId" min="1" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter Responsible Person ID">
                    </div>
                    <div>
                        <label for="receiptId" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Import Receipt Code</label>
                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4" id="receiptId" name="receipt_id" value="<%= receiptId %>" readonly>
                    </div>
                    <div>
                        <label for="importer" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Importer</label>
                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4" id="importer" name="importer" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Not Identified'}" readonly>
                        <c:if test="${empty sessionScope.userFullName}">
                            <p class="error">Not logged in or user information missing. Please log in again.</p>
                        </c:if>
                    </div>
                    <div>
                        <label for="importDate" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Import Date</label>
                        <input type="date" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500" id="importDate" name="import_date" required>
                    </div>
                    <div class="md:col-span-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Note</label>
                        <textarea class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500" id="note" name="note" rows="3" maxlength="1000"></textarea>
                    </div>
                </div>
                <div class="table-container bg-white dark:bg-gray-800 mb-6">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-blue-600 text-white">
                                    <th class="p-4 text-left">#</th>
                                    <th class="p-4 text-left">Material Name</th>
                                    <th class="p-4 text-left">Material Code</th>
                                    <th class="p-4 text-left">Supplier</th>
                                    <th class="p-4 text-left">Quantity</th>
                                    <th class="p-4 text-left">Unit</th>
                                    <th class="p-4 text-left">Unit Price (VND)</th>
                                    <th class="p-4 text-left">Total Price (VND)</th>
                                    <th class="p-4 text-left">Condition</th>
                                    <th class="p-4 text-left">Action</th>
                                </tr>
                            </thead>
                            <tbody id="materialTableBody">
                                <tr>
                                    <td class="p-4 serial-number">1</td>
                                    <td class="p-4">
                                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 material-name-select" required>
                                        <input type="hidden" class="material-id-hidden" name="materialId[]">
                                    </td>
                                    <td class="p-4">
                                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 material-code-select" readonly>
                                    </td>
                                    <td class="p-4">
                                        <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 supplier-select" name="detailSupplierId[]" required>
                                            <option value="">-- Select Supplier --</option>
                                        </select>
                                    </td>
                                    <td class="p-4">
                                        <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 quantity" name="quantity[]" min="0.01" step="0.01" required>
                                    </td>
                                    <td class="p-4">
                                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 unit-display" readonly>
                                    </td>
                                    <td class="p-4">
                                        <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 unit-price" name="price_per_unit[]" min="0.01" step="0.01" required>
                                    </td>
                                    <td class="p-4 total-price">0.00</td>
                                    <td class="p-4">
                                        <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500" name="materialCondition[]" required>
                                            <option value="">Select Condition</option>
                                            <option value="new">New</option>
                                            <option value="used">Used</option>
                                            <option value="damaged">Damaged</option>
                                        </select>
                                    </td>
                                    <td class="p-4">
                                        <button type="button" class="bg-red-500 text-white rounded-lg py-2 px-4 hover:bg-red-600 btn-sm remove-row" disabled>Delete</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="mt-6 flex flex-wrap gap-4">
                    <button type="button" id="addMaterialBtn" class="bg-blue-600 text-white rounded-lg py-2 px-4 hover:bg-blue-700">Add Material</button>
                    <button type="button" id="saveImportBtn" class="bg-green-500 text-white rounded-lg py-2 px-4 hover:bg-green-600">Save Import</button>
                    <button type="button" id="printReceiptBtn" class="bg-gray-500 text-white rounded-lg py-2 px-4 hover:bg-gray-600" onclick="showPrintPreview()">Print Receipt</button>
                    <button type="button" id="backBtn" class="bg-blue-500 text-white rounded-lg py-2 px-4 hover:bg-blue-600" onclick="goBack()">Back</button>
                </div>
                <div class="mt-6 table-container bg-white dark:bg-gray-800 p-6 rounded-xl">
                    <h5 class="text-xl font-semibold text-gray-800 dark:text-white mb-4">Summary</h5>
                    <p class="text-gray-600 dark:text-gray-300">Total Materials: <span id="totalItems">1</span></p>
                    <p class="text-gray-600 dark:text-gray-300">Total Quantity: <span id="totalQuantity">0.00</span></p>
                    <p class="text-gray-600 dark:text-gray-300">Total Amount: <span id="totalAmount">0.00</span> VND</p>
                </div>
                <div id="printReceiptPreview" class="table-container bg-white dark:bg-gray-800 p-6 rounded-xl hidden">
                    <h5 class="text-xl font-semibold text-gray-800 dark:text-white mb-4">Receipt Preview</h5>
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-blue-600 text-white">
                                    <th class="p-4 text-left">Material Name</th>
                                    <th class="p-4 text-left">Quantity</th>
                                    <th class="p-4 text-left">Unit Price</th>
                                    <th class="p-4 text-left">Total Price</th>
                                </tr>
                            </thead>
                            <tbody id="receiptTableBody"></tbody>
                            <tfoot>
                                <tr class="border-t border-gray-200 dark:border-gray-700">
                                    <td class="p-4 text-right font-semibold" colspan="3">Total Amount:</td>
                                    <td class="p-4" id="receiptTotalAmount">0.00</td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                    <div class="mt-4 flex space-x-4">
                        <button type="button" class="bg-blue-600 text-white rounded-lg py-2 px-4 hover:bg-blue-700" onclick="printReceipt()">Print</button>
                        <button type="button" class="bg-gray-500 text-white rounded-lg py-2 px-4 hover:bg-gray-600" onclick="hidePrintPreview()">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </main>

    <footer class="bg-gray-100 dark:bg-gray-800 text-center p-4 mt-8 border-t border-gray-200 dark:border-gray-700">
        <p class="text-gray-600 dark:text-gray-300 text-sm">Inventory Management System - Version 2.0 © 2025 | <a href="mailto:support@company.com" class="text-blue-600 dark:text-blue-400 hover:underline">Contact Support</a></p>
    </footer>

    <script>
        const sidebar = document.getElementById('sidebar');
        const toggleSidebar = document.getElementById('toggleSidebar');
        const toggleSidebarMobile = document.getElementById('toggleSidebarMobile');

        function toggleSidebarVisibility() {
            sidebar.classList.toggle('hidden');
        }

        sidebar.addEventListener('click', (event) => event.stopPropagation());
        toggleSidebar.addEventListener('click', toggleSidebarVisibility);
        toggleSidebarMobile.addEventListener('click', toggleSidebarVisibility);

        document.addEventListener('DOMContentLoaded', () => {
            const toggles = document.querySelectorAll('.toggle-submenu');
            toggles.forEach(toggle => {
                toggle.addEventListener('click', (event) => {
                    event.stopPropagation();
                    const submenu = toggle.parentElement.querySelector('.submenu');
                    submenu.classList.toggle('hidden');
                    const icon = toggle.querySelector('.fa-chevron-down');
                    icon.classList.toggle('rotate-180');
                });
            });

            // Initialize dark mode
            if (localStorage.getItem('darkMode') === 'true') {
                document.body.classList.add('dark');
                document.getElementById('toggleDarkMode').querySelector('i').classList.replace('fa-moon', 'fa-sun');
            }

            // Set default import date to today
            const importDateInput = document.getElementById('importDate');
            const today = new Date().toISOString().split('T')[0];
            importDateInput.value = today;

            // Initialize material autocomplete
            attachMaterialAutocomplete(document.querySelector('.material-name-select'));
        });

        document.getElementById('toggleDarkMode').addEventListener('click', () => {
            document.body.classList.toggle('dark');
            const icon = document.getElementById('toggleDarkMode').querySelector('i');
            icon.classList.toggle('fa-moon');
            icon.classList.toggle('fa-sun');
            localStorage.setItem('darkMode', document.body.classList.contains('dark'));
        });

        function showToast(message, type = 'info') {
            Toastify({
                text: message,
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: type === 'error' ? '#ef4444' : '#3b82f6',
                stopOnFocus: true,
                className: "rounded-lg shadow-lg",
                style: { borderRadius: "0.5rem" }
            }).showToast();
        }

        let materialData = [];

        function attachMaterialAutocomplete(materialInput) {
            $(materialInput).autocomplete({
                source: function (request, response) {
                    const term = request.term.toLowerCase();
                    $.ajax({
                        url: '${pageContext.request.contextPath}/ImportMaterialServlet',
                        data: { action: 'searchMaterials', term: term },
                        method: 'GET',
                        dataType: 'json',
                        success: function (data) {
                            materialData = data;
                            response(data.map(mat => ({
                                label: mat.name,
                                value: mat.material_id,
                                code: mat.material_code || 'N/A',
                                unit: mat.unit || '',
                                suppliers: mat.suppliers || []
                            })));
                        },
                        error: function (xhr, status, error) {
                            console.error('Error loading materials:', error);
                            showToast(`Unable to load material data: ${error}`, 'error');
                            response([]);
                        }
                    });
                },
                select: function (event, ui) {
                    const row = $(this).closest("tr");
                    row.find(".material-name-select").val(ui.item.label);
                    row.find(".material-id-hidden").val(ui.item.value);
                    row.find(".material-code-select").val(ui.item.code);
                    row.find(".unit-display").val(ui.item.unit);

                    const supplierSelect = row.find(".supplier-select");
                    supplierSelect.empty().append('<option value="">-- Select Supplier --</option>');
                    if (ui.item.suppliers && ui.item.suppliers.length > 0) {
                        ui.item.suppliers.forEach(supplier => {
                            supplierSelect.append(new Option(supplier.supplierName, supplier.supplierId));
                        });
                        supplierSelect.prop('disabled', false);
                    } else {
                        supplierSelect.html('<option value="">No Suppliers Available</option>');
                        supplierSelect.prop('disabled', true);
                        showToast('No suppliers are associated with material "' + ui.item.label + '". Please contact the administrator.', 'error');
                    }

                    updateTotalPrice(row[0]);
                    validateSuppliers();
                    return false;
                },
                minLength: 1
            });
        }

        function validateSuppliers() {
            const supplierSelects = document.querySelectorAll('.supplier-select');
            let firstSupplierId = null;
            let isValid = true;

            supplierSelects.forEach((select, index) => {
                if (select.value && !firstSupplierId) {
                    firstSupplierId = select.value;
                } else if (select.value && select.value !== firstSupplierId) {
                    isValid = false;
                    showToast(`All materials must be supplied by the same supplier. Please select supplier ${firstSupplierId} for row ${index + 1}.`, 'error');
                    select.classList.add('border-red-500');
                } else {
                    select.classList.remove('border-red-500');
                }
            });
            document.getElementById('saveImportBtn').disabled = !isValid || supplierSelects.length === 0 || [...supplierSelects].every(select => !select.value);
        }

        function updateSerialNumbers() {
            document.querySelectorAll('#materialTableBody tr').forEach((row, index) => {
                row.querySelector('.serial-number').textContent = index + 1;
            });
        }

        function updateRemoveButtons() {
            const rows = document.querySelectorAll('#materialTableBody tr');
            const removeButtons = document.querySelectorAll('.remove-row');
            const isSingleRow = rows.length === 1;
            removeButtons.forEach(button => {
                button.disabled = isSingleRow;
                button.classList.toggle('btn-disabled', isSingleRow);
            });
        }

        function addMaterialRow() {
            const tableBody = document.getElementById('materialTableBody');
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="p-4 serial-number"></td>
                <td class="p-4">
                    <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 material-name-select" required>
                    <input type="hidden" class="material-id-hidden" name="materialId[]">
                </td>
                <td class="p-4">
                    <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 material-code-select" readonly>
                </td>
                <td class="p-4">
                    <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 supplier-select" name="detailSupplierId[]" required>
                        <option value="">-- Select Supplier --</option>
                    </select>
                </td>
                <td class="p-4">
                    <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 quantity" name="quantity[]" min="0.01" step="0.01" required>
                </td>
                <td class="p-4">
                    <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 unit-display" readonly>
                </td>
                <td class="p-4">
                    <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 unit-price" name="price_per_unit[]" min="0.01" step="0.01" required>
                </td>
                <td class="p-4 total-price">0.00</td>
                <td class="p-4">
                    <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500" name="materialCondition[]" required>
                        <option value="">Select Condition</option>
                        <option value="new">New</option>
                        <option value="used">Used</option>
                        <option value="damaged">Damaged</option>
                    </select>
                </td>
                <td class="p-4">
                    <button type="button" class="bg-red-500 text-white rounded-lg py-2 px-4 hover:bg-red-600 btn-sm remove-row">Delete</button>
                </td>
            `;
            tableBody.appendChild(row);
            attachMaterialAutocomplete(row.querySelector('.material-name-select'));
            updateSerialNumbers();
            updateRemoveButtons();
            updateTotals();
        }

        function removeRow(button) {
            const rows = document.querySelectorAll('#materialTableBody tr');
            if (rows.length <= 1) return;
            button.closest('tr').remove();
            updateSerialNumbers();
            updateRemoveButtons();
            updateTotals();
            validateSuppliers();
        }

        function updateTotalPrice(row) {
            const quantityInput = row.querySelector('.quantity');
            const unitPriceInput = row.querySelector('.unit-price');
            const totalPriceCell = row.querySelector('.total-price');
            const quantity = parseFloat(quantityInput.value) || 0;
            const unitPrice = parseFloat(unitPriceInput.value) || 0;
            totalPriceCell.textContent = (quantity * unitPrice).toFixed(2);
            updateTotals();
        }

        function updateTotals() {
            let totalQuantity = 0;
            let totalAmount = 0;
            const rows = document.querySelectorAll('#materialTableBody tr');
            rows.forEach(row => {
                const quantity = parseFloat(row.querySelector('.quantity').value) || 0;
                const unitPrice = parseFloat(row.querySelector('.unit-price').value) || 0;
                const total = quantity * unitPrice;
                row.querySelector('.total-price').textContent = total.toFixed(2);
                totalQuantity += quantity;
                totalAmount += total;
            });
            document.getElementById('totalItems').textContent = rows.length;
            document.getElementById('totalQuantity').textContent = totalQuantity.toFixed(2);
            document.getElementById('totalAmount').textContent = totalAmount.toFixed(2);
        }

        function validateForm() {
            const importDate = document.getElementById('importDate').value.trim();
            const importer = document.getElementById('importer').value.trim();
            const note = document.getElementById('note').value.trim();
            const materialIds = document.getElementsByClassName('material-id-hidden');
            const quantities = document.getElementsByName('quantity[]');
            const unitPrices = document.getElementsByName('price_per_unit[]');
            const conditions = document.getElementsByName('materialCondition[]');
            const supplierIds = document.getElementsByName('detailSupplierId[]');
            const rows = document.querySelectorAll('#materialTableBody tr');

            rows.forEach(row => row.classList.remove('error-row'));

            if (!importDate) {
                showToast('The import date must not be empty.', 'error');
                return false;
            }
            if (!importer || importer === 'Not Identified') {
                showToast('The importer must not be empty or not identified.', 'error');
                return false;
            }
            if (note && note.length > 1000) {
                showToast('Note cannot exceed 1000 characters.', 'error');
                return false;
            }
            if (note && !/^[A-Za-z0-9\s,.()-]+$/.test(note)) {
                showToast('Note can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.', 'error');
                return false;
            }
            if (materialIds.length === 0) {
                showToast('At least one material is required.', 'error');
                return false;
            }

            const importType = document.getElementById('importType').value;
            let firstSupplierId = supplierIds[0].value;
            for (let i = 0; i < materialIds.length; i++) {
                if (!materialIds[i].value.trim()) {
                    showToast(`Material ID must not be empty at row ${i + 1}`, 'error');
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!quantities[i].value || parseFloat(quantities[i].value) <= 0) {
                    showToast(`Quantity must be greater than 0 at row ${i + 1}`, 'error');
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!unitPrices[i].value || parseFloat(unitPrices[i].value) <= 0) {
                    showToast(`Unit price must be greater than 0 at row ${i + 1}`, 'error');
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!conditions[i].value) {
                    showToast(`Condition must not be empty at row ${i + 1}`, 'error');
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (importType === 'import_from_supplier' && !supplierIds[i].value) {
                    showToast(`Supplier must not be empty at row ${i + 1}`, 'error');
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (importType === 'import_from_supplier' && supplierIds[i].value !== firstSupplierId) {
                    showToast(`All materials must be supplied by the same supplier at row ${i + 1}`, 'error');
                    rows[i].classList.add('error-row');
                    return false;
                }
            }
            return true;
        }

        function showPrintPreview() {
            const rows = document.querySelectorAll('#materialTableBody tr');
            const receiptTableBody = document.getElementById('receiptTableBody');
            const receiptTotalAmount = document.getElementById('receiptTotalAmount');
            let totalAmount = 0;

            receiptTableBody.innerHTML = '';
            rows.forEach(row => {
                const materialName = row.querySelector('.material-name-select').value;
                const quantity = parseFloat(row.querySelector('.quantity').value) || 0;
                const unitPrice = parseFloat(row.querySelector('.unit-price').value) || 0;
                const total = quantity * unitPrice;

                if (materialName && quantity > 0 && unitPrice > 0) {
                    const newRow = document.createElement('tr');
                    newRow.innerHTML = `
                        <td class="p-4">${materialName}</td>
                        <td class="p-4">${quantity.toFixed(2)}</td>
                        <td class="p-4">${unitPrice.toFixed(2)}</td>
                        <td class="p-4">${total.toFixed(2)}</td>
                    `;
                    receiptTableBody.appendChild(newRow);
                    totalAmount += total;
                }
            });
            receiptTotalAmount.textContent = totalAmount.toFixed(2);
            document.getElementById('printReceiptPreview').style.display = 'block';
        }

        function printReceipt() {
            const printContents = document.getElementById('printReceiptPreview').innerHTML;
            const originalContents = document.body.innerHTML;
            document.body.innerHTML = printContents;
            window.print();
            document.body.innerHTML = originalContents;
            hidePrintPreview();
            window.location.reload();
        }

        function hidePrintPreview() {
            document.getElementById('printReceiptPreview').style.display = 'none';
        }

        function goBack() {
            window.history.back();
        }

        function toggleFields() {
            const importType = document.getElementById('importType').value;
            document.getElementById('siteField').style.display = importType === 'import_returned_from_site' ? 'block' : 'none';
            document.getElementById('executorField').style.display = importType === 'import_returned_from_site' ? 'block' : 'none';
            if (importType === 'import_from_supplier') {
                loadAllSuppliers();
            } else {
                document.querySelectorAll('.supplier-select').forEach(select => {
                    select.disabled = true;
                    select.innerHTML = '<option value="">No Supplier Needed</option>';
                });
            }
        }

        function loadSiteMaterials() {
            const siteId = document.getElementById('siteId').value;
            if (siteId) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/ImportMaterialServlet',
                    data: { action: 'materialsBySite', siteId: siteId },
                    method: 'GET',
                    dataType: 'json',
                    success: function (materials) {
                        const tbody = document.querySelector('#materialTableBody');
                        tbody.innerHTML = '';
                        if (materials.length === 0) {
                            showToast('No materials found for this construction site.', 'error');
                            addMaterialRow();
                            return;
                        }
                        materials.forEach((material, index) => {
                            addMaterialRow();
                            const row = tbody.children[index];
                            row.querySelector('.material-name-select').value = material.name;
                            row.querySelector('.material-code-select').value = material.material_code;
                            row.querySelector('.unit-display').value = material.unit;
                            row.querySelector('.material-id-hidden').value = material.material_id;
                            row.querySelector('.quantity').value = material.quantity;
                            row.querySelector('select[name="materialCondition[]"]').value = material.material_condition;
                            row.querySelector('.supplier-select').disabled = true;
                            row.querySelector('.supplier-select').innerHTML = '<option value="">No Supplier Needed</option>';
                        });
                        updateTotals();
                    },
                    error: function (xhr, status, error) {
                        showToast(`Error loading materials for site: ${error}`, 'error');
                        console.error('Error loading site materials:', error);
                    }
                });
            }
        }

        function loadAllSuppliers() {
            const supplierSelects = document.querySelectorAll('.supplier-select');
            supplierSelects.forEach(select => {
                select.innerHTML = '<option value="">-- Select Supplier --</option>';
                <c:forEach items="${suppliers}" var="supplier">
                    select.innerHTML += `<option value="${supplier.supplierId}">${supplier.supplierName}</option>`;
                </c:forEach>
                select.disabled = false;
            });
        }

        document.addEventListener("DOMContentLoaded", () => {
            const tableBody = document.getElementById('materialTableBody');
            const addButton = document.getElementById('addMaterialBtn');
            const saveButton = document.getElementById('saveImportBtn');

            addButton.addEventListener('click', addMaterialRow);
            saveButton.addEventListener('click', () => {
                if (validateForm()) {
                    document.getElementById('importForm').submit();
                }
            });

            tableBody.addEventListener('click', (event) => {
                if (event.target.classList.contains('remove-row')) {
                    removeRow(event.target);
                }
            });

            tableBody.addEventListener('input', (event) => {
                if (event.target.classList.contains('quantity') || event.target.classList.contains('unit-price')) {
                    updateTotalPrice(event.target.closest('tr'));
                }
                if (event.target.classList.contains('supplier-select')) {
                    validateSuppliers();
                }
            });

            document.getElementById('importType').addEventListener('change', toggleFields);
            toggleFields();
        });
    </script>
</body>
</html>