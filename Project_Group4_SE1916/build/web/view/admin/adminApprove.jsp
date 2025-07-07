<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Danh sách đề xuất chờ duyệt - Hệ thống Quản lý Vật tư</title>
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
        <!-- Toastify -->
        <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
                margin-left: 18rem; /* Matches w-72 (288px) */
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

        <!-- Sidebar -->
        <aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50">
            <div class="flex items-center mb-8">
                <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
                    <i class="fas fa-boxes text-primary-600 text-2xl"></i>
                </div>
                <h2 class="text-2xl font-bold">QL Vật Tư</h2>
                <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="mb-6 px-2">
                <div class="relative">
                    <input type="text" placeholder="Tìm kiếm..." 
                           class="w-full bg-white bg-opacity-20 text-white placeholder-white placeholder-opacity-70 rounded-lg py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-white focus:ring-opacity-50 search-input">
                    <i class="fas fa-search absolute left-3 top-2.5 text-white opacity-70"></i>
                </div>
            </div>
            <nav class="space-y-2">
                <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class="nav-item flex items-center p-3">
                    <i class="fas fa-home mr-3 w-6 text-center"></i>
                    <span class="text-lg">Dashboard</span>
                    <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="nav-item flex items-center p-3">
                    <i class="fas fa-box-open mr-3 w-6 text-center"></i>
                    <span class="text-lg">Danh mục vật tư</span>
                    <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
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
                    <!-- Menu con - ẩn mặc định -->
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
                <a href="${pageContext.request.contextPath}/listuser" class="nav-item flex items-center p-3">
                    <i class="fas fa-cog mr-3 w-6 text-center"></i>
                    <span class="text-lg">Danh sách người dùng</span>
                    <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/exportHistory" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-history mr-2 w-5 text-center"></i>
                        <span class="text-base">Lịch sử xuất kho</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/importhistory" class="nav-item flex items-center p-2 justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-history mr-2 w-5 text-center"></i>
                        <span class="text-base">Lịch sử nhập kho</span>
                    </div>
                    <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
                </a>
                <a href="${pageContext.request.contextPath}/AdminApproveServlet" class="nav-item flex items-center p-3">
                    <i class="fas fa-check-circle mr-3 w-6 text-center"></i>
                    <span class="text-lg">Approve Request</span>
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
                        <h1 class="text-3xl font-bold text-gray-800 dark:text-white"> Approve Request </h1>
                        <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">Manage and approve pending material proposals</p>
                    </div>
                </div>
                <div class="flex items-center space-x-6">
                    <div class="relative">
                        <i class="fas fa-bell text-gray-500 hover:text-primary-600 cursor-pointer text-xl"></i>
                        <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">3</span>
                    </div>
                    <div class="flex items-center">
                        <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(username, "UTF-8")%>&background=3b82f6&color=fff" 
                             alt="Người dùng" class="w-10 h-10 rounded-full mr-3">
                        <span class="font-medium text-gray-700 dark:text-white text-lg"><%= username%></span>
                    </div>
                    <button id="toggleDarkMode" class="bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600">
                        <i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-xl"></i>
                    </button>
                </div>
            </header>

            <!-- Filter Section -->
            <form action="${pageContext.request.contextPath}/AdminApproveServlet" method="get" class="mb-6 flex flex-col md:flex-row gap-4">
                <div class="flex-1">
                    <input type="text" name="search" value="${param.search}" placeholder="Search by sender name..." 
                           class="w-full border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                </div>
                <div class="flex-1">
                    <input type="date" name="dateFrom" value="${param.dateFrom}" 
                           class="w-full border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                </div>
                <div class="flex-1">
                    <input type="date" name="dateTo" value="${param.dateTo}" 
                           class="w-full border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                </div>
                <div class="flex-1">
                    <select name="status" class="w-full border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                        <option value="" ${empty param.status ? 'selected' : ''}>All Status</option>
                        <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Pending</option>
                        <option value="approved_by_admin" ${param.status == 'approved_by_admin' ? 'selected' : ''}>Approved by Admin</option>
                        <option value="approved_but_not_executed" ${param.status == 'approved_but_not_executed' ? 'selected' : ''}>Approved by Director</option>
                        <option value="rejected" ${param.status == 'rejected' ? 'selected' : ''}>Rejected</option>
                    </select>
                </div>
                <button type="submit" class="btn-primary text-white px-4 py-2 rounded-lg mt-2 md:mt-0 md:ml-2">
                    Search
                </button>
            </form>

            <!-- Items Per Page -->
            <form action="${pageContext.request.contextPath}/AdminApproveServlet" method="get" class="mb-6 flex items-center gap-2">
                <span class="text-gray-700 dark:text-gray-300">Items per page:</span>
                <select name="itemsPerPage" onchange="this.form.submit()" 
                        class="border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                    <option value="10" ${itemsPerPage == '10' ? 'selected' : ''}>10 proposals/page</option>
                    <option value="20" ${itemsPerPage == '20' ? 'selected' : ''}>20 proposals/page</option>
                    <option value="30" ${itemsPerPage == '30' ? 'selected' : ''}>30 proposals/page</option>
                </select>
                <input type="hidden" name="search" value="${search}">
                <input type="hidden" name="dateFrom" value="${dateFrom}">
                <input type="hidden" name="dateTo" value="${dateTo}">
                <input type="hidden" name="status" value="${status}">
                <input type="hidden" name="page" value="${currentPage}">
            </form>

            <!-- Proposals Table -->
            <div class="table-container bg-white dark:bg-gray-800">
                <div class="overflow-x-auto">
                    <table class="w-full table-auto">
                        <thead>
                            <tr class="bg-primary-600 text-white">
                                <th class="p-4 text-left cursor-pointer" data-sort="#">No.</th>
                                <th class="p-4 text-left cursor-pointer" data-sort="proposalId">Proposal ID</th>
                                <th class="p-4 text-left cursor-pointer" data-sort="proposalType">Proposal Type</th>
                                <th class="p-4 text-left cursor-pointer" data-sort="sender">Sender</th>
                                <th class="p-4 text-left cursor-pointer" data-sort="sendDate">Send Date</th>
                                <th class="p-4 text-left cursor-pointer" data-sort="approvalDate">Approval Date</th>
                                <th class="p-4 text-left cursor-pointer" data-sort="adminStatus">Admin Status</th>
                                <th class="p-4 text-left cursor-pointer" data-sort="directorStatus">Director Status</th>
                                <th class="p-4 text-left">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="proposal" items="${pendingProposals}" varStatus="loop">
                                <tr class="border-b border-gray-200 dark:border-gray-700">
                                    <td class="p-4">${(currentPage - 1) * itemsPerPage + loop.count}</td>
                                    <td class="p-4">${not empty proposal.proposalId ? proposal.proposalId : 'N/A'}</td>
                                    <td class="p-4">${not empty proposal.proposalType ? proposal.proposalType : 'N/A'}</td>
                                    <td class="p-4">${not empty proposal.senderName ? proposal.senderName : 'N/A'}</td>
                                    <td class="p-4">
                                        <fmt:formatDate value="${proposal.proposalSentDate}" pattern="dd/MM/yyyy HH:mm" var="sendDateFormatted"/>
                                        ${not empty sendDateFormatted ? sendDateFormatted : 'N/A'}
                                    </td>
                                    <td class="p-4">
                                        <fmt:formatDate value="${proposal.approvalDate}" pattern="dd/MM/yyyy HH:mm" var="approvalDateFormatted"/>
                                        ${not empty approvalDateFormatted ? approvalDateFormatted : 'Not Approved'}
                                    </td>
                                    <td class="p-4">
                                        <span class="badge
                                              ${proposal.approval.adminStatus == 'pending' ? 'bg-yellow-300 text-yellow-900 animate-bounce' : 
                                                proposal.approval.adminStatus == 'approved' ? 'bg-blue-300 text-blue-900' : 
                                                proposal.approval.adminStatus == 'rejected' ? 'bg-red-300 text-red-900' : 
                                                'bg-gray-300 text-gray-900'}">
                                                  ${not empty proposal.approval.adminStatus ? proposal.approval.adminStatus : 'N/A'}
                                              </span>
                                        </td>
                                        <td class="p-4">
                                            <span class="badge
                                                  ${proposal.approval.directorStatus == 'pending' ? 'bg-yellow-300 text-yellow-900 animate-bounce' : 
                                                    proposal.approval.directorStatus == 'approved' ? 'bg-blue-300 text-blue-900' : 
                                                    proposal.approval.directorStatus == 'rejected' ? 'bg-red-300 text-red-900' : 
                                                    'bg-gray-300 text-gray-900'}">
                                                      ${not empty proposal.approval.directorStatus ? proposal.approval.directorStatus : 'N/A'}
                                                  </span>
                                            </td>
                                            <td class="py-4 px-6">
                                                <a href="${pageContext.request.contextPath}/AdminProposalDetailServlet?proposalId=${proposal.proposalId}"
                                                   class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
                                                    <i class="fas fa-eye mr-2"></i>View & Edit
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Pagination -->
                    <div class="mt-6 flex justify-between items-center">
                        <c:set var="currentPage" value="${currentPage}" />
                        <c:set var="itemsPerPage" value="${itemsPerPage}" />
                        <c:set var="totalPages" value="${totalPages}" />
                        <c:set var="prevPage" value="${currentPage > 1 ? currentPage - 1 : 1}" />
                        <c:set var="nextPage" value="${currentPage < totalPages ? currentPage + 1 : totalPages}" />

                        <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${prevPage}&search=${search}&dateFrom=${dateFrom}&dateTo=${dateTo}&status=${status}&itemsPerPage=${itemsPerPage}" 
                           class="btn-primary text-white px-4 py-2 rounded-lg ${currentPage <= 1 ? 'opacity-50 cursor-not-allowed' : ''}">
                            Previous
                        </a>
                        <div class="flex space-x-2">
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${i}&search=${search}&dateFrom=${dateFrom}&dateTo=${dateTo}&status=${status}&itemsPerPage=${itemsPerPage}" 
                                   class="px-4 py-2 rounded-lg ${currentPage == i ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-700'}">
                                    ${i}
                                </a>
                            </c:forEach>
                        </div>
                        <a href="${pageContext.request.contextPath}/AdminApproveServlet?page=${nextPage}&search=${search}&dateFrom=${dateFrom}&dateTo=${dateTo}&status=${status}&itemsPerPage=${itemsPerPage}" 
                           class="btn-primary text-white px-4 py-2 rounded-lg ${currentPage >= totalPages ? 'opacity-50 cursor-not-allowed' : ''}">
                            Next
                        </a>
                    </div>

                    <!-- Back to Dashboard -->
                    <div class="mt-6">
                        <a href="${pageContext.request.contextPath}/adminDashboard" 
                           class="btn-primary text-white px-4 py-2 rounded-lg">Back to Dashboard</a>
                    </div>
                </main>

                <!-- Footer -->
                <footer class="bg-gray-100 dark:bg-gray-800 text-center p-6 mt-8 border-t border-gray-200 dark:border-gray-700 transition-all duration-300">
                    <p class="text-gray-600 dark:text-gray-300 text-sm">Hệ thống Quản lý Vật tư - Phiên bản 2.0 © 2025 | <a href="mailto:support@company.com" class="text-primary-600 dark:text-primary-400 hover:underline text-base">Liên hệ hỗ trợ</a></p>
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

                    // Prevent sidebar from closing when clicking inside it
                    sidebar.addEventListener('click', (event) => {
                        event.stopPropagation();
                    });

                    // Toggle sidebar when clicking toggle buttons
                    toggleSidebar.addEventListener('click', toggleSidebarVisibility);
                    toggleSidebarMobile.addEventListener('click', toggleSidebarVisibility);

                    // Close sidebar when clicking outside (optional, only if desired)
                    document.addEventListener('click', (event) => {
                        if (!sidebar.contains(event.target) && !toggleSidebar.contains(event.target) && !toggleSidebarMobile.contains(event.target) && sidebar.classList.contains('active')) {
                            sidebar.classList.remove('active');
                            sidebar.classList.add('hidden');
                        }
                    });

                    document.addEventListener('DOMContentLoaded', () => {
                        const toggles = document.querySelectorAll('.toggle-submenu');
                        toggles.forEach(toggle => {
                            toggle.addEventListener('click', (event) => {
                                event.stopPropagation(); // Prevent submenu toggle from closing sidebar
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

                    // Table Sorting
                    document.querySelectorAll('.table th[data-sort]').forEach(th => {
                        th.addEventListener('click', (event) => {
                            event.stopPropagation(); // Prevent table sorting from closing sidebar
                            const table = th.closest('table');
                            const tbody = table.querySelector('tbody');
                            const rows = Array.from(tbody.querySelectorAll('tr'));
                            const columnIndex = th.cellIndex;
                            const sortKey = th.getAttribute('data-sort');
                            const isNumeric = sortKey === '#' || sortKey === 'proposalId';
                            const isDate = sortKey === 'sendDate' || sortKey === 'approvalDate';
                            const isAsc = th.classList.toggle('asc');
                            th.classList.toggle('desc', !isAsc);

                            // Remove sort indicators from other headers
                            table.querySelectorAll('th').forEach(header => {
                                if (header !== th)
                                    header.classList.remove('asc', 'desc');
                            });

                            rows.sort((a, b) => {
                                let aValue = a.cells[columnIndex].textContent.trim();
                                let bValue = b.cells[columnIndex].textContent.trim();

                                if (isNumeric) {
                                    aValue = parseFloat(aValue) || 0;
                                    bValue = parseFloat(bValue) || 0;
                                    return isAsc ? aValue - bValue : bValue - aValue;
                                } else if (isDate) {
                                    aValue = aValue === 'Not Approved' ? '' : new Date(aValue.split(' ').reverse().join(' ').replace(/(\d+)\/(\d+)\/(\d+)/, '$3-$2-$1'));
                                    bValue = bValue === 'Not Approved' ? '' : new Date(bValue.split(' ').reverse().join(' ').replace(/(\d+)\/(\d+)\/(\d+)/, '$3-$2-$1'));
                                    if (aValue === '' && bValue === '')
                                        return 0;
                                    if (aValue === '')
                                        return isAsc ? 1 : -1;
                                    if (bValue === '')
                                        return isAsc ? -1 : 1;
                                    return isAsc ? aValue - bValue : bValue - aValue;
                                } else {
                                    return isAsc ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue);
                                }
                            });

                            // Re-append sorted rows
                            rows.forEach(row => tbody.appendChild(row));
                        });
                    });
                </script>
            </body>
        </html>