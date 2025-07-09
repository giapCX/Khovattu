<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Import Warehouse Data - Inventory Management System</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        colors: {
                            primary: {
                                50: '#f0f9ff', 100: '#e0f2fe', 200: '#bae6fd', 300: '#7dd3fc',
                                400: '#38bdf8', 500: '#0ea5e9', 600: '#0284c7', 700: '#0369a1',
                                800: '#075985', 900: '#0c4a6e'
                            },
                            secondary: {
                                50: '#f5f3ff', 100: '#ede9fe', 200: '#ddd6fe', 300: '#c4b5fd',
                                400: '#a78bfa', 500: '#8b5cf6', 600: '#7c3aed', 700: '#6d28d9',
                                800: '#5b21b6', 900: '#4c1d95'
                            }
                        },
                        fontFamily: {
                            sans: ['Inter', 'sans-serif']
                        }
                    }
                }
            }
        </script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
        <link href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" rel="stylesheet">
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

            body {
                font-family: 'Inter', sans-serif;
                background-color: #f8fafc;
            }

            .sidebar {
                background: linear-gradient(195deg, #1e3a8a, #3b82f6);
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14), 0 7px 10px -5px rgba(59, 130, 246, 0.4);
                transition: all 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);
                transform: translateX(-100%);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            main, footer {
                transition: all 0.3s ease;
            }

            .sidebar.active ~ main,
            .sidebar.active ~ footer {
                margin-left: 18rem;
            }

            .nav-item {
                transition: all 0.2s ease;
                border-radius: 0.5rem;
            }

            .nav-item:hover {
                background-color: rgba(255, 255, 255, 0.1);
                transform: translateX(5px);
            }

            .nav-item.active {
                background-color: rgba(255, 255, 255, 0.2);
                font-weight: 600;
            }

            .table-container {
                border-radius: 1rem;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                border: 1px solid #e5e7eb;
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
            }

            .table tr:nth-child(even) {
                background-color: #f8fafc;
            }

            .error-row {
                background-color: #ffcccc;
            }

            .search-input {
                transition: all 0.3s ease;
                border-radius: 0.75rem;
            }

            .search-input:focus {
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
            }

            .dark-mode {
                background-color: #1a202c;
                color: #e2e8f0;
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

            .dark-mode .sidebar {
                background: linear-gradient(195deg, #111827, #1f2937);
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14), 0 7px 10px -5px rgba(31, 41, 55, 0.4);
            }

            .error {
                color: #dc3545;
                font-size: 0.875em;
            }

            .btn-disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }

            #successAlert, #errorAlert {
                display: none;
                position: fixed;
                top: 10px;
                left: 50%;
                transform: translateX(-50%);
                z-index: 1000;
            }

            .ui-autocomplete {
                z-index: 10000;
            }

            #printReceiptPreview {
                display: none;
                margin-top: 20px;
            }

            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .animate-fadeInUp {
                animation: fadeInUp 0.5s ease-out forwards;
            }

            @media (max-width: 768px) {
                .sidebar {
                    width: 100%;
                    max-width: 280px;
                    z-index: 50;
                }
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String username = (String) session.getAttribute("username");
            if (username == null) {
                response.sendRedirect("Login.jsp");
                return;
            }
        %>

        <aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50">
            <div class="flex items-center mb-8">
                <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
                    <i class="fas fa-boxes text-primary-600 text-2xl"></i>
                </div>
                <h2 class="text-2xl font-bold">Inventory Management</h2>
                <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100">
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

        <main class="flex-1 p-8 transition-all duration-300">
            <header class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
                <div class="flex items-center gap-4">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <div>
                        <h1 class="text-3xl font-bold text-gray-800 dark:text-white">Add Import Receipt</h1>
                        <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">Create a new import receipt for warehouse materials</p>
                    </div>
                </div>
                <div class="flex items-center space-x-6">
                    <div class="relative">
                        <i class="fas fa-bell text-gray-500 hover:text-primary-600 cursor-pointer text-xl"></i>
                        <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">3</span>
                    </div>
                    <div class="flex items-center">
                        <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(username, "UTF-8")%>&background=3b82f6&color=fff" 
                             alt="User" class="w-10 h-10 rounded-full mr-3">
                        <span class="font-medium text-gray-700 dark:text-white text-lg"><%= username%></span>
                    </div>
                    <button id="toggleDarkMode" class="bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600">
                        <i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-xl"></i>
                    </button>
                </div>
            </header>

            <div class="table-container bg-white dark:bg-gray-800 mb-8">
                <div class="p-6">
                    <div id="successAlert" class="bg-green-500 text-white rounded-lg p-4 mb-4" role="alert"></div>
                    <div id="errorAlert" class="bg-red-500 text-white rounded-lg p-4 mb-4" role="alert"></div>
                    <form id="importForm" method="post" action="${pageContext.request.contextPath}/ImportMaterialServlet">
                        <div class="mb-6">
                            <label for="receiptId" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Import Receipt Code</label>
                            <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input" id="receiptId" name="receipt_id" required pattern="[A-Za-z0-9-_]+">
                            <div id="receiptError" class="error mt-2"></div>
                        </div>
                        <div class="mb-6">
                            <label for="importer" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Importer</label>
                            <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4" id="importer" name="importer" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Not Identified'}" readonly>
                            <c:if test="${empty sessionScope.userFullName}">
                                <p class="error mt-2">Not logged in or user information missing. Please log in again.</p>
                            </c:if>
                        </div>
                        <div class="mb-6">
                            <label for="importDate" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Import Date</label>
                            <input type="date" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input" id="importDate" name="import_date" required>
                        </div>
                        <div class="mb-6">
                            <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-2">Note</label>
                            <textarea class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500" id="note" name="note" rows="3" maxlength="1000"></textarea>
                        </div>
                        <div class="table-container bg-white dark:bg-gray-800">
                            <div class="overflow-x-auto">
                                <table class="w-full table-auto">
                                    <thead>
                                        <tr class="bg-primary-600 text-white">
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
                                                <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 material-name-select" required>
                                                <input type="hidden" class="material-id-hidden" name="materialId[]">
                                            </td>
                                            <td class="p-4">
                                                <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 material-code-select" readonly>
                                            </td>
                                            <td class="p-4">
                                                <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 supplier-select" name="supplierId[]" required>
                                                    <option value="">-- Select Supplier --</option>
                                                </select>
                                            </td>
                                            <td class="p-4">
                                                <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 quantity" name="quantity[]" min="0.01" step="0.01" required>
                                            </td>
                                            <td class="p-4">
                                                <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 unit-display" readonly>
                                            </td>
                                            <td class="p-4">
                                                <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 unit-price" name="price_per_unit[]" min="0.01" step="0.01" required>
                                            </td>
                                            <td class="p-4 total-price">0.00</td>
                                            <td class="p-4">
                                                <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500" name="materialCondition[]" required>
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
                        <div class="mt-6 flex space-x-4">
                            <button type="button" id="addMaterialBtn" class="bg-primary-600 text-white rounded-lg py-2 px-4 hover:bg-primary-700">Add Material</button>
                            <button type="button" id="saveImportBtn" class="bg-green-500 text-white rounded-lg py-2 px-4 hover:bg-green-600">Save Import</button>
                            <button type="button" id="printReceiptBtn" class="bg-gray-500 text-white rounded-lg py-2 px-4 hover:bg-gray-600" onclick="showPrintPreview()">Print Receipt</button>
                            <button type="button" id="backBtn" class="bg-blue-500 text-white rounded-lg py-2 px-4 hover:bg-blue-600" onclick="goBack()">Back</button>
                        </div>
                        <div class="mt-6 table-container bg-white dark:bg-gray-800 p-6">
                            <h5 class="text-xl font-semibold text-gray-800 dark:text-white mb-4">Summary</h5>
                            <p class="text-gray-600 dark:text-gray-300">Total Materials: <span id="totalItems">1</span></p>
                            <p class="text-gray-600 dark:text-gray-300">Total Quantity: <span id="totalQuantity">0.00</span></p>
                            <p class="text-gray-600 dark:text-gray-300">Total Amount: <span id="totalAmount">0.00</span> VND</p>
                        </div>
                        <div id="printReceiptPreview" class="table-container bg-white dark:bg-gray-800 p-6">
                            <h5 class="text-xl font-semibold text-gray-800 dark:text-white mb-4">Receipt Preview</h5>
                            <div class="overflow-x-auto">
                                <table class="w-full table-auto">
                                    <thead>
                                        <tr class="bg-primary-600 text-white">
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
                                <button type="button" class="bg-primary-600 text-white rounded-lg py-2 px-4 hover:bg-primary-700" onclick="printReceipt()">Print</button>
                                <button type="button" class="bg-gray-500 text-white rounded-lg py-2 px-4 hover:bg-gray-600" onclick="hidePrintPreview()">Cancel</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </main>

        <footer class="bg-gray-100 dark:bg-gray-800 text-center p-6 mt-8 border-t border-gray-200 dark:border-gray-700 transition-all duration-300">
            <p class="text-gray-600 dark:text-gray-300 text-sm">Inventory Management System - Version 2.0 © 2025 | <a href="mailto:support@company.com" class="text-primary-600 dark:text-primary-400 hover:underline text-base">Contact Support</a></p>
        </footer>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
        <script>
            const sidebar = document.getElementById('sidebar');
            const toggleSidebar = document.getElementById('toggleSidebar');
            const toggleSidebarMobile = document.getElementById('toggleSidebarMobile');

            function toggleSidebarVisibility() {
                sidebar.classList.toggle('active');
                sidebar.classList.toggle('hidden');
            }

            sidebar.addEventListener('click', (event) => {
                event.stopPropagation();
            });

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
            });

            sidebar.classList.add('hidden');

            const toggleDarkMode = document.getElementById('toggleDarkMode');
            toggleDarkMode.addEventListener('click', () => {
                document.body.classList.toggle('dark-mode');
                const icon = toggleDarkMode.querySelector('i');
                icon.classList.toggle('fa-moon');
                icon.classList.toggle('fa-sun');
                localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
            });

            if (localStorage.getItem('darkMode') === 'true') {
                document.body.classList.add('dark-mode');
                toggleDarkMode.querySelector('i').classList.replace('fa-moon', 'fa-sun');
            }

            function showToast(message) {
                Toastify({
                    text: message,
                    duration: 3000,
                    gravity: "top",
                    position: "right",
                    backgroundColor: "#3b82f6",
                    stopOnFocus: true,
                    className: "rounded-lg shadow-lg",
                    style: {borderRadius: "0.5rem"}
                }).showToast();
            }

            let materialData = [];

            function attachMaterialAutocomplete(materialInput) {
                $(materialInput).autocomplete({
                    source: function (request, response) {
                        const term = request.term.toLowerCase();
                        fetch('${pageContext.request.contextPath}/ImportMaterialServlet', {
                            method: 'GET',
                            headers: {'Accept': 'application/json'}
                        })
                            .then(res => {
                                if (!res.ok) throw new Error(`Server error: ${res.status}`);
                                return res.json();
                            })
                            .then(data => {
                                materialData = data;
                                const filtered = materialData.filter(mat => mat.name.toLowerCase().includes(term));
                                response(filtered.map(mat => ({
                                    label: mat.name,
                                    value: mat.materialId,
                                    code: mat.code || mat.materialCode || 'N/A',
                                    unit: mat.unit || '',
                                    suppliers: mat.suppliers || []
                                })));
                            })
                            .catch(error => {
                                console.error('Error loading materials:', error);
                                showToast(`Unable to load material data: ${error.message}`);
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
                            showToast('No suppliers are associated with material "' + ui.item.label + '". Please contact the administrator.');
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
                        showToast(`All materials must be supplied by the same supplier. Please select supplier ${firstSupplierId} for row ${index + 1}.`);
                        select.classList.add('border-red-500');
                    } else {
                        select.classList.remove('border-red-500');
                    }
                });
                document.getElementById('saveImportBtn').disabled = !isValid || supplierSelects.length === 0 || [...supplierSelects].every(select => !select.value);
            }

            function updateSerialNumbers() {
                const rows = document.querySelectorAll('#materialTableBody tr');
                rows.forEach((row, index) => {
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
                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 material-name-select" required>
                        <input type="hidden" class="material-id-hidden" name="materialId[]">
                    </td>
                    <td class="p-4">
                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 material-code-select" readonly>
                    </td>
                    <td class="p-4">
                        <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 supplier-select" name="supplierId[]" required>
                            <option value="">-- Select Supplier --</option>
                        </select>
                    </td>
                    <td class="p-4">
                        <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 quantity" name="quantity[]" min="0.01" step="0.01" required>
                    </td>
                    <td class="p-4">
                        <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 unit-display" readonly>
                    </td>
                    <td class="p-4">
                        <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 unit-price" name="price_per_unit[]" min="0.01" step="0.01" required>
                    </td>
                    <td class="p-4 total-price">0.00</td>
                    <td class="p-4">
                        <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500" name="materialCondition[]" required>
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
                const receiptId = document.getElementById('receiptId').value.trim();
                const receiptError = document.getElementById('receiptError');
                const importDate = document.getElementById('importDate').value.trim();
                const importer = document.getElementById('importer').value.trim();
                const note = document.getElementById('note').value.trim();
                const materialIds = document.getElementsByClassName('material-id-hidden');
                const quantities = document.getElementsByName('quantity[]');
                const unitPrices = document.getElementsByName('price_per_unit[]');
                const conditions = document.getElementsByName('materialCondition[]');
                const supplierIds = document.getElementsByName('supplierId[]');
                const rows = document.querySelectorAll('#materialTableBody tr');

                receiptError.textContent = '';
                rows.forEach(row => row.classList.remove('error-row'));

                if (!receiptId) {
                    receiptError.textContent = 'The import receipt code must not be empty.';
                    return false;
                }
                if (!/^[A-Za-z0-9-_]+$/.test(receiptId)) {
                    receiptError.textContent = 'Receipt ID can only contain alphanumeric characters, hyphens, or underscores.';
                    return false;
                }
                if (receiptId.length > 50) {
                    receiptError.textContent = 'Receipt ID cannot exceed 50 characters.';
                    return false;
                }
                if (!importDate) {
                    showToast('The import date must not be empty.');
                    return false;
                }
                if (!importer || importer === 'Not Identified') {
                    showToast('The importer must not be empty or not identified.');
                    return false;
                }
                if (note && note.length > 1000) {
                    showToast('Note cannot exceed 1000 characters.');
                    return false;
                }
                if (note && !/^[A-Za-z0-9\s,.()-]+$/.test(note)) {
                    showToast('Note can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.');
                    return false;
                }
                if (materialIds.length === 0) {
                    showToast('At least one material is required.');
                    return false;
                }

                let firstSupplierId = supplierIds[0].value;
                for (let i = 0; i < materialIds.length; i++) {
                    if (!materialIds[i].value.trim()) {
                        showToast(`Material ID must not be empty at row ${i + 1}`);
                        rows[i].classList.add('error-row');
                        return false;
                    }
                    if (!quantities[i].value || parseFloat(quantities[i].value) <= 0) {
                        showToast(`Quantity must be greater than 0 at row ${i + 1}`);
                        rows[i].classList.add('error-row');
                        return false;
                    }
                    if (!unitPrices[i].value || parseFloat(unitPrices[i].value) <= 0) {
                        showToast(`Unit price must be greater than 0 at row ${i + 1}`);
                        rows[i].classList.add('error-row');
                        return false;
                    }
                    if (!conditions[i].value) {
                        showToast(`Condition must not be empty at row ${i + 1}`);
                        rows[i].classList.add('error-row');
                        return false;
                    }
                    if (!supplierIds[i].value) {
                        showToast(`Supplier must not be empty at row ${i + 1}`);
                        rows[i].classList.add('error-row');
                        return false;
                    }
                    if (supplierIds[i].value !== firstSupplierId) {
                        showToast(`All materials must be supplied by the same supplier at row ${i + 1}`);
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

            document.addEventListener("DOMContentLoaded", () => {
                const tableBody = document.getElementById('materialTableBody');
                const addButton = document.getElementById('addMaterialBtn');
                const saveButton = document.getElementById('saveImportBtn');
                const receiptIdInput = document.getElementById('receiptId');

                fetch('${pageContext.request.contextPath}/ImportMaterialServlet', {
                    method: 'GET',
                    headers: {'Accept': 'application/json'}
                })
                    .then(response => {
                        if (!response.ok) throw new Error(`Server error: ${response.status}`);
                        return response.json();
                    })
                    .then(data => {
                        materialData = data;
                        document.querySelectorAll(".material-name-select").forEach(attachMaterialAutocomplete);
                    })
                    .catch(error => {
                        console.error('Error loading materials:', error);
                        showToast(`Unable to load material data: ${error.message}`);
                    });

                addButton.addEventListener('click', (event) => {
                    event.stopPropagation();
                    addMaterialRow();
                });
                tableBody.addEventListener('click', (event) => {
                    if (event.target.classList.contains('remove-row')) {
                        event.stopPropagation();
                        removeRow(event.target);
                    }
                });
                tableBody.addEventListener('input', (e) => {
                    if (e.target.classList.contains('quantity') || e.target.classList.contains('unit-price')) {
                        updateTotalPrice(e.target.closest('tr'));
                    }
                });
                tableBody.addEventListener('change', (e) => {
                    if (e.target.classList.contains('supplier-select')) {
                        validateSuppliers();
                    }
                });

                receiptIdInput.addEventListener('blur', () => {
                    const receiptId = receiptIdInput.value.trim();
                    const receiptError = document.getElementById('receiptError');
                    receiptError.textContent = '';
                    if (!receiptId) {
                        receiptError.textContent = 'The import receipt code must not be empty.';
                        saveButton.disabled = true;
                        return;
                    }
                    if (!/^[A-Za-z0-9-_]+$/.test(receiptId)) {
                        receiptError.textContent = 'Receipt ID can only contain alphanumeric characters, hyphens, or underscores.';
                        saveButton.disabled = true;
                        return;
                    }
                    if (receiptId.length > 50) {
                        receiptError.textContent = 'Receipt ID cannot exceed 50 characters.';
                        saveButton.disabled = true;
                        return;
                    }
                    fetch('${pageContext.request.contextPath}/check_voucher_id', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'receipt_id=' + encodeURIComponent(receiptId) + '&type=import' // Changed from voucher_id
                    })
                        .then(response => response.json())
                        .then(data => {
                            if (data.error) {
                                receiptError.textContent = data.error;
                                saveButton.disabled = true;
                            } else if (data.exists) {
                                receiptError.textContent = 'The import receipt code already exists. Please use a different code.';
                                saveButton.disabled = true;
                            } else {
                                receiptError.textContent = '';
                                saveButton.disabled = false;
                            }
                        })
                        .catch(error => {
                            receiptError.textContent = 'Error checking receipt ID: ' + error.message;
                            saveButton.disabled = true;
                        });
                });

                saveButton.addEventListener('click', (e) => {
                    e.preventDefault();
                    if (!validateForm()) return;

                    const formData = new FormData(document.getElementById('importForm'));
                    fetch('${pageContext.request.contextPath}/ImportMaterialServlet', {
                        method: 'POST',
                        body: formData
                    })
                        .then(response => {
                            if (!response.ok) {
                                return response.text().then(text => {
                                    throw new Error(`Server error: ${response.status} - ${text}`);
                                });
                            }
                            return response.json();
                        })
                        .then(data => {
                            const successAlert = document.getElementById('successAlert');
                            const errorAlert = document.getElementById('errorAlert');
                            if (data.status === 'success') {
                                successAlert.textContent = data.message;
                                successAlert.style.display = 'block';
                                setTimeout(() => successAlert.style.display = 'none', 5000);
                                document.getElementById('importForm').reset();
                                const tableBody = document.getElementById('materialTableBody');
                                tableBody.innerHTML = `
                                    <tr>
                                        <td class="p-4 serial-number">1</td>
                                        <td class="p-4">
                                            <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 material-name-select" required>
                                            <input type="hidden" class="material-id-hidden" name="materialId[]">
                                        </td>
                                        <td class="p-4">
                                            <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 material-code-select" readonly>
                                        </td>
                                        <td class="p-4">
                                            <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 supplier-select" name="supplierId[]" required>
                                                <option value="">-- Select Supplier --</option>
                                            </select>
                                        </td>
                                        <td class="p-4">
                                            <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 quantity" name="quantity[]" min="0.01" step="0.01" required>
                                        </td>
                                        <td class="p-4">
                                            <input type="text" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 unit-display" readonly>
                                        </td>
                                        <td class="p-4">
                                            <input type="number" class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 unit-price" name="price_per_unit[]" min="0.01" step="0.01" required>
                                        </td>
                                        <td class="p-4 total-price">0.00</td>
                                        <td class="p-4">
                                            <select class="w-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500" name="materialCondition[]" required>
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
                                `;
                                updateSerialNumbers();
                                updateRemoveButtons();
                                updateTotals();
                                document.querySelectorAll(".material-name-select").forEach(attachMaterialAutocomplete);
                            } else {
                                errorAlert.textContent = data.message;
                                if (data.errorRow != null) {
                                    const rows = document.querySelectorAll('#materialTableBody tr');
                                    rows[data.errorRow].classList.add('error-row');
                                }
                                errorAlert.style.display = 'block';
                                setTimeout(() => errorAlert.style.display = 'none', 5000);
                            }
                        })
                        .catch(error => {
                            const errorAlert = document.getElementById('errorAlert');
                            errorAlert.textContent = `Error saving import receipt: ${error.message}`;
                            errorAlert.style.display = 'block';
                            setTimeout(() => errorAlert.style.display = 'none', 5000);
                        });
                });
            });
        </script>
    </body>
</html>