<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Material List</title>

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

            .thumbnail {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #e5e7eb;
            }

            .error-message {
                color: red;
                font-size: 0.875rem;
                margin-top: 0.25rem;
            }

            .view-details-cell {
                min-width: 120px;
                word-break: break-word;
            }

            .view-details-cell a {
                display: inline-block;
                white-space: nowrap;
            }

            td, th {
                line-height: 1.2;
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
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Material List</h2>
                    </div>
                    <div class="flex gap-4">
                        <a href="${pageContext.request.contextPath}/ListParentCategoryController" 
                           class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                            <i class="fas fa-arrow-left mr-2"></i> Back to Categories
                        </a>
                        <a href="${pageContext.request.contextPath}/AddMaterialController" 
                           class="btn-primary text-white px-6 py-3 rounded-lg flex items-center">
                            <i class="fas fa-plus-circle mr-2"></i> Add Material
                        </a>
                    </div>
                </div>

                <!-- Search and Filter Form -->
                <form action="ListMaterialController" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                    <div class="flex-1 min-w-[200px]">
                        <input type="text" id="searchInput" name="search" placeholder="Search by material code" 
                               value="${param.search}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <select id="filterParentCategory" name="filterParentCategory" 
                                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">All root categories</option>
                            <c:forEach var="parentCat" items="${parentCategories}">
                                <option value="${parentCat.categoryId}" <c:if test="${parentCat.categoryId == selectedParentCategory}">selected</c:if>>${parentCat.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[200px]">
                        <select id="filterCategory" name="filterCategory" 
                                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="">All sub categories</option>
                            <c:if test="${not empty selectedParentCategory}">
                                <c:forEach var="childCat" items="${childCategoriesMap[selectedParentCategory]}">
                                    <option value="${childCat.categoryId}" <c:if test="${childCat.categoryId == selectedChildCategory}">selected</c:if>>${childCat.name}</option>
                                </c:forEach>
                            </c:if>
                            <c:if test="${empty selectedParentCategory}">
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}" <c:if test="${cat.categoryId == selectedChildCategory}">selected</c:if>>${cat.name}</option>
                                </c:forEach>
                            </c:if>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-search mr-2"></i> Search
                    </button>
                    <a href="${pageContext.request.contextPath}/ListMaterialController" 
                       class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
                        <i class="fas fa-undo mr-2"></i> Reset form
                    </a><br/>
                   
                    <select name="itemsPerPage" onchange="this.form.submit()" 
                            class="border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                        <option value="10" ${itemsPerPage == 10 ? 'selected' : ''}>10 materials/page</option>
                        <option value="20" ${itemsPerPage == 20 ? 'selected' : ''}>20 materials/page</option>
                        <option value="30" ${itemsPerPage == 30 ? 'selected' : ''}>30 materials/page</option>
                    </select>
                    <!-- Hidden inputs to maintain current filters -->
                    <input type="hidden" name="page" value="${currentPage}">
                </form>

                <!-- Table -->
                <div class="table-container bg-white dark:bg-gray-800">
                    <div class="overflow-x-auto">
                        <table class="w-full table-auto sortable">
                            <thead>
                                <tr class="bg-primary-600 text-white">
                                    <th class="p-4 text-left sortable" data-sort="number">No</th>
                                   <th class="p-4 text-left sortable" data-sort="string">Material Name</th>
                                    <th class="p-4 text-left sortable" data-sort="string">Sub Category</th>
                                    <th class="p-4 text-left sortable" data-sort="string">Root Category</th>
                                   
                                    <th class="p-4 text-left sortable" data-sort="string">Sub Category Status</th>
                                    
                                    <th class="p-4 text-left sortable" data-sort="string">Unit</th>
                                    <th class="p-4 text-left">Image</th>
                                    <th class="p-4 text-left">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty materials}">
                                        <c:forEach var="mat" items="${materials}" varStatus="loop">
                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="p-4 font-medium">${(currentPage - 1) * itemsPerPage + loop.index + 1}</td>
                                                <td class="p-4 font-medium">${mat.name}</td>
                                                <td class="p-4 font-medium">${mat.category.name}</td>
                                                <td class="p-4 font-medium">${mat.category.parentCategoryName}</td>
                                            
                                                <td class="p-4 font-medium">
                                                    <c:choose>
                                                        <c:when test="${mat.category.childCategoryStatus == 'inactive'}">
                                                            <span class="badge badge-danger">Inactive</span> 
                                                        </c:when>
                                                        <c:when test="${mat.category.childCategoryStatus == 'active'}">
                                                            <span class="badge badge-success">Active</span> 
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                               
                                                <td class="p-4 font-medium">${mat.unit}</td>
                                                <td class="p-4 font-medium">
                                                    <img src="${mat.imageUrl}" class="thumbnail" alt="Material image">
                                                </td>
                                                <td class="p-4 font-medium">
                                                    <a href="${pageContext.request.contextPath}/EditMaterialController?id=${mat.materialId}&origin=listMaterial"
                                                       class="text-primary-600 dark:text-primary-400 hover:underline mr-2">Edit</a>
                                                    <form action="${pageContext.request.contextPath}/ListMaterialController" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="delete"/>
                                                        <input type="hidden" name="id" value="${mat.materialId}"/>
                                                        <button type="submit" class="text-red-600 dark:text-red-400 hover:underline" 
                                                                onclick="return confirm('Are you sure you want to disable this item?')">
                                                            Disable
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="9" class="p-4 text-center text-gray-500 dark:text-gray-400">
                                                No materials found
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
                    <!-- Previous button -->
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="ListMaterialController?page=${currentPage - 1}&itemsPerPage=${itemsPerPage}&search=${param.search}&filterParentCategory=${selectedParentCategory}&filterCategory=${selectedChildCategory}" 
                               class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&lt;</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&lt;</span>
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Page 1 always visible -->
                    <c:choose>
                        <c:when test="${currentPage == 1}">
                            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
                        </c:when>
                        <c:otherwise>
                            <a href="ListMaterialController?page=1&itemsPerPage=${itemsPerPage}&search=${param.search}&filterParentCategory=${selectedParentCategory}&filterCategory=${selectedChildCategory}" 
                               class="px-3 py-1 rounded border hover:border-blue-500">1</a>
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- ... if current page > 4 -->
                    <c:if test="${currentPage > 4}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    
                    <!-- Pages around current page -->
                    <c:forEach var="i" begin="${currentPage - 1 > 1 ? currentPage - 1 : 2}" end="${currentPage + 1 < totalPages ? currentPage + 1 : totalPages - 1}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="ListMaterialController?page=${i}&itemsPerPage=${itemsPerPage}&search=${param.search}&filterParentCategory=${selectedParentCategory}&filterCategory=${selectedChildCategory}" 
                                   class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    
                    <!-- ... if current page < totalPages - 3 -->
                    <c:if test="${currentPage < totalPages - 3}">
                        <span class="px-3 py-1">...</span>
                    </c:if>
                    
                    <!-- Last page (if > 1) -->
                    <c:if test="${totalPages > 1}">
                        <c:choose>
                            <c:when test="${currentPage == totalPages}">
                                <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${totalPages}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="ListMaterialController?page=${totalPages}&itemsPerPage=${itemsPerPage}&search=${param.search}&filterParentCategory=${selectedParentCategory}&filterCategory=${selectedChildCategory}" 
                                   class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    
                    <!-- Next button -->
                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="ListMaterialController?page=${currentPage + 1}&itemsPerPage=${itemsPerPage}&search=${param.search}&filterParentCategory=${selectedParentCategory}&filterCategory=${selectedChildCategory}" 
                               class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&gt;</a>
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

        <!-- JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
$(document).ready(function () {
    var childCategoriesMap = {
        <c:forEach var="parentCat" items="${parentCategories}" varStatus="status">
            "${parentCat.categoryId}": [
                <c:forEach var="childCat" items="${childCategoriesMap[parentCat.categoryId]}" varStatus="childStatus">
                    { categoryId: ${childCat.categoryId}, name: "${fn:escapeXml(childCat.name)}" }<c:if test="${!childStatus.last}">,</c:if>
                </c:forEach>
            ]<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    };

    function updateChildCategorySelect(parentCategoryId) {
        var $childCategorySelect = $('#filterCategory');
        var currentSelectedValue = $childCategorySelect.val();
        
        $childCategorySelect.empty();
        $childCategorySelect.append('<option value="">All sub categories</option>');

        if (!parentCategoryId) {
            <c:forEach var="cat" items="${categories}">
                $childCategorySelect.append('<option value="${cat.categoryId}" ${cat.categoryId == selectedChildCategory ? "selected" : ""}>${fn:escapeXml(cat.name)}</option>');
            </c:forEach>
        } else {
            var childCategories = childCategoriesMap[parentCategoryId] || [];
            childCategories.forEach(function(cat) {
                var selected = (cat.categoryId == "${selectedChildCategory}") ? "selected" : "";
                $childCategorySelect.append('<option value="' + cat.categoryId + '" ' + selected + '>' + cat.name + '</option>');
            });
        }
        
        if (currentSelectedValue && $childCategorySelect.find('option[value="' + currentSelectedValue + '"]').length > 0) {
            $childCategorySelect.val(currentSelectedValue);
        }
    }

    // Initialize select box when page loads
    updateChildCategorySelect('${selectedParentCategory}');

    $('#filterParentCategory').on('change', function () {
        var selectedParentCategoryId = $(this).val();
        updateChildCategorySelect(selectedParentCategoryId);
    });

    // Success message from session
    <c:if test="${not empty sessionScope.successMessage}">
        Swal.fire({
            icon: 'success',
            title: 'Success',
            text: '${sessionScope.successMessage}',
            confirmButtonText: 'OK',
            confirmButtonColor: '#3B82F6'
        }).then(function() {
            <% session.removeAttribute("successMessage"); %>
        });
    </c:if>
});
        </script>
    </body>
</html>