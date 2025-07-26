<!-- Session Check -->
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<%
    String role = (String) session.getAttribute("role");
    Integer userId = (Integer) session.getAttribute("userId");
    String userFullName = (String) session.getAttribute("userFullName");
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
                <span class="text-base">My Profile</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
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
        <!-- Construction Sites - Parent Menu -->
        <div class="nav-item flex flex-col">
            <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                <div class="flex items-center">
                    <i class="fas fa-building mr-2 w-5 text-center"></i>
                    <span class="text-base">Construction Sites</span>
                </div>
                <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
            </button>
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
        <!-- Users - Parent Menu -->
        <div class="nav-item flex flex-col">
            <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                <div class="flex items-center">
                    <i class="fas fa-users mr-2 w-5 text-center"></i>
                    <span class="text-base">Users</span>
                </div>
                <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
            </button>
            <div class="submenu hidden pl-6 space-y-1 mt-1">
                <a href="${pageContext.request.contextPath}/listuser" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                    <i class="fas fa-list mr-2 w-4 text-center"></i>
                    <span class="text-sm">Users List</span>
                </a>
            </div>
        </div>
        <!-- Inventory Management - Parent Menu -->
        <div class="nav-item flex flex-col">
            <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                <div class="flex items-center">
                    <i class="fas fa-box-open mr-2 w-5 text-center"></i>
                    <span class="text-base">Inventory Management</span>
                </div>
                <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
            </button>
            <div class="submenu hidden pl-6 space-y-1 mt-1">
                <a href="${pageContext.request.contextPath}/exportHistory" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                    <i class="fas fa-history mr-2 w-4 text-center"></i>
                    <span class="text-sm">Export History</span>
                </a>
                <a href="${pageContext.request.contextPath}/importhistory" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                    <i class="fas fa-history mr-2 w-4 text-center"></i>
                    <span class="text-sm">Import History</span>
                </a>
                <a href="${pageContext.request.contextPath}/inventory" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                    <i class="fas fa-boxes mr-2 w-4 text-center"></i>
                    <span class="text-sm">Inventory List</span>
                </a>
            </div>
        </div>
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