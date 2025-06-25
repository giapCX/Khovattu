<!-- Sidebar -->
<aside id="sidebar" class="sidebar w-72 text-white p-4 fixed h-full z-50">
    <div class="sidebar-header flex items-center mb-4">
        <div class="w-10 h-10 rounded-full bg-white flex items-center justify-center mr-2">
            <i class="fas fa-boxes text-primary-600 text-xl"></i>
        </div>
        <h2 class="text-xl font-bold">QL Vật Tư</h2>
        <button id="toggleSidebar" class="ml-auto text-white opacity-75 hover:opacity-100">
            <i class="fas fa-times"></i>
        </button>
    </div>
    <div class="mb-4 px-2">
        <div class="relative">
            <input type="text" placeholder="Tìm kiếm..." 
                   class="w-full p-2 bg-white bg-opacity-20 text-white placeholder-white placeholder-opacity-70 rounded-lg py-2 pl-8 pr-4 focus:outline-none focus:ring-2 focus:ring-white focus:ring-opacity-50 search-input">
            <i class="fas fa-search absolute left-2 top-2 text-white opacity-70"></i>
        </div>
    </div>
    <nav class="space-y-1">
        <a href="${pageContext.request.contextPath}/userprofile" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-user mr-2 w-5 text-center"></i>
                <span class="text-base">Thông tin cá nhân</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/inventory.jsp" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-warehouse mr-2 w-5 text-center"></i>
                <span class="text-base">Quản lý vật tư</span>
            </div>
            <span class="ml-auto bg-white bg-opacity-20 text-xs px-1 py-0.5 rounded">5</span>
        </a>
        <a href="${pageContext.request.contextPath}/ListMaterialController" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-box-open mr-2 w-5 text-center"></i>
                <span class="text-base">Danh mục vật tư</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/ListSupplierServlet" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-truck mr-2 w-5 text-center"></i>
                <span class="text-base">Nhà cung cấp</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/requests.jsp" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-clipboard-list mr-2 w-5 text-center"></i>
                <span class="text-base">Yêu cầu xuất/mua</span>
            </div>
            <span class="ml-auto bg-red-500 text-white text-xs px-1 py-0.5 rounded-full">3</span>
        </a>
        <a href="${pageContext.request.contextPath}/reports.jsp" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-chart-bar mr-2 w-5 text-center"></i>
                <span class="text-base">Thống kê & Báo cáo</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <div class="border-t border-white border-opacity-20 my-2"></div>
        <a href="${pageContext.request.contextPath}/importData.jsp" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-arrow-down mr-2 w-5 text-center"></i>
                <span class="text-base">Nhập kho</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/export.jsp" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-arrow-up mr-2 w-5 text-center"></i>
                <span class="text-base">Xuất kho</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/exportHistory" class="nav-item flex items-center p-2 justify-between">
            <div class="flex items-center">
                <i class="fas fa-history mr-2 w-5 text-center"></i>
                <span class="text-base">Lịch sử xuất kho</span>
            </div>
            <i class="fas fa-chevron-right ml-auto text-xs opacity-50"></i>
        </a>
    </nav>
    <div class="absolute bottom-0 left-0 right-0 p-4 bg-white bg-opacity-10">
        <a href="${pageContext.request.contextPath}/forgetPassword/changePassword.jsp" class="flex items-center p-2 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-key mr-2 w-5 text-center"></i>
            <span class="text-base">Đổi mật khẩu</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="flex items-center p-2 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-sign-out-alt mr-2 w-5 text-center"></i>
            <span class="text-base">Đăng xuất</span>
        </a>
    </div>
</aside>
