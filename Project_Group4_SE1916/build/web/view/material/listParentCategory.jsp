
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Parent Category List</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            .view-details-cell {
                min-width: 120px;
                word-break: break-word;
            }
            .view-details-cell a {
                display: inline-block;
                white-space: nowrap;
            }
            .error-message {
                color: red;
                font-size: 0.875rem;
                margin-top: 0.25rem;
            }
            
            .dropdown-container {
        position: relative;
        display: inline-block;
    }
    .dropdown-content {
        display: none;
        position: absolute;
        background-color: white;
        min-width: 250px;
        box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
        z-index: 1;
        border-radius: 8px;
        padding: 8px 0;
        max-height: 300px;
        overflow-y: auto;
    }
    .dropdown-item {
        padding: 8px 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .dropdown-item:hover {
        background-color: #f1f5f9;
    }
    .dropdown-btn {
        cursor: pointer;
        padding: 4px 12px;
        border-radius: 20px;
        background-color: #e0f2fe;
        color: #0369a1;
        border: none;
        transition: all 0.2s;
    }
    .dropdown-btn:hover {
        background-color: #bae6fd;
    }
    .action-btns {
        display: flex;
        gap: 4px;
    }
    .action-btn {
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
        cursor: pointer;
    }
    .view-btn {
        background-color: #3b82f6;
        color: white;
    }
    .edit-btn {
        background-color: #f59e0b;
        color: white;
    }
        </style>
    </head>
    <body class="bg-white font-sans min-h-screen">
        <%
            String role = (String) session.getAttribute("role");
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
        <main class="flex-1 p-6 transition-all duration-300">
            <div class="container mx-auto">
                <!-- Title and Hamburger Button -->
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-sky-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h1 class="text-4xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-sky-600 to-blue-600 animate-pulse">
                            Parent Category List
                        </h1>
                    </div>
                    <div class="flex gap-4">
                        <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" 
                           class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md inline-flex items-center">
                            <i class="fas fa-arrow-left mr-2"></i>Back to Home
                        </a>
                        <a href="${pageContext.request.contextPath}/AddParentCategoryController" 
                           class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md inline-flex items-center">
                            <i class="fas fa-plus mr-2"></i>Add Parent Category
                        </a>
                    </div>
                </div>

                <!-- Search and Filter Bar -->
                <form id="searchForm" action="${pageContext.request.contextPath}/listParentCategory" method="get" onsubmit="return validateForm()">
                    <div class="flex flex-col md:flex-row justify-between mb-6 gap-4">
                        <div class="flex w-full md:w-1/3 gap-2">
                            <div class="relative flex-1">
                                <input type="text" id="searchInput" name="search" value="${param.search}" placeholder="Search by Name Parent Category..." 
                                       class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
                                <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
                                <div id="searchError" class="error-message"></div>
                            </div>
                            <button type="submit" id="searchButton" class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
                                <i class="fas fa-search mr-2"></i>Search
                            </button>
                        </div>
                        <div class="flex flex-col md:flex-row gap-4 w-full md:w-2/3">
                            <div class="relative w-full md:w-1/2">
                                <select id="statusFilter" name="status" onchange="this.form.submit()" 
                                        class="p-3 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
                                    <option value="">All Statuses</option>
                                    <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                                    <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                                </select>
                            </div>
                            <div class="relative w-full md:w-1/2">
                                <select id="itemsPerPage" name="itemsPerPage" onchange="this.form.submit()" 
                                        class="p-3 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
                                    <option value="10" ${param.itemsPerPage == '10' ? 'selected' : ''}>10 items/page</option>
                                    <option value="20" ${param.itemsPerPage == '20' ? 'selected' : ''}>20 items/page</option>
                                    <option value="30" ${param.itemsPerPage == '30' ? 'selected' : ''}>30 items/page</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </form>

                <!-- Parent Category Table -->
                <div class="overflow-x-auto rounded-2xl shadow-xl">
                    <table class="min-w-full bg-white">
                        <thead class="bg-gradient-to-r from-sky-600 to-blue-600 text-white">
                            <tr>
                                <th class="py-4 px-6 text-left rounded-tl-2xl"><i class="fas fa-list-ol mr-2"></i>Id</th>
                                <th class="py-4 px-6 text-left"><i class="fas fa-box mr-2"></i>Category Name</th>
                                <th class="py-4 px-6 text-left"><i class="fas fa-layer-group mr-2"></i>Child Categories</th>
                                <th class="py-4 px-6 text-left"><i class="fas fa-check-circle mr-2"></i>Status</th>
                                <th class="py-4 px-6 text-center view-details-cell rounded-tr-2xl"><i class="fas fa-eye mr-2"></i>Actions</th>
                            </tr>
                        </thead>
                       <tbody id="categoryTableBody" class="divide-y divide-gray-200">
    <c:forEach var="cat" items="${parentCategories}" varStatus="loop">
        <tr class="hover:bg-gradient-to-r hover:from-sky-50 hover:to-cyan-50 transition-all duration-300">
            <td class="py-4 px-6 font-medium">${cat.categoryId}</td>
            <td class="py-4 px-6">${cat.name}</td>
            <td class="py-4 px-6">
                <div class="dropdown-container">
                    <button onclick="toggleDropdown('dropdown-${cat.categoryId}')" 
                            class="dropdown-btn flex items-center">
                        <span>${cat.childCount} child categories</span>
                        <i class="fas fa-chevron-down ml-1 text-xs"></i>
                    </button>
                    <div id="dropdown-${cat.categoryId}" class="dropdown-content">
                        <c:forEach var="childCat" items="${childCategoriesMap[cat.categoryId]}">
                            <div class="dropdown-item">
                                <span>${childCat.name}</span>
                                <div class="action-btns">
                                    <a href="${pageContext.request.contextPath}/ListMaterialController?filterParentCategory=${cat.categoryId}&filterCategory=${childCat.categoryId}"
                                       class="action-btn view-btn">
                                        <i class="fas fa-eye mr-1"></i>View
                                    </a>
                                    <a href="${pageContext.request.contextPath}/EditChildCategoryController?id=${childCat.categoryId}"
                                       class="action-btn edit-btn">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                </div>
                            </div>
                        </c:forEach>
                        <div class="dropdown-item border-t border-gray-100 bg-gray-50">
                            <a href="${pageContext.request.contextPath}/ListMaterialController?filterParentCategory=${cat.categoryId}"
                               class="text-blue-600 hover:text-blue-800 text-sm font-medium inline-flex items-center">
                                <i class="fas fa-boxes mr-1"></i> View All Materials
                            </a>
                        </div>
                    </div>
                </div>
            </td>
            <td class="py-4 px-6">
                <span class="px-3 py-1 rounded-full font-semibold
                      <c:choose>
                          <c:when test="${cat.status == 'active'}">bg-green-300 text-green-900</c:when>
                          <c:when test="${cat.status == 'inactive'}">bg-red-300 text-red-900</c:when>
                          <c:otherwise>bg-gray-300 text-gray-900</c:otherwise>
                      </c:choose>">
                    ${cat.status}
                </span>
            </td>
            <td class="py-4 px-6 text-center view-details-cell">
                <a href="${pageContext.request.contextPath}/EditParentCategoryController?categoryId=${cat.categoryId}" 
                   class="px-4 py-2 bg-gradient-to-r from-yellow-500 to-orange-500 text-white rounded-lg hover:from-yellow-600 hover:to-orange-600 transition-all duration-300 shadow-md">
                    <i class="fas fa-edit mr-2"></i>Edit
                </a>
            </td>
        </tr>
    </c:forEach>
</tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <div class="flex justify-center mt-6 gap-2">
                    <c:set var="currentPage" value="${param.page == null ? 1 : param.page}"/>
                    <c:set var="totalPages" value="${totalPages}"/>
                    <a href="${pageContext.request.contextPath}/listParentCategory?page=${currentPage - 1}&search=${param.search}&status=${param.status}&itemsPerPage=${param.itemsPerPage}" 
                       class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == 1 ? 'opacity-50 pointer-events-none' : ''}">
                        <i class="fas fa-chevron-left mr-2"></i>Previous Page
                    </a>
                    <div class="flex gap-2">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="${pageContext.request.contextPath}/listParentCategory?page=${i}&search=${param.search}&status=${param.status}&itemsPerPage=${param.itemsPerPage}" 
                               class="px-4 py-2 rounded-lg shadow-md transition-all duration-300 ${i == currentPage ? 'bg-blue-600 text-white' : 'bg-sky-200 text-sky-800 hover:bg-sky-300'}">${i}</a>
                        </c:forEach>
                    </div>
                    <a href="${pageContext.request.contextPath}/listParentCategory?page=${currentPage + 1}&search=${param.search}&status=${param.status}&itemsPerPage=${param.itemsPerPage}" 
                       class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == totalPages ? 'opacity-50 pointer-events-none' : ''}">
                        Next Page<i class="fas fa-chevron-right ml-2"></i>
                    </a>
                </div>
            </div>
        </main>


        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>

        <script>
                                    function validateForm() {
                                        const searchInput = document.getElementById('searchInput').value;
                                        const searchError = document.getElementById('searchError');
                                        const itemsPerPage = document.getElementById('itemsPerPage').value;
                                        searchError.textContent = '';
                                        if (searchInput.length > 100) {
                                            searchError.textContent = 'Search term must be less than 100 characters.';
                                            return false;
                                        }
                                        if (!itemsPerPage) {
                                            searchError.textContent = 'Please select items per page.';
                                            return false;
                                        }
                                        return true;
                                    }
                                     function toggleDropdown(dropdownId) {
        var dropdown = document.getElementById(dropdownId);
        if (dropdown.style.display === 'block') {
            dropdown.style.display = 'none';
        } else {
            // Đóng tất cả dropdown khác trước khi mở dropdown hiện tại
            document.querySelectorAll('.dropdown-content').forEach(function(dropdown) {
                dropdown.style.display = 'none';
            });
            dropdown.style.display = 'block';
        }
    }

    // Đóng dropdown khi click ra ngoài
    document.addEventListener('click', function(event) {
        if (!event.target.matches('.dropdown-btn') && !event.target.closest('.dropdown-content')) {
            document.querySelectorAll('.dropdown-content').forEach(function(dropdown) {
                dropdown.style.display = 'none';
            });
        }
    });
        </script>
    </body>
</html>
