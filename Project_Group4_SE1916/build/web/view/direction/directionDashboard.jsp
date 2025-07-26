<%@page import="dao.DashboardDirectorDAO"%>
<%@ page import="java.sql.*" %>
<%@ page import="Dal.DBContext" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Director Dashboard - Materials Management System</title>
        <!-- Tailwind CSS -->
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
        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
        <!-- Toastify -->
        <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
       
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminDashboard.css">
        
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
                background: linear-gradient(to right, #3b82f6, #8b5cf6);
                transform: translateX(5px) scale(1.02);
            }

            .nav-item.active {
                background-color: rgba(255, 255, 255, 0.2);
                font-weight: 600;
            }

            .card {
                transition: all 0.3s ease;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                border-radius: 1rem;
                border: 1px solid #e5e7eb;
            }

            .card:hover {
                transform: translateY(-5px);
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            }

            .btn-primary {
                background: linear-gradient(to right, #3b82f6, #6366f1);
                transition: all 0.3s ease;
            }

            .btn-primary:hover {
                transform: scale(1.05);
                box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.3), 0 4px 6px -2px rgba(59, 130, 246, 0.1);
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

            .badge {
                padding: 0.25rem 0.75rem;
                border-radius: 0.5rem;
                font-size: 0.75rem;
                font-weight: 600;
            }

            .badge-success {
                background-color: #d1fae5;
                color: #065f46;
            }

            .badge-warning {
                background-color: #fef3c7;
                color: #92400e;
            }

            .badge-danger {
                background-color: #fee2e2;
                color: #991b1b;
            }

            .dark-mode {
                background-color: #1a202c;
                color: #e2e8f0;
            }

            .dark-mode .card,
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

            .delay-100 {
                animation-delay: 0.1s;
            }
            .delay-200 {
                animation-delay: 0.2s;
            }
            .delay-300 {
                animation-delay: 0.3s;
            }

            th.asc::after {
                content: ' ↑';
                font-size: 0.75rem;
            }

            th.desc::after {
                content: ' ↓';
                font-size: 0.75rem;
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
        <!-- Session Check -->
        <%
            String username = (String) session.getAttribute("username");
            if (username == null) {
                response.sendRedirect("Login.jsp");
                return;
            }
        %>
        <%
            DashboardDirectorDAO dao = new DashboardDirectorDAO();
            int totalMaterials = 0;
            int lowInventory = 0;
            int conSite = 0;
            int supplier = 0;
            int emp = 0;
            int proPend = 0;
            try {
                totalMaterials = dao.countTotalMaterials();
                lowInventory = dao.countLowStockMaterials(10);
                conSite = dao.countOngoingSites();
                supplier = dao.countActiveSuppliers();
                emp = dao.countUsers();
                proPend = dao.countPendingDirectorProposals();
            } catch (Exception e) {
                e.printStackTrace();
            }
            // Set attributes for JSTL
            request.setAttribute("totalMaterials", totalMaterials);
            request.setAttribute("lowInventory", lowInventory);
            request.setAttribute("conSite", conSite);
            request.setAttribute("supplier", supplier);
            request.setAttribute("emp", emp);
            request.setAttribute("proPend", proPend);
        %>
        <!-- Sidebar -->
        <aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50 hidden">
            <div class="sidebar-header flex items-center mb-4">
                <div class="w-10 h-10 rounded-full bg-white flex items-center justify-center mr-2">
                    <i class="fas fa-boxes text-primary-600 text-xl"></i>
                </div>
                <h2 class="text-xl font-bold">Materials Management</h2>
                <button id="toggleSidebar" class="ml-auto text-white opacity-75 hover:opacity-100">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <nav class="space-y-2">
                <a href="${pageContext.request.contextPath}/userprofile" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-user mr-2 w-5 text-center"></i>
                        <span class="text-base">My Profile</span>
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
                <!-- Supplier - Parent Menu -->
                <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fa-truck mr-2 w-5 text-center"></i>
                            <span class="text-base">Suppliers</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <!-- Submenu - hidden by default -->
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href="${pageContext.request.contextPath}/ListSupplierServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">Suppliers List</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/AddSupplierServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-circle-plus mr-2 w-4 text-center"></i>
                            <span class="text-sm">Add New Supplier</span>
                        </a>
                    </div>
                </div>
                <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fa-building mr-2 w-5 text-center"></i>
                            <span class="text-base">Construction Sites</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <!-- Submenu - hidden by default -->
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href="${pageContext.request.contextPath}/ListConstructionSites" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">Construction Sites List</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/EditConstructionSiteServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-circle-plus mr-2 w-4 text-center"></i>
                            <span class="text-sm">Add New Site</span>
                        </a>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/DirectorProposalsServlet" class="nav-item active flex items-center p-3">
                    <i class="fas fa-clipboard-list mr-3 w-6 text-center"></i>
                    <span class="text-lg">Approve Requests</span>
                    <span class="ml-auto bg-red-500 text-white text-sm px-2 py-1 rounded-full">3</span>
                </a>
                <a href="${pageContext.request.contextPath}/exportHistory" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-history mr-2 w-5 text-center"></i>
                        <span class="text-base">Export History</span>
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
            </nav>
            <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
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

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <!-- Header -->
            <header class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
                <div class="flex items-center gap-4">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <div>
                        <h1 class="text-3xl font-bold text-gray-800 dark:text-white">System Overview</h1>
                        <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">Material Data Statistics and Analysis</p>
                    </div>
                </div>
                <div class="flex items-center space-x-6">
                    
                    <div class="flex items-center">
                        <img src="https://ui-avatars.com/api/?name=Director&background=3b82f6&color=fff" 
                             alt="Director" class="w-10 h-10 rounded-full mr-3">
                        <span class="font-medium text-gray-700 dark:text-white text-lg"><%= username%></span>
                    </div>
                    <button id="toggleDarkMode" class="bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600">
                        <i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-xl"></i>
                    </button>
                </div>
            </header>

            <!-- Dashboard Stats -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-8">
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Materials</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${totalMaterials}</h3>
                        </div>
                        <div class="p-4 rounded-full bg-primary-100 dark:bg-primary-900 text-primary-600 dark:text-primary-300">
                            <i class="fas fa-boxes text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/ListMaterialController" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">View Report</a>
                    </div>
                </div>

                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-200">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Suppliers</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${supplier}</h3>
                        </div>
                        <div class="p-4 rounded-full bg-blue-100 dark:bg-blue-900 text-blue-600 dark:text-blue-300">
                            <i class="fas fa-building text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/ListSupplierServlet" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">View Details</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-300">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Low Inventory</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${lowInventory}</h3>
                            <p class="text-sm text-red-500 mt-3"><i class="fas fa-exclamation-circle mr-1"></i>Needs Replenishment</p>
                        </div>
                        <div class="p-4 rounded-full bg-red-100 dark:bg-red-900 text-red-600 dark:text-red-300">
                            <i class="fas fa-exclamation text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/inventory?sortOrder=ASC&quantityThreshold=10" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">View Details</a>
                    </div>
                </div>
                    <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-300">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Construction Sites</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${conSite}</h3>
                            <p class="text-sm text-green-500 mt-3"><i class="fas mr-1"></i>Active</p>
                        </div>
                        <div class="p-4 rounded-full bg-green-100 dark:bg-green-900 text-green-600 dark:text-green-300">
                            <i class="fas fa-building text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/ListConstructionSites" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">View Details</a>
                    </div>
                </div>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-8">
                
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-300">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Pending Requests</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${proPend}</h3>
                            <p class="text-sm text-yellow-500 mt-3"><i class="fas fa-clock mr-1"></i>Pending Approval</p>
                        </div>
                        <div class="p-4 rounded-full bg-yellow-100 dark:bg-yellow-900 text-yellow-600 dark:text-yellow-300">
                            <i class="fas fa-clipboard-list text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/proposals" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">View All</a>
                    </div>
                </div>
            </div>
            <!-- Charts Row -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
                <div class="lg:col-span-2 card bg-white dark:bg-gray-800 p-6">
                    <div class="flex justify-between items-center mb-4">
                        <div>
                            <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Inventory Trends</h2>
                            <p class="text-sm text-gray-600 dark:text-gray-300">Track import/export warehouse over time</p>
                        </div>
                    </div>
                    <canvas id="inventoryChart" class="border rounded-lg"></canvas>
                </div>
                <div class="card bg-white dark:bg-gray-800 p-6">
                    <div class="mb-4">
                        <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Material Category Distribution</h2>
                        <p class="text-sm text-gray-600 dark:text-gray-300">Proportion of material categories in warehouse</p>
                    </div>
                    <canvas id="distributionChart" class="border rounded-lg"></canvas>
                </div>
            </div>

        </main>

        <!-- Footer -->
        <footer class="bg-gray-100 dark:bg-gray-800 text-center p-6 mt-8 border-t border-gray-200 dark:border-gray-700 transition-all duration-300">
            <p class="text-gray-600 dark:text-gray-300 text-sm">Materials Management System - Version 2.0 © 2025 | <a href="mailto:support@company.com" class="text-primary-600 dark:text-primary-400 hover:underline text-base">Contact Support</a></p>
        </footer>

        <!-- JavaScript -->
        <script>
            // Toggle Sidebar
            const sidebar = document.getElementById('sidebar');
            const toggleSidebar = document.getElementById('toggleSidebar');
            const toggleSidebarMobile = document.getElementById('toggleSidebarMobile');

            function toggleSidebarVisibility() {
                sidebar.classList.toggle('active');
                sidebar.classList.toggle('hidden');
            }

            toggleSidebar.addEventListener('click', toggleSidebarVisibility);
            toggleSidebarMobile.addEventListener('click', toggleSidebarVisibility);
            document.addEventListener('DOMContentLoaded', () => {
                const toggles = document.querySelectorAll('.toggle-submenu');
                toggles.forEach(toggle => {
                    toggle.addEventListener('click', () => {
                        const submenu = toggle.parentElement.querySelector('.submenu');
                        submenu.classList.toggle('hidden');
                        const icon = toggle.querySelector('.fa-chevron-down');
                        icon.classList.toggle('rotate-180');
                    });
                });
            });

            // Initialize sidebar as hidden
            sidebar.classList.add('hidden');

            // Dark Mode Toggle
            const toggleDarkMode = document.getElementById('toggleDarkMode');
            toggleDarkMode.addEventListener('click', () => {
                document.body.classList.toggle('dark-mode');
                const icon = toggleDarkMode.querySelector('i');
                icon.classList.toggle('fa-moon');
                icon.classList.toggle('fa-sun');
                localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
            });

            // Load Dark Mode Preference
            if (localStorage.getItem('darkMode') === 'true') {
                document.body.classList.add('dark-mode');
                toggleDarkMode.querySelector('i').classList.replace('fa-moon', 'fa-sun');
            }

            // Toast Notification
            function showToast(message, backgroundColor = "#3b82f6") {
                Toastify({
                    text: message,
                    duration: 3000,
                    gravity: "top",
                    position: "right",
                    backgroundColor: backgroundColor,
                    stopOnFocus: true,
                    className: "rounded-lg shadow-lg",
                    style: {borderRadius: "0.5rem"}
                }).showToast();
            }

            // Approve/Reject Request
            function approveRequest(id) {
                showToast(`Request #${id} has been approved`, "#10b981");
                // Backend API call to update request status
            }

            function rejectRequest(id) {
                const reason = prompt('Reason for rejection:');
                if (reason) {
                    showToast(`Request #${id} has been rejected: ${reason}`, "#ef4444");
                    // Backend API call to update request status
                }
            }

            // Export to Excel
            function exportToExcel(chartId) {
                showToast(`Exporting report to Excel...`);
                // Backend call to generate Excel file
            }

            // Inventory Chart
            const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            const imported = [];
            const exported = [];
            const remaining = [];
            <c:forEach var="item" items="${inventoryTrend}">
                imported.push(${item.imported != null ? item.imported : 0});
                exported.push(${item.exported != null ? item.exported : 0});
                remaining.push(${item.remaining != null ? item.remaining : 0});
            </c:forEach>
            // Fallback if no data
            if (imported.length === 0) {
                imported.push(...Array(12).fill(0));
                exported.push(...Array(12).fill(0));
                remaining.push(...Array(12).fill(0));
            }
            console.log('Inventory Trend Data:', { imported, exported, remaining });

            const inventoryCtx = document.getElementById('inventoryChart').getContext('2d');
            new Chart(inventoryCtx, {
                type: 'line',
                data: {
                    labels: months,
                    datasets: [
                        {
                            label: 'Imported',
                            data: imported,
                            borderColor: '#10b981',
                            backgroundColor: 'rgba(16, 185, 129, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: 'Exported',
                            data: exported,
                            borderColor: '#ef4444',
                            backgroundColor: 'rgba(239, 68, 68, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: 'In Stock',
                            data: remaining,
                            borderColor: '#3b82f6',
                            backgroundColor: 'rgba(59, 130, 246, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: { usePointStyle: true, padding: 20 }
                        },
                        tooltip: { enabled: true, mode: 'index', intersect: false }
                    },
                    scales: {
                        y: { beginAtZero: true, grid: { drawBorder: false } },
                        x: { grid: { display: false } }
                    }
                }
            });

            // Distribution Chart
            const distLabels = [];
            const distData = [];
            <c:forEach var="entry" items="${materialDistribution}">
                distLabels.push('${entry.key}');
                distData.push(${entry.value != null ? entry.value : 0});
            </c:forEach>
            // Fallback if no data
            if (distLabels.length === 0) {
                distLabels.push('No Data');
                distData.push(1);
            }
            console.log('Material Distribution Data:', { distLabels, distData });

            function generateColors(count) {
                const hexColors = [
                    "#e6194b", "#3cb44b", "#ffe119", "#4363d8", "#f58231", 
                    "#911eb4", "#46f0f0", "#f032e6", "#bcf60c", "#fabebe"
                ];
                const colors = [];
                for (let i = 0; i < count; i++) {
                    colors.push(hexColors[i % hexColors.length]);
                }
                return colors;
            }

            const distColors = generateColors(distLabels.length);
            const distributionCtx = document.getElementById('distributionChart').getContext('2d');
            new Chart(distributionCtx, {
                type: 'doughnut',
                data: {
                    labels: distLabels,
                    datasets: [{
                        data: distData,
                        backgroundColor: distColors,
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    cutout: '70%',
                    plugins: {
                        legend: { display: false }
                    }
                }
            });

            // Table Sorting
            document.querySelectorAll('th').forEach(th => {
                th.addEventListener('click', () => {
                    const table = th.closest('table');
                    const tbody = table.querySelector('tbody');
                    const rows = Array.from(tbody.querySelectorAll('tr'));
                    const columnIndex = th.cellIndex;
                    const isNumeric = columnIndex === 2 || columnIndex === 3;
                    const isAsc = th.classList.toggle('asc');
                    th.classList.toggle('desc', !isAsc);
                    table.querySelectorAll('th').forEach(header => {
                        if (header !== th)
                            header.classList.remove('asc', 'desc');
                    });
                    rows.sort((a, b) => {
                        let aValue = a.cells[columnIndex].textContent;
                        let bValue = b.cells[columnIndex].textContent;
                        if (isNumeric) {
                            aValue = parseFloat(aValue) || 0;
                            bValue = parseFloat(bValue) || 0;
                            return isAsc ? aValue - bValue : bValue - aValue;
                        }
                        return isAsc ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue);
                    });
                    tbody.innerHTML = '';
                    rows.forEach(row => tbody.appendChild(row));
                });
            });
        </script>
    </body>
</html>