<!-- Sidebar -->
<aside id="sidebar" class="sidebar w-72 text-white p-6 fixed h-full z-50 hidden">
    <div class="flex items-center mb-8">
        <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center mr-3">
            <i class="fas fa-boxes text-primary-600 text-2xl"></i>
        </div>
        <h2 class="text-2xl font-bold">QL Vật Tư</h2>
        <button id="toggleSidebar" class="ml-auto text-white opacity-70 hover:opacity-100">
            <i class="fas fa-times"></i>
        </button>
    </div>
    <nav class="space-y-2">
        <a href="${pageContext.request.contextPath}/userprofile" class="nav-item flex items-center p-3">
            <i class="fas fa-user mr-3 w-6 text-center"></i>
            <span class="text-lg">Thông tin cá nhân</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/createRequest.jsp" class="nav-item flex items-center p-3">
            <i class="fas fa-file-alt mr-3 w-6 text-center"></i>
            <span class="text-lg">Tạo yêu cầu</span>
            <i class="fas fa-chevron-right ml-auto text-sm opacity-50"></i>
        </a>
        <a href="${pageContext.request.contextPath}/requestHistory.jsp" class="nav-item flex items-center p-3">
            <i class="fas fa-history mr-3 w-6 text-center"></i>
            <span class="text-lg">Lịch sử yêu cầu</span>
            <span class="ml-auto bg-red-500 text-white text-sm px-2 py-1 rounded-full">2</span>
        </a>
    </nav>
    <div class="absolute bottom-0 left-0 right-0 p-6 bg-white bg-opacity-10">
        <a href="${pageContext.request.contextPath}/forgetPassword/changePassword.jsp" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-key mr-3"></i>
            <span class="text-lg">Đổi mật khẩu</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="flex items-center p-3 rounded-lg hover:bg-white hover:bg-opacity-20">
            <i class="fas fa-sign-out-alt mr-3"></i>
            <span class="text-lg">Đăng xuất</span>
        </a>
    </div>
</aside>
