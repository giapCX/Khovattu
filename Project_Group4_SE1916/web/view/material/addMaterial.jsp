<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Material</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding-top: 20px; }
        .form-group { margin-bottom: 15px; }
        .alert { margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <c:if test="${not empty message}">
            <div class="alert alert-${messageType} alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <h2>Add New Material</h2>
        <form action="${pageContext.request.contextPath}/AddMaterialController" method="post">
            <div class="form-group">
                <label for="code" class="form-label">Material Code</label>
                <input type="text" class="form-control" id="code" name="code" required>
            </div>
            <div class="form-group">
                <label for="name" class="form-label">Material Name</label>
                <input type="text" class="form-control" id="name" name="name" required>
            </div>
            <div class="form-group">
                <label for="category" class="form-label">Category</label>
                <select class="form-select" id="category" name="category" required>
                    <option value="">Select Category</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}">${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label for="brand" class="form-label">Brand</label>
                <select class="form-select" id="brand" name="brand" required>
                    <option value="">Select Brand</option>
                    <c:forEach var="brand" items="${brands}">
                        <option value="${brand.brandId}" data-category="${brand.category.categoryId}">${brand.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label for="unit" class="form-label">Unit</label>
                <input type="text" class="form-control" id="unit" name="unit" required>
            </div>
            <div class="form-group">
                <label for="description" class="form-label">Description</label>
                <textarea class="form-control" id="description" name="description" rows="4"></textarea>
            </div>
            <div class="form-group">
                <label for="imageUrl" class="form-label">Image (URL)</label>
                <input type="url" class="form-control" id="imageUrl" name="imageUrl">
            </div>
            <div class="form-group">
                <label for="suppliers" class="form-label">Suppliers</label>
                <select multiple class="form-select" id="suppliers" name="suppliers">
                    <c:forEach var="sup" items="${suppliers}">
                        <option value="${sup.supplierId}">${sup.supplierName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-primary">Save</button>
                <a href="${pageContext.request.contextPath}/AddMaterialController" class="btn btn-secondary">Cancel</a>
                <a href="${pageContext.request.contextPath}/ListMaterialController?action=list" class="btn btn-secondary">Back</a>
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

            // Auto-dismiss alerts after 5 seconds
            setTimeout(function() {
                $('.alert').alert('close');
            }, 5000);
        });
    </script>
</body>
</html>