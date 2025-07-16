
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

            <!-- Menu con - ẩn mặc định -->
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
                    <i class="fas fas fa-file-alt mr-2 w-5 text-center"></i>
                    <span class="text-base">Proposals</span>
                </div>
                <i class="fas fa-chevron-down ml-auto text-xs opacity-50"></i>
            </button>

            <!-- Menu con - ẩn mặc định -->
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
        <a href="${pageContext.request.contextPath}/view/warehouse/importData.jsp" class="nav-item flex items-center p-2 justify-between">
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