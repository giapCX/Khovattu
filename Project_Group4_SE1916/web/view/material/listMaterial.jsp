<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Material Management - Material List</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
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
            .thumbnail {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #e5e7eb;
            }
            td, th {
    line-height: 1.2; /* Giảm chiều cao dòng so với mặc định */
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
                            Material List
                        </h1>
                    </div>
                    <div class="flex gap-4">
                        <a href="${pageContext.request.contextPath}/ListParentCategoryController" 
                           class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md inline-flex items-center">
                            <i class="fas fa-arrow-left mr-2"></i>Back to Categories
                        </a>
                        <a href="${pageContext.request.contextPath}/AddMaterialController" 
                           class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md inline-flex items-center">
                            <i class="fas fa-plus mr-2"></i>Add Material
                        </a>
                        <a href="${pageContext.request.contextPath}/AddChildCategoryController" 
                           class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md inline-flex items-center">
                            <i class="fas fa-plus mr-2"></i>Add Child Category
                        </a>
                        <a href="${pageContext.request.contextPath}/EditChildCategoryController" 
                           class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md inline-flex items-center">
                            <i class="fas fa-plus mr-2"></i>Edit Child Category
                        </a>
                    </div>
                </div>

                <!-- Search and Filter Bar -->
                <div class="flex flex-col md:flex-row justify-between mb-6 gap-4">
                    <div class="flex w-full md:w-1/3 gap-2">
                        <div class="relative flex-1">
                            <input type="text" id="searchInput" placeholder="Search by material code..." 
                                   class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
                            <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
                        </div>
                        <button id="searchButton" class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
                            <i class="fas fa-search mr-2"></i>Search
                        </button>
                    </div>
                    <div class="flex flex-col md:flex-row gap-4 w-full md:w-2/3">
                        <div class="relative w-full md:w-1/2">
                            <select id="filterParentCategory" class="p-3 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
                                <option value="">All parent categories</option>
                                <c:forEach var="parentCat" items="${parentCategories}">
                                    <option value="${parentCat.categoryId}" <c:if test="${parentCat.categoryId == selectedParentCategory}">selected</c:if>>${parentCat.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="relative w-full md:w-1/2">
                      <select id="filterCategory" class="p-3 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
    <option value="">All child categories</option>
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
                        <div class="relative w-full md:w-1/2">
                            <form action="${pageContext.request.contextPath}/ListMaterialController" method="get" class="relative w-full md:w-1/2">
                                <select id="itemsPerPage" name="itemsPerPage" onchange="this.form.submit()" class="p-3 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
                                    <option value="10" ${itemsPerPage == 10 ? 'selected' : ''}>10 items/page</option>
                                    <option value="20" ${itemsPerPage == 20 ? 'selected' : ''}>20 items/page</option>
                                    <option value="30" ${itemsPerPage == 30 ? 'selected' : ''}>30 items/page</option>
                                </select>
                                <!-- Giữ các tham số hiện tại -->
                                <input type="hidden" name="page" value="${currentPage}">
                                <input type="hidden" name="filterParentCategory" value="${selectedParentCategory}">
                                <input type="hidden" name="search" value="${param.search}">
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Material Table -->
                <div class="overflow-x-auto rounded-2xl shadow-xl">
                    <table class="min-w-full bg-white">
       <thead class="bg-gradient-to-r from-sky-600 to-blue-600 text-white">
    <tr>
        <th class="py-2 px-4 text-left rounded-tl-2xl"><i class="fas fa-list-ol mr-2"> No</i></th>
        <th class="py-2 px-4 text-left"><i class="fas fa-barcode mr-2"></i>Material Code</th>
        <th class="py-2 px-4 text-left"><i class="fas fa-layer-group mr-2"></i>Parent Category</th>
        <th class="py-2 px-4 text-left"><i class="fas fa-tag mr-2"></i>Child Category</th>
        <th class="py-2 px-4 text-left"><i class="fas fa-cube mr-2"></i>Material Name</th>
        <th class="py-2 px-4 text-left"><i class="fas fa-balance-scale mr-2"></i>Unit</th>
        <th class="py-2 px-4 text-left"><i class="fas fa-truck mr-2"></i>Suppliers</th>
        <th class="py-2 px-4 text-left"><i class="fas fa-image mr-2"></i>Image</th>
        <th class="py-2 px-4 text-left"><i class="fas fa-info-circle mr-2"></i>Child Category Status</th>
        <th class="py-2 px-4 text-center view-details-cell rounded-tr-2xl"><i class="fas fa-cogs mr-2"></i>Actions</th>
    </tr>
</thead>
<tbody class="divide-y divide-gray-200">
    <c:forEach var="mat" items="${materials}" varStatus="loop">
        <tr class="hover:bg-gradient-to-r hover:from-sky-50 hover:to-cyan-50 transition-all duration-300">
            <td class="py-2 px-4 font-medium">${(currentPage - 1) * itemsPerPage + loop.index + 1}</td>
            <td class="py-2 px-4">${mat.code}</td>
            <td class="py-2 px-4">${mat.category.parentCategoryName}</td>
            <td class="py-2 px-4">${mat.category.name}</td>
            <td class="py-2 px-4">${mat.name}</td>
            <td class="py-2 px-4">${mat.unit}</td>
            <td class="py-2 px-4">
                <c:choose>
                    <c:when test="${not empty mat.suppliers}">
                        <c:forEach var="supplier" items="${mat.suppliers}" varStatus="status">
                            ${fn:escapeXml(supplier.supplierName)}<c:if test="${!status.last}">,</c:if>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        No suppliers
                    </c:otherwise>
                </c:choose>
            </td>
            <td class="py-2 px-4">
                <img src="${mat.imageUrl}" class="thumbnail" alt="Material image">
            </td>
            <td class="py-2 px-4 text-center">
                <span class="${mat.category.childCategoryStatus == 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'} px-2 py-1 rounded-full">
                    ${mat.category.childCategoryStatus}
                </span>
            </td>
            <td class="py-2 px-4 text-center view-details-cell">
                <a href="${pageContext.request.contextPath}/EditMaterialController?id=${mat.materialId}&origin=listMaterial" 
                   class="px-4 py-2 bg-gradient-to-r from-yellow-500 to-orange-500 text-white rounded-lg hover:from-yellow-600 hover:to-orange-600 transition-all duration-300 shadow-md">
                    <i class="fas fa-edit mr-2"></i>Edit
                </a>
                <form action="${pageContext.request.contextPath}/ListMaterialController" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="id" value="${mat.materialId}"/>
                    <button type="submit" class="px-4 py-2 bg-gradient-to-r from-red-500 to-pink-500 text-white rounded-lg hover:from-red-600 hover:to-pink-600 transition-all duration-300 shadow-md" onclick="return confirm('Are you sure you want to delete?')">
                        <i class="fas fa-trash-alt mr-2"></i>Delete
                    </button>
                </form>
            </td>
        </tr>
    </c:forEach>
</tbody>
                    </table>
                </div>

                <div class="flex justify-center mt-6 gap-2">
                    <a href="${pageContext.request.contextPath}/ListMaterialController?page=${currentPage - 1}&filterParentCategory=${selectedParentCategory}&search=${param.search}&itemsPerPage=${itemsPerPage}" 
                       class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == 1 ? 'opacity-50 pointer-events-none' : ''}">
                        <i class="fas fa-chevron-left mr-2"></i>Previous Page
                    </a>
                    <div class="flex gap-2">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="${pageContext.request.contextPath}/ListMaterialController?page=${i}&filterParentCategory=${selectedParentCategory}&search=${param.search}&itemsPerPage=${itemsPerPage}" 
                               class="px-4 py-2 rounded-lg shadow-md transition-all duration-300 ${i == currentPage ? 'bg-blue-600 text-white' : 'bg-sky-200 text-sky-800 hover:bg-sky-300'}">${i}</a>
                        </c:forEach>
                    </div>
                    <a href="${pageContext.request.contextPath}/ListMaterialController?page=${currentPage + 1}&filterParentCategory=${selectedParentCategory}&search=${param.search}&itemsPerPage=${itemsPerPage}" 
                       class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == totalPages ? 'opacity-50 pointer-events-none' : ''}">
                        Next Page<i class="fas fa-chevron-right ml-2"></i>
                    </a>
                </div>
            </div>

        </main>

        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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
        var currentSelectedValue = $childCategorySelect.val(); // Lưu giá trị đang chọn
        
        $childCategorySelect.empty();
        $childCategorySelect.append('<option value="">All child categories</option>');

        if (!parentCategoryId) {
            // Nếu không chọn parent category, hiển thị tất cả child categories
            <c:forEach var="cat" items="${categories}">
                $childCategorySelect.append('<option value="${cat.categoryId}" ${cat.categoryId == selectedChildCategory ? "selected" : ""}>${fn:escapeXml(cat.name)}</option>');
            </c:forEach>
        } else {
            // Nếu chọn parent category, chỉ hiển thị child categories của parent đó
            var childCategories = childCategoriesMap[parentCategoryId] || [];
            childCategories.forEach(function(cat) {
                var selected = (cat.categoryId == "${selectedChildCategory}") ? "selected" : "";
                $childCategorySelect.append('<option value="' + cat.categoryId + '" ' + selected + '>' + cat.name + '</option>');
            });
        }
        
        // Khôi phục giá trị đã chọn nếu nó vẫn tồn tại trong danh sách mới
        if (currentSelectedValue && $childCategorySelect.find('option[value="' + currentSelectedValue + '"]').length > 0) {
            $childCategorySelect.val(currentSelectedValue);
        }
    }

    // Khởi tạo select box khi trang được tải
    updateChildCategorySelect('${selectedParentCategory}');

    $('#filterParentCategory').on('change', function () {
        var selectedParentCategoryId = $(this).val();
        var selectedChildCategoryId = $('#filterCategory').val();
        
        // Cập nhật dropdown child category
        updateChildCategorySelect(selectedParentCategoryId);
        
        // Nếu có child category đang được chọn và nó thuộc parent category mới, giữ nguyên selection
        if (selectedChildCategoryId && $('#filterCategory option[value="' + selectedChildCategoryId + '"]').length > 0) {
            $('#filterCategory').val(selectedChildCategoryId);
        } else {
            // Nếu không, reset về "All child categories"
            $('#filterCategory').val('');
        }
        
        // Gửi request filter
        var url = '${pageContext.request.contextPath}/ListMaterialController?filterParentCategory=' + selectedParentCategoryId;
        if (selectedChildCategoryId) {
            url += '&filterCategory=' + selectedChildCategoryId;
        }
        window.location.href = url;
    });

    $('#filterCategory').on('change', function () {
        var selectedParentCategoryId = $('#filterParentCategory').val();
        var selectedChildCategoryId = $(this).val();
        
        var url = '${pageContext.request.contextPath}/ListMaterialController';
        var params = [];
        
        if (selectedParentCategoryId) {
            params.push('filterParentCategory=' + selectedParentCategoryId);
        }
        
        if (selectedChildCategoryId) {
            params.push('filterCategory=' + selectedChildCategoryId);
        }
        
        if (params.length > 0) {
            url += '?' + params.join('&');
        }
        
        window.location.href = url;
    });

    $('#searchButton').on('click', function () {
        var searchValue = $('#searchInput').val();
        var selectedParentCategoryId = $('#filterParentCategory').val();
        var selectedChildCategoryId = $('#filterCategory').val();
        var url = '${pageContext.request.contextPath}/ListMaterialController?search=' + encodeURIComponent(searchValue);
        
        if (selectedParentCategoryId) {
            url += '&filterParentCategory=' + selectedParentCategoryId;
        }
        
        if (selectedChildCategoryId) {
            url += '&filterCategory=' + selectedChildCategoryId;
        }
        
        window.location.href = url;
    });
});
</script>
    </body>
</html>