<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50 bg-gradient-to-r from-blue-900 to-blue-500 shadow-lg">
    <div class="flex items-center mb-8">
        <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
            <i class="fas fa-boxes text-primary-600 text-2xl"></i>
        </div>
        <h2 class="text-2xl font-bold">Material Management</h2>
        <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100">
            <i class="fas fa-times"></i>
        </button>
    </div>
    <nav class="space-y-2">
        <div class="flex items-center space-x-3 bg-white bg-opacity-10 rounded-lg p-3 mb-6">
            <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode((String) session.getAttribute('username'), 'UTF-8')%>&background=0ea5e9&color=fff"
                 alt="Avatar" class="w-10 h-10 rounded-full border border-white shadow" />
            <div class="text-white">
                <p class="font-semibold text-base"><%= session.getAttribute("username")%></p>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class="nav-item flex items-center p-2 justify-between active">
            <div class="flex items-center">
                <i class="fas fa-home mr-2 w-5 text-center"></i>
                <span class="text-base">Dashboard</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/ListConstructionSites" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-building mr-2 w-5 text-center"></i>
                <span class="text-base">Construction Sites</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="nav-item flex items-center p-3">
            <i class="fas fa-box-open mr-3 w-6 text-center"></i>
            <span class="text-lg">Material Categories</span>
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
        <a href="${pageContext.request.contextPath}/listuser" class="nav-item flex items-center p-3">
            <i class="fas fa-cog mr-3 w-6 text-center"></i>
            <span class="text-lg">User List</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
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
        <a href="${pageContext.request.contextPath}/AdminApproveServlet" class="nav-item flex items-center p-3">
            <i class="fas fa-check-circle mr-3 w-6 text-center"></i>
            <span class="text-lg">Approve Proposals</span>
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
<script>
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
</script>