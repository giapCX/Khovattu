<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="Dal.DBContext" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Materials Management - Admin Dashboard</title>
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

        <!-- Sidebar -->
        <aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50">
            <div class="flex items-center mb-8">
                <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
                    <i class="fas fa-boxes text-primary-600 text-2xl"></i>
                </div>
                <h2 class="text-2xl font-bold">Materials Management</h2>
                <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <nav class="space-y-2">
                <div class="flex items-center space-x-3 bg-white bg-opacity-10 rounded-lg p-3 mb-6">
                    <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(username, "UTF-8")%>&background=0ea5e9&color=fff"
                         alt="Avatar" class="w-10 h-10 rounded-full border border-white shadow" />
                    <div class="text-white">
                        <p class="font-semibold text-base"><%= username%></p>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/userprofile" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-user mr-2 w-5 text-center"></i>
                        <span class="text-base">My Information</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fa-building mr-2 w-5 text-center"></i>
                            <span class="text-base">Construction Site</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <!-- Submenu - hidden by default -->
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href="${pageContext.request.contextPath}/ListConstructionSites" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">List Construction Site</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/EditConstructionSiteServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-circle-plus mr-2 w-4 text-center"></i>
                            <span class="text-sm">Create New Site </span>
                        </a>
                    </div>
                </div>

                <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fa-box-open mr-2 w-5 text-center"></i>
                            <span class="text-base">Material Category</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <!-- Submenu - hidden by default -->
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href = "${pageContext.request.contextPath}/ListParentCategoryController" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-folder-tree mr-2 w-4 text-center"></i>
                            <span class="text-sm">Categories</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/ListMaterialController" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-cubes mr-2 w-4 text-center"></i>
                            <span class="text-sm">Material </span>
                        </a>
                        <a href="${pageContext.request.contextPath}/unit" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-clipboard-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">Unit List </span>
                        </a>
                    </div>
                </div> 
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
                            <span class="text-sm">Create New Supplier </span>
                        </a>
                    </div>
                </div>
             
             
               
                  <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fas fa-users mr-2 w-5 text-center"></i>
                            <span class="text-base">Users</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <!-- Submenu - hidden by default -->
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href="${pageContext.request.contextPath}/listuser" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-list mr-2 w-4 text-center"></i>
                            <span class="text-sm">User List</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/adduser" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-user-plus  mr-2 w-4 text-center"></i>
                            <span class="text-sm"> Add User </span>
                        </a>
                    </div>
                </div> 
               

                <div class="nav-item flex flex-col">
                    <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                        <div class="flex items-center">
                            <i class="fas fa-box-open mr-2 w-5 text-center"></i>
                            <span class="text-base">Inventory Management</span>
                        </div>
                        <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
                    </button>
                    <!-- Submenu - hidden by default -->
                    <div class="submenu hidden pl-6 space-y-1 mt-1">
                        <a href="${pageContext.request.contextPath}/exportHistory" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-history mr-2 w-4 text-center"></i>
                            <span class="text-sm">Export History</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/importhistory" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-history mr-2 w-4 text-center"></i>
                            <span class="text-sm"> Import History </span>
                        </a>
                        <a href="${pageContext.request.contextPath}/inventory" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                            <i class="fas fa-boxes mr-2 w-4 text-center"></i>
                            <span class="text-sm"> Inventory List </span>
                        </a>
                    </div>
                </div> 


                <a href="${pageContext.request.contextPath}/AdminApproveServlet" class="nav-item flex items-center p-3">
                    <i class="fas fa-check-circle mr-2 w-5 text-center"></i>
                    <span class="text-base">Approve Request</span>
                    <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
                </a>
            </nav>
            <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
                <a href="${pageContext.request.contextPath}/forgetPassword/changePassword.jsp" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
                    <i class="fas fa-key mr-3"></i>
                    <span class="text-lg">Change password</span>
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
                        <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(username, "UTF-8")%>&background=3b82f6&color=fff" 
                             alt="User" class="w-10 h-10 rounded-full mr-3">
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
                            <p class="text-sm text-green-500 mt-3"><i class="fas fa-arrow-up mr-1"></i></p>
                        </div>
                        <div class="p-4 rounded-full bg-primary-100 dark:bg-primary-900 text-primary-600 dark:text-primary-300">
                            <i class="fas fa-boxes text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/ListMaterialController" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">View Details</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Current Stock</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${currentTotalStock}</h3>
                            <p class="text-sm text-blue-500 mt-3"><i class="fas fa-warehouse mr-1"></i>Total Quantity</p>
                        </div>
                        <div class="p-4 rounded-full bg-blue-100 dark:bg-blue-900 text-blue-600 dark:text-blue-300">
                            <i class="fas fa-warehouse text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/inventory" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">View Inventory</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-100">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Low Stock Materials</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${lowStockCount}</h3>
                            <p class="text-sm text-red-500 mt-3"><i class="fas fa-exclamation-circle mr-1"></i>Need Restock</p>
                        </div>
                        <div class="p-4 rounded-full bg-red-100 dark:bg-red-900 text-red-600 dark:text-red-300">
                            <i class="fas fa-exclamation text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/inventory?sortOrder=ASC&quantityThreshold=10" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Check Now</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-200">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Pending Requests</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${pendingProposals}</h3>
                            <p class="text-sm text-yellow-500 mt-3"><i class="fas fa-clock mr-1"></i>Awaiting Processing</p>
                        </div>
                        <div class="p-4 rounded-full bg-yellow-100 dark:bg-yellow-900 text-yellow-600 dark:text-yellow-300">
                            <i class="fas fa-clipboard-list text-2xl"></i>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4">
                        <a href="${pageContext.request.contextPath}/AdminApproveServlet?status=pending" class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline">Approve Request</a>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp delay-300">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Today's Transactions</p>
                            <h3 class="text-3xl font-bold mt-2 text-gray-800 dark:text-white">${todayTransactions}</h3>
                            <a href="" class="text-sm text-blue-500 mt-3 hover:underline"><i class="fas fa-sync-alt mr-1"></i>Latest Update</a>
                        </div>
                        <div class="p-4 rounded-full bg-blue-100 dark:bg-blue-900 text-blue-600 dark:text-blue-300">
                            <i class="fas fa-exchange-alt text-2xl"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Monthly Statistics -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-8 mb-8">
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Import This Month</p>
                            <h3 class="text-3xl font-bold mt-2 text-green-600 dark:text-green-400">${totalImportThisMonth}</h3>
                            <p class="text-sm text-green-500 mt-3"><i class="fas fa-arrow-down mr-1"></i>Materials In</p>
                        </div>
                        <div class="p-4 rounded-full bg-green-100 dark:bg-green-900 text-green-600 dark:text-green-300">
                            <i class="fas fa-download text-2xl"></i>
                        </div>
                    </div>
                </div>
                <div class="card bg-white dark:bg-gray-800 animate-fadeInUp">
                    <div class="p-6 flex items-start justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Export This Month</p>
                            <h3 class="text-3xl font-bold mt-2 text-red-600 dark:text-red-400">${totalExportThisMonth}</h3>
                            <p class="text-sm text-red-500 mt-3"><i class="fas fa-arrow-up mr-1"></i>Materials Out</p>
                        </div>
                        <div class="p-4 rounded-full bg-red-100 dark:bg-red-900 text-red-600 dark:text-red-300">
                            <i class="fas fa-upload text-2xl"></i>
                        </div>
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

            <!-- Tables Row -->
            <div class=" grid-cols-1 lg:grid-cols-2 gap-8">
                <div class="table-container bg-white dark:bg-gray-800">
                    <div class="p-6 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
                        <div>
                            <h2 class="text-xl font-semibold text-gray-800 dark:text-white">Low Stock Materials</h2>
                            <p class="text-sm text-gray-600 dark:text-gray-300">List of materials that need restocking</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/inventory?sortOrder=ASC&quantityThreshold=10"class="text-sm text-primary-600 dark:text-primary-400 hover:underline">View All</a>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-primary-600 text-white">
                                    <th class="p-4 text-left">Material Name</th>
                                    <th class="p-4 text-left">Quantity</th>
                                    <th class="p-4 text-left">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%-- Display list of low stock materials --%>
                                <c:forEach var="item" items="${lowStockMaterials}">
                                    <tr class="border-b border-gray-200 dark:border-gray-700">
                                        <td class="p-4">${item.materialName}</td>
                                        <td class="p-4">${item.quantityInStock}</td>
                                        <td class="p-4">
                                            <c:choose>
                                                <c:when test="${item.quantityInStock <= 5}">
                                                    <span class="badge badge-danger">Critical</span>
                                                </c:when>
                                                <c:when test="${item.quantityInStock <= 10}">
                                                    <span class="badge badge-warning">Low Stock</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-success">Sufficient</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
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

            // Inventory Chart - real data with accurate stock calculation
            const inventoryTrend = JSON.parse('<%= new com.google.gson.Gson().toJson(request.getAttribute("inventoryTrend"))%>');
            const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            const imported = inventoryTrend.map(item => item.imported);
            const exported = inventoryTrend.map(item => item.exported);
            const remaining = inventoryTrend.map(item => item.remaining);
            const inventoryCtx = document.getElementById('inventoryChart').getContext('2d');
            new Chart(inventoryCtx, {
                type: 'line',
                data: {
                    labels: months,
                    datasets: [
                        {label: 'Imported', data: imported, borderColor: '#10b981', backgroundColor: 'rgba(16, 185, 129, 0.1)', borderWidth: 2, tension: 0.3, fill: true},
                        {label: 'Exported', data: exported, borderColor: '#ef4444', backgroundColor: 'rgba(239, 68, 68, 0.1)', borderWidth: 2, tension: 0.3, fill: true},
                        {label: 'Stock Level', data: remaining, borderColor: '#3b82f6', backgroundColor: 'rgba(59, 130, 246, 0.1)', borderWidth: 2, tension: 0.3, fill: true}
                    ]
                },
                options: {
                    responsive: true, 
                    plugins: {
                        legend: {position: 'top', labels: {usePointStyle: true, padding: 20}}, 
                        tooltip: {
                            enabled: true, 
                            mode: 'index', 
                            intersect: false,
                            callbacks: {
                                label: function(context) {
                                    let label = context.dataset.label || '';
                                    if (label) {
                                        label += ': ';
                                    }
                                    if (context.parsed.y !== null) {
                                        label += new Intl.NumberFormat().format(context.parsed.y);
                                    }
                                    return label;
                                }
                            }
                        }
                    }, 
                    scales: {
                        y: {
                            beginAtZero: false, 
                            grid: {drawBorder: false},
                            ticks: {
                                callback: function(value) {
                                    return new Intl.NumberFormat().format(value);
                                }
                            }
                        }, 
                        x: {grid: {display: false}}
                    }
                }
            });
            // Distribution Chart - real data
            const materialDistribution = JSON.parse('<%= new com.google.gson.Gson().toJson(request.getAttribute("materialDistribution"))%>');
            const distLabels = Object.keys(materialDistribution);
            const distData = Object.values(materialDistribution);
            // Function to generate HEX colors for each material
            function generateColors(count) {
                const hexColors = [
                    "#e6194b", "#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#46f0f0", "#f032e6",
                    "#bcf60c", "#fabebe", "#008080", "#e6beff", "#9a6324", "#fffac8", "#800000", "#aaffc3",
                    "#808000", "#ffd8b1", "#000075", "#808080"
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
                data: {labels: distLabels, datasets: [{data: distData, backgroundColor: distColors, borderWidth: 0}]},
                options: {responsive: true, cutout: '70%', plugins: {legend: {display: false}}}
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