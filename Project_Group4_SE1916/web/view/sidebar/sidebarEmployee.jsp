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
    <div class="flex items-center mb-8">
        <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
            <i class="fas fa-boxes text-primary-600 text-2xl"></i>
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
                <span class="text-base">My Information</span>
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

            </div>
        </div>
        <div class="nav-item flex flex-col">
            <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                <div class="flex items-center">
                    <i class="fas fa-building mr-2 w-5 text-center"></i>
                    <span class="text-base">Construction Site</span>
                </div>
                <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
            </button>
            <!-- Menu con - ẩn mặc định -->
            <div class="submenu hidden pl-6 space-y-1 mt-1">
                <a href="${pageContext.request.contextPath}/ListConstructionSites" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                    <i class="fas fa-list mr-2 w-4 text-center"></i>
                    <span class="text-sm">List Construction Site</span>
                </a>

            </div>
        </div>
        <!-- Proposal - Menu cha -->
        <div class="nav-item flex flex-col">
            <button type="button" class="flex items-center p-2 justify-between w-full text-left toggle-submenu">
                <div class="flex items-center">
                    <i class="fas fas fa-file-alt mr-2 w-5 text-center"></i>
                    <span class="text-base">Request List</span>
                </div>
                <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
            </button>

            <!-- Menu con - ẩn mặc định -->
            <div class="submenu hidden pl-6 space-y-1 mt-1">
                <a href="${pageContext.request.contextPath}/ListProposalServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                    <i class="fas fa-list mr-2 w-4 text-center"></i>
                    <span class="text-sm">My Submitted Proposals</span>
                </a>
                <a href="${pageContext.request.contextPath}/ProposalServlet" class="flex items-center p-2 hover:bg-white hover:bg-opacity-20 rounded-lg">
                    <i class="fas fa-circle-plus mr-2 w-4 text-center"></i>
                    <span class="text-sm">Create New Proposal</span>
                </a>
            </div>
        </div>
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
