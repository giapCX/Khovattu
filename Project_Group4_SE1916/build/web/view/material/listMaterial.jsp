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
    <style>
        body { padding-top: 20px; }
        .thumbnail { width: 50px; height: 50px; object-fit: cover; }
        .action-btn { margin-right: 5px; }
        .filter-group { margin-bottom: 15px; }
        .header-actions { margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="header-actions">
          
            <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class ="btn btn-secondary">Back to Home</a>
            <a href="${pageContext.request.contextPath}/AddMaterialController" class="btn btn-primary">Add Material</a>
        </div>

        <div class="row filter-group">
            <div class="col-md-4">
                <div class="input-group">
                    <input type="text" id="searchInput" class="form-control" placeholder="Search by material code">
                    <button id="searchButton" class="btn btn-primary">Search</button>
                </div>
            </div>
            <div class="col-md-2">
                <select id="filterCategory" class="form-select">
                    <option value="">All categories</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}">${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <select id="filterBrand" class="form-select">
                    <option value="">All brands</option>
                    <c:forEach var="brand" items="${brands}">
                        <option value="${brand.name}" data-category-id="${brand.category.categoryId}">${brand.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <select id="filterSupplier" class="form-select">
                    <option value="">All suppliers</option>
                    <c:forEach var="sup" items="${suppliers}">
                        <c:set var="materialIds">
                            <c:forEach var="mat" items="${sup.materials}" varStatus="status">
                                ${mat.materialId}<c:if test="${!status.last}">,</c:if>
                            </c:forEach>
                        </c:set>
                        <option value="${sup.supplierName}" data-material-ids="${materialIds}">${sup.supplierName}</option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <table id="materialTable" class="table table-striped">
            <thead>
                <tr>
                    <th>Material Code</th>
                    <th>Category</th>
                    <th>Brand</th>
                    <th>Material Name</th>
                    <th>Unit</th>
                    <th>Supplier</th>
                    <th>Image</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="mat" items="${materials}">
                    <tr>
                        <td>${mat.code}</td>
                        <td>${mat.brand.category.name}</td>
                        <td>${mat.brand.name}</td>
                        <td>${mat.name}</td>
                        <td>${mat.unit}</td>
                        <td>
                            <c:forEach var="sup" items="${mat.suppliers}" varStatus="status">
                                ${sup.supplierName}<c:if test="${!status.last}">, </c:if>
                            </c:forEach>
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
                            <img id="detailImage" class="img-fluid" src="${material.imageUrl}" alt="Material image">
                        </div>
                        <div class="col-md-8">
                            <p><strong>Material Code:</strong> <span id="detailCode">${material.code}</span></p>
                            <p><strong>Material Name:</strong> <span id="detailName">${material.name}</span></p>
                            <p><strong>Category:</strong> <span id="detailCategory">${material.brand.category.name}</span></p>
                            <p><strong>Brand:</strong> <span id="detailBrand">${material.brand.name}</span></p>
                            <p><strong>Unit:</strong> <span id="detailUnit">${material.unit}</span></p>
                            <p><strong>Description:</strong> <span id="detailDescription">${material.description}</span></p>
                            <p><strong>Suppliers:</strong> <span id="detailSuppliers">
                                <c:forEach var="sup" items="${material.suppliers}" varStatus="status">
                                    ${sup.supplierName}<c:if test="${!status.last}">, </c:if>
                                </c:forEach>
                            </span></p>
                            <p><strong>Inventory:</strong> <span id="detailInventory">${inventory}</span></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <a href="${pageContext.request.contextPath}/material/edit?id=${material.materialId}" class="btn btn-primary">Edit</a>
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
                language: { url: '//cdn.datatables.net/plug-ins/1.13.4/i18n/vi.json' }
            });

            $('#searchButton').on('click', function () {
                var searchValue = $('#searchInput').val();
                table.column(0).search(searchValue).draw();
            });

            $('#filterCategory').on('change', function () {
                var selectedCategoryId = $(this).val();
                var categoryName = selectedCategoryId ? getCategoryName(selectedCategoryId) : '';
                if (!selectedCategoryId) {
                    table.columns().search('').draw();
                } else {
                    table.column(3).search(categoryName).draw();
                }
                updateBrandAndSupplierOptions(selectedCategoryId, null);
            });

            $('#filterBrand').on('change', function () {
                var selectedBrand = $(this).val();
                table.column(2).search(selectedBrand).draw();
                updateBrandAndSupplierOptions($('#filterCategory').val(), selectedBrand);
            });

            $('#filterSupplier').on('change', function () {
                table.column(5).search(this.value).draw();
            });

            // Store original options for brands and suppliers
            var originalBrandOptions = $('#filterBrand option').clone();
            var originalSupplierOptions = $('#filterSupplier option').clone();
            var materials = [
                <c:forEach var="mat" items="${materials}" varStatus="status">
                    {
                        materialId: ${mat.materialId},
                        categoryId: ${mat.brand.category.categoryId},
                        categoryName: "${fn:escapeXml(mat.brand.category.name)}",
                        brandName: "${fn:escapeXml(mat.brand.name)}"
                    }<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];
            var categories = [
                <c:forEach var="cat" items="${categories}" varStatus="status">
                    { categoryId: ${cat.categoryId}, name: "${fn:escapeXml(cat.name)}" }<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];

            function getCategoryName(categoryId) {
                var cat = categories.find(c => c.categoryId == categoryId);
                return cat ? cat.name : '';
            }

            function updateBrandAndSupplierOptions(categoryId, selectedBrand) {
                // Lưu giá trị đang chọn trước khi cập nhật
                var currentSelectedBrand = $('#filterBrand').val();
                
                // Update brands - chỉ thêm "Tất cả nhãn hiệu" 1 lần
                $('#filterBrand').empty();
                $('#filterBrand').append('<option value="">All brands</option>');
                
                originalBrandOptions.each(function() {
                    var option = $(this);
                    // Bỏ qua option "Tất cả nhãn hiệu" vì đã thêm ở trên
                    if (option.val() === '') return;
                    
                    var optionCategoryId = option.data('category-id');
                    if (!categoryId || (categoryId && optionCategoryId == categoryId)) {
                        $('#filterBrand').append(option.clone());
                    }
                });

                // Khôi phục giá trị đã chọn nếu vẫn tồn tại trong danh sách mới
                if (currentSelectedBrand && $('#filterBrand option[value="' + currentSelectedBrand + '"]').length > 0) {
                    $('#filterBrand').val(currentSelectedBrand);
                } else {
                    $('#filterBrand').val('');
                }

                // Update suppliers (giữ nguyên như cũ)
                $('#filterSupplier').empty().append('<option value="">All suppliers</option>');
                originalSupplierOptions.each(function() {
                    var option = $(this);
                    if (option.val() === '') return;
                    
                    var materialIds = option.data('material-ids').split(',').filter(id => id.trim() !== '');
                    var hasMatchingMaterial = materialIds.some(materialId => {
                        var mat = materials.find(m => m.materialId == materialId);
                        return mat && (!categoryId || mat.categoryId == categoryId) && (!selectedBrand || mat.brandName == selectedBrand);
                    });
                    if (hasMatchingMaterial) {
                        $('#filterSupplier').append(option.clone());
                    }
                });
            }
            // Initialize with no category or brand selected
            updateBrandAndSupplierOptions('', null);
        });

        // Hiển thị thông báo thành công từ session
        <c:if test="${not empty sessionScope.successMessage}">
            Swal.fire({
                icon: 'success',
                title: 'Success',
                text: '${sessionScope.successMessage}',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'animated fadeInDown'
                }
            });
            <% session.removeAttribute("successMessage"); %>
        </c:if>
    </script>
</body>
</html>