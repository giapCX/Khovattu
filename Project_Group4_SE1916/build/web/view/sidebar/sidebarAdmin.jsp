<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50 bg-gradient-to-b from-blue-900 to-blue-500 shadow-lg">
    <div class="flex items-center mb-8">
        <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
            <i class="fas fa-boxes text-primary-600 text-2xl"></i>
        </div>
        <h2 class="text-2xl font-bold">Material Management</h2>
        <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100">
            <i class="fas fa-times"></i>
        </button>
    </div>
    <div class="mb-6 px-2">
        <div class="relative">
            <input type="text" placeholder="Search..." 
                   class="w-full bg-white bg-opacity-20 text-white placeholder-white placeholder-opacity-70 rounded-lg py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-white focus:ring-opacity-50">
            <i class="fas fa-search absolute left-3 top-2.5 text-white opacity-70"></i>
        </div>
    </div>
    <nav class="space-y-2">
        <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class="nav-item flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-home mr-3 w-6 text-center"></i>
            <span class="text-lg">Dashboard</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="nav-item flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-box-open mr-3 w-6 text-center"></i>
            <span class="text-lg">Material Categories</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <div class="nav-item flex flex-col">
            <button type="button" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20 toggle-submenu">
                <div class="flex items-center">
                    <i class="fas fa-truck mr-3 w-6 text-center"></i>
                    <span class="text-lg">Suppliers</span>
                </div>
                <i class="fas fa-chevron-down ml-auto text-sm opacity-50"></i>
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
        <a href="${pageContext.request.contextPath}/listuser" class="nav-item flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-cog mr-3 w-6 text-center"></i>
            <span class="text-lg">User List</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/exportHistory" class="nav-item flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-history mr-3 w-6 text-center"></i>
            <span class="text-lg">Export History</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/importhistory" class="nav-item flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-history mr-3 w-6 text-center"></i>
            <span class="text-lg">Import History</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/AdminApproveServlet" class="nav-item flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20 active">
            <i class="fas fa-check-circle mr-3 w-6 text-center"></i>
            <span class="text-lg">Approve Proposals</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
    </nav>
    <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
        <a href="${pageContext.request.contextPath}/userprofile" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-user mr-3"></i>
            <span class="text-lg">My Profile</span>
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