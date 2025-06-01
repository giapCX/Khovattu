<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa vật tư</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding-top: 70px; }
        .navbar-brand { font-weight: bold; }
        .form-group { margin-bottom: 15px; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Quản lý vật tư</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">Xin chào, Admin One (Admin)</span>
                <a class="btn btn-outline-light" href="#">Đăng xuất</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h2>Sửa vật tư</h2>
        <form action="material/edit" method="post">
            <input type="hidden" name="id" value="${material.materialId}">
            <div class="form-group">
                <label for="code" class="form-label">Mã vật tư</label>
                <input type="text" class="form-control" id="code" name="code" value="${material.code}" required>
            </div>
            <div class="form-group">
                <label for="name" class="form-label">Tên vật tư</label>
                <input type="text" class="form-control" id="name" name="name" value="${material.name}" required>
            </div>
            <div class="form-group">
                <label for="category" class="form-label">Danh mục</label>
                <select class="form-select" id="category" name="category" required>
                    <option value="">Chọn danh mục</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}" ${cat.categoryId == material.brand.category.categoryId ? 'selected' : ''}>${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label for="brand" class="form-label">Nhãn hiệu</label>
                <select class="form-select" id="brand" name="brand" required>
                    <option value="">Chọn nhãn hiệu</option>
                    <c:forEach var="brand" items="${brands}">
                        <option value="${brand.brandId}" data-category="${brand.category.categoryId}" ${brand.brandId == material.brand.brandId ? 'selected' : ''}>${brand.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label for="unit" class="form-label">Đơn vị</label>
                <input type="text" class="form-control" id="unit" name="unit" value="${material.unit}" required>
            </div>
            <div class="form-group">
                <label for="description" class="form-label">Mô tả</label>
                <textarea class="form-control" id="description" name="description" rows="4">${material.description}</textarea>
            </div>
            <div class="form-group">
                <label for="imageUrl" class="form-label">Hình ảnh (URL)</label>
                <input type="url" class="form-control" id="imageUrl" name="imageUrl" value="${material.imageUrl}">
            </div>
            <div class="form-group">
                <label for="suppliers" class="form-label">Nhà cung cấp</label>
                <select multiple class="form-select" id="suppliers" name="suppliers">
                    <c:forEach var="sup" items="${suppliers}">
                        <option value="${sup.supplierId}" <c:forEach var="matSup" items="${material.suppliers}"><c:if test="${matSup.supplierId == sup.supplierId}">selected</c:if></c:forEach>>${sup.supplierName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-primary">Lưu</button>
                <a href="material?action=list" class="btn btn-secondary">Hủy</a>
            </div>
        </form>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#category').change(function() {
                var categoryId = $(this).val();
                $('#brand option').each(function() {
                    if (categoryId === '') {
                        $(this).show();
                    } else {
                        if ($(this).data('category') == categoryId || $(this).val() === '') {
                            $(this).show();
                        } else {
                            $(this).hide();
                        }
                    }
                });
                $('#brand').val('');
            });
        });
    </script>
</body>
</html>