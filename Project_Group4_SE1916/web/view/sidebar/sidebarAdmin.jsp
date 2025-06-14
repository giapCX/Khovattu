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
        <a href="${pageContext.request.contextPath}/userprofile" class="nav-item flex items-center p-3">
            <i class="fas fa-tachometer-alt mr-3 w-6 text-center"></i>
            <span class="text-lg">Thông tin cá nhân</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/home.jsp" class="nav-item active flex items-center p-3">
            <i class="fas fa-tachometer-alt mr-3 w-6 text-center"></i>
            <span class="text-lg">Tổng quan</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/inventory.jsp" class="nav-item flex items-center p-3">
            <i class="fas fa-warehouse mr-3 w-6 text-center"></i>
            <span class="text-lg">Quản lý kho</span>
            <span class="ml-auto bg-white bg-opacity-20 text-sm px-2 py-1 rounded-full">5</span>
        </a>
        <a href="${pageContext.request.contextPath}/ListSupplierServlet" class="nav-item flex items-center p-3">
            <i class="fas fa-box-open mr-3 w-6 text-center"></i>
            <span class="text-lg">Danh sách nhà cung cấp</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/ListMaterialController" class="nav-item flex items-center p-3">
            <i class="fas fa-box-open mr-3 w-6 text-center"></i>
            <span class="text-lg">Danh mục vật tư</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/orders.jsp" class="nav-item flex items-center p-3">
            <i class="fas fa-clipboard-list mr-3 w-6 text-center"></i>
            <span class="text-lg">Đơn hàng</span>
            <span class="ml-auto bg-red-500 text-white text-sm px-2 py-1 rounded-full">3</span>
        </a>
        <a href="${pageContext.request.contextPath}/reports.jsp" class="nav-item flex items-center p-3">
            <i class="fas fa-chart-bar mr-3 w-6 text-center"></i>
            <span class="text-lg">Báo cáo</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/listuser" class="nav-item flex items-center p-3">
            <i class="fas fa-cog mr-3 w-6 text-center"></i>
            <span class="text-lg">Danh sách người dùng</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
    </nav>
    <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
        <a href="${pageContext.request.contextPath}/logout" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-sign-out-alt mr-3"></i>
            <span class="text-lg">Đăng xuất</span>
        </a>
    </div>
</aside>
