<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Parent Category</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">
        
        <style>
            .btn-primary:disabled {
                opacity: 0.5;
                cursor: not-allowed;
                background-color: #9ca3af;
                border-color: #9ca3af;
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">

        <%
            String role = (String) session.getAttribute("role");
            if (role == null || (!role.equals("admin") && !role.equals("direction"))) {
                response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
                return;
            }
        %>
        
        <!-- Sidebar -->
        <c:choose>
            <c:when test="${role == 'admin'}">
                <jsp:include page="/view/sidebar/sidebarAdmin.jsp" />
            </c:when>
            <c:when test="${role == 'direction'}">
                <jsp:include page="/view/sidebar/sidebarDirection.jsp" />
            </c:when>
            <c:when test="${role == 'warehouse'}">
                <jsp:include page="/view/sidebar/sidebarWarehouse.jsp" />
            </c:when>
            <c:when test="${role == 'employee'}">
                <jsp:include page="/view/sidebar/sidebarEmployee.jsp" />
            </c:when>
        </c:choose>

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Edit Parent Category</h2>
                </div>

                <!-- Current Category Info -->
                <c:if test="${not empty category}">
                    <div class="mb-6 p-4 bg-gray-50 dark:bg-gray-700 border-l-4 border-blue-500 rounded-lg">
                        <p class="text-sm text-gray-700 dark:text-gray-300">
                            <i class="fas fa-info-circle mr-2"></i><strong>Editing:</strong>
                            <span class="font-medium">${category.name}</span>
                            <span class="text-blue-600 dark:text-blue-400">(Root Category)</span>
                        </p>
                    </div>
                </c:if>

                <!-- Error/Success Messages -->
                <c:if test="${not empty errorMessage}">
                    <div class="mb-4 p-3 rounded bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-300">
                        <i class="fas fa-exclamation-circle mr-2"></i>${errorMessage}
                    </div>
                </c:if>
                <c:if test="${not empty successMessage}">
                    <div class="mb-4 p-3 rounded bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-300">
                        <i class="fas fa-check-circle mr-2"></i>${successMessage}
                    </div>
                </c:if>

                <c:if test="${not empty category}">
                    <form action="${pageContext.request.contextPath}/EditParentCategoryController" method="post" id="editParentCategoryForm" class="space-y-4">
                        <input type="hidden" name="categoryId" value="${category.categoryId}" />
                        
                        <div class="space-y-2">
                            <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Category Name</label>
                            <input type="text" id="name" name="name" value="${category.name}" required 
                                   class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                                   placeholder="Enter parent category name"
                                   maxlength="100">
                            <p class="text-xs text-gray-500">Tên danh mục phải có từ 2 đến 100 ký tự</p>
                        </div>

                        <div class="space-y-2">
                            <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                            <select id="status" name="status" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                                <option value="active" <c:if test="${category.status == 'active'}">selected</c:if>>Active</option>
                                <option value="inactive" <c:if test="${category.status == 'inactive'}">selected</c:if>>Inactive</option>
                            </select>
                        </div>

                        <div class="flex gap-4">
                            <button type="submit" id="updateBtn" disabled class="btn-primary text-white px-6 py-2 rounded-lg flex items-center justify-center transition-all duration-300">
                                <i class="fas fa-save mr-2"></i> Update Category
                            </button>
                            <a href="${pageContext.request.contextPath}/ListParentCategoryController" 
                               class="btn-secondary text-white px-6 py-2 rounded-lg flex items-center justify-center">
                                <i class="fas fa-times mr-2"></i> Cancel
                            </a>
                        </div>
                    </form>
                </c:if>

                <c:if test="${empty category}">
                    <div class="text-center py-8">
                        <i class="fas fa-exclamation-triangle text-4xl text-yellow-500 mb-4"></i>
                        <p class="text-gray-600 dark:text-gray-400">Danh mục không tồn tại hoặc đã bị xóa.</p>
                        <a href="${pageContext.request.contextPath}/ListParentCategoryController" 
                           class="btn-primary text-white px-6 py-2 rounded-lg mt-4 inline-block">
                            <i class="fas fa-arrow-left mr-2"></i> Back to List
                        </a>
                    </div>
                </c:if>

            </div>
            
            <div class="mt-6 flex justify-center gap-4 max-w-2xl mx-auto w-full">
                <div class="w-1/3">
                    <a href="${pageContext.request.contextPath}/ListParentCategoryController" 
                       class="btn-secondary text-white px-6 py-3 rounded-lg">
                        Back to list category
                    </a>
                </div>
                <div class="w-1/2">
                    <div class="w-full">
                        <jsp:include page="/view/backToDashboardButton.jsp" />
                    </div>
                </div>
            </div>
        </main>

        <!-- JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            // Only handle UI state - validation is done server-side
            let initialName = '';
            let initialStatus = '';
            const updateBtn = document.getElementById('updateBtn');

            // Initialize values after page load
            document.addEventListener('DOMContentLoaded', function() {
                initialName = document.getElementById('name').value.trim();
                initialStatus = document.getElementById('status').value;
                checkChanges();
            });

            function checkChanges() {
                const currentName = document.getElementById('name').value.trim();
                const currentStatus = document.getElementById('status').value;
                
                const hasChanges = (currentName !== initialName || currentStatus !== initialStatus);
                updateBtn.disabled = !hasChanges;
            }

            // Add event listeners for UI updates only
            document.getElementById('name').addEventListener('input', checkChanges);
            document.getElementById('status').addEventListener('change', checkChanges);

            // Handle success/error messages
            <c:if test="${not empty successMessage}">
                setTimeout(function() {
                    initialName = document.getElementById('name').value.trim();
                    initialStatus = document.getElementById('status').value;
                    checkChanges();
                }, 100);
                
                Swal.fire({
                    icon: 'success',
                    title: 'Thành công',
                    text: '${successMessage}',
                    showConfirmButton: false,
                    timer: 2000
                });
                <% session.removeAttribute("successMessage"); %>
            </c:if>

            <c:if test="${not empty errorMessage}">
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi',
                    text: '${errorMessage}',
                    showConfirmButton: false,
                    timer: 3000
                });
                <% session.removeAttribute("errorMessage"); %>
            </c:if>
        </script>

    </body>
</html>