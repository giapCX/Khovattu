<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Parent Category List</title>

        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome: icon -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- style CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            .badge {
                padding: 0.25rem 0.75rem;
                border-radius: 0.5rem;
                font-size: 1rem;
                font-weight: 600;
            }

            .badge-success {
                background-color: #d1fae5;
                color: #065f46;
            }

            .badge-danger {
                background-color: #fee2e2;
                color: #991b1b;
            }

            .dropdown-container {
                position: relative;
                display: inline-block;
            }
            
            .dropdown-btn {
                cursor: pointer;
                padding: 0.5rem 1rem;
                border-radius: 0.5rem;
                background-color: #e0f2fe;
                color: #0369a1;
                border: none;
                font-weight: 500;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }
            
            .dropdown-content {
                display: none;
                position: absolute;
                background-color: white;
                min-width: 250px;
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
                z-index: 10;
                border-radius: 0.5rem;
                padding: 0.5rem 0;
                max-height: 300px;
                overflow-y: auto;
                border: 1px solid #e2e8f0;
                margin-top: 0.5rem;
            }
            
            .dropdown-item {
                padding: 0.75rem 1rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
                transition: background-color 0.2s;
                border-bottom: 1px solid #f1f5f9;
            }
            
            .dropdown-item:last-child {
                border-bottom: none;
            }
            
            .dropdown-item:hover {
                background-color: #f8fafc;
            }
            
            .action-btns {
                display: flex;
                gap: 0.5rem;
            }
            
            .action-btn {
                padding: 0.375rem 0.75rem;
                border-radius: 0.375rem;
                font-size: 0.75rem;
                cursor: pointer;
                transition: all 0.2s;
                display: flex;
                align-items: center;
                gap: 0.25rem;
            }
            
            .view-btn {
                background-color: #3b82f6;
                color: white;
            }
            
            .edit-btn {
                background-color: #f59e0b;
                color: white;
            }
            
            .view-all-materials {
                background-color: #f8fafc;
                padding: 0.75rem 1rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
                color: #3b82f6;
                font-weight: 500;
                text-decoration: none;
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">

        <%
            String role = (String) session.getAttribute("role");
            if (role == null) {
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
            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Parent Category List</h2>
                    </div>
                    <div class="flex gap-4">
                        <a href="${pageContext.request.contextPath}/AddParentCategoryController" 
                           class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                            <i class="fas fa-plus-circle mr-2"></i> Add Parent Category
                        </a>
                        <a href="${pageContext.request.contextPath}/AddChildCategoryController" 
                           class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                            <i class="fas fa-plus-circle mr-2"></i> Add Child Category
                        </a>
                    </div>
                </div>

                <!-- Search and Filter Form -->
                <form action="${pageContext.request.contextPath}/listParentCategory" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <input type="text" name="search" placeholder="Search by name" value="${param.search}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                    </div>
                    <div class="flex-1 min-w-[150px]">
                        <select name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">All Status</option>
                            <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                    <a href="${pageContext.request.contextPath}/listParentCategory" onclick="event.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;" class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-undo mr-2"></i> Reset form
                    </a>
                    <span class="text-gray-700 dark:text-gray-300">Items per page:</span>
                    <select name="itemsPerPage" onchange="this.form.submit()" 
                            class="border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500">
                        <option value="10" ${param.itemsPerPage == '10' ? 'selected' : ''}>10 items/page</option>
                        <option value="20" ${param.itemsPerPage == '20' ? 'selected' : ''}>20 items/page</option>
                        <option value="30" ${param.itemsPerPage == '30' ? 'selected' : ''}>30 items/page</option>
                    </select>
                </form>

                <!-- Table -->
                <div class="table-container bg-white dark:bg-gray-800">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto">
                            <thead>
                                <tr class="bg-primary-600 text-white">
                                    <th class="p-4 text-left">ID</th>
                                    <th class="p-4 text-left">Category Name</th>
                                    <th class="p-4 text-left">Child Categories</th>
                                    <th class="p-4 text-left">Status</th>
                                    <th class="p-4 text-left">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty parentCategories}">
                                        <c:forEach var="cat" items="${parentCategories}">
                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="p-4 font-medium">${cat.categoryId}</td>
                                                <td class="p-4 font-medium">${cat.name}</td>
                                                <td class="p-4 font-medium">
                                                    <div class="dropdown-container">
                                                        <button onclick="toggleDropdown('dropdown-${cat.categoryId}', this)" 
                                                                class="dropdown-btn">
                                                            <span>${cat.childCount} child categories</span>
                                                            <i class="fas fa-chevron-down text-xs"></i>
                                                        </button>
                                                        <div id="dropdown-${cat.categoryId}" class="dropdown-content">
                                                            <c:forEach var="childCat" items="${childCategoriesMap[cat.categoryId]}">
                                                                <div class="dropdown-item">
                                                                    <span>${childCat.name}</span>
                                                                    <div class="action-btns">
                                                                        <a href="${pageContext.request.contextPath}/ListMaterialController?filterParentCategory=${cat.categoryId}&filterCategory=${childCat.categoryId}"
                                                                           class="action-btn view-btn">
                                                                            <i class="fas fa-eye"></i>
                                                                            <span>View</span>
                                                                        </a>
                                                                        <a href="${pageContext.request.contextPath}/EditChildCategoryController?id=${childCat.categoryId}"
                                                                           class="action-btn edit-btn">
                                                                            <i class="fas fa-edit"></i>
                                                                            <span>Edit</span>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </c:forEach>
                                                            <a href="${pageContext.request.contextPath}/ListMaterialController?filterParentCategory=${cat.categoryId}"
                                                               class="view-all-materials">
                                                                <i class="fas fa-boxes"></i>
                                                                <span>View All Materials</span>
                                                            </a>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <c:choose>
                                                        <c:when test="${cat.status == 'active'}">
                                                            <span class="badge badge-success">Active</span>
                                                        </c:when>
                                                        <c:when test="${cat.status == 'inactive'}">
                                                            <span class="badge badge-danger">Inactive</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <a href="${pageContext.request.contextPath}/EditParentCategoryController?categoryId=${cat.categoryId}"
                                                       class="text-primary-600 dark:text-primary-400 hover:underline">Edit</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="p-4 text-center text-gray-500 dark:text-gray-400">
                                                No parent categories found
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div><br/>

                <!-- Pagination -->
                <div class="pagination flex items-center justify-center space-x-1">
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="listParentCategory?page=${currentPage - 1}&itemsPerPage=${param.itemsPerPage}&search=${param.search}&status=${param.status}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&lt;</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&lt;</span>
                        </c:otherwise>
                    </c:choose>
                    
                    <c:choose>
                        <c:when test="${currentPage == 1}">
                            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
                        </c:when>
                        <c:otherwise>
                            <a href="listParentCategory?page=1&itemsPerPage=${param.itemsPerPage}&search=${param.search}&status=${param.status}" class="px-3 py-1 rounded border hover:border-blue-500">1</a>
                        </c:otherwise>
                    </c:choose>
                    
                    <c:if test="${currentPage > 4}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    
                    <c:forEach var="i" begin="${currentPage - 1 > 1 ? currentPage - 1 : 2}" end="${currentPage + 1 < totalPages ? currentPage + 1 : totalPages - 1}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="listParentCategory?page=${i}&itemsPerPage=${param.itemsPerPage}&search=${param.search}&status=${param.status}" class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    
                    <c:if test="${currentPage < totalPages - 3}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    
                    <c:if test="${totalPages > 1}">
                        <c:choose>
                            <c:when test="${currentPage == totalPages}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${totalPages}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="listParentCategory?page=${totalPages}&itemsPerPage=${param.itemsPerPage}&search=${param.search}&status=${param.status}" class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    
                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="listParentCategory?page=${currentPage + 1}&itemsPerPage=${param.itemsPerPage}&search=${param.search}&status=${param.status}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&gt;</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&gt;</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <div class="mt-6 flex justify-center">
                    <jsp:include page="/view/backToDashboardButton.jsp" />
                </div>
            </div>
        </main>

        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
        
        <script>
            function toggleDropdown(dropdownId, button) {
                var dropdown = document.getElementById(dropdownId);
                if (dropdown.style.display === 'block') {
                    dropdown.style.display = 'none';
                    button.classList.remove('active');
                } else {
                    // Close all other dropdowns before opening this one
                    document.querySelectorAll('.dropdown-content').forEach(function(content) {
                        content.style.display = 'none';
                    });
                    document.querySelectorAll('.dropdown-btn').forEach(function(btn) {
                        btn.classList.remove('active');
                    });
                    
                    dropdown.style.display = 'block';
                    button.classList.add('active');
                }
            }

            // Close dropdown when clicking outside
            document.addEventListener('click', function(event) {
                if (!event.target.matches('.dropdown-btn') && !event.target.closest('.dropdown-content')) {
                    document.querySelectorAll('.dropdown-content').forEach(function(dropdown) {
                        dropdown.style.display = 'none';
                    });
                    document.querySelectorAll('.dropdown-btn').forEach(function(btn) {
                        btn.classList.remove('active');
                    });
                }
            });
        </script>
    </body>
</html>