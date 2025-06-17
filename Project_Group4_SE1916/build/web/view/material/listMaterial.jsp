<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material Management - Material List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f4f6f9;
            padding-top: 20px;
        }
        .container {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            padding: 2rem;
        }
        .header-actions .btn {
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .header-actions .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        .filter-group .form-control, .filter-group .form-select {
            border-radius: 8px;
            border: 1px solid #d1d5db;
            padding: 10px;
            transition: border-color 0.3s ease;
        }
        .filter-group .form-control:focus, .filter-group .form-select:focus {
            border-color: #60a5fa;
            box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.1);
        }
        .filter-group .btn {
            border-radius: 8px;
            padding: 10px 20px;
        }
        .table th, .table td {
            vertical-align: middle;
            font-size: 0.95rem;
        }
        .table th {
            background-color: #bfdbfe;
            color: #1e3a8a;
            font-weight: 600;
        }
        .table tbody tr {
            background-color: #eff6ff;
        }
        .table tbody tr:hover {
            background-color: #dbeafe;
            transition: background-color 0.2s ease;
        }
        .thumbnail {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
        }
        .action-btn {
            border-radius: 6px;
            padding: 6px 12px;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }
        .action-btn:hover {
            transform: translateY(-1px);
        }
        .modal-content {
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        }
        .modal-header {
            background-color: #bfdbfe;
            border-bottom: 1px solid #e5e7eb;
            color: #1e3a8a;
        }
        .modal-body img {
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        .dataTables_paginate {
            display: flex;
            justify-content: center;
            margin-top: 1rem;
        }
        .dataTables_paginate .paginate_button {
            margin: 0 5px;
            padding: 8px 12px;
            border-radius: 6px;
            background-color: transparent;
            color: #1e3a8a;
            transition: all 0.3s ease;
        }
        .dataTables_paginate .paginate_button:hover {
            background-color: #60a5fa;
            color: white;
        }
        .dataTables_paginate .paginate_button.current {
            background-color: #60a5fa;
            color: white;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="header-actions flex justify-between items-center mb-6">
            <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="btn btn-secondary">PREVIOUS PAGE</a>
            <div>
                <a href="${pageContext.request.contextPath}/AddMaterialController" class="btn btn-primary mr-2">Add Material</a>
                <a href="${pageContext.request.contextPath}/AddChildCategoryController" class="btn btn-primary">Add Child Category</a>
            </div>
        </div>

        <div class="row filter-group mb-4">
            <div class="col-md-4 mb-3">
                <div class="input-group">
                    <input type="text" id="searchInput" class="form-control" placeholder="Search by material code">
                    <button id="searchButton" class="btn btn-primary">Search</button>
                </div>
            </div>
            <div class="col-md-2 mb-3">
                <select id="filterParentCategory" class="form-select">
                    <option value="">All parent categories</option>
                    <c:forEach var="parentCat" items="${parentCategories}">
                        <option value="${parentCat.categoryId}" <c:if test="${parentCat.categoryId == selectedParentCategory}">selected</c:if>>${parentCat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2 mb-3">
                <select id="filterCategory" class="form-select">
                    <option value="">All child categories</option>
                    <c:if test="${not empty selectedParentCategory}">
                        <c:forEach var="childCat" items="${childCategoriesMap[selectedParentCategory]}">
                            <option value="${childCat.categoryId}">${childCat.name}</option>
                        </c:forEach>
                    </c:if>
                    <c:if test="${empty selectedParentCategory}">
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}">${cat.name}</option>
                        </c:forEach>
                    </c:if>
                </select>
            </div>
        </div>

        <div class="table-responsive">
            <table id="materialTable" class="table table-striped">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Material Code</th>
                        <th>Parent Category</th>
                        <th>Child Category</th>
                        <th>Material Name</th>
                        <th>Unit</th>
                        <th>Suppliers</th>
                        <th>Image</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="mat" items="${materials}" varStatus="loop">
                        <tr>
                            <td>${loop.index + 1}</td>
                            <td>${mat.code}</td>
                            <td>${mat.category.parentCategoryName}</td>
                            <td>${mat.category.name}</td>
                            <td>${mat.name}</td>
                            <td>${mat.unit}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty mat.suppliers}">
                                        <c:forEach var="supplier" items="${mat.suppliers}" varStatus="status">
                                            ${fn:escapeXml(supplier.supplierName)}<c:if test="${!status.last}">,</c:if>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        Không có nhà cung cấp
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <img src="${mat.imageUrl}" class="thumbnail" alt="Material image">
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/EditMaterialController?id=${mat.materialId}" class="btn btn-sm btn-warning action-btn">Edit</a>
                                <form action="${pageContext.request.contextPath}/ListMaterialController" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="delete"/>
                                    <input type="hidden" name="id" value="${mat.materialId}"/>
                                    <button type="submit" class="btn btn-sm btn-danger action-btn" onclick="return confirm('Are you sure you want to delete?')">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="detailModal" tabindex="-1" aria-labelledby="detailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="detailModalLabel">Material Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-4">
                            <img id="detailImage" class="img-fluid" src="" alt="Material image">
                        </div>
                        <div class="col-md-8">
                            <p><strong>Material Code:</strong> <span id="detailCode"></span></p>
                            <p><strong>Parent Category:</strong> <span id="detailParentCategory"></span></p>
                            <p><strong>Child Category:</strong> <span id="detailCategory"></span></p>
                            <p><strong>Material Name:</strong> <span id="detailName"></span></p>
                            <p><strong>Unit:</strong> <span id="detailUnit"></span></p>
                            <p><strong>Suppliers:</strong> <span id="detailSuppliers"></span></p>
                            <p><strong>Description:</strong> <span id="detailDescription"></span></p>
                            <p><strong>Inventory:</strong> <span id="detailInventory"></span></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <a id="editMaterialLink" href="" class="btn btn-primary">Edit</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
$(document).ready(function () {
    var table = $('#materialTable').DataTable({
        dom: '<"top"lf>rt<"bottom"p><"clear">',
        pagingType: 'full_numbers',
        pageLength: 10,
        lengthMenu: [5, 10, 25, 50, 100]
    });

    var childCategoriesMap = {
        <c:forEach var="parentCat" items="${parentCategories}" varStatus="status">
            "${parentCat.categoryId}": [
                <c:forEach var="childCat" items="${childCategoriesMap[parentCat.categoryId]}" varStatus="childStatus">
                    { categoryId: ${childCat.categoryId}, name: "${fn:escapeXml(childCat.name)}" }<c:if test="${!childStatus.last}">,</c:if>
                </c:forEach>
            ]<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    };

    var categories = [
        <c:forEach var="cat" items="${categories}" varStatus="status">
            { categoryId: ${cat.categoryId}, name: "${fn:escapeXml(cat.name)}" }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    var parentCategories = [
        <c:forEach var="parentCat" items="${parentCategories}" varStatus="status">
            { categoryId: ${parentCat.categoryId}, name: "${fn:escapeXml(parentCat.name)}" }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    function getCategoryName(categoryId) {
        var cat = categories.find(c => c.categoryId == categoryId);
        return cat ? cat.name : '';
    }

    function getParentCategoryName(categoryId) {
        var parentCat = parentCategories.find(c => c.categoryId == categoryId);
        return parentCat ? parentCat.name : '';
    }

    function updateChildCategorySelect(parentCategoryId) {
        var $childCategorySelect = $('#filterCategory');
        $childCategorySelect.empty();
        $childCategorySelect.append('<option value="">All child categories</option>');

        if (!parentCategoryId) {
            categories.forEach(function(cat) {
                $childCategorySelect.append('<option value="' + cat.categoryId + '">' + cat.name + '</option>');
            });
        } else {
            var childCategories = childCategoriesMap[parentCategoryId] || [];
            childCategories.forEach(function(cat) {
                $childCategorySelect.append('<option value="' + cat.categoryId + '">' + cat.name + '</option>');
            });
        }
    }

    // Khởi tạo childCategorySelect dựa trên selectedParentCategory
    <c:if test="${not empty selectedParentCategory}">
        updateChildCategorySelect('${selectedParentCategory}');
    </c:if>

    $('#filterParentCategory').on('change', function () {
        var selectedParentCategoryId = $(this).val();
        // Tải lại trang với bộ lọc mới
        var url = '${pageContext.request.contextPath}/ListMaterialController';
        if (selectedParentCategoryId) {
            url += '?filterParentCategory=' + selectedParentCategoryId;
        }
        window.location.href = url;
    });

    $('#filterCategory').on('change', function () {
        var selectedCategoryId = $(this).val();
        var categoryName = selectedCategoryId ? getCategoryName(selectedCategoryId) : '';
        table.column(3).search(categoryName).draw();
    });

    $('#searchButton').on('click', function () {
        var searchValue = $('#searchInput').val();
        table.column(1).search(searchValue).draw();
    });

    <c:if test="${not empty sessionScope.successMessage}">
        Swal.fire({
            icon: 'success',
            title: 'Success',
            text: '${sessionScope.successMessage}',
            showConfirmButton: false,
            timer: 2000,
            customClass: { popup: 'animated fadeInDown' }
        });
        <% session.removeAttribute("successMessage"); %>
    </c:if>
});
    </script>
</body>
</html>