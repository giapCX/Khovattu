<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Add Category</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">
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
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Add new category</h2>
                </div>

                <!-- Category Type Info -->
                <div class="mb-6 p-4 bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-500 rounded-lg">
                    <p class="text-sm text-blue-700 dark:text-blue-300">
                        <i class="fas fa-info-circle mr-2"></i><strong>Hướng dẫn:</strong>
                    </p>
                    <ul class="mt-2 text-sm text-blue-600 dark:text-blue-400 list-disc list-inside">
                        <li>Để tạo <strong>danh mục cha</strong>: Không chọn danh mục cha</li>
                        <li>Để tạo <strong>danh mục con</strong>: Chọn một danh mục cha từ dropdown</li>
                    </ul>
                </div>

                <form action="${pageContext.request.contextPath}/AddCategoryController" method="post" id="addCategoryForm" class="space-y-4">
                    <div class="space-y-2">
                        <label for="parentCategory" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Parent Category (Optional)</label>
                        <select id="parentCategory" name="parentCategory" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">-- Select Parent Category (Leave empty for parent category) --</option>
                            <c:forEach var="category" items="${parentCategories}">
                                <option value="${category.categoryId}">${category.name}</option>
                            </c:forEach>
                        </select>
                        <small class="text-sm text-gray-500 dark:text-gray-400">Nếu không chọn, danh mục sẽ được tạo như danh mục cha</small>
                    </div>

                    <div class="space-y-2">
                        <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Category Name</label>
                        <input type="text" id="name" name="name" value="${not empty param.name ? param.name : ''}" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" placeholder="Enter category name">
                    </div>

                    <div class="space-y-2">
                        <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                        <select id="status" name="status" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>

                    <button type="submit" class="btn-primary text-white px-4 py-2 rounded-lg flex items-center justify-center">
                        <i class="fas fa-plus-circle mr-2"></i> Add Category
                    </button>
                </form>

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

        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            <c:if test="${not empty successMessage}">
                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: '${successMessage}',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: { popup: 'animated fadeInDown' }
                }).then(() => {
                    document.getElementById('addCategoryForm').reset();
                });
                <% session.removeAttribute("successMessage"); %>
            </c:if>

            // Hiển thị thông tin loại danh mục dựa trên lựa chọn
            document.getElementById('parentCategory').addEventListener('change', function() {
                const infoDiv = document.querySelector('.category-type-info');
                const selectedValue = this.value;
                
                if (selectedValue === '') {
                    infoDiv.innerHTML = '<p class="text-sm text-blue-700 dark:text-blue-300"><i class="fas fa-info-circle mr-2"></i><strong>Đang tạo:</strong> <span class="text-primary">Danh mục cha</span></p>';
                } else {
                    const selectedText = this.options[this.selectedIndex].text;
                    infoDiv.innerHTML = '<p class="text-sm text-blue-700 dark:text-blue-300"><i class="fas fa-info-circle mr-2"></i><strong>Đang tạo:</strong> <span class="text-green-600">Danh mục con</span> thuộc về <strong>' + selectedText + '</strong></p>';
                }
            });

            // Client-side validation
            const form = document.getElementById('addCategoryForm');
            form.addEventListener('submit', (e) => {
                const name = document.getElementById('name').value.trim();

                // Name validation
                if (name === '') {
                    e.preventDefault();
                    alert('Category name cannot be empty.');
                    return;
                }

                if (name.length < 2 || name.length > 100) {
                    e.preventDefault();
                    alert('Category name must be between 2 and 100 characters.');
                    return;
                }
            });
        </script>

    </body>
</html>